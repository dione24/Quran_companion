import 'dart:io';
import 'dart:isolate';
import 'package:dio/dio.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class DownloadService {
  static const String downloadsBoxName = 'downloads';
  late Box<Map> _downloadsBox;
  final Dio _dio = Dio();
  final Map<String, CancelToken> _activeDownloads = {};
  
  // Audio sources
  static const String baseAudioUrl = 'https://cdn.islamic.network/quran/audio/128/';
  static const Map<String, String> reciters = {
    'ar.alafasy': 'Mishary Rashid Alafasy',
    'ar.abdurrahmaansudais': 'Abdul Rahman Al-Sudais',
    'ar.abdulbasitmurattal': 'Abdul Basit',
    'ar.husary': 'Mahmoud Khalil Al-Hussary',
    'ar.minshawi': 'Mohamed Siddiq El-Minshawi',
  };

  Future<void> init() async {
    _downloadsBox = await Hive.openBox<Map>(downloadsBoxName);
  }

  Future<bool> checkConnectivity() async {
    final connectivityResult = await Connectivity().checkConnectivity();
    return connectivityResult != ConnectivityResult.none;
  }

  Future<String> getDownloadPath() async {
    final directory = await getApplicationDocumentsDirectory();
    final audioDir = Directory('${directory.path}/quran_audio');
    if (!await audioDir.exists()) {
      await audioDir.create(recursive: true);
    }
    return audioDir.path;
  }

  Future<void> downloadSurah({
    required int surahNumber,
    required String reciter,
    required Function(double) onProgress,
    required Function() onComplete,
    required Function(String) onError,
  }) async {
    final downloadId = '${reciter}_$surahNumber';
    
    if (_activeDownloads.containsKey(downloadId)) {
      onError('Download already in progress');
      return;
    }

    if (!await checkConnectivity()) {
      onError('No internet connection');
      return;
    }

    try {
      final cancelToken = CancelToken();
      _activeDownloads[downloadId] = cancelToken;
      
      final downloadPath = await getDownloadPath();
      final fileName = '${reciter}_$surahNumber.mp3';
      final filePath = '$downloadPath/$fileName';
      
      // Check if file already exists
      if (await File(filePath).exists()) {
        onComplete();
        return;
      }
      
      // Construct download URL
      final url = '$baseAudioUrl$reciter/$surahNumber.mp3';
      
      // Start download
      await _dio.download(
        url,
        filePath,
        cancelToken: cancelToken,
        onReceiveProgress: (received, total) {
          if (total != -1) {
            final progress = received / total;
            onProgress(progress);
            _updateDownloadProgress(downloadId, progress);
          }
        },
      );
      
      // Save download info
      await _saveDownloadInfo(downloadId, {
        'surahNumber': surahNumber,
        'reciter': reciter,
        'filePath': filePath,
        'downloadDate': DateTime.now().toIso8601String(),
        'fileSize': await File(filePath).length(),
      });
      
      _activeDownloads.remove(downloadId);
      onComplete();
      
    } catch (e) {
      _activeDownloads.remove(downloadId);
      if (e is DioException && e.type == DioExceptionType.cancel) {
        onError('Download cancelled');
      } else {
        onError('Download failed: ${e.toString()}');
      }
    }
  }

  Future<void> downloadVerse({
    required int surahNumber,
    required int verseNumber,
    required String reciter,
    required Function(double) onProgress,
    required Function() onComplete,
    required Function(String) onError,
  }) async {
    final downloadId = '${reciter}_${surahNumber}_$verseNumber';
    
    if (_activeDownloads.containsKey(downloadId)) {
      onError('Download already in progress');
      return;
    }

    if (!await checkConnectivity()) {
      onError('No internet connection');
      return;
    }

    try {
      final cancelToken = CancelToken();
      _activeDownloads[downloadId] = cancelToken;
      
      final downloadPath = await getDownloadPath();
      final fileName = '${reciter}_${surahNumber}_$verseNumber.mp3';
      final filePath = '$downloadPath/$fileName';
      
      // Check if file already exists
      if (await File(filePath).exists()) {
        onComplete();
        return;
      }
      
      // Construct download URL (verse-specific)
      final formattedVerse = verseNumber.toString().padLeft(3, '0');
      final formattedSurah = surahNumber.toString().padLeft(3, '0');
      final url = '$baseAudioUrl$reciter/$formattedSurah$formattedVerse.mp3';
      
      // Start download
      await _dio.download(
        url,
        filePath,
        cancelToken: cancelToken,
        onReceiveProgress: (received, total) {
          if (total != -1) {
            final progress = received / total;
            onProgress(progress);
            _updateDownloadProgress(downloadId, progress);
          }
        },
      );
      
      // Save download info
      await _saveDownloadInfo(downloadId, {
        'surahNumber': surahNumber,
        'verseNumber': verseNumber,
        'reciter': reciter,
        'filePath': filePath,
        'downloadDate': DateTime.now().toIso8601String(),
        'fileSize': await File(filePath).length(),
      });
      
      _activeDownloads.remove(downloadId);
      onComplete();
      
    } catch (e) {
      _activeDownloads.remove(downloadId);
      if (e is DioException && e.type == DioExceptionType.cancel) {
        onError('Download cancelled');
      } else {
        onError('Download failed: ${e.toString()}');
      }
    }
  }

  Future<void> downloadMultipleSurahs({
    required List<int> surahNumbers,
    required String reciter,
    required Function(int, double) onProgress,
    required Function(int) onSurahComplete,
    required Function() onAllComplete,
    required Function(String) onError,
  }) async {
    // Use isolate for batch downloads
    final receivePort = ReceivePort();
    await Isolate.spawn(
      _batchDownloadIsolate,
      BatchDownloadParams(
        surahNumbers: surahNumbers,
        reciter: reciter,
        sendPort: receivePort.sendPort,
      ),
    );
    
    receivePort.listen((message) {
      if (message is DownloadProgress) {
        onProgress(message.surahNumber, message.progress);
      } else if (message is DownloadComplete) {
        onSurahComplete(message.surahNumber);
      } else if (message is DownloadError) {
        onError(message.error);
      } else if (message is AllDownloadsComplete) {
        onAllComplete();
        receivePort.close();
      }
    });
  }

  static void _batchDownloadIsolate(BatchDownloadParams params) async {
    final dio = Dio();
    
    for (final surahNumber in params.surahNumbers) {
      try {
        final url = '$baseAudioUrl${params.reciter}/$surahNumber.mp3';
        final tempDir = await getTemporaryDirectory();
        final filePath = '${tempDir.path}/${params.reciter}_$surahNumber.mp3';
        
        await dio.download(
          url,
          filePath,
          onReceiveProgress: (received, total) {
            if (total != -1) {
              params.sendPort.send(DownloadProgress(
                surahNumber: surahNumber,
                progress: received / total,
              ));
            }
          },
        );
        
        params.sendPort.send(DownloadComplete(surahNumber: surahNumber));
      } catch (e) {
        params.sendPort.send(DownloadError(
          error: 'Failed to download surah $surahNumber: ${e.toString()}',
        ));
      }
    }
    
    params.sendPort.send(AllDownloadsComplete());
  }

  void cancelDownload(String downloadId) {
    final cancelToken = _activeDownloads[downloadId];
    if (cancelToken != null) {
      cancelToken.cancel('User cancelled');
      _activeDownloads.remove(downloadId);
    }
  }

  void cancelAllDownloads() {
    _activeDownloads.forEach((id, token) {
      token.cancel('All downloads cancelled');
    });
    _activeDownloads.clear();
  }

  Future<void> _saveDownloadInfo(String id, Map<String, dynamic> info) async {
    await _downloadsBox.put(id, info);
  }

  Future<void> _updateDownloadProgress(String id, double progress) async {
    final info = _downloadsBox.get(id) ?? {};
    info['progress'] = progress;
    await _downloadsBox.put(id, info);
  }

  Future<String?> getOfflineAudioPath(int surahNumber, String reciter, [int? verseNumber]) async {
    final downloadPath = await getDownloadPath();
    final fileName = verseNumber != null
        ? '${reciter}_${surahNumber}_$verseNumber.mp3'
        : '${reciter}_$surahNumber.mp3';
    final filePath = '$downloadPath/$fileName';
    
    if (await File(filePath).exists()) {
      return filePath;
    }
    return null;
  }

  Future<bool> isDownloaded(int surahNumber, String reciter, [int? verseNumber]) async {
    final path = await getOfflineAudioPath(surahNumber, reciter, verseNumber);
    return path != null;
  }

  Future<Map<String, dynamic>> getStorageInfo() async {
    final downloadPath = await getDownloadPath();
    final directory = Directory(downloadPath);
    
    if (!await directory.exists()) {
      return {
        'totalSize': 0,
        'fileCount': 0,
        'downloads': [],
      };
    }
    
    int totalSize = 0;
    int fileCount = 0;
    final List<Map<String, dynamic>> downloads = [];
    
    await for (final file in directory.list()) {
      if (file is File) {
        final stat = await file.stat();
        totalSize += stat.size;
        fileCount++;
        
        downloads.add({
          'path': file.path,
          'size': stat.size,
          'modified': stat.modified.toIso8601String(),
        });
      }
    }
    
    return {
      'totalSize': totalSize,
      'totalSizeMB': (totalSize / (1024 * 1024)).toStringAsFixed(2),
      'fileCount': fileCount,
      'downloads': downloads,
    };
  }

  Future<void> deleteDownload(String downloadId) async {
    final info = _downloadsBox.get(downloadId);
    if (info != null && info['filePath'] != null) {
      final file = File(info['filePath']);
      if (await file.exists()) {
        await file.delete();
      }
      await _downloadsBox.delete(downloadId);
    }
  }

  Future<void> clearAllDownloads() async {
    final downloadPath = await getDownloadPath();
    final directory = Directory(downloadPath);
    
    if (await directory.exists()) {
      await directory.delete(recursive: true);
    }
    
    await _downloadsBox.clear();
  }

  List<Map<String, dynamic>> getDownloadHistory() {
    return _downloadsBox.values.map((v) => Map<String, dynamic>.from(v)).toList();
  }
}

// Classes for isolate communication
class BatchDownloadParams {
  final List<int> surahNumbers;
  final String reciter;
  final SendPort sendPort;

  BatchDownloadParams({
    required this.surahNumbers,
    required this.reciter,
    required this.sendPort,
  });
}

class DownloadProgress {
  final int surahNumber;
  final double progress;

  DownloadProgress({required this.surahNumber, required this.progress});
}

class DownloadComplete {
  final int surahNumber;

  DownloadComplete({required this.surahNumber});
}

class DownloadError {
  final String error;

  DownloadError({required this.error});
}

class AllDownloadsComplete {}