import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/quran_service.dart';
import '../services/audio_service.dart';
import '../services/tafsir_service.dart';
import '../services/memorization_service.dart';
import '../services/quiz_service.dart';
import '../services/download_service.dart';
import '../services/tajweed_service.dart';
import '../services/share_service.dart';
import '../services/progress_service.dart';

// Language Provider
final languageProvider = StateNotifierProvider<LanguageNotifier, String>((ref) {
  return LanguageNotifier();
});

class LanguageNotifier extends StateNotifier<String> {
  LanguageNotifier() : super('fr');
  
  void setLanguage(String languageCode) {
    state = languageCode;
    _saveLanguage(languageCode);
  }
  
  Future<void> _saveLanguage(String languageCode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('language_code', languageCode);
  }
}

// Theme Mode Provider
final themeModeProvider = StateNotifierProvider<ThemeModeNotifier, ThemeMode>((ref) {
  return ThemeModeNotifier();
});

class ThemeModeNotifier extends StateNotifier<ThemeMode> {
  ThemeModeNotifier() : super(ThemeMode.system);
  
  void setThemeMode(ThemeMode mode) {
    state = mode;
    _saveThemeMode(mode);
  }
  
  Future<void> _saveThemeMode(ThemeMode mode) async {
    final prefs = await SharedPreferences.getInstance();
    final modeString = mode == ThemeMode.dark ? 'dark' :
                       mode == ThemeMode.light ? 'light' : 'system';
    await prefs.setString('theme_mode', modeString);
  }
}

// Service Providers
final quranServiceProvider = Provider<QuranService>((ref) {
  return QuranService();
});

final audioServiceProvider = Provider<AudioService>((ref) {
  return AudioService();
});

final tafsirServiceProvider = Provider<TafsirService>((ref) {
  return TafsirService();
});

final memorizationServiceProvider = Provider<MemorizationService>((ref) {
  return MemorizationService();
});

final quizServiceProvider = Provider<QuizService>((ref) {
  return QuizService();
});

final downloadServiceProvider = Provider<DownloadService>((ref) {
  return DownloadService();
});

final tajweedServiceProvider = Provider<TajweedService>((ref) {
  return TajweedService();
});

final shareServiceProvider = Provider<ShareService>((ref) {
  return ShareService();
});

final progressServiceProvider = Provider<ProgressService>((ref) {
  return ProgressService();
});

// Tajweed Settings Provider
final tajweedEnabledProvider = StateNotifierProvider<TajweedEnabledNotifier, bool>((ref) {
  return TajweedEnabledNotifier();
});

class TajweedEnabledNotifier extends StateNotifier<bool> {
  TajweedEnabledNotifier() : super(true);
  
  void toggle() {
    state = !state;
    _saveSetting(state);
  }
  
  Future<void> _saveSetting(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('tajweed_enabled', enabled);
  }
}

// Current Playing Verse Provider
final currentPlayingVerseProvider = StateNotifierProvider<CurrentPlayingVerseNotifier, int?>((ref) {
  return CurrentPlayingVerseNotifier();
});

class CurrentPlayingVerseNotifier extends StateNotifier<int?> {
  CurrentPlayingVerseNotifier() : super(null);
  
  void setVerse(int? verseId) {
    state = verseId;
  }
}

// Tafsir Source Provider
final tafsirSourceProvider = StateNotifierProvider<TafsirSourceNotifier, String>((ref) {
  return TafsirSourceNotifier();
});

class TafsirSourceNotifier extends StateNotifier<String> {
  TafsirSourceNotifier() : super('ibn-kathir');
  
  void setSource(String source) {
    state = source;
    _saveSource(source);
  }
  
  Future<void> _saveSource(String source) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('tafsir_source', source);
  }
}

// Reading Progress Provider
final readingProgressProvider = StateNotifierProvider<ReadingProgressNotifier, Map<String, dynamic>>((ref) {
  return ReadingProgressNotifier();
});

class ReadingProgressNotifier extends StateNotifier<Map<String, dynamic>> {
  ReadingProgressNotifier() : super({
    'currentSurah': 1,
    'currentVerse': 1,
    'totalRead': 0,
    'streak': 0,
    'lastReadDate': null,
  });
  
  void updateProgress(int surah, int verse) {
    state = {
      ...state,
      'currentSurah': surah,
      'currentVerse': verse,
      'totalRead': state['totalRead'] + 1,
    };
    _saveProgress();
  }
  
  void updateStreak() {
    final today = DateTime.now();
    final lastRead = state['lastReadDate'] != null 
        ? DateTime.parse(state['lastReadDate']) 
        : null;
    
    int newStreak = state['streak'];
    if (lastRead == null || today.difference(lastRead).inDays == 1) {
      newStreak++;
    } else if (today.difference(lastRead!).inDays > 1) {
      newStreak = 1;
    }
    
    state = {
      ...state,
      'streak': newStreak,
      'lastReadDate': today.toIso8601String(),
    };
    _saveProgress();
  }
  
  Future<void> _saveProgress() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('reading_progress', state.toString());
  }
}

// Download Progress Provider
final downloadProgressProvider = StateNotifierProvider<DownloadProgressNotifier, Map<String, double>>((ref) {
  return DownloadProgressNotifier();
});

class DownloadProgressNotifier extends StateNotifier<Map<String, double>> {
  DownloadProgressNotifier() : super({});
  
  void updateProgress(String id, double progress) {
    state = {
      ...state,
      id: progress,
    };
  }
  
  void removeProgress(String id) {
    final newState = Map<String, double>.from(state);
    newState.remove(id);
    state = newState;
  }
}

// Memorization Progress Provider
final memorizationProgressProvider = StateNotifierProvider<MemorizationProgressNotifier, List<Map<String, dynamic>>>((ref) {
  return MemorizationProgressNotifier();
});

class MemorizationProgressNotifier extends StateNotifier<List<Map<String, dynamic>>> {
  MemorizationProgressNotifier() : super([]);
  
  void addVerse(int surahId, int verseId, String level) {
    state = [
      ...state,
      {
        'surahId': surahId,
        'verseId': verseId,
        'level': level,
        'lastReviewed': DateTime.now().toIso8601String(),
        'reviewCount': 0,
      }
    ];
  }
  
  void updateLevel(int surahId, int verseId, String newLevel) {
    state = state.map((item) {
      if (item['surahId'] == surahId && item['verseId'] == verseId) {
        return {
          ...item,
          'level': newLevel,
          'lastReviewed': DateTime.now().toIso8601String(),
          'reviewCount': item['reviewCount'] + 1,
        };
      }
      return item;
    }).toList();
  }
}

// Quiz Score Provider
final quizScoreProvider = StateNotifierProvider<QuizScoreNotifier, Map<String, dynamic>>((ref) {
  return QuizScoreNotifier();
});

class QuizScoreNotifier extends StateNotifier<Map<String, dynamic>> {
  QuizScoreNotifier() : super({
    'highScore': 0,
    'totalQuizzes': 0,
    'currentStreak': 0,
    'averageScore': 0.0,
  });
  
  void updateScore(int score) {
    final highScore = state['highScore'] as int;
    final totalQuizzes = state['totalQuizzes'] as int;
    final averageScore = state['averageScore'] as double;
    
    final newHighScore = score > highScore ? score : highScore;
    final newTotalQuizzes = totalQuizzes + 1;
    final newAverageScore = ((averageScore * totalQuizzes) + score) / newTotalQuizzes;
    
    state = {
      'highScore': newHighScore,
      'totalQuizzes': newTotalQuizzes,
      'currentStreak': state['currentStreak'] + 1,
      'averageScore': newAverageScore,
    };
  }
}