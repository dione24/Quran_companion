import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/reciter.dart';

class OfflineAudioService {
  static const String baseAudioUrl = 'https://server8.mp3quran.net';
  
  // Get the local directory for storing audio files
  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    final audioDir = Directory('${directory.path}/audio');
    if (!await audioDir.exists()) {
      await audioDir.create(recursive: true);
    }
    return audioDir.path;
  }

  // Check if a specific surah audio is downloaded for a reciter
  Future<bool> isAudioDownloaded(int surahNumber, String reciterIdentifier) async {
    try {
      final path = await _localPath;
      final formattedSurah = surahNumber.toString().padLeft(3, '0');
      final file = File('$path/${reciterIdentifier}_$formattedSurah.mp3');
      return await file.exists();
    } catch (e) {
      return false;
    }
  }

  // Get local path for a specific audio file
  Future<String> getLocalAudioPath(int surahNumber, String reciterIdentifier) async {
    final path = await _localPath;
    final formattedSurah = surahNumber.toString().padLeft(3, '0');
    return '$path/${reciterIdentifier}_$formattedSurah.mp3';
  }

  // Download a specific surah for a reciter
  Future<bool> downloadSurahAudio(int surahNumber, Reciter reciter, {Function(double)? onProgress}) async {
    try {
      final formattedSurah = surahNumber.toString().padLeft(3, '0');
      final url = '$baseAudioUrl/${reciter.identifier}/$formattedSurah.mp3';
      
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final localPath = await getLocalAudioPath(surahNumber, reciter.identifier);
        final file = File(localPath);
        await file.writeAsBytes(response.bodyBytes);
        
        // Mark as downloaded in preferences
        await _markAsDownloaded(surahNumber, reciter.identifier);
        return true;
      }
      return false;
    } catch (e) {
      print('Error downloading audio: $e');
      return false;
    }
  }

  // Download all surahs for a specific reciter
  Future<void> downloadAllSurahsForReciter(Reciter reciter, {Function(int, int)? onProgress}) async {
    for (int i = 1; i <= 114; i++) {
      try {
        final success = await downloadSurahAudio(i, reciter);
        if (success) {
          onProgress?.call(i, 114);
        }
        // Small delay to avoid overwhelming the server
        await Future.delayed(const Duration(milliseconds: 500));
      } catch (e) {
        print('Error downloading surah $i for ${reciter.englishName}: $e');
      }
    }
  }

  // Get download progress for a reciter
  Future<double> getDownloadProgress(String reciterIdentifier) async {
    int downloadedCount = 0;
    for (int i = 1; i <= 114; i++) {
      if (await isAudioDownloaded(i, reciterIdentifier)) {
        downloadedCount++;
      }
    }
    return downloadedCount / 114.0;
  }

  // Check if all surahs are downloaded for a reciter
  Future<bool> isReciterFullyDownloaded(String reciterIdentifier) async {
    final progress = await getDownloadProgress(reciterIdentifier);
    return progress >= 1.0;
  }

  // Get list of downloaded reciters
  Future<List<String>> getDownloadedReciters() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList('downloaded_reciters') ?? [];
  }

  // Delete all audio files for a reciter
  Future<void> deleteReciterAudio(String reciterIdentifier) async {
    try {
      final path = await _localPath;
      final directory = Directory(path);
      
      await for (final file in directory.list()) {
        if (file is File && file.path.contains('${reciterIdentifier}_')) {
          await file.delete();
        }
      }
      
      // Remove from downloaded list
      final prefs = await SharedPreferences.getInstance();
      final downloaded = prefs.getStringList('downloaded_reciters') ?? [];
      downloaded.remove(reciterIdentifier);
      await prefs.setStringList('downloaded_reciters', downloaded);
    } catch (e) {
      print('Error deleting reciter audio: $e');
    }
  }

  // Get total storage used by audio files
  Future<double> getTotalStorageUsed() async {
    try {
      final path = await _localPath;
      final directory = Directory(path);
      double totalSize = 0;
      
      await for (final file in directory.list()) {
        if (file is File && file.path.endsWith('.mp3')) {
          final stat = await file.stat();
          totalSize += stat.size;
        }
      }
      
      return totalSize / (1024 * 1024); // Return in MB
    } catch (e) {
      return 0;
    }
  }

  // Mark a surah as downloaded for a reciter
  Future<void> _markAsDownloaded(int surahNumber, String reciterIdentifier) async {
    final prefs = await SharedPreferences.getInstance();
    final key = 'downloaded_${reciterIdentifier}_$surahNumber';
    await prefs.setBool(key, true);
    
    // Add to downloaded reciters list if not already there
    final downloaded = prefs.getStringList('downloaded_reciters') ?? [];
    if (!downloaded.contains(reciterIdentifier)) {
      downloaded.add(reciterIdentifier);
      await prefs.setStringList('downloaded_reciters', downloaded);
    }
  }

  // Clear all downloaded audio
  Future<void> clearAllAudio() async {
    try {
      final path = await _localPath;
      final directory = Directory(path);
      
      if (await directory.exists()) {
        await directory.delete(recursive: true);
      }
      
      // Clear preferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('downloaded_reciters');
    } catch (e) {
      print('Error clearing audio: $e');
    }
  }
}
