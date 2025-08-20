import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/models/memorization_model.dart';
import '../../../core/providers/app_providers.dart';

class MemorizationCard extends ConsumerWidget {
  final MemorizationVerse verse;
  final VoidCallback onTap;
  final VoidCallback onDelete;
  final bool showDueDate;

  const MemorizationCard({
    super.key,
    required this.verse,
    required this.onTap,
    required this.onDelete,
    this.showDueDate = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final locale = ref.watch(languageProvider);
    final isDark = theme.brightness == Brightness.dark;

    Color getMasteryColor() {
      switch (verse.masteryLevel) {
        case MasteryLevel.beginner:
          return Colors.orange;
        case MasteryLevel.intermediate:
          return Colors.blue;
        case MasteryLevel.mastered:
          return Colors.green;
      }
    }

    String getMasteryText() {
      switch (verse.masteryLevel) {
        case MasteryLevel.beginner:
          return locale == 'fr' ? 'Débutant' : 'Beginner';
        case MasteryLevel.intermediate:
          return locale == 'fr' ? 'Intermédiaire' : 'Intermediate';
        case MasteryLevel.mastered:
          return locale == 'fr' ? 'Maîtrisé' : 'Mastered';
      }
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${verse.surahName} - ${locale == 'fr' ? 'Verset' : 'Verse'} ${verse.verseNumber}',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: getMasteryColor().withOpacity(0.2),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            getMasteryText(),
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: getMasteryColor(),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  PopupMenuButton<String>(
                    onSelected: (value) {
                      if (value == 'delete') {
                        onDelete();
                      }
                    },
                    itemBuilder: (context) => [
                      PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            const Icon(Icons.delete, size: 20),
                            const SizedBox(width: 8),
                            Text(locale == 'fr' ? 'Supprimer' : 'Delete'),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isDark
                      ? Colors.grey.shade900
                      : Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  verse.arabicText,
                  style: TextStyle(
                    fontSize: 18,
                    fontFamily: 'Amiri',
                    height: 1.5,
                    color: theme.colorScheme.onSurface,
                  ),
                  textDirection: TextDirection.rtl,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                verse.translation,
                style: theme.textTheme.bodyMedium,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(
                    Icons.repeat,
                    size: 16,
                    color: theme.colorScheme.onSurface.withOpacity(0.6),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${verse.reviewCount} ${locale == 'fr' ? 'révisions' : 'reviews'}',
                    style: theme.textTheme.bodySmall,
                  ),
                  const SizedBox(width: 16),
                  Icon(
                    Icons.check_circle,
                    size: 16,
                    color: theme.colorScheme.onSurface.withOpacity(0.6),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${verse.accuracy.toStringAsFixed(0)}%',
                    style: theme.textTheme.bodySmall,
                  ),
                  if (showDueDate) ...[
                    const Spacer(),
                    Icon(
                      Icons.schedule,
                      size: 16,
                      color: Colors.red.shade400,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      _formatDueDate(verse.nextReviewDate, locale),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.red.shade400,
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDueDate(DateTime date, String locale) {
    final now = DateTime.now();
    final difference = date.difference(now);
    
    if (difference.inDays > 0) {
      return locale == 'fr' 
          ? 'Dans ${difference.inDays} jours'
          : 'In ${difference.inDays} days';
    } else if (difference.inHours > 0) {
      return locale == 'fr'
          ? 'Dans ${difference.inHours} heures'
          : 'In ${difference.inHours} hours';
    } else {
      return locale == 'fr' ? 'En retard' : 'Overdue';
    }
  }
}