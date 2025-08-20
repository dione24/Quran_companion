import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers/app_providers.dart';

class QuickActionsGrid extends ConsumerWidget {
  final Function(String) onActionTap;

  const QuickActionsGrid({
    super.key,
    required this.onActionTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final locale = ref.watch(languageProvider);
    final isDark = theme.brightness == Brightness.dark;

    final actions = [
      QuickAction(
        id: 'read',
        iconData: Icons.menu_book,
        labelFr: 'Lire',
        labelEn: 'Read',
        color: Colors.blue,
      ),
      QuickAction(
        id: 'memorize',
        iconData: Icons.psychology,
        labelFr: 'Mémoriser',
        labelEn: 'Memorize',
        color: Colors.green,
      ),
      QuickAction(
        id: 'quiz',
        iconData: Icons.quiz,
        labelFr: 'Quiz',
        labelEn: 'Quiz',
        color: Colors.orange,
      ),
      QuickAction(
        id: 'prayer',
        iconData: Icons.access_time,
        labelFr: 'Prières',
        labelEn: 'Prayers',
        color: Colors.purple,
      ),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        childAspectRatio: 0.85,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: actions.length,
      itemBuilder: (context, index) {
        final action = actions[index];
        return _QuickActionItem(
          action: action,
          locale: locale,
          isDark: isDark,
          onTap: () => onActionTap(action.id),
        );
      },
    );
  }
}

class _QuickActionItem extends StatelessWidget {
  final QuickAction action;
  final String locale;
  final bool isDark;
  final VoidCallback onTap;

  const _QuickActionItem({
    required this.action,
    required this.locale,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: BoxDecoration(
          color: action.color.withOpacity(isDark ? 0.15 : 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: action.color.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              action.iconData,
              color: action.color,
              size: 28,
            ),
            const SizedBox(height: 8),
            Text(
              locale == 'fr' ? action.labelFr : action.labelEn,
              style: theme.textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

class QuickAction {
  final String id;
  final IconData iconData;
  final String labelFr;
  final String labelEn;
  final Color color;

  QuickAction({
    required this.id,
    required this.iconData,
    required this.labelFr,
    required this.labelEn,
    required this.color,
  });
}