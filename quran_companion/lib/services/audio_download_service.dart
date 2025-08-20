import 'dart:io';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import '../models/reciter.dart';

class AudioDownloadService {
  final Dio _dio = Dio();
  static const String baseAudioUrl = 'https://cdn.islamic.network/quran/audio/128';
  
  // Download progress tracking
  final Map<String, double> _downloadProgress = {};
  final Map<String, CancelToken> _cancelTokens = {};
  
  Future<String> get _audioDirectory async {
    final appDir = await getApplicationDocumentsDirectory();
    final audioDir = Directory(path.join(appDir.path, 'audio'));
    if (!await audioDir.exists()) {
      await audioDir.create(recursive: true);
    }
    return audioDir.path;
  }
  
  // Get local file path for a surah audio
  Future<String> getLocalAudioPath(int surahNumber, String reciterIdentifier) async {
    final dir = await _audioDirectory;
    return path.join(dir, reciterIdentifier, '$surahNumber.mp3');
  }
  
  // Check if audio file exists locally
  Future<bool> isAudioDownloaded(int surahNumber, String reciterIdentifier) async {
    final filePath = await getLocalAudioPath(surahNumber, reciterIdentifier);
    return File(filePath).exists();
  }
  
  // Download surah audio
  Future<void> downloadSurahAudio(
    int surahNumber,
    Reciter reciter, {
    Function(double)? onProgress,
    Function()? onComplete,
    Function(String)? onError,
  }) async {
    try {
      final url = '$baseAudioUrl/${reciter.identifier}/$surahNumber.mp3';
      final filePath = await getLocalAudioPath(surahNumber, reciter.identifier);
      final file = File(filePath);
      
      // Create directory if it doesn't exist
      final dir = file.parent;
      if (!await dir.exists()) {
        await dir.create(recursive: true);
      }
      
      // Create cancel token for this download
      final cancelToken = CancelToken();
      final downloadKey = '${reciter.identifier}_$surahNumber';
      _cancelTokens[downloadKey] = cancelToken;
      
      // Download file
      await _dio.download(
        url,
        filePath,
        cancelToken: cancelToken,
        onReceiveProgress: (received, total) {
          if (total != -1) {
            final progress = received / total;
            _downloadProgress[downloadKey] = progress;
            onProgress?.call(progress);
          }
        },
      );
      
      _downloadProgress.remove(downloadKey);
      _cancelTokens.remove(downloadKey);
      onComplete?.call();
      
    } catch (e) {
      if (e is DioException && e.type == DioExceptionType.cancel) {
        // Download was cancelled
        onError?.call('Download cancelled');
      } else {
        onError?.call('Download failed: $e');
      }
    }
  }
  
  // Download multiple surahs
  Future<void> downloadMultipleSurahs(
    List<int> surahNumbers,
    Reciter reciter, {
    Function(int, double)? onProgress,
    Function(int)? onSurahComplete,
    Function()? onAllComplete,
    Function(String)? onError,
  }) async {
    for (final surahNumber in surahNumbers) {
      try {
        await downloadSurahAudio(
          surahNumber,
          reciter,
          onProgress: (progress) => onProgress?.call(surahNumber, progress),
          onComplete: () => onSurahComplete?.call(surahNumber),
          onError: onError,
        );
      } catch (e) {
        onError?.call('Failed to download surah $surahNumber: $e');
      }
    }
    onAllComplete?.call();
  }
  
  // Download complete Quran for a reciter
  Future<void> downloadCompleteQuran(
    Reciter reciter, {
    Function(int, double)? onProgress,
    Function(int, int)? onOverallProgress,
    Function()? onComplete,
    Function(String)? onError,
  }) async {
    final surahNumbers = List.generate(114, (i) => i + 1);
    int completed = 0;
    
    await downloadMultipleSurahs(
      surahNumbers,
      reciter,
      onProgress: onProgress,
      onSurahComplete: (surahNumber) {
        completed++;
        onOverallProgress?.call(completed, 114);
      },
      onAllComplete: onComplete,
      onError: onError,
    );
  }
  
  // Cancel download
  void cancelDownload(int surahNumber, String reciterIdentifier) {
    final downloadKey = '${reciterIdentifier}_$surahNumber';
    _cancelTokens[downloadKey]?.cancel();
    _cancelTokens.remove(downloadKey);
    _downloadProgress.remove(downloadKey);
  }
  
  // Cancel all downloads
  void cancelAllDownloads() {
    for (final token in _cancelTokens.values) {
      token.cancel();
    }
    _cancelTokens.clear();
    _downloadProgress.clear();
  }
  
  // Get download progress
  double? getDownloadProgress(int surahNumber, String reciterIdentifier) {
    final downloadKey = '${reciterIdentifier}_$surahNumber';
    return _downloadProgress[downloadKey];
  }
  
  // Delete downloaded audio
  Future<void> deleteAudio(int surahNumber, String reciterIdentifier) async {
    final filePath = await getLocalAudioPath(surahNumber, reciterIdentifier);
    final file = File(filePath);
    if (await file.exists()) {
      await file.delete();
    }
  }
  
  // Delete all audio for a reciter
  Future<void> deleteReciterAudio(String reciterIdentifier) async {
    final dir = await _audioDirectory;
    final reciterDir = Directory(path.join(dir, reciterIdentifier));
    if (await reciterDir.exists()) {
      await reciterDir.delete(recursive: true);
    }
  }
  
  // Delete all downloaded audio
  Future<void> deleteAllAudio() async {
    final dir = await _audioDirectory;
    final audioDir = Directory(dir);
    if (await audioDir.exists()) {
      await audioDir.delete(recursive: true);
      await audioDir.create(); // Recreate empty directory
    }
  }
  
  // Get total size of downloaded audio
  Future<int> getDownloadedAudioSize() async {
    final dir = await _audioDirectory;
    final audioDir = Directory(dir);
    
    if (!await audioDir.exists()) {
      return 0;
    }
    
    int totalSize = 0;
    await for (final entity in audioDir.list(recursive: true)) {
      if (entity is File) {
        totalSize += await entity.length();
      }
    }
    
    return totalSize;
  }
  
  // Get list of downloaded surahs for a reciter
  Future<List<int>> getDownloadedSurahs(String reciterIdentifier) async {
    final dir = await _audioDirectory;
    final reciterDir = Directory(path.join(dir, reciterIdentifier));
    
    if (!await reciterDir.exists()) {
      return [];
    }
    
    final downloadedSurahs = <int>[];
    await for (final entity in reciterDir.list()) {
      if (entity is File && entity.path.endsWith('.mp3')) {
        final fileName = path.basenameWithoutExtension(entity.path);
        final surahNumber = int.tryParse(fileName);
        if (surahNumber != null) {
          downloadedSurahs.add(surahNumber);
        }
      }
    }
    
    downloadedSurahs.sort();
    return downloadedSurahs;
  }
  
  // Format file size for display
  String formatFileSize(int bytes) {
    if (bytes < 1024) {
      return '$bytes B';
    } else if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(1)} KB';
    } else if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    } else {
      return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
    }
  }
}