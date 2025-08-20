import 'package:flutter/widgets.dart';
import '../models/surah.dart';
import '../models/verse.dart';
import '../services/quran_service.dart';

class QuranProvider extends ChangeNotifier {
  final QuranService _quranService = QuranService();
  
  List<Surah> _surahs = [];
  List<Verse> _currentVerses = [];
  Verse? _verseOfTheDay;
  bool _isLoading = false;
  String? _error;
  
  List<Surah> get surahs => _surahs;
  List<Verse> get currentVerses => _currentVerses;
  Verse? get verseOfTheDay => _verseOfTheDay;
  bool get isLoading => _isLoading;
  String? get error => _error;
  
  Future<void> loadSurahs() async {
    if (_isLoading) return; // Prevent multiple simultaneous calls
    
    _isLoading = true;
    _error = null;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      notifyListeners();
    });
    
    try {
      _surahs = await _quranService.getAllSurahs();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        notifyListeners();
      });
    }
  }
  
  Future<void> loadSurahVerses(int surahNumber, {String? translationEdition}) async {
    if (_isLoading) return; // Prevent multiple simultaneous calls
    
    _isLoading = true;
    _error = null;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      notifyListeners();
    });
    
    try {
      if (translationEdition != null) {
        _currentVerses = await _quranService.getSurahWithTranslation(
          surahNumber, 
          translationEdition,
        );
      } else {
        _currentVerses = await _quranService.getSurahVerses(surahNumber);
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        notifyListeners();
      });
    }
  }
  
  Future<void> loadVerseOfTheDay() async {
    try {
      _verseOfTheDay = await _quranService.getVerseOfTheDay();
      WidgetsBinding.instance.addPostFrameCallback((_) {
        notifyListeners();
      });
    } catch (e) {
      // Silently fail for verse of the day
    }
  }
  
  Future<List<Verse>> searchVerses(String query) async {
    try {
      return await _quranService.searchVerses(query);
    } catch (e) {
      return [];
    }
  }
}