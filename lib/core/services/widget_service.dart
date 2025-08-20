import 'dart:convert';
import 'dart:math';
import 'package:flutter/services.dart';
import 'package:home_widget/home_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';

class WidgetService {
  static const String widgetName = 'QuranCompanionWidget';
  static const String iosWidgetName = 'QuranCompanionWidget';
  static const String androidWidgetName = 'quran_companion_widget';
  
  static Future<void> updateDailyVerse() async {
    try {
      // Load Quran data
      final String jsonString = await rootBundle.loadString('assets/data/quran/quran_data.json');
      final Map<String, dynamic> quranData = json.decode(jsonString);
      
      // Get random verse
      final random = Random();
      final surahIndex = random.nextInt(114);
      final surahData = quranData['surahs'][surahIndex];
      final verseIndex = random.nextInt(surahData['verses'].length);
      final verse = surahData['verses'][verseIndex];
      
      // Get language preference
      final prefs = await SharedPreferences.getInstance();
      final language = prefs.getString('language_code') ?? 'fr';
      
      // Get translation
      final translation = verse['translations'][language] ?? verse['translations']['fr'];
      
      // Update widget data
      await HomeWidget.saveWidgetData<String>('arabic_text', verse['arabic']);
      await HomeWidget.saveWidgetData<String>('translation', translation);
      await HomeWidget.saveWidgetData<String>('reference', 
          '${surahData['name']} ${verseIndex + 1}');
      await HomeWidget.saveWidgetData<String>('last_update', 
          DateTime.now().toIso8601String());
      
      // Update widget
      await HomeWidget.updateWidget(
        name: androidWidgetName,
        iOSName: iosWidgetName,
      );
      
      // Save to preferences for app display
      await prefs.setString('daily_verse_arabic', verse['arabic']);
      await prefs.setString('daily_verse_translation', translation);
      await prefs.setString('daily_verse_reference', 
          '${surahData['name']} ${verseIndex + 1}');
      await prefs.setString('daily_verse_date', DateTime.now().toIso8601String());
      
    } catch (e) {
      print('Error updating daily verse widget: $e');
    }
  }
  
  static Future<Map<String, String>> getDailyVerse() async {
    final prefs = await SharedPreferences.getInstance();
    
    // Check if we need to update (once per day)
    final lastUpdateStr = prefs.getString('daily_verse_date');
    if (lastUpdateStr != null) {
      final lastUpdate = DateTime.parse(lastUpdateStr);
      final now = DateTime.now();
      if (now.difference(lastUpdate).inDays == 0) {
        // Same day, return cached verse
        return {
          'arabic': prefs.getString('daily_verse_arabic') ?? '',
          'translation': prefs.getString('daily_verse_translation') ?? '',
          'reference': prefs.getString('daily_verse_reference') ?? '',
        };
      }
    }
    
    // Need to update
    await updateDailyVerse();
    
    return {
      'arabic': prefs.getString('daily_verse_arabic') ?? '',
      'translation': prefs.getString('daily_verse_translation') ?? '',
      'reference': prefs.getString('daily_verse_reference') ?? '',
    };
  }
  
  static Future<void> registerBackgroundCallback() async {
    await HomeWidget.registerBackgroundCallback(backgroundCallback);
  }
  
  static Future<void> backgroundCallback(Uri? uri) async {
    if (uri?.host == 'updateverse') {
      await updateDailyVerse();
    }
  }
  
  static Future<void> setWidgetEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('widget_enabled', enabled);
    
    if (enabled) {
      await updateDailyVerse();
    }
  }
  
  static Future<bool> isWidgetEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('widget_enabled') ?? false;
  }
}