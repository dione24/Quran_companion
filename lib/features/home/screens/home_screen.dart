import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers/app_providers.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/theme/app_theme.dart';
import '../widgets/daily_verse_card.dart';
import '../widgets/quick_actions_grid.dart';
import '../widgets/progress_card.dart';
import '../widgets/recent_activity.dart';
import '../../quran/screens/quran_reader_screen.dart';
import '../../search/screens/search_screen.dart';
import '../../bookmarks/screens/bookmarks_screen.dart';
import '../../settings/screens/settings_screen.dart';
import '../../memorization/screens/memorization_screen.dart';
import '../../quiz/screens/quiz_home_screen.dart';
import '../../prayer/screens/prayer_times_screen.dart';
import '../../more/screens/more_screen.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _selectedIndex = 0;
  
  late final List<Widget> _screens;
  
  @override
  void initState() {
    super.initState();
    _screens = [
      const HomeTab(),
      const QuranReaderScreen(),
      const SearchScreen(),
      const BookmarksScreen(),
      const MoreScreen(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _screens,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.home_outlined),
            selectedIcon: const Icon(Icons.home),
            label: l10n.home,
          ),
          NavigationDestination(
            icon: const Icon(Icons.menu_book_outlined),
            selectedIcon: const Icon(Icons.menu_book),
            label: l10n.quranReader,
          ),
          NavigationDestination(
            icon: const Icon(Icons.search_outlined),
            selectedIcon: const Icon(Icons.search),
            label: l10n.search,
          ),
          NavigationDestination(
            icon: const Icon(Icons.bookmark_outline),
            selectedIcon: const Icon(Icons.bookmark),
            label: l10n.bookmarks,
          ),
          NavigationDestination(
            icon: const Icon(Icons.more_horiz_outlined),
            selectedIcon: const Icon(Icons.more_horiz),
            label: ref.watch(languageProvider) == 'fr' ? 'Plus' : 'More',
          ),
        ],
      ),
    );
  }
}

class HomeTab extends ConsumerWidget {
  const HomeTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final locale = ref.watch(languageProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.appTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {
              // Navigate to notifications
            },
          ),
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const SettingsScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          // Refresh data
          await Future.delayed(const Duration(seconds: 1));
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Greeting
                Text(
                  _getGreeting(locale),
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _getSubGreeting(locale),
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.7),
                  ),
                ),
                const SizedBox(height: 24),
                
                // Daily Verse Card
                const DailyVerseCard(),
                const SizedBox(height: 24),
                
                // Progress Card
                const ProgressCard(),
                const SizedBox(height: 24),
                
                // Quick Actions
                Text(
                  locale == 'fr' ? 'Actions rapides' : 'Quick Actions',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                QuickActionsGrid(
                  onActionTap: (action) {
                    _handleQuickAction(context, action);
                  },
                ),
                const SizedBox(height: 24),
                
                // Recent Activity
                Text(
                  locale == 'fr' ? 'Activité récente' : 'Recent Activity',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                const RecentActivity(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _getGreeting(String locale) {
    final hour = DateTime.now().hour;
    
    if (locale == 'fr') {
      if (hour < 12) return 'Bonjour';
      if (hour < 18) return 'Bon après-midi';
      return 'Bonsoir';
    } else {
      if (hour < 12) return 'Good Morning';
      if (hour < 18) return 'Good Afternoon';
      return 'Good Evening';
    }
  }

  String _getSubGreeting(String locale) {
    if (locale == 'fr') {
      return 'Que la paix soit avec vous';
    } else {
      return 'Peace be upon you';
    }
  }

  void _handleQuickAction(BuildContext context, String action) {
    switch (action) {
      case 'read':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const QuranReaderScreen()),
        );
        break;
      case 'memorize':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const MemorizationScreen()),
        );
        break;
      case 'quiz':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const QuizHomeScreen()),
        );
        break;
      case 'prayer':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const PrayerTimesScreen()),
        );
        break;
    }
  }
}