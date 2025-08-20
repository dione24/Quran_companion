import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../models/memorization_model.dart';

class MemorizationService {
  static const String boxName = 'memorization';
  late Box<Map> _memorizationBox;
  final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();
  
  Future<void> init() async {
    _memorizationBox = await Hive.openBox<Map>(boxName);
  }

  Future<void> addVerseToMemorization(MemorizationVerse verse) async {
    await _memorizationBox.put(verse.id, verse.toMap());
    await scheduleSpacedRepetition(verse);
  }

  Future<void> updateVerseMastery(String verseId, MasteryLevel newLevel) async {
    final verseData = _memorizationBox.get(verseId);
    if (verseData != null) {
      final verse = MemorizationVerse.fromMap(verseData);
      verse.masteryLevel = newLevel;
      verse.lastReviewDate = DateTime.now();
      verse.reviewCount++;
      
      await _memorizationBox.put(verseId, verse.toMap());
      await scheduleSpacedRepetition(verse);
    }
  }

  Future<void> scheduleSpacedRepetition(MemorizationVerse verse) async {
    // Calculate next review date based on mastery level
    final Duration interval = _getSpacedRepetitionInterval(verse.masteryLevel, verse.reviewCount);
    final DateTime nextReview = DateTime.now().add(interval);
    
    // Schedule notification
    await _scheduleNotification(
      verse.id.hashCode,
      'Révision de mémorisation',
      'Il est temps de réviser: Sourate ${verse.surahName}, Verset ${verse.verseNumber}',
      nextReview,
    );
  }

  Duration _getSpacedRepetitionInterval(MasteryLevel level, int reviewCount) {
    // Spaced repetition algorithm (simplified SM-2)
    switch (level) {
      case MasteryLevel.beginner:
        return Duration(hours: reviewCount == 0 ? 1 : 6);
      case MasteryLevel.intermediate:
        return Duration(days: reviewCount < 3 ? 1 : 3);
      case MasteryLevel.mastered:
        return Duration(days: reviewCount < 5 ? 7 : 30);
    }
  }

  Future<void> _scheduleNotification(
    int id,
    String title,
    String body,
    DateTime scheduledDate,
  ) async {
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'memorization_channel',
      'Memorization Reminders',
      channelDescription: 'Reminders for Quran memorization review',
      importance: Importance.high,
      priority: Priority.high,
    );
    
    const NotificationDetails notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: DarwinNotificationDetails(),
    );
    
    await _notifications.schedule(
      id,
      title,
      body,
      scheduledDate,
      notificationDetails,
    );
  }

  List<MemorizationVerse> getVersesForReview() {
    final now = DateTime.now();
    final List<MemorizationVerse> versesForReview = [];
    
    for (final key in _memorizationBox.keys) {
      final verseData = _memorizationBox.get(key);
      if (verseData != null) {
        final verse = MemorizationVerse.fromMap(verseData);
        if (verse.nextReviewDate.isBefore(now)) {
          versesForReview.add(verse);
        }
      }
    }
    
    return versesForReview;
  }

  List<MemorizationVerse> getAllMemorizedVerses() {
    return _memorizationBox.values
        .map((data) => MemorizationVerse.fromMap(data))
        .toList();
  }

  Map<String, dynamic> getMemorizationStats() {
    final verses = getAllMemorizedVerses();
    
    return {
      'totalVerses': verses.length,
      'beginnerVerses': verses.where((v) => v.masteryLevel == MasteryLevel.beginner).length,
      'intermediateVerses': verses.where((v) => v.masteryLevel == MasteryLevel.intermediate).length,
      'masteredVerses': verses.where((v) => v.masteryLevel == MasteryLevel.mastered).length,
      'dueForReview': getVersesForReview().length,
      'averageReviewCount': verses.isEmpty 
          ? 0 
          : verses.map((v) => v.reviewCount).reduce((a, b) => a + b) ~/ verses.length,
    };
  }

  Future<void> removeVerse(String verseId) async {
    await _memorizationBox.delete(verseId);
    await _notifications.cancel(verseId.hashCode);
  }

  Future<void> clearAllMemorization() async {
    await _memorizationBox.clear();
  }
}