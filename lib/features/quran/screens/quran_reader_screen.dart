import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers/app_providers.dart';
import '../../../core/services/quran_service.dart';
import '../../../core/services/audio_service.dart';
import '../../../core/services/tajweed_service.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/theme/app_theme.dart';

class QuranReaderScreen extends ConsumerStatefulWidget {
  final int? initialSurah;
  final int? initialVerse;

  const QuranReaderScreen({
    super.key,
    this.initialSurah,
    this.initialVerse,
  });

  @override
  ConsumerState<QuranReaderScreen> createState() => _QuranReaderScreenState();
}

class _QuranReaderScreenState extends ConsumerState<QuranReaderScreen> {
  late QuranService _quranService;
  late AudioService _audioService;
  late TajweedService _tajweedService;
  
  int _currentSurah = 1;
  int _currentVerse = 1;
  Map<String, dynamic>? _surahData;
  String _translation = '';
  double _fontSize = 24.0;
  bool _isLoading = true;
  bool _isPlaying = false;

  @override
  void initState() {
    super.initState();
    _currentSurah = widget.initialSurah ?? 1;
    _currentVerse = widget.initialVerse ?? 1;
    
    _quranService = ref.read(quranServiceProvider);
    _audioService = ref.read(audioServiceProvider);
    _tajweedService = ref.read(tajweedServiceProvider);
    
    _loadSurah();
  }

  Future<void> _loadSurah() async {
    setState(() => _isLoading = true);
    
    try {
      final surahData = await _quranService.getSurah(_currentSurah);
      final translation = await _quranService.getTranslation(
        _currentSurah,
        _currentVerse,
        ref.read(languageProvider),
      );
      
      setState(() {
        _surahData = surahData;
        _translation = translation;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _playAudio() async {
    if (_isPlaying) {
      await _audioService.pause();
    } else {
      await _audioService.playVerse(_currentSurah, _currentVerse);
    }
    setState(() => _isPlaying = !_isPlaying);
  }

  void _nextVerse() {
    if (_surahData != null) {
      final verses = _surahData!['ayahs'] as List;
      if (_currentVerse < verses.length) {
        setState(() => _currentVerse++);
        _loadTranslation();
      }
    }
  }

  void _previousVerse() {
    if (_currentVerse > 1) {
      setState(() => _currentVerse--);
      _loadTranslation();
    }
  }

  Future<void> _loadTranslation() async {
    final translation = await _quranService.getTranslation(
      _currentSurah,
      _currentVerse,
      ref.read(languageProvider),
    );
    setState(() => _translation = translation);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final tajweedEnabled = ref.watch(tajweedEnabledProvider);
    final isDark = theme.brightness == Brightness.dark;

    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: Text(l10n.quranReader)),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_surahData == null) {
      return Scaffold(
        appBar: AppBar(title: Text(l10n.quranReader)),
        body: Center(
          child: Text(l10n.error),
        ),
      );
    }

    final verses = _surahData!['ayahs'] as List;
    final currentVerseData = verses[_currentVerse - 1];

    return Scaffold(
      appBar: AppBar(
        title: Text('${_surahData!['name']} - ${l10n.verse} $_currentVerse'),
        actions: [
          IconButton(
            icon: Icon(tajweedEnabled ? Icons.palette : Icons.palette_outlined),
            onPressed: () {
              ref.read(tajweedEnabledProvider.notifier).toggle();
            },
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: _showSettings,
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          _tajweedService.buildTajweedRichText(
                            currentVerseData['text'],
                            _currentSurah,
                            _currentVerse,
                            AppTheme.arabicTextStyle(
                              fontSize: _fontSize,
                              color: theme.colorScheme.onSurface,
                            ),
                            tajweedEnabled,
                          ),
                          const SizedBox(height: 16),
                          const Divider(),
                          const SizedBox(height: 16),
                          Text(
                            _translation,
                            style: theme.textTheme.bodyLarge,
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.cardColor,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                IconButton(
                  icon: const Icon(Icons.skip_previous),
                  onPressed: _currentVerse > 1 ? _previousVerse : null,
                ),
                IconButton(
                  icon: Icon(_isPlaying ? Icons.pause : Icons.play_arrow),
                  onPressed: _playAudio,
                  iconSize: 32,
                ),
                IconButton(
                  icon: const Icon(Icons.skip_next),
                  onPressed: _currentVerse < verses.length ? _nextVerse : null,
                ),
                IconButton(
                  icon: const Icon(Icons.bookmark_border),
                  onPressed: () {
                    // Add bookmark
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.share),
                  onPressed: () {
                    // Share verse
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showSettings() {
    showModalBottomSheet(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                ref.read(languageProvider) == 'fr' 
                    ? 'Paramètres de lecture'
                    : 'Reading Settings',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(ref.read(languageProvider) == 'fr' 
                      ? 'Taille du texte'
                      : 'Text Size'),
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.remove),
                        onPressed: () {
                          if (_fontSize > 16) {
                            setState(() => _fontSize -= 2);
                            this.setState(() {});
                          }
                        },
                      ),
                      Text('${_fontSize.toInt()}'),
                      IconButton(
                        icon: const Icon(Icons.add),
                        onPressed: () {
                          if (_fontSize < 40) {
                            setState(() => _fontSize += 2);
                            this.setState(() {});
                          }
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}