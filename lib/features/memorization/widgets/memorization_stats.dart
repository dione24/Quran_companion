import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers/app_providers.dart';

class MemorizationStats extends ConsumerWidget {
  final Map<String, dynamic> stats;

  const MemorizationStats({
    super.key,
    required this.stats,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final locale = ref.watch(languageProvider);
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      children: [
        _buildOverviewCard(context, locale, isDark),
        const SizedBox(height: 16),
        _buildMasteryBreakdown(context, locale, isDark),
        const SizedBox(height: 16),
        _buildActivityStats(context, locale, isDark),
      ],
    );
  }

  Widget _buildOverviewCard(BuildContext context, String locale, bool isDark) {
    final theme = Theme.of(context);
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              locale == 'fr' ? 'Vue d\'ensemble' : 'Overview',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem(
                  context,
                  value: stats['totalVerses'].toString(),
                  label: locale == 'fr' ? 'Total versets' : 'Total Verses',
                  icon: Icons.book,
                  color: Colors.blue,
                ),
                _buildStatItem(
                  context,
                  value: stats['dueForReview'].toString(),
                  label: locale == 'fr' ? 'À réviser' : 'Due Review',
                  icon: Icons.schedule,
                  color: Colors.orange,
                ),
                _buildStatItem(
                  context,
                  value: stats['averageReviewCount'].toString(),
                  label: locale == 'fr' ? 'Moy. révisions' : 'Avg. Reviews',
                  icon: Icons.repeat,
                  color: Colors.purple,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMasteryBreakdown(BuildContext context, String locale, bool isDark) {
    final theme = Theme.of(context);
    final total = (stats['totalVerses'] as int?) ?? 1;
    final beginner = (stats['beginnerVerses'] as int?) ?? 0;
    final intermediate = (stats['intermediateVerses'] as int?) ?? 0;
    final mastered = (stats['masteredVerses'] as int?) ?? 0;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              locale == 'fr' ? 'Niveaux de maîtrise' : 'Mastery Levels',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildProgressBar(
              label: locale == 'fr' ? 'Débutant' : 'Beginner',
              value: beginner,
              total: total,
              color: Colors.orange,
              isDark: isDark,
            ),
            const SizedBox(height: 12),
            _buildProgressBar(
              label: locale == 'fr' ? 'Intermédiaire' : 'Intermediate',
              value: intermediate,
              total: total,
              color: Colors.blue,
              isDark: isDark,
            ),
            const SizedBox(height: 12),
            _buildProgressBar(
              label: locale == 'fr' ? 'Maîtrisé' : 'Mastered',
              value: mastered,
              total: total,
              color: Colors.green,
              isDark: isDark,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityStats(BuildContext context, String locale, bool isDark) {
    final theme = Theme.of(context);
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              locale == 'fr' ? 'Activité' : 'Activity',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.warning,
                  color: Colors.red,
                  size: 20,
                ),
              ),
              title: Text(
                locale == 'fr' 
                    ? '${stats['dueForReview']} versets en retard'
                    : '${stats['dueForReview']} verses overdue',
              ),
              subtitle: Text(
                locale == 'fr'
                    ? 'Nécessitent une révision immédiate'
                    : 'Need immediate review',
              ),
              contentPadding: EdgeInsets.zero,
            ),
            if (stats['totalVerses'] > 0)
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.trending_up,
                    color: Colors.green,
                    size: 20,
                  ),
                ),
                title: Text(
                  locale == 'fr'
                      ? 'Progression constante'
                      : 'Steady progress',
                ),
                subtitle: Text(
                  locale == 'fr'
                      ? '${stats['averageReviewCount']} révisions en moyenne'
                      : '${stats['averageReviewCount']} reviews on average',
                ),
                contentPadding: EdgeInsets.zero,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(
    BuildContext context, {
    required String value,
    required String label,
    required IconData icon,
    required Color color,
  }) {
    final theme = Theme.of(context);
    
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
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
          style: theme.textTheme.bodySmall,
        ),
      ],
    );
  }

  Widget _buildProgressBar({
    required String label,
    required int value,
    required int total,
    required Color color,
    required bool isDark,
  }) {
    final percentage = total > 0 ? (value / total * 100) : 0.0;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label),
            Text('$value (${percentage.toStringAsFixed(0)}%)'),
          ],
        ),
        const SizedBox(height: 4),
        LinearProgressIndicator(
          value: percentage / 100,
          minHeight: 8,
          borderRadius: BorderRadius.circular(4),
          backgroundColor: isDark 
              ? Colors.grey.shade800 
              : Colors.grey.shade300,
          valueColor: AlwaysStoppedAnimation<Color>(color),
        ),
      ],
    );
  }
}