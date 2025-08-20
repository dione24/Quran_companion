import 'package:flutter/material.dart';
import '../services/local_storage_service.dart';

class SettingsProvider extends ChangeNotifier {
  final LocalStorageService _localStorage = LocalStorageService();
  
  // Settings
  ThemeMode _themeMode = ThemeMode.system;
  Locale _locale = const Locale('fr');
  double _arabicFontSize = 28.0;
  double _translationFontSize = 16.0;
  bool _showTranslation = true;
  bool _nightMode = false;
  String _selectedTranslation = 'fr.hamidullah';
  String _selectedReciter = 'ar.alafasy';
  bool _dailyReminder = false;
  TimeOfDay _reminderTime = const TimeOfDay(hour: 8, minute: 0);
  
  // Getters
  ThemeMode get themeMode => _themeMode;
  Locale get locale => _locale;
  double get arabicFontSize => _arabicFontSize;
  double get translationFontSize => _translationFontSize;
  bool get showTranslation => _showTranslation;
  bool get nightMode => _nightMode;
  String get selectedTranslation => _selectedTranslation;
  String get selectedReciter => _selectedReciter;
  bool get dailyReminder => _dailyReminder;
  TimeOfDay get reminderTime => _reminderTime;
  
  Future<void> loadSettings() async {
    _themeMode = ThemeMode.values[await _localStorage.getSetting<int>('theme_mode') ?? 0];
    final langCode = await _localStorage.getSetting<String>('language') ?? 'fr';
    _locale = Locale(langCode);
    _arabicFontSize = await _localStorage.getSetting<double>('arabic_font_size') ?? 28.0;
    _translationFontSize = await _localStorage.getSetting<double>('translation_font_size') ?? 16.0;
    _showTranslation = await _localStorage.getSetting<bool>('show_translation') ?? true;
    _nightMode = await _localStorage.getSetting<bool>('night_mode') ?? false;
    _selectedTranslation = await _localStorage.getSetting<String>('selected_translation') ?? 'fr.hamidullah';
    _selectedReciter = await _localStorage.getSetting<String>('selected_reciter') ?? 'ar.alafasy';
    _dailyReminder = await _localStorage.getSetting<bool>('daily_reminder') ?? false;
    final reminderHour = await _localStorage.getSetting<int>('reminder_hour') ?? 8;
    final reminderMinute = await _localStorage.getSetting<int>('reminder_minute') ?? 0;
    _reminderTime = TimeOfDay(hour: reminderHour, minute: reminderMinute);
    notifyListeners();
  }
  
  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    await _localStorage.setSetting('theme_mode', mode.index);
    notifyListeners();
  }
  
  Future<void> setLocale(Locale locale) async {
    _locale = locale;
    await _localStorage.setSetting('language', locale.languageCode);
    notifyListeners();
  }
  
  Future<void> setArabicFontSize(double size) async {
    _arabicFontSize = size;
    await _localStorage.setSetting('arabic_font_size', size);
    notifyListeners();
  }
  
  Future<void> setTranslationFontSize(double size) async {
    _translationFontSize = size;
    await _localStorage.setSetting('translation_font_size', size);
    notifyListeners();
  }
  
  Future<void> setShowTranslation(bool show) async {
    _showTranslation = show;
    await _localStorage.setSetting('show_translation', show);
    notifyListeners();
  }
  
  Future<void> setNightMode(bool enabled) async {
    _nightMode = enabled;
    await _localStorage.setSetting('night_mode', enabled);
    notifyListeners();
  }
  
  Future<void> setSelectedTranslation(String translation) async {
    _selectedTranslation = translation;
    await _localStorage.setSetting('selected_translation', translation);
    notifyListeners();
  }
  
  Future<void> setSelectedReciter(String reciter) async {
    _selectedReciter = reciter;
    await _localStorage.setSetting('selected_reciter', reciter);
    notifyListeners();
  }
  
  Future<void> setDailyReminder(bool enabled) async {
    _dailyReminder = enabled;
    await _localStorage.setSetting('daily_reminder', enabled);
    notifyListeners();
  }
  
  Future<void> setReminderTime(TimeOfDay time) async {
    _reminderTime = time;
    await _localStorage.setSetting('reminder_hour', time.hour);
    await _localStorage.setSetting('reminder_minute', time.minute);
    notifyListeners();
  }
}