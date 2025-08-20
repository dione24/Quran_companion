import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/surah.dart';

class SurahListTile extends StatelessWidget {
  final Surah surah;
  final VoidCallback onTap;
  
  const SurahListTile({
    super.key,
    required this.surah,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ListTile(
        onTap: onTap,
        leading: Container(
          width: 45,
          height: 45,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Theme.of(context).colorScheme.primaryContainer,
          ),
          child: Center(
            child: Text(
              '${surah.number}',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onPrimaryContainer,
              ),
            ),
          ),
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                surah.englishName,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            Text(
              surah.name,
              style: GoogleFonts.amiri(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
              textDirection: TextDirection.rtl,
            ),
          ],
        ),
        subtitle: Row(
          children: [
            Icon(
              surah.revelationType == 'Meccan' ? Icons.wb_sunny : Icons.location_city,
              size: 14,
            ),
            const SizedBox(width: 4),
            Text(
              surah.revelationType == 'Meccan' ? l10n.makkah : l10n.madinah,
              style: const TextStyle(fontSize: 12),
            ),
            const SizedBox(width: 8),
            Text(
              '${surah.numberOfAyahs} ${l10n.verses}',
              style: const TextStyle(fontSize: 12),
            ),
          ],
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      ),
    );
  }
}