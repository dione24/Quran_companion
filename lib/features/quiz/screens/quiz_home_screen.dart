import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers/app_providers.dart';
import '../../../core/services/quiz_service.dart';
import '../../../core/models/quiz_model.dart';
import '../../../core/localization/app_localizations.dart';
import 'quiz_play_screen.dart';
import '../widgets/quiz_stats_card.dart';
import '../widgets/quiz_category_card.dart';
import '../widgets/quiz_leaderboard.dart';

class QuizHomeScreen extends ConsumerStatefulWidget {
  const QuizHomeScreen({super.key});

  @override
  ConsumerState<QuizHomeScreen> createState() => _QuizHomeScreenState();
}

class _QuizHomeScreenState extends ConsumerState<QuizHomeScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late QuizService _quizService;
  Map<String, dynamic> _stats = {};
  List<QuizResult> _history = [];
  Map<QuizCategory, int> _categoryScores = {};

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _quizService = ref.read(quizServiceProvider);
    _loadData();
  }

  Future<void> _loadData() async {
    final stats = await _quizService.getQuizStats();
    final history = _quizService.getQuizHistory();
    final categoryScores = _quizService.getCategoryScores();
    
    setState(() {
      _stats = stats;
      _history = history;
      _categoryScores = categoryScores;
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final locale = ref.watch(languageProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.quiz),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: locale == 'fr' ? 'Jouer' : 'Play'),
            Tab(text: locale == 'fr' ? 'Statistiques' : 'Statistics'),
            Tab(text: locale == 'fr' ? 'Classement' : 'Leaderboard'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildPlayTab(context),
          _buildStatsTab(context),
          _buildLeaderboardTab(context),
        ],
      ),
    );
  }

  Widget _buildPlayTab(BuildContext context) {
    final theme = Theme.of(context);
    final locale = ref.watch(languageProvider);
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          QuizStatsCard(stats: _stats),
          const SizedBox(height: 24),
          Text(
            locale == 'fr' ? 'Catégories' : 'Categories',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            childAspectRatio: 1.2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            children: [
              QuizCategoryCard(
                category: QuizCategory.surahFacts,
                icon: Icons.book,
                color: Colors.blue,
                titleFr: 'Faits sur les sourates',
                titleEn: 'Surah Facts',
                onTap: () => _startQuiz(QuizCategory.surahFacts),
              ),
              QuizCategoryCard(
                category: QuizCategory.prophets,
                icon: Icons.person,
                color: Colors.green,
                titleFr: 'Prophètes',
                titleEn: 'Prophets',
                onTap: () => _startQuiz(QuizCategory.prophets),
              ),
              QuizCategoryCard(
                category: QuizCategory.islamicHistory,
                icon: Icons.history,
                color: Colors.orange,
                titleFr: 'Histoire islamique',
                titleEn: 'Islamic History',
                onTap: () => _startQuiz(QuizCategory.islamicHistory),
              ),
              QuizCategoryCard(
                category: QuizCategory.general,
                icon: Icons.quiz,
                color: Colors.purple,
                titleFr: 'Général',
                titleEn: 'General',
                onTap: () => _startQuiz(QuizCategory.general),
              ),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => _showQuizSettings(context),
              icon: const Icon(Icons.settings),
              label: Text(
                locale == 'fr' ? 'Quiz personnalisé' : 'Custom Quiz',
              ),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsTab(BuildContext context) {
    final theme = Theme.of(context);
    final locale = ref.watch(languageProvider);
    
    if (_history.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.bar_chart,
              size: 80,
              color: theme.colorScheme.primary.withOpacity(0.3),
            ),
            const SizedBox(height: 16),
            Text(
              locale == 'fr' 
                  ? 'Aucune statistique disponible'
                  : 'No statistics available',
              style: theme.textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              locale == 'fr'
                  ? 'Jouez à des quiz pour voir vos statistiques'
                  : 'Play quizzes to see your statistics',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
          ],
        ),
      );
    }
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStatsSummary(context),
          const SizedBox(height: 24),
          _buildCategoryPerformance(context),
          const SizedBox(height: 24),
          _buildRecentHistory(context),
        ],
      ),
    );
  }

  Widget _buildStatsSummary(BuildContext context) {
    final theme = Theme.of(context);
    final locale = ref.watch(languageProvider);
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              locale == 'fr' ? 'Résumé' : 'Summary',
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
                  value: _stats['totalQuizzes'].toString(),
                  label: locale == 'fr' ? 'Quiz joués' : 'Quizzes Played',
                  icon: Icons.quiz,
                  color: Colors.blue,
                ),
                _buildStatItem(
                  context,
                  value: '${(_stats['averageScore'] ?? 0).toStringAsFixed(0)}%',
                  label: locale == 'fr' ? 'Score moyen' : 'Average Score',
                  icon: Icons.grade,
                  color: Colors.green,
                ),
                _buildStatItem(
                  context,
                  value: _stats['currentStreak'].toString(),
                  label: locale == 'fr' ? 'Série' : 'Streak',
                  icon: Icons.local_fire_department,
                  color: Colors.orange,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryPerformance(BuildContext context) {
    final theme = Theme.of(context);
    final locale = ref.watch(languageProvider);
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              locale == 'fr' ? 'Performance par catégorie' : 'Category Performance',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ..._categoryScores.entries.map((entry) {
              final categoryName = _getCategoryName(entry.key, locale);
              final score = entry.value;
              final maxScore = _history
                  .where((r) => r.category == entry.key)
                  .fold(0, (max, r) => r.score > max ? r.score : max);
              
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(categoryName),
                        Text('$score ${locale == 'fr' ? 'points' : 'points'}'),
                      ],
                    ),
                    const SizedBox(height: 4),
                    LinearProgressIndicator(
                      value: maxScore > 0 ? score / maxScore : 0,
                      minHeight: 8,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ],
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentHistory(BuildContext context) {
    final theme = Theme.of(context);
    final locale = ref.watch(languageProvider);
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              locale == 'fr' ? 'Historique récent' : 'Recent History',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ..._history.take(5).map((result) {
              return ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: _getDifficultyColor(result.difficulty).withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.quiz,
                    color: _getDifficultyColor(result.difficulty),
                    size: 20,
                  ),
                ),
                title: Text(
                  _getCategoryName(result.category, locale),
                ),
                subtitle: Text(
                  '${result.correctAnswers}/${result.totalQuestions} ${locale == 'fr' ? 'correct' : 'correct'}',
                ),
                trailing: Text(
                  '${result.score} pts',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildLeaderboardTab(BuildContext context) {
    return QuizLeaderboard(
      history: _history,
      stats: _stats,
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

  void _startQuiz(QuizCategory category) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => QuizPlayScreen(
          category: category,
          difficulty: QuizDifficulty.medium,
          questionCount: 10,
          isTimedMode: false,
        ),
      ),
    ).then((_) => _loadData());
  }

  void _showQuizSettings(BuildContext context) {
    final locale = ref.read(languageProvider);
    QuizCategory selectedCategory = QuizCategory.general;
    QuizDifficulty selectedDifficulty = QuizDifficulty.medium;
    int questionCount = 10;
    bool isTimedMode = false;
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 16,
            right: 16,
            top: 16,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                locale == 'fr' ? 'Paramètres du quiz' : 'Quiz Settings',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 24),
              // Category selection
              Text(locale == 'fr' ? 'Catégorie' : 'Category'),
              const SizedBox(height: 8),
              DropdownButtonFormField<QuizCategory>(
                value: selectedCategory,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                ),
                items: QuizCategory.values.map((category) {
                  return DropdownMenuItem(
                    value: category,
                    child: Text(_getCategoryName(category, locale)),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedCategory = value!;
                  });
                },
              ),
              const SizedBox(height: 16),
              // Difficulty selection
              Text(locale == 'fr' ? 'Difficulté' : 'Difficulty'),
              const SizedBox(height: 8),
              DropdownButtonFormField<QuizDifficulty>(
                value: selectedDifficulty,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                ),
                items: QuizDifficulty.values.map((difficulty) {
                  return DropdownMenuItem(
                    value: difficulty,
                    child: Text(_getDifficultyName(difficulty, locale)),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedDifficulty = value!;
                  });
                },
              ),
              const SizedBox(height: 16),
              // Question count
              Text(locale == 'fr' ? 'Nombre de questions' : 'Number of Questions'),
              const SizedBox(height: 8),
              Slider(
                value: questionCount.toDouble(),
                min: 5,
                max: 20,
                divisions: 3,
                label: questionCount.toString(),
                onChanged: (value) {
                  setState(() {
                    questionCount = value.toInt();
                  });
                },
              ),
              Center(
                child: Text(
                  '$questionCount ${locale == 'fr' ? 'questions' : 'questions'}',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              const SizedBox(height: 16),
              // Timed mode
              SwitchListTile(
                title: Text(locale == 'fr' ? 'Mode chronométré' : 'Timed Mode'),
                subtitle: Text(
                  locale == 'fr' 
                      ? '30 secondes par question'
                      : '30 seconds per question',
                ),
                value: isTimedMode,
                onChanged: (value) {
                  setState(() {
                    isTimedMode = value;
                  });
                },
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => QuizPlayScreen(
                          category: selectedCategory,
                          difficulty: selectedDifficulty,
                          questionCount: questionCount,
                          isTimedMode: isTimedMode,
                        ),
                      ),
                    ).then((_) => _loadData());
                  },
                  child: Text(locale == 'fr' ? 'Commencer' : 'Start'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  String _getCategoryName(QuizCategory category, String locale) {
    switch (category) {
      case QuizCategory.surahFacts:
        return locale == 'fr' ? 'Faits sur les sourates' : 'Surah Facts';
      case QuizCategory.prophets:
        return locale == 'fr' ? 'Prophètes' : 'Prophets';
      case QuizCategory.islamicHistory:
        return locale == 'fr' ? 'Histoire islamique' : 'Islamic History';
      case QuizCategory.general:
        return locale == 'fr' ? 'Général' : 'General';
    }
  }

  String _getDifficultyName(QuizDifficulty difficulty, String locale) {
    switch (difficulty) {
      case QuizDifficulty.easy:
        return locale == 'fr' ? 'Facile' : 'Easy';
      case QuizDifficulty.medium:
        return locale == 'fr' ? 'Moyen' : 'Medium';
      case QuizDifficulty.hard:
        return locale == 'fr' ? 'Difficile' : 'Hard';
    }
  }

  Color _getDifficultyColor(QuizDifficulty difficulty) {
    switch (difficulty) {
      case QuizDifficulty.easy:
        return Colors.green;
      case QuizDifficulty.medium:
        return Colors.orange;
      case QuizDifficulty.hard:
        return Colors.red;
    }
  }
}