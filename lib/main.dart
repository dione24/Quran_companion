import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:home_widget/home_widget.dart';
import 'package:workmanager/workmanager.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/constants/app_constants.dart';
import 'core/theme/app_theme.dart';
import 'core/localization/app_localizations.dart';
import 'core/services/notification_service.dart';
import 'core/services/background_service.dart';
import 'core/services/permission_service.dart';
import 'core/providers/app_providers.dart';
import 'features/home/screens/home_screen.dart';
import 'features/splash/screens/splash_screen.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    await BackgroundService.handleBackgroundTask(task, inputData);
    return Future.value(true);
  });
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Hive
  await Hive.initFlutter();
  
  // Register Hive Adapters
  await _registerHiveAdapters();
  
  // Open Hive Boxes
  await _openHiveBoxes();
  
  // Initialize Audio Service
  await JustAudioBackground.init(
    androidNotificationChannelId: 'com.qurancompanion.audio',
    androidNotificationChannelName: 'Quran Audio',
    androidNotificationOngoing: true,
    androidStopForegroundOnPause: true,
    androidShowNotificationBadge: true,
    androidNotificationIcon: 'drawable/ic_notification',
    fastForwardInterval: const Duration(seconds: 10),
    rewindInterval: const Duration(seconds: 10),
  );
  
  // Initialize Notifications
  await NotificationService.initialize(flutterLocalNotificationsPlugin);
  
  // Initialize Home Widget
  await HomeWidget.setAppGroupId('group.com.qurancompanion');
  
  // Initialize Workmanager for background tasks
  await Workmanager().initialize(
    callbackDispatcher,
    isInDebugMode: false,
  );
  
  // Register periodic task for daily verse update
  await Workmanager().registerPeriodicTask(
    "daily-verse-update",
    "updateDailyVerse",
    frequency: const Duration(hours: 24),
    initialDelay: const Duration(seconds: 10),
    constraints: Constraints(
      networkType: NetworkType.not_required,
    ),
  );
  
  // Request permissions
  await PermissionService.requestInitialPermissions();
  
  // Set preferred orientations
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);
  
  // Set system UI overlay style
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      statusBarBrightness: Brightness.light,
    ),
  );
  
  runApp(
    const ProviderScope(
      child: QuranCompanionApp(),
    ),
  );
}

Future<void> _registerHiveAdapters() async {
  // Register your Hive adapters here
  // Example: Hive.registerAdapter(BookmarkAdapter());
}

Future<void> _openHiveBoxes() async {
  await Hive.openBox('bookmarks');
  await Hive.openBox('notes');
  await Hive.openBox('settings');
  await Hive.openBox('memorization');
  await Hive.openBox('quiz_scores');
  await Hive.openBox('progress');
  await Hive.openBox('downloads');
  await Hive.openBox('tafsir_preferences');
}

class QuranCompanionApp extends ConsumerStatefulWidget {
  const QuranCompanionApp({super.key});

  @override
  ConsumerState<QuranCompanionApp> createState() => _QuranCompanionAppState();
}

class _QuranCompanionAppState extends ConsumerState<QuranCompanionApp> {
  @override
  void initState() {
    super.initState();
    _loadSettings();
  }
  
  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final languageCode = prefs.getString('language_code') ?? 'fr';
    final themeMode = prefs.getString('theme_mode') ?? 'system';
    
    ref.read(languageProvider.notifier).setLanguage(languageCode);
    ref.read(themeModeProvider.notifier).setThemeMode(
      themeMode == 'dark' ? ThemeMode.dark :
      themeMode == 'light' ? ThemeMode.light : ThemeMode.system
    );
  }
  
  @override
  Widget build(BuildContext context) {
    final locale = ref.watch(languageProvider);
    final themeMode = ref.watch(themeModeProvider);
    
    return MaterialApp(
      title: 'Quran Companion',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      locale: Locale(locale),
      supportedLocales: const [
        Locale('fr', 'FR'),
        Locale('en', 'US'),
      ],
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: const SplashScreen(),
    );
  }
}