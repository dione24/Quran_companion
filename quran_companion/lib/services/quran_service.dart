import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/surah.dart';
import '../models/verse.dart';
import 'local_storage_service.dart';

class QuranService {
  static const String baseUrl = 'https://api.alquran.cloud/v1';
  final LocalStorageService _localStorage = LocalStorageService();

  Future<List<Surah>> getAllSurahs() async {
    try {
      // Try to get from local storage first
      final localData = await _localStorage.getCachedSurahs();
      if (localData != null) {
        return localData;
      }

      // Fetch from API
      final response = await http.get(
        Uri.parse('$baseUrl/surah'),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> surahsJson = data['data'];
        final surahs = surahsJson.map((json) => Surah.fromJson(json)).toList();
        
        // Cache the data
        await _localStorage.cacheSurahs(surahs);
        
        return surahs;
      } else {
        throw Exception('Failed to load surahs');
      }
    } catch (e) {
      // Try to get from local storage if network fails
      final localData = await _localStorage.getCachedSurahs();
      if (localData != null) {
        return localData;
      }
      throw Exception('Failed to load surahs: $e');
    }
  }

  Future<List<Verse>> getSurahVerses(int surahNumber, {String? edition}) async {
    try {
      // Try to get from local storage first
      final localData = await _localStorage.getCachedVerses(surahNumber, edition ?? 'quran-simple');
      if (localData != null) {
        return localData;
      }

      // Fetch from API
      final url = edition != null 
        ? '$baseUrl/surah/$surahNumber/$edition'
        : '$baseUrl/surah/$surahNumber';
        
      final response = await http.get(
        Uri.parse(url),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> versesJson = data['data']['ayahs'];
        final verses = versesJson.map((json) => Verse.fromJson(json)).toList();
        
        // Cache the data
        await _localStorage.cacheVerses(surahNumber, edition ?? 'quran-simple', verses);
        
        return verses;
      } else {
        throw Exception('Failed to load verses');
      }
    } catch (e) {
      // Try to get from local storage if network fails
      final localData = await _localStorage.getCachedVerses(surahNumber, edition ?? 'quran-simple');
      if (localData != null) {
        return localData;
      }
      throw Exception('Failed to load verses: $e');
    }
  }

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
      throw Exception('Failed to load surah with translation: $e');
    }
  }

  Future<Verse> getVerseOfTheDay() async {
    try {
      // Get a random verse (you can implement your own logic)
      final random = DateTime.now().day % 6236 + 1; // Total verses in Quran
      
      final response = await http.get(
        Uri.parse('$baseUrl/ayah/$random'),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return Verse.fromJson(data['data']);
      } else {
        throw Exception('Failed to load verse of the day');
      }
    } catch (e) {
      // Return a default verse if network fails
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
  }

  Future<List<Verse>> searchVerses(String query, {String? edition}) async {
    try {
      final url = edition != null
        ? '$baseUrl/search/$query/all/$edition'
        : '$baseUrl/search/$query/all/en';
        
      final response = await http.get(
        Uri.parse(url),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['data'] == null || data['data']['matches'] == null) {
          return [];
        }
        final List<dynamic> matchesJson = data['data']['matches'];
        return matchesJson.map((json) => Verse.fromJson(json)).toList();
      } else {
        return [];
      }
    } catch (e) {
      return [];
    }
  }

  Future<String> getTafsir(int surahNumber, int verseNumber) async {
    try {
      // Using a tafsir edition (you can change this to any available tafsir)
      final response = await http.get(
        Uri.parse('$baseUrl/ayah/$surahNumber:$verseNumber/en.sahih'),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['data']['text'] ?? '';
      } else {
        return '';
      }
    } catch (e) {
      return '';
    }
  }
}