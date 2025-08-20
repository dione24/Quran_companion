import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../l10n/app_localizations.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/verse.dart';
import '../providers/settings_provider.dart';
import '../providers/bookmark_provider.dart';
import '../services/audio_service.dart';

class VerseWidget extends StatelessWidget {
  final Verse verse;
  final String surahName;
  final VoidCallback? onBookmark;
  final VoidCallback? onShare;
  final VoidCallback? onPlayAudio;
  
  const VerseWidget({
    super.key,
    required this.verse,
    required this.surahName,
    this.onBookmark,
    this.onShare,
    this.onPlayAudio,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final settingsProvider = context.watch<SettingsProvider>();
    
    return Consumer<BookmarkProvider>(
      builder: (context, bookmarkProvider, child) {
        final isBookmarked = bookmarkProvider.bookmarks.any((b) => 
          b.surahNumber == verse.surahNumber && b.verseNumber == verse.numberInSurah
        );
        
        return StreamBuilder<int?>(
              stream: context.read<AudioService>().currentVerseStream,
              builder: (context, audioSnapshot) {
                final isCurrentlyPlaying = audioSnapshot.data == verse.numberInSurah;
                
                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  elevation: isCurrentlyPlaying ? 8 : 1,
                  color: isCurrentlyPlaying 
                      ? Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.3)
                      : (settingsProvider.nightMode ? Colors.grey[900] : null),
                  child: Container(
                    decoration: isCurrentlyPlaying 
                        ? BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Theme.of(context).colorScheme.primary,
                              width: 2,
                            ),
                          )
                        : null,
                    child: InkWell(
                      onTap: () {
                        // Show verse options modal
                        showModalBottomSheet(
                          context: context,
                          builder: (BuildContext modalContext) => Container(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                ListTile(
                                  leading: Icon(
                                    isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                                  ),
                                  title: Text(isBookmarked ? l10n.removeBookmark : l10n.bookmark),
                                  onTap: () {
                                    Navigator.pop(modalContext);
                                    onBookmark?.call();
                                  },
                                ),
                                ListTile(
                                  leading: const Icon(Icons.copy),
                                  title: Text(l10n.copyVerse),
                                  onTap: () {
                                    final text = '$surahName ${verse.numberInSurah}\n\n'
                                        '${verse.text}\n\n'
                                        '${verse.translation ?? ''}';
                                    Clipboard.setData(ClipboardData(text: text));
                                    Navigator.pop(modalContext);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text(l10n.copied)),
                                    );
                                  },
                                ),
                                ListTile(
                                  leading: const Icon(Icons.share),
                                  title: Text(l10n.shareVerse),
                                  onTap: () {
                                    Navigator.pop(modalContext);
                                    onShare?.call();
                                  },
                                ),
                                ListTile(
                                  leading: const Icon(Icons.play_arrow),
                                  title: Text(l10n.play),
                                  onTap: () {
                                    Navigator.pop(modalContext);
                                    onPlayAudio?.call();
                                  },
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                      borderRadius: BorderRadius.circular(12),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // Verse number and actions
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: isCurrentlyPlaying 
                                        ? Theme.of(context).colorScheme.primary
                                        : Theme.of(context).colorScheme.primaryContainer,
                                  ),
                                  child: Text(
                                    '${verse.numberInSurah}',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: isCurrentlyPlaying 
                                          ? Colors.white
                                          : Theme.of(context).colorScheme.onPrimaryContainer,
                                    ),
                                  ),
                                ),
                                Row(
                                  children: [
                                    IconButton(
                                      icon: Icon(
                                        isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                                        color: isBookmarked ? Theme.of(context).colorScheme.primary : null,
                                      ),
                                      onPressed: onBookmark,
                                    ),
                                    IconButton(
                                      icon: Icon(
                                        isCurrentlyPlaying ? Icons.volume_up : Icons.play_arrow,
                                        color: isCurrentlyPlaying ? Theme.of(context).colorScheme.primary : null,
                                      ),
                                      onPressed: onPlayAudio,
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.share),
                                      onPressed: onShare,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            
                            const SizedBox(height: 12),
                            
                            // Arabic text
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              padding: isCurrentlyPlaying 
                                  ? const EdgeInsets.all(8) 
                                  : EdgeInsets.zero,
                              decoration: isCurrentlyPlaying 
                                  ? BoxDecoration(
                                      color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(8),
                                    )
                                  : null,
                              child: Text(
                                verse.text,
                                style: GoogleFonts.amiri(
                                  fontSize: isCurrentlyPlaying 
                                      ? settingsProvider.arabicFontSize + 2
                                      : settingsProvider.arabicFontSize,
                                  height: 1.8,
                                  fontWeight: isCurrentlyPlaying ? FontWeight.w600 : FontWeight.normal,
                                  color: isCurrentlyPlaying 
                                      ? Theme.of(context).colorScheme.primary
                                      : (settingsProvider.nightMode ? Colors.white : null),
                                ),
                                textDirection: TextDirection.rtl,
                                textAlign: TextAlign.right,
                              ),
                            ),
                            
                            // Translation
                            if (settingsProvider.showTranslation && verse.translation != null) ...[
                              const SizedBox(height: 16),
                              const Divider(),
                              const SizedBox(height: 8),
                              Text(
                                verse.translation!,
                                style: TextStyle(
                                  fontSize: settingsProvider.translationFontSize,
                                  color: settingsProvider.nightMode 
                                      ? Colors.grey[300] 
                                      : Theme.of(context).textTheme.bodyMedium?.color,
                                ),
                              ),
                            ],
                            
                            // Tafsir
                            if (verse.tafsir != null && verse.tafsir!.isNotEmpty) ...[
                              const SizedBox(height: 12),
                              ExpansionTile(
                                title: Text(l10n.tafsir),
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text(
                                      verse.tafsir!,
                                      style: Theme.of(context).textTheme.bodySmall,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                            
                            // Sajda indicator
                            if (verse.sajda) ...[
                              const SizedBox(height: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Theme.of(context).colorScheme.tertiaryContainer,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.mosque,
                                      size: 16,
                                      color: Theme.of(context).colorScheme.onTertiaryContainer,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      'Sajda',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Theme.of(context).colorScheme.onTertiaryContainer,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
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
}