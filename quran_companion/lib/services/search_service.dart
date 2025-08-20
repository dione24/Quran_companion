import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/verse.dart';
import '../models/surah.dart';

class SearchService {
  static Database? _database;
  static const String _dbName = 'quran_search.db';
  static const String _versesTable = 'verses';
  static const String _surahsTable = 'surahs';
  
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }
  
  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, _dbName);
    
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }
  
  Future<void> _onCreate(Database db, int version) async {
    // Create surahs table
    await db.execute('''
      CREATE TABLE $_surahsTable (
        number INTEGER PRIMARY KEY,
        name TEXT NOT NULL,
        englishName TEXT NOT NULL,
        englishNameTranslation TEXT NOT NULL,
        numberOfAyahs INTEGER NOT NULL,
        revelationType TEXT NOT NULL
      )
    ''');
    
    // Create verses table with FTS (Full Text Search) support
    await db.execute('''
      CREATE VIRTUAL TABLE $_versesTable USING fts4(
        number INTEGER,
        text TEXT,
        translation TEXT,
        numberInSurah INTEGER,
        surahNumber INTEGER,
        surahName TEXT,
        juz INTEGER,
        page INTEGER,
        tokenize=unicode61
      )
    ''');
    
    // Create index for faster queries
    await db.execute('''
      CREATE INDEX IF NOT EXISTS idx_verse_surah 
      ON $_versesTable(surahNumber, numberInSurah)
    ''');
  }
  
  // Index all verses for search
  Future<void> indexVerses(List<Verse> verses, String surahName) async {
    final db = await database;
    final batch = db.batch();
    
    for (final verse in verses) {
      batch.insert(
        _versesTable,
        {
          'number': verse.number,
          'text': verse.text,
          'translation': verse.translation ?? '',
          'numberInSurah': verse.numberInSurah,
          'surahNumber': verse.surahNumber,
          'surahName': surahName,
          'juz': verse.juz,
          'page': verse.page,
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
    
    await batch.commit(noResult: true);
  }
  
  // Index surahs for search
  Future<void> indexSurahs(List<Surah> surahs) async {
    final db = await database;
    final batch = db.batch();
    
    for (final surah in surahs) {
      batch.insert(
        _surahsTable,
        surah.toJson(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
    
    await batch.commit(noResult: true);
  }
  
  // Search with fuzzy matching
  Future<List<SearchResult>> search(String query, {
    bool searchArabic = true,
    bool searchTranslation = true,
    int limit = 50,
  }) async {
    if (query.trim().isEmpty) return [];
    
    final db = await database;
    final results = <SearchResult>[];
    
    // Prepare search query for FTS
    final searchQuery = query.split(' ').map((word) => '$word*').join(' ');
    
    try {
      // Build WHERE clause based on search options
      final whereClause = <String>[];
      if (searchArabic) whereClause.add('text MATCH ?');
      if (searchTranslation) whereClause.add('translation MATCH ?');
      
      if (whereClause.isEmpty) return [];
      
      final sql = '''
        SELECT 
          number,
          text,
          translation,
          numberInSurah,
          surahNumber,
          surahName,
          snippet($_versesTable, '<b>', '</b>', '...', -1, 30) as snippet
        FROM $_versesTable
        WHERE ${whereClause.join(' OR ')}
        LIMIT ?
      ''';
      
      final params = <dynamic>[];
      if (searchArabic) params.add(searchQuery);
      if (searchTranslation) params.add(searchQuery);
      params.add(limit);
      
      final maps = await db.rawQuery(sql, params);
      
      for (final map in maps) {
        results.add(SearchResult(
          verse: Verse(
            number: map['number'] as int,
            text: map['text'] as String,
            numberInSurah: map['numberInSurah'] as int,
            surahNumber: map['surahNumber'] as int,
            translation: map['translation'] as String?,
            juz: 0,
            manzil: 0,
            page: 0,
            ruku: 0,
            hizbQuarter: 0,
            sajda: false,
          ),
          surahName: map['surahName'] as String,
          snippet: map['snippet'] as String,
        ));
      }
    } catch (e) {
      debugPrint('Search error: $e');
    }
    
    return results;
  }
  
  // Search in specific surah
  Future<List<SearchResult>> searchInSurah(
    String query,
    int surahNumber, {
    bool searchArabic = true,
    bool searchTranslation = true,
  }) async {
    if (query.trim().isEmpty) return [];
    
    final db = await database;
    final results = <SearchResult>[];
    
    try {
      final whereClause = <String>['surahNumber = ?'];
      if (searchArabic) whereClause.add('text LIKE ?');
      if (searchTranslation) whereClause.add('translation LIKE ?');
      
      final sql = '''
        SELECT * FROM $_versesTable
        WHERE ${whereClause.join(' AND ')}
        ORDER BY numberInSurah
      ''';
      
      final params = <dynamic>[surahNumber];
      if (searchArabic) params.add('%$query%');
      if (searchTranslation) params.add('%$query%');
      
      final maps = await db.query(
        _versesTable,
        where: whereClause.join(' AND '),
        whereArgs: params,
      );
      
      for (final map in maps) {
        results.add(SearchResult(
          verse: Verse(
            number: map['number'] as int,
            text: map['text'] as String,
            numberInSurah: map['numberInSurah'] as int,
            surahNumber: map['surahNumber'] as int,
            translation: map['translation'] as String?,
            juz: map['juz'] as int,
            manzil: 0,
            page: map['page'] as int,
            ruku: 0,
            hizbQuarter: 0,
            sajda: false,
          ),
          surahName: map['surahName'] as String,
          snippet: '',
        ));
      }
    } catch (e) {
      debugPrint('Search in surah error: $e');
    }
    
    return results;
  }
  
  // Get search suggestions
  Future<List<String>> getSuggestions(String query, {int limit = 10}) async {
    if (query.isEmpty) return [];
    
    final db = await database;
    final suggestions = <String>[];
    
    try {
      // Get unique words from verses that match the query
      final sql = '''
        SELECT DISTINCT substr(text, 1, 50) as suggestion
        FROM $_versesTable
        WHERE text LIKE ?
        LIMIT ?
      ''';
      
      final maps = await db.rawQuery(sql, ['%$query%', limit]);
      
      for (final map in maps) {
        suggestions.add(map['suggestion'] as String);
      }
    } catch (e) {
      debugPrint('Suggestions error: $e');
    }
    
    return suggestions;
  }
  
  // Check if database is indexed
  Future<bool> isDatabaseIndexed() async {
    final db = await database;
    final count = Sqflite.firstIntValue(
      await db.rawQuery('SELECT COUNT(*) FROM $_versesTable'),
    );
    return count != null && count > 0;
  }
  
  // Clear search index
  Future<void> clearIndex() async {
    final db = await database;
    await db.delete(_versesTable);
    await db.delete(_surahsTable);
  }
  
  // Get indexed verses count
  Future<int> getIndexedVersesCount() async {
    final db = await database;
    final count = Sqflite.firstIntValue(
      await db.rawQuery('SELECT COUNT(*) FROM $_versesTable'),
    );
    return count ?? 0;
  }
}

class SearchResult {
  final Verse verse;
  final String surahName;
  final String snippet;
  
  SearchResult({
    required this.verse,
    required this.surahName,
    required this.snippet,
  });
}