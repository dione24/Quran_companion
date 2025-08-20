import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;

class NotificationService {
  static Future<void> initialize(FlutterLocalNotificationsPlugin plugin) async {
    tz.initializeTimeZones();
    
    const AndroidInitializationSettings androidSettings = 
        AndroidInitializationSettings('@mipmap/ic_launcher');
    
    const DarwinInitializationSettings iosSettings = 
        DarwinInitializationSettings(
          requestAlertPermission: true,
          requestBadgePermission: true,
          requestSoundPermission: true,
        );
    
    const InitializationSettings settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );
    
    await plugin.initialize(
      settings,
      onDidReceiveNotificationResponse: onNotificationTapped,
    );
  }
  
  static void onNotificationTapped(NotificationResponse response) {
    // Handle notification tap
    if (response.payload != null) {
      // Navigate to specific screen based on payload
      print('Notification payload: ${response.payload}');
    }
  }
  
  static Future<void> showNotification(
    FlutterLocalNotificationsPlugin plugin, {
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    const AndroidNotificationDetails androidDetails = 
        AndroidNotificationDetails(
      'quran_companion_channel',
      'Quran Companion Notifications',
      channelDescription: 'Notifications for Quran Companion app',
      importance: Importance.high,
      priority: Priority.high,
      showWhen: true,
    );
    
    const DarwinNotificationDetails iosDetails = 
        DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        );
    
    const NotificationDetails details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );
    
    await plugin.show(id, title, body, details, payload: payload);
  }
  
  static Future<void> scheduleNotification(
    FlutterLocalNotificationsPlugin plugin, {
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
    String? payload,
  }) async {
    const AndroidNotificationDetails androidDetails = 
        AndroidNotificationDetails(
      'scheduled_channel',
      'Scheduled Notifications',
      channelDescription: 'Scheduled notifications for reminders',
      importance: Importance.high,
      priority: Priority.high,
    );
    
    const DarwinNotificationDetails iosDetails = 
        DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        );
    
    const NotificationDetails details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );
    
    await plugin.zonedSchedule(
      id,
      title,
      body,
      tz.TZDateTime.from(scheduledDate, tz.local),
      details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      payload: payload,
    );
  }
  
  static Future<void> cancelNotification(
    FlutterLocalNotificationsPlugin plugin,
    int id,
  ) async {
    await plugin.cancel(id);
  }
  
  static Future<void> cancelAllNotifications(
    FlutterLocalNotificationsPlugin plugin,
  ) async {
    await plugin.cancelAll();
  }
  
  static Future<void> schedulePrayerReminder(
    FlutterLocalNotificationsPlugin plugin, {
    required String prayerName,
    required DateTime prayerTime,
    int minutesBefore = 10,
  }) async {
    final reminderTime = prayerTime.subtract(Duration(minutes: minutesBefore));
    
    await scheduleNotification(
      plugin,
      id: prayerName.hashCode,
      title: 'Prayer Reminder',
      body: '$prayerName in $minutesBefore minutes',
      scheduledDate: reminderTime,
      payload: 'prayer_$prayerName',
    );
  }
  
  static Future<void> scheduleDailyVerseNotification(
    FlutterLocalNotificationsPlugin plugin,
  ) async {
    final now = DateTime.now();
    var scheduledDate = DateTime(now.year, now.month, now.day, 8, 0); // 8 AM
    
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }
    
    await scheduleNotification(
      plugin,
      id: 999,
      title: 'Daily Verse',
      body: 'Your daily verse is ready',
      scheduledDate: scheduledDate,
      payload: 'daily_verse',
    );
  }
}