import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'package:adhan/adhan.dart';
import '../models/verse.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();
  
  final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();
  
  // Notification IDs
  static const int dailyVerseId = 1;
  static const int fajrId = 2;
  static const int dhuhrId = 3;
  static const int asrId = 4;
  static const int maghribId = 5;
  static const int ishaId = 6;
  static const int reminderBaseId = 100;
  
  Future<void> initialize() async {
    tz.initializeTimeZones();
    
    // Android settings
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    
    // iOS settings
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    
    // Initialize
    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );
    
    await _notifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );
    
    // Request permissions for iOS
    await _requestPermissions();
  }
  
  Future<void> _requestPermissions() async {
    final platform = _notifications.resolvePlatformSpecificImplementation<
        IOSFlutterLocalNotificationsPlugin>();
    
    await platform?.requestPermissions(
      alert: true,
      badge: true,
      sound: true,
    );
    
    final androidPlatform = _notifications.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    
    await androidPlatform?.requestNotificationsPermission();
  }
  
  void _onNotificationTapped(NotificationResponse response) {
    // Handle notification tap
    // You can navigate to specific screens based on the payload
    final payload = response.payload;
    if (payload != null) {
      // Parse payload and navigate accordingly
      print('Notification tapped with payload: $payload');
    }
  }
  
  // Schedule daily verse notification
  Future<void> scheduleDailyVerse({
    required TimeOfDay time,
    required String title,
    required String body,
  }) async {
    final now = DateTime.now();
    var scheduledDate = DateTime(
      now.year,
      now.month,
      now.day,
      time.hour,
      time.minute,
    );
    
    // If the time has passed today, schedule for tomorrow
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }
    
    await _notifications.zonedSchedule(
      dailyVerseId,
      title,
      body,
      tz.TZDateTime.from(scheduledDate, tz.local),
      NotificationDetails(
        android: AndroidNotificationDetails(
          'daily_verse',
          'Daily Verse',
          channelDescription: 'Daily verse notifications',
          importance: Importance.high,
          priority: Priority.high,
          styleInformation: BigTextStyleInformation(body),
        ),
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
      payload: 'daily_verse',
    );
  }
  
  // Schedule prayer time notifications
  Future<void> schedulePrayerNotifications({
    required Coordinates coordinates,
    required CalculationParameters params,
    required Map<Prayer, bool> enabledPrayers,
  }) async {
    final prayerTimes = PrayerTimes.today(coordinates, params);
    
    final prayers = {
      Prayer.fajr: (prayerTimes.fajr, fajrId, 'Fajr'),
      Prayer.dhuhr: (prayerTimes.dhuhr, dhuhrId, 'Dhuhr'),
      Prayer.asr: (prayerTimes.asr, asrId, 'Asr'),
      Prayer.maghrib: (prayerTimes.maghrib, maghribId, 'Maghrib'),
      Prayer.isha: (prayerTimes.isha, ishaId, 'Isha'),
    };
    
    for (final entry in prayers.entries) {
      final prayer = entry.key;
      final (time, id, name) = entry.value;
      
      if (enabledPrayers[prayer] ?? false) {
        await _schedulePrayerNotification(
          id: id,
          prayerName: name,
          prayerTime: time,
        );
      } else {
        await cancelNotification(id);
      }
    }
  }
  
  Future<void> _schedulePrayerNotification({
    required int id,
    required String prayerName,
    required DateTime prayerTime,
  }) async {
    final now = DateTime.now();
    var scheduledTime = prayerTime;
    
    // If prayer time has passed today, schedule for tomorrow
    if (scheduledTime.isBefore(now)) {
      scheduledTime = scheduledTime.add(const Duration(days: 1));
    }
    
    await _notifications.zonedSchedule(
      id,
      'Prayer Time',
      'It\'s time for $prayerName prayer',
      tz.TZDateTime.from(scheduledTime, tz.local),
      NotificationDetails(
        android: AndroidNotificationDetails(
          'prayer_times',
          'Prayer Times',
          channelDescription: 'Prayer time notifications',
          importance: Importance.max,
          priority: Priority.max,
          sound: const RawResourceAndroidNotificationSound('adhan'),
          playSound: true,
        ),
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
          sound: 'adhan.mp3',
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
      payload: 'prayer_$prayerName',
    );
  }
  
  // Schedule reading reminder
  Future<void> scheduleReadingReminder({
    required int id,
    required TimeOfDay time,
    required String title,
    required String body,
    required DateTimeComponents repeat,
  }) async {
    final now = DateTime.now();
    var scheduledDate = DateTime(
      now.year,
      now.month,
      now.day,
      time.hour,
      time.minute,
    );
    
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }
    
    await _notifications.zonedSchedule(
      reminderBaseId + id,
      title,
      body,
      tz.TZDateTime.from(scheduledDate, tz.local),
      NotificationDetails(
        android: AndroidNotificationDetails(
          'reading_reminders',
          'Reading Reminders',
          channelDescription: 'Quran reading reminders',
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: repeat,
      payload: 'reading_reminder_$id',
    );
  }
  
  // Show instant notification
  Future<void> showNotification({
    required String title,
    required String body,
    String? payload,
  }) async {
    await _notifications.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title,
      body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          'general',
          'General',
          channelDescription: 'General notifications',
          importance: Importance.high,
          priority: Priority.high,
          styleInformation: BigTextStyleInformation(body),
        ),
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      payload: payload,
    );
  }
  
  // Show verse notification with Arabic text
  Future<void> showVerseNotification({
    required Verse verse,
    required String surahName,
  }) async {
    final title = '$surahName ${verse.numberInSurah}';
    final body = verse.text + (verse.translation != null ? '\n\n${verse.translation}' : '');
    
    await _notifications.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title,
      body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          'verses',
          'Verses',
          channelDescription: 'Verse notifications',
          importance: Importance.high,
          priority: Priority.high,
          styleInformation: BigTextStyleInformation(
            body,
            contentTitle: title,
          ),
        ),
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      payload: 'verse_${verse.surahNumber}_${verse.numberInSurah}',
    );
  }
  
  // Cancel notification
  Future<void> cancelNotification(int id) async {
    await _notifications.cancel(id);
  }
  
  // Cancel all notifications
  Future<void> cancelAllNotifications() async {
    await _notifications.cancelAll();
  }
  
  // Get pending notifications
  Future<List<PendingNotificationRequest>> getPendingNotifications() async {
    return await _notifications.pendingNotificationRequests();
  }
  
  // Check if notifications are enabled
  Future<bool> areNotificationsEnabled() async {
    final androidPlatform = _notifications.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    
    if (androidPlatform != null) {
      final enabled = await androidPlatform.areNotificationsEnabled();
      return enabled ?? false;
    }
    
    // For iOS, check if permissions are granted
    final iosPlatform = _notifications.resolvePlatformSpecificImplementation<
        IOSFlutterLocalNotificationsPlugin>();
    
    if (iosPlatform != null) {
      // This would need additional implementation
      return true;
    }
    
    return false;
  }
}