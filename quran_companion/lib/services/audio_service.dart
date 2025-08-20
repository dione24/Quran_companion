import 'dart:async';
import 'package:just_audio/just_audio.dart';
import 'package:flutter/foundation.dart';
import 'package:audio_session/audio_session.dart';
import '../models/reciter.dart';
import 'audio_download_service.dart';
import 'offline_audio_service.dart';

class AudioService {
  final AudioPlayer _audioPlayer = AudioPlayer();
  final AudioDownloadService _downloadService = AudioDownloadService();
  final OfflineAudioService _offlineAudioService = OfflineAudioService();
  static const String baseAudioUrl = 'https://server8.mp3quran.net';
  
  Reciter? _currentReciter;
  int? _currentSurah;
  int? _currentVerse;
  bool _isPlayingVerse = false;
  bool _cancelSequential = false;
  
  // Stream controllers for audio synchronization
  final _currentVerseController = StreamController<int?>.broadcast();
  final _playbackStateController = StreamController<bool>.broadcast();
  
  Stream<int?> get currentVerseStream => _currentVerseController.stream;
  Stream<bool> get playbackStateStream => _playbackStateController.stream;
  
  // Popular reciters with their server directories
  final List<Reciter> reciters = [
    Reciter(
      identifier: 'afs',
      name: 'مشاري العفاسي',
      englishName: 'Mishary Rashid Alafasy',
      style: 'Murattal',
      bitrate: '128',
    ),
    Reciter(
      identifier: 'abdulbasit',
      name: 'عبد الباسط عبد الصمد',
      englishName: 'Abdul Basit Abdul Samad',
      style: 'Murattal',
      bitrate: '128',
    ),
    Reciter(
      identifier: 'minshawi',
      name: 'محمد صديق المنشاوي',
      englishName: 'Mohamed Siddiq Al-Minshawi',
      style: 'Murattal',
      bitrate: '128',
    ),
    Reciter(
      identifier: 'husary',
      name: 'محمود خليل الحصري',
      englishName: 'Mahmoud Khalil Al-Hussary',
      style: 'Murattal',
      bitrate: '128',
    ),
  ];
  
  AudioService() {
    _init();
  }

  // Map our short identifiers to everyayah.com directory names for verse audio
  String _everyAyahDirFor(String identifier) {
    switch (identifier) {
      case 'afs':
        return 'Alafasy_128kbps';
      case 'abdulbasit':
        return 'Abdul_Basit_Murattal_64kbps';
      case 'minshawi':
        return 'Minshawy_Murattal_128kbps';
      case 'husary':
        return 'Husary_64kbps';
      default:
        return 'Alafasy_128kbps';
    }
  }
  
  Future<void> _init() async {
    final session = await AudioSession.instance;
    await session.configure(const AudioSessionConfiguration.speech());
    
    // Handle interruptions
    session.interruptionEventStream.listen((event) {
      if (event.begin) {
        pause();
      }
    });
  }
  
  Future<void> playSurah(int surahNumber, Reciter reciter) async {
    try {
      _currentSurah = surahNumber;
      _currentReciter = reciter;
      
      // Check if audio is downloaded (try new offline service first)
      bool isDownloaded = await _offlineAudioService.isAudioDownloaded(
        surahNumber,
        reciter.identifier,
      );
      
      if (!isDownloaded) {
        // Fallback to old download service
        isDownloaded = await _downloadService.isAudioDownloaded(
          surahNumber,
          reciter.identifier,
        );
      }
      
      if (isDownloaded) {
        // Play from local file (try new service first)
        String localPath;
        try {
          localPath = await _offlineAudioService.getLocalAudioPath(
            surahNumber,
            reciter.identifier,
          );
        } catch (e) {
          // Fallback to old service
          localPath = await _downloadService.getLocalAudioPath(
            surahNumber,
            reciter.identifier,
          );
        }
        await _audioPlayer.setAudioSource(AudioSource.uri(Uri.file(localPath)));
      } else {
        // Stream from internet - format surah number with leading zeros
        final formattedSurah = surahNumber.toString().padLeft(3, '0');
        final url = '$baseAudioUrl/${reciter.identifier}/$formattedSurah.mp3';
        debugPrint('Attempting to play audio from: $url');
        await _audioPlayer.setUrl(url);
      }
      
      await _audioPlayer.play();
    } catch (e) {
      debugPrint('Audio error: $e');
      throw Exception('Failed to play audio: $e');
    }
  }
  
  Future<void> playVerse(int surahNumber, int verseNumber, Reciter reciter) async {
    try {
      _currentSurah = surahNumber;
      _currentVerse = verseNumber;
      _currentReciter = reciter;
      _isPlayingVerse = true;
      
      // Format: 001001 (surah 001, verse 001)
      final formattedSurah = surahNumber.toString().padLeft(3, '0');
      final formattedVerse = verseNumber.toString().padLeft(3, '0');
      final verseId = '$formattedSurah$formattedVerse';
      
      final dir = _everyAyahDirFor(reciter.identifier);
      final url = 'https://everyayah.com/data/$dir/$verseId.mp3';
      debugPrint('Attempting to play verse from: $url');
      await _audioPlayer.setUrl(url);
      
      // Notify listeners about current verse
      _currentVerseController.add(verseNumber);
      _playbackStateController.add(true);
      
      await _audioPlayer.play();
      
      // Listen for completion to auto-play next verse
      _audioPlayer.playerStateStream.listen((state) {
        if (state.processingState == ProcessingState.completed) {
          _onVerseCompleted();
        }
      });
    } catch (e) {
      _isPlayingVerse = false;
      _playbackStateController.add(false);
      throw Exception('Failed to play verse audio: $e');
    }
  }
  
  Future<void> pause() async {
    await _audioPlayer.pause();
  }
  
  Future<void> resume() async {
    await _audioPlayer.play();
  }
  
  Future<void> stop() async {
    await _audioPlayer.stop();
  }

  // Cancel any ongoing sequential playback
  void cancelSequential() {
    _cancelSequential = true;
  }
  
  Future<void> seek(Duration position) async {
    await _audioPlayer.seek(position);
  }
  
  Stream<Duration> get positionStream => _audioPlayer.positionStream;
  Stream<Duration?> get durationStream => _audioPlayer.durationStream;
  Stream<PlayerState> get playerStateStream => _audioPlayer.playerStateStream;
  
  bool get isPlaying => _audioPlayer.playing;

  // Offline audio management methods
  Future<bool> downloadSurahAudio(int surahNumber, Reciter reciter, {Function(double)? onProgress}) async {
    return await _offlineAudioService.downloadSurahAudio(surahNumber, reciter, onProgress: onProgress);
  }

  Future<void> downloadAllSurahsForReciter(Reciter reciter, {Function(int, int)? onProgress}) async {
    await _offlineAudioService.downloadAllSurahsForReciter(reciter, onProgress: onProgress);
  }

  Future<double> getDownloadProgress(String reciterIdentifier) async {
    return await _offlineAudioService.getDownloadProgress(reciterIdentifier);
  }

  Future<bool> isReciterFullyDownloaded(String reciterIdentifier) async {
    return await _offlineAudioService.isReciterFullyDownloaded(reciterIdentifier);
  }

  Future<List<String>> getDownloadedReciters() async {
    return await _offlineAudioService.getDownloadedReciters();
  }

  Future<void> deleteReciterAudio(String reciterIdentifier) async {
    await _offlineAudioService.deleteReciterAudio(reciterIdentifier);
  }

  Future<double> getTotalStorageUsed() async {
    return await _offlineAudioService.getTotalStorageUsed();
  }

  Future<void> clearAllAudio() async {
    await _offlineAudioService.clearAllAudio();
  }

  // Handle verse completion and auto-play next verse
  void _onVerseCompleted() {
    if (_currentVerse != null && _currentSurah != null && _currentReciter != null) {
      _currentVerseController.add(null); // Clear current verse highlight
      _playbackStateController.add(false);
      _isPlayingVerse = false;
    }
  }

  // Sequential verse playback for continuous reading
  Future<void> playSequentialVerses(int surahNumber, List<int> verseNumbers, Reciter reciter) async {
    _cancelSequential = false;
    for (int i = 0; i < verseNumbers.length; i++) {
      if (_cancelSequential) {
        break;
      }
      try {
        await playVerse(surahNumber, verseNumbers[i], reciter);
        
        // Wait for verse to complete before playing next
        await _audioPlayer.playerStateStream
            .where((state) => state.processingState == ProcessingState.completed)
            .first;
        
        // Small pause between verses
        await Future.delayed(const Duration(milliseconds: 500));
      } catch (e) {
        debugPrint('Error playing verse ${verseNumbers[i]}: $e');
        break;
      }
    }
  }

  // Get current playing verse
  int? get currentVerse => _currentVerse;
  bool get isPlayingVerse => _isPlayingVerse;

  void dispose() {
    _currentVerseController.close();
    _playbackStateController.close();
    _audioPlayer.dispose();
  }
}