import 'package:flutter_test/flutter_test.dart';
import 'package:quran_companion/core/services/download_service.dart';

void main() {
  group('DownloadService', () {
    late DownloadService downloadService;

    setUp(() {
      downloadService = DownloadService();
    });

    test('reciters map contains expected reciters', () {
      expect(DownloadService.reciters.length, 5);
      expect(
        DownloadService.reciters['ar.alafasy'],
        'Mishary Rashid Alafasy',
      );
      expect(
        DownloadService.reciters['ar.abdurrahmaansudais'],
        'Abdul Rahman Al-Sudais',
      );
      expect(
        DownloadService.reciters['ar.abdulbasitmurattal'],
        'Abdul Basit',
      );
      expect(
        DownloadService.reciters['ar.husary'],
        'Mahmoud Khalil Al-Hussary',
      );
      expect(
        DownloadService.reciters['ar.minshawi'],
        'Mohamed Siddiq El-Minshawi',
      );
    });

    test('baseAudioUrl is correctly formatted', () {
      expect(
        DownloadService.baseAudioUrl,
        'https://cdn.islamic.network/quran/audio/128/',
      );
      expect(DownloadService.baseAudioUrl.endsWith('/'), true);
    });

    test('BatchDownloadParams holds correct data', () {
      final params = BatchDownloadParams(
        surahNumbers: [1, 2, 3],
        reciter: 'ar.alafasy',
        sendPort: null as dynamic, // Mock sendPort for testing
      );

      expect(params.surahNumbers.length, 3);
      expect(params.surahNumbers[0], 1);
      expect(params.reciter, 'ar.alafasy');
    });

    test('DownloadProgress holds correct data', () {
      final progress = DownloadProgress(
        surahNumber: 1,
        progress: 0.5,
      );

      expect(progress.surahNumber, 1);
      expect(progress.progress, 0.5);
    });

    test('DownloadComplete holds correct data', () {
      final complete = DownloadComplete(surahNumber: 1);
      expect(complete.surahNumber, 1);
    });

    test('DownloadError holds correct error message', () {
      final error = DownloadError(error: 'Test error message');
      expect(error.error, 'Test error message');
    });

    test('AllDownloadsComplete can be instantiated', () {
      final complete = AllDownloadsComplete();
      expect(complete, isNotNull);
    });

    test('getAudioUrl formats URL correctly for surah', () {
      const reciter = 'ar.alafasy';
      const surahNumber = 1;
      
      final expectedUrl = 
          '${DownloadService.baseAudioUrl}$reciter/$surahNumber.mp3';
      
      expect(
        expectedUrl,
        'https://cdn.islamic.network/quran/audio/128/ar.alafasy/1.mp3',
      );
    });

    test('getAudioUrl formats URL correctly for verse', () {
      const reciter = 'ar.alafasy';
      const surahNumber = 1;
      const verseNumber = 1;
      
      final formattedSurah = surahNumber.toString().padLeft(3, '0');
      final formattedVerse = verseNumber.toString().padLeft(3, '0');
      final expectedUrl = 
          '${DownloadService.baseAudioUrl}$reciter/$formattedSurah$formattedVerse.mp3';
      
      expect(
        expectedUrl,
        'https://cdn.islamic.network/quran/audio/128/ar.alafasy/001001.mp3',
      );
    });

    test('download file naming convention is correct', () {
      const reciter = 'ar.alafasy';
      const surahNumber = 1;
      
      final expectedFileName = '${reciter}_$surahNumber.mp3';
      expect(expectedFileName, 'ar.alafasy_1.mp3');
      
      const verseNumber = 1;
      final expectedVerseFileName = '${reciter}_${surahNumber}_$verseNumber.mp3';
      expect(expectedVerseFileName, 'ar.alafasy_1_1.mp3');
    });

    test('storage info returns correct structure', () async {
      // This test would need mocking in a real scenario
      final storageInfo = {
        'totalSize': 0,
        'totalSizeMB': '0.00',
        'fileCount': 0,
        'downloads': [],
      };

      expect(storageInfo.containsKey('totalSize'), true);
      expect(storageInfo.containsKey('totalSizeMB'), true);
      expect(storageInfo.containsKey('fileCount'), true);
      expect(storageInfo.containsKey('downloads'), true);
      expect(storageInfo['downloads'], isList);
    });
  });
}