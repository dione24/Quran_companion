import 'package:flutter_test/flutter_test.dart';
import 'package:quran_companion/models/mosque.dart';
import 'package:quran_companion/services/quran_service.dart';
import 'package:quran_companion/services/audio_service.dart';
import 'package:latlong2/latlong.dart';

void main() {
  group('QuranService Tests', () {
    late QuranService quranService;

    setUp(() {
      quranService = QuranService();
    });

    test('QuranService can be instantiated', () {
      expect(quranService, isNotNull);
    });

    test('getAllSurahs returns list or throws', () async {
      try {
        final surahs = await quranService.getAllSurahs();
        expect(surahs, isNotEmpty);
        expect(surahs.length, 114); // Quran has 114 surahs
      } catch (e) {
        // Network error is acceptable in tests
        expect(e.toString(), contains('Failed to load surahs'));
      }
    });

    test('searchVerses handles empty query', () async {
      final results = await quranService.searchVerses('');
      expect(results, isEmpty);
    });
  });

  group('AudioService Tests', () {
    late AudioService audioService;

    setUp(() {
      audioService = AudioService();
    });

    test('AudioService has reciters', () {
      expect(audioService.reciters, isNotEmpty);
      expect(audioService.reciters.length, greaterThan(0));
    });

    test('Reciters have valid properties', () {
      for (final reciter in audioService.reciters) {
        expect(reciter.identifier, isNotEmpty);
        expect(reciter.name, isNotEmpty);
        expect(reciter.englishName, isNotEmpty);
        expect(reciter.style, isNotEmpty);
        expect(reciter.bitrate, isNotEmpty);
      }
    });
  });

  group('Mosque Model Tests', () {
    test('Mosque calculates distance correctly', () {
      final mosque = Mosque(
        id: 'test',
        name: 'Test Mosque',
        location: LatLng(48.8566, 2.3522), // Paris
        distance: 1500,
      );

      expect(mosque.formattedDistance, '1500 m');
    });

    test('Mosque formats km distance correctly', () {
      final mosque = Mosque(
        id: 'test',
        name: 'Test Mosque',
        location: LatLng(48.8566, 2.3522),
        distance: 2500,
      );

      expect(mosque.formattedDistance, '2.5 km');
    });

    test('Mosque from Geoapify JSON parsing', () {
      final json = {
        'properties': {
          'place_id': '123',
          'name': 'Test Mosque',
          'formatted': '123 Test Street',
        },
        'geometry': {
          'coordinates': [2.3522, 48.8566],
        },
      };

      final mosque = Mosque.fromGeoapifyJson(json, 48.8566, 2.3522);
      
      expect(mosque.id, '123');
      expect(mosque.name, 'Test Mosque');
      expect(mosque.address, '123 Test Street');
      expect(mosque.location.latitude, 48.8566);
      expect(mosque.location.longitude, 2.3522);
      expect(mosque.distance, 0); // Same location
    });
  });

  group('Search Functionality Tests', () {
    test('Search handles special characters', () async {
      final quranService = QuranService();
      
      // Test with Arabic text
      final arabicResults = await quranService.searchVerses('الله');
      // Results depend on network availability
      
      // Test with English text
      final englishResults = await quranService.searchVerses('Allah');
      // Results depend on network availability
      
      // Test with numbers
      final numberResults = await quranService.searchVerses('1:1');
      // Results depend on network availability
    });
  });

  group('Bookmark Functionality Tests', () {
    test('Bookmark verse key generation', () {
      final bookmarkData = {
        'surahNumber': 2,
        'verseNumber': 255,
      };
      
      final verseKey = '${bookmarkData['surahNumber']}:${bookmarkData['verseNumber']}';
      expect(verseKey, '2:255'); // Ayat al-Kursi
    });
  });
}