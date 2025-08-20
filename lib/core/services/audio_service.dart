import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'download_service.dart';

class AudioService {
  final AudioPlayer _audioPlayer = AudioPlayer();
  final DownloadService _downloadService = DownloadService();
  
  String _currentReciter = 'ar.alafasy';
  int? _currentSurah;
  int? _currentVerse;
  bool _isPlaying = false;
  
  AudioPlayer get player => _audioPlayer;
  bool get isPlaying => _isPlaying;
  String get currentReciter => _currentReciter;
  
  Future<void> init() async {
    await _downloadService.init();
    
    // Listen to player state
    _audioPlayer.playerStateStream.listen((state) {
      _isPlaying = state.playing;
    });
  }
  
  Future<void> setReciter(String reciter) async {
    _currentReciter = reciter;
  }
  
  Future<void> playSurah(int surahNumber, {bool offline = false}) async {
    try {
      _currentSurah = surahNumber;
      _currentVerse = null;
      
      String? audioUrl;
      
      if (offline) {
        // Try to get offline audio first
        audioUrl = await _downloadService.getOfflineAudioPath(
          surahNumber,
          _currentReciter,
        );
      }
      
      if (audioUrl == null) {
        // Use online URL
        audioUrl = _getOnlineAudioUrl(surahNumber);
      }
      
      // Set audio source with metadata
      await _audioPlayer.setAudioSource(
        AudioSource.uri(
          Uri.parse(audioUrl),
          tag: MediaItem(
            id: '$surahNumber',
            title: 'Surah $surahNumber',
            artist: DownloadService.reciters[_currentReciter] ?? 'Unknown',
            artUri: Uri.parse('https://example.com/icon.png'),
          ),
        ),
      );
      
      await _audioPlayer.play();
      
    } catch (e) {
      print('Error playing surah: $e');
      throw e;
    }
  }
  
  Future<void> playVerse(
    int surahNumber, 
    int verseNumber, 
    {bool offline = false}
  ) async {
    try {
      _currentSurah = surahNumber;
      _currentVerse = verseNumber;
      
      String? audioUrl;
      
      if (offline) {
        audioUrl = await _downloadService.getOfflineAudioPath(
          surahNumber,
          _currentReciter,
          verseNumber,
        );
      }
      
      if (audioUrl == null) {
        audioUrl = _getVerseAudioUrl(surahNumber, verseNumber);
      }
      
      await _audioPlayer.setAudioSource(
        AudioSource.uri(
          Uri.parse(audioUrl),
          tag: MediaItem(
            id: '$surahNumber:$verseNumber',
            title: 'Surah $surahNumber, Verse $verseNumber',
            artist: DownloadService.reciters[_currentReciter] ?? 'Unknown',
          ),
        ),
      );
      
      await _audioPlayer.play();
      
    } catch (e) {
      print('Error playing verse: $e');
      throw e;
    }
  }
  
  Future<void> playVerseRange(
    int surahNumber,
    int startVerse,
    int endVerse,
    {bool offline = false}
  ) async {
    final List<AudioSource> sources = [];
    
    for (int verse = startVerse; verse <= endVerse; verse++) {
      String? audioUrl;
      
      if (offline) {
        audioUrl = await _downloadService.getOfflineAudioPath(
          surahNumber,
          _currentReciter,
          verse,
        );
      }
      
      if (audioUrl == null) {
        audioUrl = _getVerseAudioUrl(surahNumber, verse);
      }
      
      sources.add(
        AudioSource.uri(
          Uri.parse(audioUrl),
          tag: MediaItem(
            id: '$surahNumber:$verse',
            title: 'Surah $surahNumber, Verse $verse',
            artist: DownloadService.reciters[_currentReciter] ?? 'Unknown',
          ),
        ),
      );
    }
    
    await _audioPlayer.setAudioSource(
      ConcatenatingAudioSource(children: sources),
    );
    
    await _audioPlayer.play();
  }
  
  Future<void> pause() async {
    await _audioPlayer.pause();
  }
  
  Future<void> resume() async {
    await _audioPlayer.play();
  }
  
  Future<void> stop() async {
    await _audioPlayer.stop();
    _currentSurah = null;
    _currentVerse = null;
  }
  
  Future<void> seek(Duration position) async {
    await _audioPlayer.seek(position);
  }
  
  Future<void> setSpeed(double speed) async {
    await _audioPlayer.setSpeed(speed);
  }
  
  Future<void> setVolume(double volume) async {
    await _audioPlayer.setVolume(volume);
  }
  
  Future<void> next() async {
    if (_audioPlayer.hasNext) {
      await _audioPlayer.seekToNext();
    }
  }
  
  Future<void> previous() async {
    if (_audioPlayer.hasPrevious) {
      await _audioPlayer.seekToPrevious();
    }
  }
  
  Stream<Duration> get positionStream => _audioPlayer.positionStream;
  Stream<Duration?> get durationStream => _audioPlayer.durationStream;
  Stream<PlayerState> get playerStateStream => _audioPlayer.playerStateStream;
  Stream<int?> get currentIndexStream => _audioPlayer.currentIndexStream;
  
  String _getOnlineAudioUrl(int surahNumber) {
    return 'https://cdn.islamic.network/quran/audio/128/$_currentReciter/$surahNumber.mp3';
  }
  
  String _getVerseAudioUrl(int surahNumber, int verseNumber) {
    final formattedSurah = surahNumber.toString().padLeft(3, '0');
    final formattedVerse = verseNumber.toString().padLeft(3, '0');
    return 'https://cdn.islamic.network/quran/audio/128/$_currentReciter/$formattedSurah$formattedVerse.mp3';
  }
  
  Future<void> downloadSurahAudio(
    int surahNumber,
    Function(double) onProgress,
    Function() onComplete,
    Function(String) onError,
  ) async {
    await _downloadService.downloadSurah(
      surahNumber: surahNumber,
      reciter: _currentReciter,
      onProgress: onProgress,
      onComplete: onComplete,
      onError: onError,
    );
  }
  
  Future<bool> isSurahDownloaded(int surahNumber) async {
    return await _downloadService.isDownloaded(surahNumber, _currentReciter);
  }
  
  void dispose() {
    _audioPlayer.dispose();
  }
}