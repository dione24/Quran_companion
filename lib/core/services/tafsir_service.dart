import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:hive_flutter/hive_flutter.dart';

class TafsirService {
  static const Map<String, String> tafsirSources = {
    'ibn-kathir': 'Ibn Kathir',
    'jalalayn': 'Jalalayn',
    'maariful-quran': 'Maariful Quran',
    'qurtubi': 'Al-Qurtubi',
    'tabari': 'Al-Tabari',
  };
  
  late Box _tafsirBox;
  String _currentSource = 'ibn-kathir';
  Map<String, dynamic>? _cachedTafsir;
  
  Future<void> init() async {
    _tafsirBox = await Hive.openBox('tafsir_cache');
    await _loadPreferredSource();
  }
  
  Future<void> _loadPreferredSource() async {
    final Box prefsBox = await Hive.openBox('tafsir_preferences');
    _currentSource = prefsBox.get('preferred_source', defaultValue: 'ibn-kathir');
  }
  
  Future<void> setPreferredSource(String source) async {
    _currentSource = source;
    final Box prefsBox = await Hive.openBox('tafsir_preferences');
    await prefsBox.put('preferred_source', source);
    _cachedTafsir = null; // Clear cache when source changes
  }
  
  String get currentSource => _currentSource;
  
  Future<String> getTafsir(
    int surahNumber, 
    int verseNumber,
    String language,
  ) async {
    final cacheKey = '${_currentSource}_${surahNumber}_${verseNumber}_$language';
    
    // Check cache first
    final cached = _tafsirBox.get(cacheKey);
    if (cached != null) {
      return cached;
    }
    
    // Try to load from local assets
    String? tafsir = await _loadLocalTafsir(surahNumber, verseNumber, language);
    
    // If not found locally, fetch from API
    if (tafsir == null || tafsir.isEmpty) {
      tafsir = await _fetchTafsirFromAPI(surahNumber, verseNumber, language);
    }
    
    // Cache the result
    if (tafsir != null && tafsir.isNotEmpty) {
      await _tafsirBox.put(cacheKey, tafsir);
    }
    
    return tafsir ?? _getDefaultTafsir(language);
  }
  
  Future<String?> _loadLocalTafsir(
    int surahNumber,
    int verseNumber,
    String language,
  ) async {
    try {
      final String jsonPath = 'assets/data/tafsir/${_currentSource}_$language.json';
      final String jsonString = await rootBundle.loadString(jsonPath);
      final Map<String, dynamic> tafsirData = json.decode(jsonString);
      
      final key = '$surahNumber:$verseNumber';
      return tafsirData[key];
    } catch (e) {
      print('Error loading local tafsir: $e');
      return null;
    }
  }
  
  Future<String?> _fetchTafsirFromAPI(
    int surahNumber,
    int verseNumber,
    String language,
  ) async {
    try {
      // Map source to API edition ID
      final editionId = _getAPIEditionId(_currentSource, language);
      
      final url = 'https://api.alquran.cloud/v1/ayah/$surahNumber:$verseNumber/$editionId';
      final response = await http.get(Uri.parse(url));
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['data']['text'];
      }
    } catch (e) {
      print('Error fetching tafsir from API: $e');
    }
    return null;
  }
  
  String _getAPIEditionId(String source, String language) {
    // Map internal source names to API edition IDs
    final Map<String, Map<String, String>> editionMap = {
      'ibn-kathir': {
        'en': 'en.ibn-kathir',
        'fr': 'fr.hamidullah',  // Fallback for French
      },
      'jalalayn': {
        'en': 'en.jalalayn',
        'fr': 'fr.hamidullah',
      },
      'maariful-quran': {
        'en': 'en.maududi',
        'fr': 'fr.hamidullah',
      },
      'qurtubi': {
        'en': 'en.sahih',
        'fr': 'fr.hamidullah',
      },
      'tabari': {
        'en': 'en.sahih',
        'fr': 'fr.hamidullah',
      },
    };
    
    return editionMap[source]?[language] ?? 'en.sahih';
  }
  
  String _getDefaultTafsir(String language) {
    if (language == 'fr') {
      return 'Tafsir non disponible pour ce verset.';
    } else {
      return 'Tafsir not available for this verse.';
    }
  }
  
  Future<List<String>> getAvailableSources() async {
    return tafsirSources.keys.toList();
  }
  
  String getSourceDisplayName(String source) {
    return tafsirSources[source] ?? source;
  }
  
  Future<Map<String, dynamic>> getTafsirMetadata(String source) async {
    try {
      final String jsonPath = 'assets/data/tafsir/${source}_metadata.json';
      final String jsonString = await rootBundle.loadString(jsonPath);
      return json.decode(jsonString);
    } catch (e) {
      return {
        'name': getSourceDisplayName(source),
        'author': 'Unknown',
        'description': '',
        'language': ['en', 'ar'],
      };
    }
  }
  
  Future<void> downloadTafsirSource(
    String source,
    String language,
    Function(double) onProgress,
    Function() onComplete,
    Function(String) onError,
  ) async {
    try {
      // In a real app, this would download the tafsir data
      // For now, we'll simulate the download
      for (int i = 0; i <= 100; i += 10) {
        await Future.delayed(const Duration(milliseconds: 100));
        onProgress(i / 100);
      }
      onComplete();
    } catch (e) {
      onError(e.toString());
    }
  }
  
  Future<bool> isTafsirDownloaded(String source, String language) async {
    try {
      final String jsonPath = 'assets/data/tafsir/${source}_$language.json';
      await rootBundle.loadString(jsonPath);
      return true;
    } catch (e) {
      return false;
    }
  }
  
  Future<void> clearCache() async {
    await _tafsirBox.clear();
    _cachedTafsir = null;
  }
  
  Future<Map<String, dynamic>> getStorageInfo() async {
    final boxSize = _tafsirBox.length;
    
    return {
      'cacheEntries': boxSize,
      'sources': tafsirSources.length,
      'currentSource': _currentSource,
    };
  }
}