import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers/app_providers.dart';

class RecentActivity extends ConsumerWidget {
  const RecentActivity({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final locale = ref.watch(languageProvider);
    final progress = ref.watch(readingProgressProvider);
    final memorization = ref.watch(memorizationProgressProvider);
    final quizStats = ref.watch(quizScoreProvider);
    
    final List<ActivityItem> activities = [
      if (progress['lastReadDate'] != null)
        ActivityItem(
          icon: Icons.book,
          titleFr: 'Lecture récente',
          titleEn: 'Recent Reading',
          subtitleFr: 'Sourate ${progress['currentSurah']}, Verset ${progress['currentVerse']}',
          subtitleEn: 'Surah ${progress['currentSurah']}, Verse ${progress['currentVerse']}',
          time: _formatTime(DateTime.parse(progress['lastReadDate'])),
          color: Colors.blue,
        ),
      if (memorization.isNotEmpty)
        ActivityItem(
          icon: Icons.psychology,
          titleFr: 'Mémorisation',
          titleEn: 'Memorization',
          subtitleFr: '${memorization.length} versets en cours',
          subtitleEn: '${memorization.length} verses in progress',
          time: _formatTime(DateTime.now()),
          color: Colors.green,
        ),
      if (quizStats['totalQuizzes'] > 0)
        ActivityItem(
          icon: Icons.quiz,
          titleFr: 'Dernier quiz',
          titleEn: 'Last Quiz',
          subtitleFr: 'Score: ${quizStats['averageScore'].toStringAsFixed(0)}%',
          subtitleEn: 'Score: ${quizStats['averageScore'].toStringAsFixed(0)}%',
          time: _formatTime(DateTime.now()),
          color: Colors.orange,
        ),
    ];

    if (activities.isEmpty) {
      return Card(
        child: Container(
          padding: const EdgeInsets.all(32),
          child: Center(
            child: Column(
              children: [
                Icon(
                  Icons.history,
                  size: 48,
                  color: theme.colorScheme.onSurface.withOpacity(0.3),
                ),
                const SizedBox(height: 16),
                Text(
                  locale == 'fr' 
                      ? 'Aucune activité récente'
                      : 'No recent activity',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.5),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Card(
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: activities.length.clamp(0, 5),
        separatorBuilder: (context, index) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final activity = activities[index];
          return ListTile(
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: activity.color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                activity.icon,
                color: activity.color,
                size: 20,
              ),
            ),
            title: Text(
              locale == 'fr' ? activity.titleFr : activity.titleEn,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
            subtitle: Text(
              locale == 'fr' ? activity.subtitleFr : activity.subtitleEn,
              style: theme.textTheme.bodySmall,
            ),
            trailing: Text(
              activity.time,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.5),
              ),
            ),
            onTap: () {
              // Navigate to relevant screen
            },
          );
        },
      ),
    );
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);

    if (difference.inMinutes < 1) {
      return 'À l\'instant';
    } else if (difference.inMinutes < 60) {
      return 'Il y a ${difference.inMinutes} min';
    } else if (difference.inHours < 24) {
      return 'Il y a ${difference.inHours} h';
    } else if (difference.inDays < 7) {
      return 'Il y a ${difference.inDays} j';
    } else {
      return '${time.day}/${time.month}';
    }
  }
}

class ActivityItem {
  final IconData icon;
  final String titleFr;
  final String titleEn;
  final String subtitleFr;
  final String subtitleEn;
  final String time;
  final Color color;

  ActivityItem({
    required this.icon,
    required this.titleFr,
    required this.titleEn,
    required this.subtitleFr,
    required this.subtitleEn,
    required this.time,
    required this.color,
  });
}