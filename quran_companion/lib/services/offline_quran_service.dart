import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/surah.dart';
import '../models/verse.dart';

class OfflineQuranService {
  static const String _surahsKey = 'cached_surahs';
  static const String _versesKeyPrefix = 'cached_verses_';
  static const String _isDataDownloadedKey = 'is_quran_data_downloaded';
  
  // Check if offline data is available
  Future<bool> isOfflineDataAvailable() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_isDataDownloadedKey) ?? false;
  }
  
  // Download and cache all Quran data for offline use
  Future<void> downloadOfflineData() async {
    final prefs = await SharedPreferences.getInstance();
    
    try {
      // Load surahs data from assets
      final surahsJson = await rootBundle.loadString('assets/data/quran/surahs.json');
      final surahsData = json.decode(surahsJson);
      await prefs.setString(_surahsKey, surahsJson);
      
      // Load all verses for each surah
      final List<dynamic> surahsList = surahsData['data'];
      for (var surahData in surahsList) {
        final surahNumber = surahData['number'];
        
        // Load Arabic verses
        final arabicJson = await rootBundle.loadString('assets/data/quran/surah_$surahNumber.json');
        await prefs.setString('${_versesKeyPrefix}${surahNumber}_quran-simple', arabicJson);
        
        // Load French translation
        try {
          final frenchJson = await rootBundle.loadString('assets/data/translations/surah_${surahNumber}_fr.hamidullah.json');
          await prefs.setString('${_versesKeyPrefix}${surahNumber}_fr.hamidullah', frenchJson);
        } catch (e) {
          // French translation not available for this surah
        }
        
        // Load English translation
        try {
          final englishJson = await rootBundle.loadString('assets/data/translations/surah_${surahNumber}_en.sahih.json');
          await prefs.setString('${_versesKeyPrefix}${surahNumber}_en.sahih', englishJson);
        } catch (e) {
          // English translation not available for this surah
        }
      }
      
      // Mark as downloaded
      await prefs.setBool(_isDataDownloadedKey, true);
    } catch (e) {
      throw Exception('Failed to download offline data: $e');
    }
  }
  
  // Get all surahs from local storage
  Future<List<Surah>> getAllSurahs() async {
    final prefs = await SharedPreferences.getInstance();
    final surahsJson = prefs.getString(_surahsKey);
    
    if (surahsJson == null) {
      throw Exception('No offline surahs data available');
    }
    
    final data = json.decode(surahsJson);
    final List<dynamic> surahsList = data['data'];
    return surahsList.map((json) => Surah.fromJson(json)).toList();
  }
  
  // Get verses for a specific surah from local storage
  Future<List<Verse>> getSurahVerses(int surahNumber, {String? edition}) async {
    final prefs = await SharedPreferences.getInstance();
    final key = '${_versesKeyPrefix}${surahNumber}_${edition ?? 'quran-simple'}';
    final versesJson = prefs.getString(key);
    
    if (versesJson == null) {
      throw Exception('No offline verses data available for surah $surahNumber');
    }
    
    final data = json.decode(versesJson);
    final List<dynamic> versesList = data['data']['ayahs'];
    return versesList.map((json) => Verse.fromJson(json)).toList();
  }
  
  // Get surah with translation from local storage
  Future<List<Verse>> getSurahWithTranslation(int surahNumber, String translationEdition) async {
    try {
      // Get Arabic text
      final arabicVerses = await getSurahVerses(surahNumber);
      
      // Get translation
      final translationVerses = await getSurahVerses(surahNumber, edition: translationEdition);
      
      // Combine them
      for (int i = 0; i < arabicVerses.length && i < translationVerses.length; i++) {
        arabicVerses[i].translation = translationVerses[i].text;
      }
      
      return arabicVerses;
    } catch (e) {
      // Fallback to Arabic only if translation not available
      return await getSurahVerses(surahNumber);
    }
  }
  
  // Get a verse of the day from local storage
  Future<Verse> getVerseOfTheDay() async {
    try {
      // Use a deterministic approach based on current date
      final now = DateTime.now();
      final dayOfYear = now.difference(DateTime(now.year, 1, 1)).inDays + 1;
      
      // Cycle through different surahs based on day of year
      final surahNumber = (dayOfYear % 114) + 1;
      final verses = await getSurahVerses(surahNumber);
      
      if (verses.isNotEmpty) {
        final verseIndex = dayOfYear % verses.length;
        final verse = verses[verseIndex];
        return verse;
      }
    } catch (e) {
      // Fallback verse
    }
    
    // Return Al-Fatiha verse 1 as fallback
    return Verse(
      number: 1,
      text: 'بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ',
      numberInSurah: 1,
      juz: 1,
      manzil: 1,
      page: 1,
      ruku: 1,
      hizbQuarter: 1,
      sajda: false,
      surahNumber: 1,
    );
  }
  
  // Search verses in local storage
  Future<List<Verse>> searchVerses(String query) async {
    final results = <Verse>[];
    
    try {
      final surahs = await getAllSurahs();
      
      for (final surah in surahs) {
        try {
          final verses = await getSurahVerses(surah.number);
          
          for (final verse in verses) {
            if (verse.text.contains(query) || 
                (verse.translation?.contains(query) ?? false)) {
              results.add(verse);
            }
          }
        } catch (e) {
          // Skip this surah if verses not available
          continue;
        }
      }
    } catch (e) {
      // Return empty results if search fails
    }
    
    return results;
  }
  
  // Clear all offline data
  Future<void> clearOfflineData() async {
    final prefs = await SharedPreferences.getInstance();
    
    // Remove all cached data
    final keys = prefs.getKeys();
    for (final key in keys) {
      if (key.startsWith(_versesKeyPrefix) || 
          key == _surahsKey || 
          key == _isDataDownloadedKey) {
        await prefs.remove(key);
      }
    }
  }
}
