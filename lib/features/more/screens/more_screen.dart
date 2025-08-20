import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers/app_providers.dart';
import '../../settings/screens/settings_screen.dart';
import '../../prayer/screens/prayer_times_screen.dart';
import '../../memorization/screens/memorization_screen.dart';
import '../../quiz/screens/quiz_home_screen.dart';

class MoreScreen extends ConsumerWidget {
  const MoreScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final locale = ref.watch(languageProvider);

    final menuItems = [
      MenuItemData(
        icon: Icons.access_time,
        titleFr: 'Heures de prière',
        titleEn: 'Prayer Times',
        screen: const PrayerTimesScreen(),
      ),
      MenuItemData(
        icon: Icons.explore,
        titleFr: 'Qibla',
        titleEn: 'Qibla',
        screen: null, // Placeholder
      ),
      MenuItemData(
        icon: Icons.mosque,
        titleFr: 'Mosquées',
        titleEn: 'Mosques',
        screen: null, // Placeholder
      ),
      MenuItemData(
        icon: Icons.psychology,
        titleFr: 'Mémorisation',
        titleEn: 'Memorization',
        screen: const MemorizationScreen(),
      ),
      MenuItemData(
        icon: Icons.quiz,
        titleFr: 'Quiz',
        titleEn: 'Quiz',
        screen: const QuizHomeScreen(),
      ),
      MenuItemData(
        icon: Icons.download,
        titleFr: 'Téléchargements',
        titleEn: 'Downloads',
        screen: null, // Placeholder
      ),
      MenuItemData(
        icon: Icons.widgets,
        titleFr: 'Widget',
        titleEn: 'Widget',
        screen: null, // Placeholder
      ),
      MenuItemData(
        icon: Icons.settings,
        titleFr: 'Paramètres',
        titleEn: 'Settings',
        screen: const SettingsScreen(),
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(locale == 'fr' ? 'Plus' : 'More'),
      ),
      body: ListView.separated(
        itemCount: menuItems.length,
        separatorBuilder: (context, index) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final item = menuItems[index];
          return ListTile(
            leading: Icon(item.icon, color: theme.colorScheme.primary),
            title: Text(locale == 'fr' ? item.titleFr : item.titleEn),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              if (item.screen != null) {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => item.screen!),
                );
              }
            },
          );
        },
      ),
    );
  }
}

class MenuItemData {
  final IconData icon;
  final String titleFr;
  final String titleEn;
  final Widget? screen;

  MenuItemData({
    required this.icon,
    required this.titleFr,
    required this.titleEn,
    this.screen,
  });
}