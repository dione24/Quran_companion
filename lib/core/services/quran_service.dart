import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;

class QuranService {
  Map<String, dynamic>? _quranData;
  Map<String, dynamic>? _translationsData;
  
  Future<void> loadQuranData() async {
    if (_quranData != null) return;
    
    try {
      final String jsonString = await rootBundle.loadString('assets/data/quran/quran_data.json');
      _quranData = json.decode(jsonString);
    } catch (e) {
      print('Error loading Quran data: $e');
      // Fallback to API if local data fails
      await _loadFromAPI();
    }
  }
  
  Future<void> _loadFromAPI() async {
    try {
      final response = await http.get(
        Uri.parse('https://api.alquran.cloud/v1/quran/quran-uthmani'),
      );
      
      if (response.statusCode == 200) {
        _quranData = json.decode(response.body);
      }
    } catch (e) {
      print('Error loading from API: $e');
    }
  }
  
  Future<Map<String, dynamic>> getSurah(int surahNumber) async {
    await loadQuranData();
    
    if (_quranData == null) {
      throw Exception('Quran data not loaded');
    }
    
    final surahs = _quranData!['data']['surahs'] as List;
    return surahs.firstWhere(
      (surah) => surah['number'] == surahNumber,
      orElse: () => throw Exception('Surah not found'),
    );
  }
  
  Future<Map<String, dynamic>> getVerse(int surahNumber, int verseNumber) async {
    final surah = await getSurah(surahNumber);
    final verses = surah['ayahs'] as List;
    
    return verses.firstWhere(
      (verse) => verse['numberInSurah'] == verseNumber,
      orElse: () => throw Exception('Verse not found'),
    );
  }
  
  Future<String> getTranslation(
    int surahNumber, 
    int verseNumber, 
    String language,
  ) async {
    // Load translations
    if (_translationsData == null) {
      final String jsonString = await rootBundle.loadString(
        'assets/data/translations/translations_$language.json'
      );
      _translationsData = json.decode(jsonString);
    }
    
    final key = '$surahNumber:$verseNumber';
    return _translationsData?[key] ?? '';
  }
  
  Future<List<Map<String, dynamic>>> searchVerses(String query) async {
    await loadQuranData();
    
    if (_quranData == null) {
      return [];
    }
    
    final List<Map<String, dynamic>> results = [];
    final surahs = _quranData!['data']['surahs'] as List;
    final searchQuery = query.toLowerCase();
    
    for (final surah in surahs) {
      final verses = surah['ayahs'] as List;
      for (final verse in verses) {
        final text = verse['text'].toString().toLowerCase();
        if (text.contains(searchQuery)) {
          results.add({
            'surah': surah['name'],
            'surahNumber': surah['number'],
            'verseNumber': verse['numberInSurah'],
            'text': verse['text'],
          });
        }
      }
    }
    
    return results;
  }
  
  Future<List<Map<String, dynamic>>> getAllSurahs() async {
    await loadQuranData();
    
    if (_quranData == null) {
      return [];
    }
    
    final surahs = _quranData!['data']['surahs'] as List;
    return surahs.map((surah) => {
      'number': surah['number'],
      'name': surah['name'],
      'englishName': surah['englishName'],
      'englishNameTranslation': surah['englishNameTranslation'],
      'numberOfAyahs': surah['numberOfAyahs'],
      'revelationType': surah['revelationType'],
    }).toList();
  }
  
  Future<Map<String, dynamic>> getJuz(int juzNumber) async {
    await loadQuranData();
    
    if (_quranData == null) {
      throw Exception('Quran data not loaded');
    }
    
    // Juz mapping logic
    final juzData = {
      'number': juzNumber,
      'startSurah': _getJuzStartSurah(juzNumber),
      'startVerse': _getJuzStartVerse(juzNumber),
      'endSurah': _getJuzEndSurah(juzNumber),
      'endVerse': _getJuzEndVerse(juzNumber),
    };
    
    return juzData;
  }
  
  int _getJuzStartSurah(int juzNumber) {
    // Simplified juz mapping - in production, use complete mapping
    final Map<int, int> juzStartSurah = {
      1: 1, 2: 2, 3: 2, 4: 3, 5: 4, 6: 4, 7: 5, 8: 6, 9: 7, 10: 8,
      11: 9, 12: 11, 13: 12, 14: 15, 15: 17, 16: 18, 17: 21, 18: 23,
      19: 25, 20: 27, 21: 29, 22: 33, 23: 36, 24: 39, 25: 41, 26: 46,
      27: 51, 28: 58, 29: 67, 30: 78,
    };
    return juzStartSurah[juzNumber] ?? 1;
  }
  
  int _getJuzStartVerse(int juzNumber) {
    // Simplified - in production, use complete mapping
    return 1;
  }
  
  int _getJuzEndSurah(int juzNumber) {
    // Simplified - in production, use complete mapping
    return _getJuzStartSurah(juzNumber + 1) - 1;
  }
  
  int _getJuzEndVerse(int juzNumber) {
    // Simplified - in production, use complete mapping
    return 999;
  }
  
  Future<int> getTotalPages() async {
    // Standard Quran has 604 pages
    return 604;
  }
  
  Future<Map<String, dynamic>> getPage(int pageNumber) async {
    // Page mapping logic - simplified
    // In production, use complete page-to-verse mapping
    return {
      'pageNumber': pageNumber,
      'startSurah': 1,
      'startVerse': 1,
      'endSurah': 1,
      'endVerse': 7,
    };
  }
}