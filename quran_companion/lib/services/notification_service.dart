import 'package:flutter/material.dart';
import '../models/verse.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();
  
  // Notification IDs
  static const int dailyVerseId = 1;
  static const int fajrId = 2;
  static const int dhuhrId = 3;
  static const int asrId = 4;
  static const int maghribId = 5;
  static const int ishaId = 6;
  static const int reminderBaseId = 100;
  
  Future<void> initialize() async {
    // Notification service temporarily disabled
    debugPrint('NotificationService: Initialized (notifications temporarily disabled)');
  }

  // Stub methods to prevent errors
  Future<void> scheduleDailyVerse(Verse verse) async {
    debugPrint('NotificationService: scheduleDailyVerse called (disabled)');
  }

  Future<void> schedulePrayerReminders(double latitude, double longitude) async {
    debugPrint('NotificationService: schedulePrayerReminders called (disabled)');
  }

  Future<void> scheduleMemorizationReminder(int verseId, DateTime reminderTime) async {
    debugPrint('NotificationService: scheduleMemorizationReminder called (disabled)');
  }

  Future<void> cancelAllNotifications() async {
    debugPrint('NotificationService: cancelAllNotifications called (disabled)');
  }

  Future<void> cancelNotification(int id) async {
    debugPrint('NotificationService: cancelNotification called (disabled)');
  }
}
