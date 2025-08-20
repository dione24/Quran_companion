import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:quran_companion/main.dart';
import 'package:quran_companion/providers/quran_provider.dart';
import 'package:quran_companion/providers/bookmark_provider.dart';
import 'package:quran_companion/providers/settings_provider.dart';
import 'package:quran_companion/screens/home_screen.dart';

void main() {
  testWidgets('App launches successfully', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const QuranCompanionApp());

    // Verify that the app launches
    expect(find.byType(MaterialApp), findsOneWidget);
  });

  testWidgets('Home screen displays correctly', (WidgetTester tester) async {
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => QuranProvider()),
          ChangeNotifierProvider(create: (_) => BookmarkProvider()),
          ChangeNotifierProvider(create: (_) => SettingsProvider()),
        ],
        child: const MaterialApp(
          home: HomeScreen(),
        ),
      ),
    );

    // Verify home screen is displayed
    expect(find.byType(HomeScreen), findsOneWidget);
    
    // Verify bottom navigation exists
    expect(find.byType(NavigationBar), findsOneWidget);
  });

  group('Provider Tests', () {
    test('QuranProvider initializes correctly', () {
      final provider = QuranProvider();
      expect(provider.surahs, isEmpty);
      expect(provider.currentVerses, isEmpty);
      expect(provider.verseOfTheDay, isNull);
      expect(provider.isLoading, isFalse);
      expect(provider.error, isNull);
    });

    test('BookmarkProvider initializes correctly', () {
      final provider = BookmarkProvider();
      expect(provider.bookmarks, isEmpty);
      expect(provider.isLoading, isFalse);
    });

    test('SettingsProvider has default values', () {
      final provider = SettingsProvider();
      expect(provider.themeMode, ThemeMode.system);
      expect(provider.locale.languageCode, 'fr');
      expect(provider.arabicFontSize, 28.0);
      expect(provider.translationFontSize, 16.0);
      expect(provider.showTranslation, isTrue);
      expect(provider.nightMode, isFalse);
    });
  });
}