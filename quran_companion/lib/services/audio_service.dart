import 'package:just_audio/just_audio.dart';
import 'package:audio_session/audio_session.dart';
import '../models/reciter.dart';
import 'audio_download_service.dart';

class AudioService {
  final AudioPlayer _audioPlayer = AudioPlayer();
  final AudioDownloadService _downloadService = AudioDownloadService();
  static const String baseAudioUrl = 'https://cdn.islamic.network/quran/audio/128';
  
  Reciter? _currentReciter;
  int? _currentSurah;
  
  // Popular reciters
  final List<Reciter> reciters = [
    Reciter(
      identifier: 'ar.alafasy',
      name: 'مشاري العفاسي',
      englishName: 'Mishary Rashid Alafasy',
      style: 'Murattal',
      bitrate: '128',
    ),
    Reciter(
      identifier: 'ar.abdulbasitmurattal',
      name: 'عبد الباسط عبد الصمد',
      englishName: 'Abdul Basit Abdul Samad',
      style: 'Murattal',
      bitrate: '128',
    ),
    Reciter(
      identifier: 'ar.minshawi',
      name: 'محمد صديق المنشاوي',
      englishName: 'Mohamed Siddiq Al-Minshawi',
      style: 'Murattal',
      bitrate: '128',
    ),
    Reciter(
      identifier: 'ar.husary',
      name: 'محمود خليل الحصري',
      englishName: 'Mahmoud Khalil Al-Hussary',
      style: 'Murattal',
      bitrate: '128',
    ),
  ];
  
  AudioService() {
    _init();
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
      
      // Check if audio is downloaded
      final isDownloaded = await _downloadService.isAudioDownloaded(
        surahNumber,
        reciter.identifier,
      );
      
      if (isDownloaded) {
        // Play from local file
        final localPath = await _downloadService.getLocalAudioPath(
          surahNumber,
          reciter.identifier,
        );
        await _audioPlayer.setAudioSource(AudioSource.uri(Uri.file(localPath)));
      } else {
        // Stream from internet
        final url = '$baseAudioUrl/${reciter.identifier}/$surahNumber.mp3';
        await _audioPlayer.setUrl(url);
      }
      
      await _audioPlayer.play();
    } catch (e) {
      throw Exception('Failed to play audio: $e');
    }
  }
  
  Future<void> playVerse(int surahNumber, int verseNumber, Reciter reciter) async {
    try {
      // Format: 001001 (surah 001, verse 001)
      final formattedSurah = surahNumber.toString().padLeft(3, '0');
      final formattedVerse = verseNumber.toString().padLeft(3, '0');
      final verseId = '$formattedSurah$formattedVerse';
      
      final url = 'https://everyayah.com/data/${reciter.identifier}/$verseId.mp3';
      await _audioPlayer.setUrl(url);
      await _audioPlayer.play();
    } catch (e) {
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
  
  Future<void> seek(Duration position) async {
    await _audioPlayer.seek(position);
  }
  
  Stream<Duration> get positionStream => _audioPlayer.positionStream;
  Stream<Duration?> get durationStream => _audioPlayer.durationStream;
  Stream<PlayerState> get playerStateStream => _audioPlayer.playerStateStream;
  
  bool get isPlaying => _audioPlayer.playing;
  
  void dispose() {
    _audioPlayer.dispose();
  }
}