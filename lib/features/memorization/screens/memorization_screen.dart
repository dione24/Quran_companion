import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers/app_providers.dart';
import '../../../core/services/memorization_service.dart';
import '../../../core/models/memorization_model.dart';
import '../../../core/localization/app_localizations.dart';
import '../widgets/memorization_card.dart';
import '../widgets/memorization_stats.dart';
import 'memorization_practice_screen.dart';
import 'add_memorization_screen.dart';

class MemorizationScreen extends ConsumerStatefulWidget {
  const MemorizationScreen({super.key});

  @override
  ConsumerState<MemorizationScreen> createState() => _MemorizationScreenState();
}

class _MemorizationScreenState extends ConsumerState<MemorizationScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late MemorizationService _memorizationService;
  List<MemorizationVerse> _allVerses = [];
  List<MemorizationVerse> _dueForReview = [];
  Map<String, dynamic> _stats = {};

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _memorizationService = ref.read(memorizationServiceProvider);
    _loadData();
  }

  Future<void> _loadData() async {
    await _memorizationService.init();
    setState(() {
      _allVerses = _memorizationService.getAllMemorizedVerses();
      _dueForReview = _memorizationService.getVersesForReview();
      _stats = _memorizationService.getMemorizationStats();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final locale = ref.watch(languageProvider);
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.memorization),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: locale == 'fr' ? 'En cours' : 'In Progress'),
            Tab(text: locale == 'fr' ? 'À réviser' : 'To Review'),
            Tab(text: locale == 'fr' ? 'Statistiques' : 'Statistics'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AddMemorizationScreen(),
                ),
              );
              if (result == true) {
                _loadData();
              }
            },
          ),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // In Progress Tab
          _buildInProgressTab(context),
          // To Review Tab
          _buildToReviewTab(context),
          // Statistics Tab
          _buildStatisticsTab(context),
        ],
      ),
      floatingActionButton: _dueForReview.isNotEmpty
          ? FloatingActionButton.extended(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MemorizationPracticeScreen(
                      verses: _dueForReview,
                    ),
                  ),
                ).then((_) => _loadData());
              },
              icon: const Icon(Icons.play_arrow),
              label: Text(
                locale == 'fr' 
                    ? 'Commencer la révision (${_dueForReview.length})'
                    : 'Start Review (${_dueForReview.length})',
              ),
            )
          : null,
    );
  }

  Widget _buildInProgressTab(BuildContext context) {
    final inProgressVerses = _allVerses
        .where((v) => v.masteryLevel != MasteryLevel.mastered)
        .toList();

    if (inProgressVerses.isEmpty) {
      return _buildEmptyState(
        context,
        icon: Icons.book_outlined,
        title: ref.watch(languageProvider) == 'fr' 
            ? 'Aucun verset en cours'
            : 'No verses in progress',
        subtitle: ref.watch(languageProvider) == 'fr'
            ? 'Ajoutez des versets à mémoriser'
            : 'Add verses to memorize',
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: inProgressVerses.length,
      itemBuilder: (context, index) {
        final verse = inProgressVerses[index];
        return MemorizationCard(
          verse: verse,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => MemorizationPracticeScreen(
                  verses: [verse],
                ),
              ),
            ).then((_) => _loadData());
          },
          onDelete: () async {
            await _memorizationService.removeVerse(verse.id);
            _loadData();
          },
        );
      },
    );
  }

  Widget _buildToReviewTab(BuildContext context) {
    if (_dueForReview.isEmpty) {
      return _buildEmptyState(
        context,
        icon: Icons.check_circle_outline,
        title: ref.watch(languageProvider) == 'fr'
            ? 'Aucune révision en attente'
            : 'No reviews pending',
        subtitle: ref.watch(languageProvider) == 'fr'
            ? 'Toutes les révisions sont à jour'
            : 'All reviews are up to date',
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _dueForReview.length,
      itemBuilder: (context, index) {
        final verse = _dueForReview[index];
        return MemorizationCard(
          verse: verse,
          showDueDate: true,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => MemorizationPracticeScreen(
                  verses: [verse],
                ),
              ),
            ).then((_) => _loadData());
          },
          onDelete: () async {
            await _memorizationService.removeVerse(verse.id);
            _loadData();
          },
        );
      },
    );
  }

  Widget _buildStatisticsTab(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: MemorizationStats(stats: _stats),
    );
  }

  Widget _buildEmptyState(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    final theme = Theme.of(context);
    
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 80,
            color: theme.colorScheme.primary.withOpacity(0.3),
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: theme.textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
        ],
      ),
    );
  }
}