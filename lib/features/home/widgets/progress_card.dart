import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers/app_providers.dart';
import '../../../core/services/share_service.dart';

class ProgressCard extends ConsumerWidget {
  const ProgressCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final locale = ref.watch(languageProvider);
    final progress = ref.watch(readingProgressProvider);
    final memorization = ref.watch(memorizationProgressProvider);
    final isDark = theme.brightness == Brightness.dark;

    final streak = progress['streak'] ?? 0;
    final totalRead = progress['totalRead'] ?? 0;
    final completionPercentage = (totalRead / 6236 * 100).clamp(0, 100);
    final versesMemorized = memorization.length;

    return Card(
      elevation: 2,
      child: InkWell(
        onTap: () {
          // Navigate to detailed progress
        },
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    locale == 'fr' ? 'Votre Progrès' : 'Your Progress',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.share, size: 20),
                    onPressed: () async {
                      final shareService = ref.read(shareServiceProvider);
                      await shareService.shareProgressCard(
                        context: context,
                        readingStreak: streak,
                        completionPercentage: completionPercentage.toDouble(),
                        versesMemorized: versesMemorized,
                        language: locale,
                      );
                    },
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildStatItem(
                    context,
                    icon: Icons.local_fire_department,
                    value: streak.toString(),
                    label: locale == 'fr' ? 'Jours' : 'Days',
                    color: Colors.orange,
                  ),
                  _buildStatItem(
                    context,
                    icon: Icons.book,
                    value: totalRead.toString(),
                    label: locale == 'fr' ? 'Versets lus' : 'Verses Read',
                    color: Colors.blue,
                  ),
                  _buildStatItem(
                    context,
                    icon: Icons.psychology,
                    value: versesMemorized.toString(),
                    label: locale == 'fr' ? 'Mémorisés' : 'Memorized',
                    color: Colors.green,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        locale == 'fr' ? 'Achèvement' : 'Completion',
                        style: theme.textTheme.bodySmall,
                      ),
                      Text(
                        '${completionPercentage.toStringAsFixed(1)}%',
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  LinearProgressIndicator(
                    value: completionPercentage / 100,
                    minHeight: 8,
                    borderRadius: BorderRadius.circular(4),
                    backgroundColor: isDark 
                        ? Colors.grey.shade800 
                        : Colors.grey.shade300,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Colors.teal.shade400,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatItem(
    BuildContext context, {
    required IconData icon,
    required String value,
    required String label,
    required Color color,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withOpacity(isDark ? 0.2 : 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: color,
            size: 24,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurface.withOpacity(0.6),
          ),
        ),
      ],
    );
  }
}