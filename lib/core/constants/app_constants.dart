class AppConstants {
  // App Info
  static const String appName = 'Quran Companion';
  static const String appVersion = '2.0.0';
  static const String appBuildNumber = '1';
  
  // API Endpoints
  static const String quranApiBase = 'https://api.alquran.cloud/v1';
  static const String audioApiBase = 'https://cdn.islamic.network/quran/audio';
  static const String tafsirApiBase = 'https://api.quranenc.com/v1';
  
  // Geoapify API
  static const String geoapifyApiKey = 'YOUR_GEOAPIFY_API_KEY';
  static const String geoapifyApiBase = 'https://api.geoapify.com/v2';
  
  // Storage Keys
  static const String languageKey = 'language_code';
  static const String themeModeKey = 'theme_mode';
  static const String fontSizeKey = 'font_size';
  static const String tajweedEnabledKey = 'tajweed_enabled';
  static const String tafsirSourceKey = 'tafsir_source';
  static const String reciterKey = 'selected_reciter';
  static const String notificationsEnabledKey = 'notifications_enabled';
  static const String widgetEnabledKey = 'widget_enabled';
  
  // Quran Data
  static const int totalSurahs = 114;
  static const int totalVerses = 6236;
  static const int totalJuz = 30;
  static const int totalPages = 604;
  
  // Default Values
  static const String defaultLanguage = 'fr';
  static const String defaultThemeMode = 'system';
  static const double defaultFontSize = 18.0;
  static const String defaultReciter = 'ar.alafasy';
  static const String defaultTafsirSource = 'ibn-kathir';
  
  // Notification Channels
  static const String notificationChannelId = 'quran_companion_channel';
  static const String notificationChannelName = 'Quran Companion';
  static const String notificationChannelDescription = 'Notifications for Quran Companion app';
  
  // Audio Notification Channel
  static const String audioChannelId = 'com.qurancompanion.audio';
  static const String audioChannelName = 'Quran Audio';
  
  // Widget
  static const String androidWidgetName = 'quran_companion_widget';
  static const String iosWidgetName = 'QuranCompanionWidget';
  static const String appGroupId = 'group.com.qurancompanion';
  
  // Memorization Levels
  static const Map<String, int> masteryLevels = {
    'beginner': 0,
    'intermediate': 1,
    'mastered': 2,
  };
  
  // Quiz Settings
  static const int defaultQuizQuestions = 10;
  static const int quizTimeLimit = 30; // seconds per question
  static const int minQuizQuestions = 5;
  static const int maxQuizQuestions = 20;
  
  // Download Settings
  static const int maxConcurrentDownloads = 3;
  static const int downloadRetryAttempts = 3;
  static const Duration downloadTimeout = Duration(minutes: 5);
  
  // Cache Settings
  static const Duration cacheExpiry = Duration(days: 7);
  static const int maxCacheSize = 100; // MB
  
  // Animation Durations
  static const Duration shortAnimation = Duration(milliseconds: 200);
  static const Duration mediumAnimation = Duration(milliseconds: 400);
  static const Duration longAnimation = Duration(milliseconds: 600);
  
  // Padding and Spacing
  static const double defaultPadding = 16.0;
  static const double smallPadding = 8.0;
  static const double largePadding = 24.0;
  static const double extraLargePadding = 32.0;
  
  // Border Radius
  static const double defaultRadius = 12.0;
  static const double smallRadius = 8.0;
  static const double largeRadius = 16.0;
  static const double circularRadius = 100.0;
  
  // Font Sizes
  static const double minFontSize = 12.0;
  static const double maxFontSize = 32.0;
  static const double fontSizeStep = 2.0;
  
  // Arabic Font Sizes
  static const double minArabicFontSize = 16.0;
  static const double maxArabicFontSize = 40.0;
  static const double defaultArabicFontSize = 24.0;
  
  // Social Media URLs
  static const String twitterUrl = 'https://twitter.com/qurancompanion';
  static const String facebookUrl = 'https://facebook.com/qurancompanion';
  static const String instagramUrl = 'https://instagram.com/qurancompanion';
  static const String websiteUrl = 'https://qurancompanion.app';
  static const String supportEmail = 'support@qurancompanion.app';
  
  // Feature Flags
  static const bool enableTajweed = true;
  static const bool enableMemorization = true;
  static const bool enableQuiz = true;
  static const bool enableSocialSharing = true;
  static const bool enableOfflineAudio = true;
  static const bool enableWidget = true;
  static const bool enableWatchApp = true;
  
  // Regex Patterns
  static final RegExp arabicRegex = RegExp(r'[\u0600-\u06FF\u0750-\u077F\u08A0-\u08FF]+');
  static final RegExp emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
  
  // Error Messages
  static const Map<String, Map<String, String>> errorMessages = {
    'network': {
      'fr': 'Erreur de connexion réseau',
      'en': 'Network connection error',
    },
    'loading': {
      'fr': 'Erreur de chargement des données',
      'en': 'Error loading data',
    },
    'permission': {
      'fr': 'Permission refusée',
      'en': 'Permission denied',
    },
    'download': {
      'fr': 'Échec du téléchargement',
      'en': 'Download failed',
    },
    'unknown': {
      'fr': 'Une erreur inconnue s\'est produite',
      'en': 'An unknown error occurred',
    },
  };
}