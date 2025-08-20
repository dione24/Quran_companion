import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/surah.dart';
import '../models/verse.dart';
import '../providers/quran_provider.dart';
import '../providers/settings_provider.dart';
import '../providers/bookmark_provider.dart';
import '../widgets/verse_widget.dart';
import '../l10n/app_localizations.dart';
import '../services/audio_service.dart';

class QuranReaderScreen extends StatefulWidget {
  final Surah surah;
  
  const QuranReaderScreen({super.key, required this.surah});

  @override
  State<QuranReaderScreen> createState() => _QuranReaderScreenState();
}

class _QuranReaderScreenState extends State<QuranReaderScreen> {
  final ScrollController _scrollController = ScrollController();
  bool _isReaderMode = false;
  final Map<int, GlobalKey> _verseKeys = {};
  
  @override
  void initState() {
    super.initState();
    _loadSurahData();
    _setupAudioListener();
  }

  Widget _buildMiniPlayer(AudioService audioService) {
    return StreamBuilder<bool>(
      stream: audioService.playbackStateStream,
      initialData: false,
      builder: (context, playbackSnap) {
        final isPlaying = playbackSnap.data == true;
        if (!isPlaying) {
          return const SizedBox.shrink();
        }
        return StreamBuilder<int?>(
          stream: audioService.currentVerseStream,
          initialData: null,
          builder: (context, verseSnap) {
            return SafeArea(
              top: false,
              child: Material(
                color: Theme.of(context).colorScheme.surface,
                elevation: 8,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(minHeight: 56, maxHeight: 96),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    child: Row(
                  children: [
                    IconButton(
                      icon: Icon(isPlaying ? Icons.pause_circle_filled : Icons.play_circle_fill),
                      onPressed: () async {
                        if (isPlaying) {
                          await audioService.pause();
                        } else {
                          await audioService.resume();
                        }
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.stop_circle),
                      onPressed: () async {
                        audioService.cancelSequential();
                        await audioService.stop();
                      },
                    ),
                    Expanded(
                      child: StreamBuilder<Duration?>(
                        stream: audioService.durationStream,
                        initialData: Duration.zero,
                        builder: (context, durSnap) {
                          final total = durSnap.data ?? Duration.zero;
                          return StreamBuilder<Duration>(
                            stream: audioService.positionStream,
                            initialData: Duration.zero,
                            builder: (context, posSnap) {
                              final pos = posSnap.data ?? Duration.zero;
                              final max = total.inMilliseconds.toDouble().clamp(0.0, double.infinity);
                              final value = pos.inMilliseconds.toDouble().clamp(0.0, max);
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Slider(
                                    min: 0,
                                    max: max > 0 ? max : 1,
                                    value: max > 0 ? value : 0,
                                    onChanged: (v) async {
                                      if (max > 0) {
                                        await audioService.seek(Duration(milliseconds: v.round()));
                                      }
                                    },
                                  ),
                                  if (verseSnap.data != null)
                                    Text(
                                      'Ayah ${verseSnap.data}',
                                      style: Theme.of(context).textTheme.bodySmall,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                ],
                              );
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
  
  Future<void> _playWholeSurah() async {
    final settingsProvider = context.read<SettingsProvider>();
    final audioService = context.read<AudioService>();
    final quranProvider = context.read<QuranProvider>();
    try {
      final reciter = audioService.reciters.firstWhere(
        (r) => r.identifier == settingsProvider.selectedReciter,
        orElse: () => audioService.reciters.first,
      );
      // Ensure verses are loaded
      if (quranProvider.currentVerses.isEmpty) {
        await quranProvider.loadSurahVerses(
          widget.surah.number,
          translationEdition: settingsProvider.showTranslation ? settingsProvider.selectedTranslation : null,
        );
      }
      final verseNumbers = quranProvider.currentVerses
          .map((v) => v.numberInSurah)
          .toList(growable: false);
      if (verseNumbers.isEmpty) return;
      // Fire-and-forget to avoid blocking UI while it plays the whole surah
      // ignore: unawaited_futures
      audioService.playSequentialVerses(widget.surah.number, verseNumbers, reciter);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error playing surah audio: $e')),
        );
      }
    }
  }
  
  void _setupAudioListener() {
    final audioService = context.read<AudioService>();
    audioService.currentVerseStream.listen((currentVerse) {
      if (currentVerse != null && mounted) {
        _scrollToVerse(currentVerse);
      }
    });
  }

  Widget _buildSurahHeader(QuranProvider quranProvider, SettingsProvider settingsProvider) {
    final l10n = AppLocalizations.of(context)!;
    if (widget.surah.number != 1 && widget.surah.number != 9) {
      return Container
        (
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Text(
          l10n.bismillah,
          style: GoogleFonts.amiri(
            fontSize: settingsProvider.arabicFontSize,
            color: settingsProvider.nightMode ? Colors.white : null,
          ),
          textAlign: TextAlign.center,
          textDirection: TextDirection.rtl,
        ),
      );
    }
    return const SizedBox.shrink();
  }
  
  void _scrollToVerse(int verseNumber) {
    final key = _verseKeys[verseNumber];
    if (key?.currentContext != null) {
      Scrollable.ensureVisible(
        key!.currentContext!,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
        alignment: 0.2, // Show verse at 20% from top of screen
      );
    }
  }
  
  void _loadSurahData() {
    final settingsProvider = context.read<SettingsProvider>();
    final quranProvider = context.read<QuranProvider>();
    
    if (settingsProvider.showTranslation) {
      quranProvider.loadSurahVerses(
        widget.surah.number,
        translationEdition: settingsProvider.selectedTranslation,
      );
    } else {
      quranProvider.loadSurahVerses(widget.surah.number);
    }
  }
  
  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final quranProvider = context.watch<QuranProvider>();
    final settingsProvider = context.watch<SettingsProvider>();
    final bookmarkProvider = context.watch<BookmarkProvider>();
    
    final audioService = context.read<AudioService>();
    return Scaffold(
      appBar: _isReaderMode
          ? null
          : AppBar(
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.surah.name,
                    style: GoogleFonts.amiri(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '${widget.surah.englishNameTranslation} • ${widget.surah.numberOfAyahs} ${l10n.verses}',
                  ),
                ],
              ),
              actions: [
                IconButton(
                  icon: Icon(_isReaderMode ? Icons.list : Icons.book),
                  onPressed: () {
                    setState(() {
                      _isReaderMode = !_isReaderMode;
                    });
                  },
                ),
                PopupMenuButton<String>(
                  onSelected: (value) {
                    switch (value) {
                      case 'play_surah':
                        _playWholeSurah();
                        break;
                      case 'font_size':
                        _showFontSizeDialog();
                        break;
                      case 'translation':
                        _showTranslationDialog();
                        break;
                      case 'night_mode':
                        settingsProvider.setNightMode(!settingsProvider.nightMode);
                        break;
                    }
                  },
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      value: 'play_surah',
                      child: Row(
                        children: [
                          const Icon(Icons.play_circle_fill),
                          const SizedBox(width: 8),
                          const Text('Play Surah'),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: 'font_size',
                      child: Row(
                        children: [
                          const Icon(Icons.text_fields),
                          const SizedBox(width: 8),
                          Text(l10n.fontSize),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: 'translation',
                      child: Row(
                        children: [
                          const Icon(Icons.translate),
                          const SizedBox(width: 8),
                          Text(l10n.translation),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: 'night_mode',
                      child: Row(
                        children: [
                          Icon(settingsProvider.nightMode ? Icons.light_mode : Icons.dark_mode),
                          const SizedBox(width: 8),
                          Text(l10n.nightMode),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
      body: quranProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : quranProvider.error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(l10n.error),
                      const SizedBox(height: 8),
                      ElevatedButton(
                        onPressed: _loadSurahData,
                        child: Text(l10n.retry),
                      ),
                    ],
                  ),
                )
              : quranProvider.currentVerses.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const SizedBox(height: 8),
                          Text(l10n.loading),
                          const SizedBox(height: 8),
                          ElevatedButton(
                            onPressed: _loadSurahData,
                            child: Text(l10n.retry),
                          ),
                        ],
                      ),
                    )
              : _isReaderMode 
                  ? _buildReaderModeView(quranProvider, settingsProvider, bookmarkProvider)
                  : Container(
                      color: settingsProvider.nightMode
                          ? Colors.black
                          : Theme.of(context).colorScheme.background,
                      child: ListView.builder(
                        controller: _scrollController,
                        padding: const EdgeInsets.all(16),
                        itemCount: quranProvider.currentVerses.length + 1,
                        itemBuilder: (context, index) {
                          try {
                            if (index == 0) {
                              return _buildSurahHeader(quranProvider, settingsProvider);
                            }
                            final verse = quranProvider.currentVerses[index - 1];
                            _verseKeys[verse.numberInSurah] ??= GlobalKey();
                            return VerseWidget(
                              key: _verseKeys[verse.numberInSurah],
                              verse: verse,
                              surahName: widget.surah.name,
                              onBookmark: () async {
                                try {
                                  final isBookmarked = await bookmarkProvider.isBookmarked(
                                    widget.surah.number,
                                    verse.numberInSurah,
                                  );
                                  if (isBookmarked) {
                                    final bookmark = bookmarkProvider.getBookmark(
                                      widget.surah.number,
                                      verse.numberInSurah,
                                    );
                                    if (bookmark != null) {
                                      await bookmarkProvider.removeBookmark(bookmark.id);
                                      if (mounted) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(content: Text('Bookmark removed')),
                                        );
                                      }
                                    }
                                  } else {
                                    await bookmarkProvider.addBookmark(
                                      surahNumber: widget.surah.number,
                                      verseNumber: verse.numberInSurah,
                                      surahName: widget.surah.name,
                                      verseText: verse.text,
                                      translation: verse.translation,
                                    );
                                    if (mounted) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(content: Text('Bookmark added')),
                                      );
                                    }
                                  }
                                  await bookmarkProvider.loadBookmarks();
                                } catch (e) {
                                  if (mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text('Error with bookmark: $e')),
                                    );
                                  }
                                }
                              },
                              onShare: () {
                                _shareVerse(verse);
                              },
                              onPlayAudio: () {
                                _playVerseAudio(verse);
                              },
                            );
                          } catch (e, st) {
                            debugPrint('Render error in verse item: $e\n$st');
                            return const SizedBox.shrink();
                          }
                        },
                  ),
                ),
      bottomNavigationBar: _buildMiniPlayer(audioService),
    );
  }

  Widget _buildReaderModeView(QuranProvider quranProvider, SettingsProvider settingsProvider, BookmarkProvider bookmarkProvider) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _isReaderMode = false;
        });
      },
      child: Container(
        color: settingsProvider.nightMode ? Colors.black : const Color(0xFFF5F5DC), // Beige background for reading
        child: Stack(
          children: [
            // Main content
            ListView.builder(
              controller: _scrollController,
              padding: EdgeInsets.symmetric(
                horizontal: MediaQuery.of(context).size.width * 0.1, // 10% margin on each side
                vertical: 40,
              ),
              itemCount: quranProvider.currentVerses.length + 1,
              itemBuilder: (context, index) {
                if (index == 0) {
                  // Bismillah for all surahs except At-Tawbah (9) and Al-Fatihah (1)
                  if (widget.surah.number != 1 && widget.surah.number != 9) {
                    return Container(
                      padding: const EdgeInsets.symmetric(vertical: 24),
                      child: Text(
                        AppLocalizations.of(context)!.bismillah,
                        style: GoogleFonts.amiri(
                          fontSize: settingsProvider.arabicFontSize + 4, // Slightly larger in reader mode
                          color: settingsProvider.nightMode ? Colors.white : Colors.black87,
                          height: 1.8,
                        ),
                        textAlign: TextAlign.center,
                        textDirection: TextDirection.rtl,
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                }
                
                final verse = quranProvider.currentVerses[index - 1];
                return Container(
                  margin: const EdgeInsets.only(bottom: 32),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Arabic text
                      Text(
                        verse.text,
                        style: GoogleFonts.amiri(
                          fontSize: settingsProvider.arabicFontSize + 2, // Slightly larger
                          color: settingsProvider.nightMode ? Colors.white : Colors.black87,
                          height: 2.0, // Increased line height for better readability
                        ),
                        textAlign: TextAlign.right,
                        textDirection: TextDirection.rtl,
                      ),
                      
                      // Verse number
                      const SizedBox(height: 12),
                      Text(
                        '﴿${verse.numberInSurah}﴾',
                        style: GoogleFonts.amiri(
                          fontSize: 18,
                          color: settingsProvider.nightMode ? Colors.grey[400] : Colors.grey[600],
                        ),
                        textAlign: TextAlign.center,
                      ),
                      
                      // Translation (if available and enabled)
                      if (verse.translation != null && settingsProvider.showTranslation) ...[
                        const SizedBox(height: 16),
                        Text(
                          verse.translation!,
                          style: TextStyle(
                            fontSize: settingsProvider.translationFontSize + 1, // Slightly larger
                            color: settingsProvider.nightMode ? Colors.grey[300] : Colors.grey[700],
                            height: 1.6,
                          ),
                          textAlign: TextAlign.left,
                        ),
                      ],
                    ],
                  ),
                );
              },
            ),
            
            // Floating controls
            Positioned(
              top: 40,
              right: 20,
              child: Column(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.7),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.fullscreen_exit, color: Colors.white),
                      onPressed: () {
                        setState(() {
                          _isReaderMode = false;
                        });
                      },
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.7),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: IconButton(
                      icon: Icon(
                        settingsProvider.showTranslation ? Icons.translate : Icons.translate_outlined,
                        color: Colors.white,
                      ),
                      onPressed: () {
                        settingsProvider.setShowTranslation(!settingsProvider.showTranslation);
                        _loadSurahData();
                      },
                    ),
                  ),
                ],
              ),
            ),
            
            // Surah title overlay (appears briefly on tap)
            Positioned(
              top: 40,
              left: 20,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.7),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  widget.surah.name,
                  style: GoogleFonts.amiri(
                    fontSize: 16,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  void _playVerseAudio(Verse verse) async {
    final settingsProvider = context.read<SettingsProvider>();
    final audioService = context.read<AudioService>();
    
    try {
      final reciter = audioService.reciters.firstWhere(
        (r) => r.identifier == settingsProvider.selectedReciter,
        orElse: () => audioService.reciters.first,
      );
      
      await audioService.playVerse(
        widget.surah.number,
        verse.numberInSurah,
        reciter,
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error playing verse audio: $e')),
        );
      }
    }
  }
  
  void _shareVerse(Verse verse) {
    final text = '${widget.surah.name} ${verse.numberInSurah}\n\n'
        '${verse.text}\n\n'
        '${verse.translation ?? ''}';
    
    Clipboard.setData(ClipboardData(text: text));
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(AppLocalizations.of(context)!.copied)),
    );
  }
  
  void _showFontSizeDialog() {
    final settingsProvider = context.read<SettingsProvider>();
    final l10n = AppLocalizations.of(context)!;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.fontSize),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(l10n.arabicFontSize),
              Slider(
                value: settingsProvider.arabicFontSize,
                min: 18,
                max: 40,
                divisions: 11,
                label: settingsProvider.arabicFontSize.round().toString(),
                onChanged: (value) {
                  settingsProvider.setArabicFontSize(value);
                },
              ),
              const SizedBox(height: 16),
              Text(l10n.translationFontSize),
              Slider(
                value: settingsProvider.translationFontSize,
                min: 12,
                max: 24,
                divisions: 12,
                label: settingsProvider.translationFontSize.round().toString(),
                onChanged: (value) {
                  settingsProvider.setTranslationFontSize(value);
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel),
          ),
        ],
      ),
    );
  }
  
  void _showTranslationDialog() {
    final settingsProvider = context.read<SettingsProvider>();
    final l10n = AppLocalizations.of(context)!;
    
    final translations = {
      'fr.hamidullah': 'Français - Hamidullah',
      'en.sahih': 'English - Sahih International',
      'en.yusufali': 'English - Yusuf Ali',
      'ur.maududi': 'اردو - مودودی',
    };
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.translation),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SwitchListTile(
                title: Text(l10n.showTranslation),
                value: settingsProvider.showTranslation,
                onChanged: (value) {
                  settingsProvider.setShowTranslation(value);
                  if (value) {
                    _loadSurahData();
                  }
                },
              ),
              if (settingsProvider.showTranslation) ...[
                const Divider(),
                ...translations.entries.map((entry) => RadioListTile<String>(
                  title: Text(entry.value),
                  value: entry.key,
                  groupValue: settingsProvider.selectedTranslation,
                  onChanged: (value) {
                    if (value != null) {
                      settingsProvider.setSelectedTranslation(value);
                      _loadSurahData();
                      Navigator.pop(context);
                    }
                  },
                )),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel),
          ),
        ],
      ),
    );
  }
}