import 'dart:convert';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/surah.dart';
import '../models/verse.dart';
import '../models/bookmark.dart';
import '../models/bookmark.g.dart';

class LocalStorageService {
  static const String _surahsKey = 'cached_surahs';
  static const String _versesKeyPrefix = 'cached_verses_';
  static const String _bookmarksBoxName = 'bookmarks';
  static const String _notesBoxName = 'notes';
  static const String _settingsBoxName = 'settings';
  
  late Box<Bookmark> _bookmarksBox;
  late Box _notesBox;
  late Box _settingsBox;
  
  Future<void> init() async {
    await Hive.initFlutter();
    
    // Register adapters
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(BookmarkAdapter());
    }
    
    _bookmarksBox = await Hive.openBox<Bookmark>(_bookmarksBoxName);
    _notesBox = await Hive.openBox(_notesBoxName);
    _settingsBox = await Hive.openBox(_settingsBoxName);
  }
  
  // Surahs caching
  Future<void> cacheSurahs(List<Surah> surahs) async {
    final prefs = await SharedPreferences.getInstance();
    final surahsJson = surahs.map((s) => s.toJson()).toList();
    await prefs.setString(_surahsKey, json.encode(surahsJson));
  }
  
  Future<List<Surah>?> getCachedSurahs() async {
    final prefs = await SharedPreferences.getInstance();
    final surahsString = prefs.getString(_surahsKey);
    if (surahsString != null) {
      final List<dynamic> surahsJson = json.decode(surahsString);
      return surahsJson.map((json) => Surah.fromJson(json)).toList();
    }
    return null;
  }
  
  // Verses caching
  Future<void> cacheVerses(int surahNumber, String edition, List<Verse> verses) async {
    final prefs = await SharedPreferences.getInstance();
    final key = '$_versesKeyPrefix${surahNumber}_$edition';
    final versesJson = verses.map((v) => v.toJson()).toList();
    await prefs.setString(key, json.encode(versesJson));
  }
  
  Future<List<Verse>?> getCachedVerses(int surahNumber, String edition) async {
    final prefs = await SharedPreferences.getInstance();
    final key = '$_versesKeyPrefix${surahNumber}_$edition';
    final versesString = prefs.getString(key);
    if (versesString != null) {
      final List<dynamic> versesJson = json.decode(versesString);
      return versesJson.map((json) => Verse.fromJson(json)).toList();
    }
    return null;
  }
  
  // Bookmarks
  Future<void> addBookmark(Bookmark bookmark) async {
    final prefs = await SharedPreferences.getInstance();
    final bookmarks = await getBookmarks();
    bookmarks.add(bookmark);
    final bookmarksJson = bookmarks.map((b) => {
      'id': b.id,
      'surahNumber': b.surahNumber,
      'verseNumber': b.verseNumber,
      'surahName': b.surahName,
      'verseText': b.verseText,
      'createdAt': b.createdAt.toIso8601String(),
      'note': b.note,
      'translation': b.translation,
    }).toList();
    await prefs.setString('bookmarks', json.encode(bookmarksJson));
  }
  
  Future<void> removeBookmark(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final bookmarks = await getBookmarks();
    bookmarks.removeWhere((b) => b.id == id);
    final bookmarksJson = bookmarks.map((b) => {
      'id': b.id,
      'surahNumber': b.surahNumber,
      'verseNumber': b.verseNumber,
      'surahName': b.surahName,
      'verseText': b.verseText,
      'createdAt': b.createdAt.toIso8601String(),
      'note': b.note,
      'translation': b.translation,
    }).toList();
    await prefs.setString('bookmarks', json.encode(bookmarksJson));
  }
  
  Future<List<Bookmark>> getBookmarks() async {
    final prefs = await SharedPreferences.getInstance();
    final bookmarksString = prefs.getString('bookmarks');
    if (bookmarksString != null) {
      final List<dynamic> bookmarksJson = json.decode(bookmarksString);
      return bookmarksJson.map((json) => Bookmark(
        id: json['id'],
        surahNumber: json['surahNumber'],
        verseNumber: json['verseNumber'],
        surahName: json['surahName'],
        verseText: json['verseText'],
        createdAt: DateTime.parse(json['createdAt']),
        note: json['note'],
        translation: json['translation'],
      )).toList();
    }
    return [];
  }
  
  Future<bool> isBookmarked(int surahNumber, int verseNumber) async {
    final bookmarks = await getBookmarks();
    return bookmarks.any((b) => 
      b.surahNumber == surahNumber && b.verseNumber == verseNumber
    );
  }
  
  // Settings
  Future<void> setSetting(String key, dynamic value) async {
    final prefs = await SharedPreferences.getInstance();
    if (value is String) {
      await prefs.setString(key, value);
    } else if (value is int) {
      await prefs.setInt(key, value);
    } else if (value is double) {
      await prefs.setDouble(key, value);
    } else if (value is bool) {
      await prefs.setBool(key, value);
    }
  }
  
  Future<T?> getSetting<T>(String key) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.get(key) as T?;
  }
  
  // API Key
  Future<void> setApiKey(String apiKey) async {
    await setSetting('geoapify_api_key', apiKey);
  }
  
  Future<String?> getApiKey() async {
    return await getSetting<String>('geoapify_api_key');
  }
}