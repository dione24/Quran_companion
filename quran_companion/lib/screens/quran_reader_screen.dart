import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/surah.dart';
import '../models/verse.dart';
import '../providers/quran_provider.dart';
import '../providers/settings_provider.dart';
import '../providers/bookmark_provider.dart';
import '../services/audio_service.dart';
import '../widgets/verse_widget.dart';

class QuranReaderScreen extends StatefulWidget {
  final Surah surah;
  
  const QuranReaderScreen({super.key, required this.surah});

  @override
  State<QuranReaderScreen> createState() => _QuranReaderScreenState();
}

class _QuranReaderScreenState extends State<QuranReaderScreen> {
  final AudioService _audioService = AudioService();
  final ScrollController _scrollController = ScrollController();
  bool _isPlaying = false;
  
  @override
  void initState() {
    super.initState();
    _loadSurahData();
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
    _audioService.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final quranProvider = context.watch<QuranProvider>();
    final settingsProvider = context.watch<SettingsProvider>();
    final bookmarkProvider = context.watch<BookmarkProvider>();
    
    return Scaffold(
      appBar: AppBar(
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
              style: const TextStyle(fontSize: 12),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(_isPlaying ? Icons.pause : Icons.play_arrow),
            onPressed: _toggleAudioPlayback,
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              switch (value) {
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
              : Container(
                  color: settingsProvider.nightMode ? Colors.black : null,
                  child: ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(16),
                    itemCount: quranProvider.currentVerses.length + 1,
                    itemBuilder: (context, index) {
                      if (index == 0) {
                        // Bismillah for all surahs except At-Tawbah (9) and Al-Fatihah (1)
                        if (widget.surah.number != 1 && widget.surah.number != 9) {
                          return Container(
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
                      
                      final verse = quranProvider.currentVerses[index - 1];
                      return VerseWidget(
                        verse: verse,
                        surahName: widget.surah.name,
                        onBookmark: () async {
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
                            }
                          } else {
                            await bookmarkProvider.addBookmark(
                              surahNumber: widget.surah.number,
                              verseNumber: verse.numberInSurah,
                              surahName: widget.surah.name,
                              verseText: verse.text,
                              translation: verse.translation,
                            );
                          }
                        },
                        onShare: () {
                          _shareVerse(verse);
                        },
                        onPlayAudio: () {
                          _playVerseAudio(verse);
                        },
                      );
                    },
                  ),
                ),
    );
  }
  
  void _toggleAudioPlayback() async {
    final settingsProvider = context.read<SettingsProvider>();
    
    if (_isPlaying) {
      await _audioService.pause();
      setState(() {
        _isPlaying = false;
      });
    } else {
      try {
        final reciter = _audioService.reciters.firstWhere(
          (r) => r.identifier == settingsProvider.selectedReciter,
          orElse: () => _audioService.reciters.first,
        );
        
        await _audioService.playSurah(widget.surah.number, reciter);
        setState(() {
          _isPlaying = true;
        });
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error playing audio: $e')),
          );
        }
      }
    }
  }
  
  void _playVerseAudio(Verse verse) async {
    final settingsProvider = context.read<SettingsProvider>();
    
    try {
      final reciter = _audioService.reciters.firstWhere(
        (r) => r.identifier == settingsProvider.selectedReciter,
        orElse: () => _audioService.reciters.first,
      );
      
      await _audioService.playVerse(
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
        content: Column(
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
        content: Column(
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