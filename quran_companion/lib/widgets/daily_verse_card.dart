import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/verse.dart';

class DailyVerseCard extends StatelessWidget {
  final Verse verse;
  
  const DailyVerseCard({super.key, required this.verse});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    return Card(
      elevation: 4,
      child: InkWell(
        onTap: () {
          // Navigate to the verse in reader
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Theme.of(context).colorScheme.primaryContainer,
                Theme.of(context).colorScheme.secondaryContainer,
              ],
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    l10n.dailyVerse,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.share),
                    onPressed: () {
                      final text = '${verse.verseKey}\n\n${verse.text}';
                      Clipboard.setData(ClipboardData(text: text));
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(l10n.copied)),
                      );
                    },
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                verse.text,
                style: GoogleFonts.amiri(
                  fontSize: 20,
                  height: 1.8,
                ),
                textDirection: TextDirection.rtl,
                textAlign: TextAlign.right,
              ),
              const SizedBox(height: 8),
              Text(
                '${l10n.surah} ${verse.surahNumber}, ${l10n.verse} ${verse.numberInSurah}',
                style: Theme.of(context).textTheme.labelMedium,
              ),
            ],
          ),
        ),
      ),
    );
  }
}