import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProgressService {
  late Box _progressBox;
  
  Future<void> init() async {
    _progressBox = await Hive.openBox('reading_progress');
  }
  
  Future<void> updateReadingProgress({
    required int surahNumber,
    required int verseNumber,
    required int totalVerses,
  }) async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    
    // Update last read position
    await _progressBox.put('lastSurah', surahNumber);
    await _progressBox.put('lastVerse', verseNumber);
    await _progressBox.put('lastReadTime', now.toIso8601String());
    
    // Update verses read today
    final todayKey = 'verses_${today.toIso8601String()}';
    final versesReadToday = _progressBox.get(todayKey, defaultValue: 0) as int;
    await _progressBox.put(todayKey, versesReadToday + 1);
    
    // Update total verses read
    final totalRead = _progressBox.get('totalVersesRead', defaultValue: 0) as int;
    await _progressBox.put('totalVersesRead', totalRead + 1);
    
    // Update reading streak
    await _updateReadingStreak();
    
    // Update completion percentage
    await _updateCompletionPercentage(totalRead + 1, totalVerses);
    
    // Save to SharedPreferences for widget access
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('reading_streak', getReadingStreak());
    await prefs.setInt('verses_read_today', versesReadToday + 1);
    await prefs.setDouble('completion_percentage', getCompletionPercentage());
  }
  
  Future<void> _updateReadingStreak() async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    
    final lastStreakDateStr = _progressBox.get('lastStreakDate');
    if (lastStreakDateStr == null) {
      // First time reading
      await _progressBox.put('currentStreak', 1);
      await _progressBox.put('lastStreakDate', today.toIso8601String());
      return;
    }
    
    final lastStreakDate = DateTime.parse(lastStreakDateStr);
    final daysDifference = today.difference(lastStreakDate).inDays;
    
    if (daysDifference == 0) {
      // Already read today, no change to streak
      return;
    } else if (daysDifference == 1) {
      // Consecutive day, increment streak
      final currentStreak = _progressBox.get('currentStreak', defaultValue: 0) as int;
      await _progressBox.put('currentStreak', currentStreak + 1);
      await _progressBox.put('lastStreakDate', today.toIso8601String());
      
      // Update longest streak if necessary
      final longestStreak = _progressBox.get('longestStreak', defaultValue: 0) as int;
      if (currentStreak + 1 > longestStreak) {
        await _progressBox.put('longestStreak', currentStreak + 1);
      }
    } else {
      // Streak broken, reset to 1
      await _progressBox.put('currentStreak', 1);
      await _progressBox.put('lastStreakDate', today.toIso8601String());
    }
  }
  
  Future<void> _updateCompletionPercentage(int versesRead, int totalVerses) async {
    final percentage = (versesRead / totalVerses) * 100;
    await _progressBox.put('completionPercentage', percentage);
  }
  
  int getReadingStreak() {
    return _progressBox.get('currentStreak', defaultValue: 0) as int;
  }
  
  int getLongestStreak() {
    return _progressBox.get('longestStreak', defaultValue: 0) as int;
  }
  
  double getCompletionPercentage() {
    return _progressBox.get('completionPercentage', defaultValue: 0.0) as double;
  }
  
  int getTotalVersesRead() {
    return _progressBox.get('totalVersesRead', defaultValue: 0) as int;
  }
  
  Map<String, dynamic> getLastReadPosition() {
    return {
      'surah': _progressBox.get('lastSurah', defaultValue: 1),
      'verse': _progressBox.get('lastVerse', defaultValue: 1),
      'time': _progressBox.get('lastReadTime'),
    };
  }
  
  int getVersesReadToday() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final todayKey = 'verses_${today.toIso8601String()}';
    return _progressBox.get(todayKey, defaultValue: 0) as int;
  }
  
  Map<String, int> getWeeklyProgress() {
    final Map<String, int> weeklyData = {};
    final now = DateTime.now();
    
    for (int i = 6; i >= 0; i--) {
      final date = now.subtract(Duration(days: i));
      final dateOnly = DateTime(date.year, date.month, date.day);
      final key = 'verses_${dateOnly.toIso8601String()}';
      final verses = _progressBox.get(key, defaultValue: 0) as int;
      
      final dayName = _getDayName(date.weekday);
      weeklyData[dayName] = verses;
    }
    
    return weeklyData;
  }
  
  String _getDayName(int weekday) {
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return days[weekday - 1];
  }
  
  Map<String, dynamic> getAllStats() {
    return {
      'readingStreak': getReadingStreak(),
      'longestStreak': getLongestStreak(),
      'completionPercentage': getCompletionPercentage(),
      'totalVersesRead': getTotalVersesRead(),
      'versesReadToday': getVersesReadToday(),
      'lastReadPosition': getLastReadPosition(),
      'weeklyProgress': getWeeklyProgress(),
    };
  }
  
  Future<void> resetProgress() async {
    await _progressBox.clear();
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('reading_streak', 0);
    await prefs.setInt('verses_read_today', 0);
    await prefs.setDouble('completion_percentage', 0.0);
  }
  
  Future<void> exportProgress() async {
    final stats = getAllStats();
    // In a real app, this would export to a file or cloud service
    print('Exporting progress: $stats');
  }
  
  Future<void> importProgress(Map<String, dynamic> data) async {
    // In a real app, this would import from a file or cloud service
    for (final entry in data.entries) {
      await _progressBox.put(entry.key, entry.value);
    }
  }
}