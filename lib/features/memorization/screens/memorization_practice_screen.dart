import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/models/memorization_model.dart';
import '../../../core/providers/app_providers.dart';
import '../../../core/services/memorization_service.dart';
import '../../../core/services/audio_service.dart';
import '../../../core/theme/app_theme.dart';

class MemorizationPracticeScreen extends ConsumerStatefulWidget {
  final List<MemorizationVerse> verses;

  const MemorizationPracticeScreen({
    super.key,
    required this.verses,
  });

  @override
  ConsumerState<MemorizationPracticeScreen> createState() =>
      _MemorizationPracticeScreenState();
}

class _MemorizationPracticeScreenState
    extends ConsumerState<MemorizationPracticeScreen> {
  int _currentIndex = 0;
  bool _isTextHidden = false;
  bool _showTranslation = true;
  int _correctCount = 0;
  int _incorrectCount = 0;
  late AudioService _audioService;
  late MemorizationService _memorizationService;

  @override
  void initState() {
    super.initState();
    _audioService = ref.read(audioServiceProvider);
    _memorizationService = ref.read(memorizationServiceProvider);
  }

  MemorizationVerse get currentVerse => widget.verses[_currentIndex];

  void _toggleTextVisibility() {
    setState(() {
      _isTextHidden = !_isTextHidden;
    });
  }

  void _toggleTranslation() {
    setState(() {
      _showTranslation = !_showTranslation;
    });
  }

  Future<void> _playVerse() async {
    await _audioService.playVerse(
      currentVerse.surahNumber,
      currentVerse.verseNumber,
    );
  }

  void _markCorrect() {
    setState(() {
      _correctCount++;
      currentVerse.correctCount++;
    });
    _nextVerse();
  }

  void _markIncorrect() {
    setState(() {
      _incorrectCount++;
      currentVerse.incorrectCount++;
    });
    _nextVerse();
  }

  void _nextVerse() {
    if (_currentIndex < widget.verses.length - 1) {
      setState(() {
        _currentIndex++;
        _isTextHidden = false;
      });
    } else {
      _showCompletionDialog();
    }
  }

  void _previousVerse() {
    if (_currentIndex > 0) {
      setState(() {
        _currentIndex--;
        _isTextHidden = false;
      });
    }
  }

  Future<void> _updateMastery(MasteryLevel level) async {
    await _memorizationService.updateVerseMastery(currentVerse.id, level);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          ref.read(languageProvider) == 'fr'
              ? 'Niveau de maîtrise mis à jour'
              : 'Mastery level updated',
        ),
      ),
    );
  }

  void _showCompletionDialog() {
    final locale = ref.read(languageProvider);
    final accuracy = _correctCount / (_correctCount + _incorrectCount) * 100;
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text(
          locale == 'fr' ? 'Session terminée!' : 'Session Complete!',
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.celebration,
              size: 64,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 16),
            Text(
              locale == 'fr'
                  ? 'Vous avez révisé ${widget.verses.length} versets'
                  : 'You reviewed ${widget.verses.length} verses',
            ),
            const SizedBox(height: 8),
            Text(
              locale == 'fr'
                  ? 'Précision: ${accuracy.toStringAsFixed(0)}%'
                  : 'Accuracy: ${accuracy.toStringAsFixed(0)}%',
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            },
            child: Text(locale == 'fr' ? 'Terminer' : 'Finish'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final locale = ref.watch(languageProvider);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(locale == 'fr' ? 'Pratique' : 'Practice'),
        actions: [
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                '${_currentIndex + 1} / ${widget.verses.length}',
                style: theme.textTheme.titleMedium,
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Progress indicator
          LinearProgressIndicator(
            value: (_currentIndex + 1) / widget.verses.length,
            minHeight: 4,
          ),
          
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Verse info
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                currentVerse.surahName,
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                '${locale == 'fr' ? 'Verset' : 'Verse'} ${currentVerse.verseNumber}',
                                style: theme.textTheme.bodyMedium,
                              ),
                            ],
                          ),
                          Chip(
                            label: Text(currentVerse.masteryLevelText),
                            backgroundColor: _getMasteryColor().withOpacity(0.2),
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Arabic text
                  GestureDetector(
                    onTap: _toggleTextVisibility,
                    child: Card(
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          color: isDark
                              ? Colors.grey.shade900
                              : Colors.grey.shade50,
                        ),
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 300),
                          child: _isTextHidden
                              ? Column(
                                  key: const ValueKey('hidden'),
                                  children: [
                                    Icon(
                                      Icons.visibility_off,
                                      size: 48,
                                      color: theme.colorScheme.onSurface
                                          .withOpacity(0.3),
                                    ),
                                    const SizedBox(height: 16),
                                    Text(
                                      locale == 'fr'
                                          ? 'Tapez pour révéler'
                                          : 'Tap to reveal',
                                      style: theme.textTheme.bodyLarge?.copyWith(
                                        color: theme.colorScheme.onSurface
                                            .withOpacity(0.5),
                                      ),
                                    ),
                                  ],
                                )
                              : Text(
                                  key: const ValueKey('visible'),
                                  currentVerse.arabicText,
                                  style: AppTheme.arabicTextStyle(
                                    fontSize: 28,
                                    color: theme.colorScheme.onSurface,
                                  ),
                                  textAlign: TextAlign.center,
                                  textDirection: TextDirection.rtl,
                                ),
                        ),
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Translation
                  if (_showTranslation)
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Text(
                          currentVerse.translation,
                          style: theme.textTheme.bodyLarge,
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  
                  const SizedBox(height: 24),
                  
                  // Control buttons
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    alignment: WrapAlignment.center,
                    children: [
                      ElevatedButton.icon(
                        onPressed: _playVerse,
                        icon: const Icon(Icons.play_arrow),
                        label: Text(locale == 'fr' ? 'Écouter' : 'Listen'),
                      ),
                      OutlinedButton.icon(
                        onPressed: _toggleTextVisibility,
                        icon: Icon(_isTextHidden
                            ? Icons.visibility
                            : Icons.visibility_off),
                        label: Text(
                          _isTextHidden
                              ? (locale == 'fr' ? 'Montrer' : 'Show')
                              : (locale == 'fr' ? 'Cacher' : 'Hide'),
                        ),
                      ),
                      OutlinedButton.icon(
                        onPressed: _toggleTranslation,
                        icon: const Icon(Icons.translate),
                        label: Text(
                          locale == 'fr' ? 'Traduction' : 'Translation',
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Self-assessment
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            locale == 'fr'
                                ? 'Comment était votre récitation?'
                                : 'How was your recitation?',
                            style: theme.textTheme.titleMedium,
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: ElevatedButton.icon(
                                  onPressed: _markCorrect,
                                  icon: const Icon(Icons.check),
                                  label: Text(
                                    locale == 'fr' ? 'Correct' : 'Correct',
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.green,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: ElevatedButton.icon(
                                  onPressed: _markIncorrect,
                                  icon: const Icon(Icons.close),
                                  label: Text(
                                    locale == 'fr' ? 'À revoir' : 'Need work',
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.orange,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          // Bottom navigation
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.cardColor,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  onPressed: _currentIndex > 0 ? _previousVerse : null,
                  icon: const Icon(Icons.arrow_back),
                ),
                PopupMenuButton<MasteryLevel>(
                  onSelected: _updateMastery,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      border: Border.all(color: theme.dividerColor),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.school, size: 20),
                        const SizedBox(width: 8),
                        Text(locale == 'fr' ? 'Maîtrise' : 'Mastery'),
                        const Icon(Icons.arrow_drop_down),
                      ],
                    ),
                  ),
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      value: MasteryLevel.beginner,
                      child: Text(locale == 'fr' ? 'Débutant' : 'Beginner'),
                    ),
                    PopupMenuItem(
                      value: MasteryLevel.intermediate,
                      child: Text(
                        locale == 'fr' ? 'Intermédiaire' : 'Intermediate',
                      ),
                    ),
                    PopupMenuItem(
                      value: MasteryLevel.mastered,
                      child: Text(locale == 'fr' ? 'Maîtrisé' : 'Mastered'),
                    ),
                  ],
                ),
                IconButton(
                  onPressed: _currentIndex < widget.verses.length - 1
                      ? _nextVerse
                      : _showCompletionDialog,
                  icon: Icon(
                    _currentIndex < widget.verses.length - 1
                        ? Icons.arrow_forward
                        : Icons.check,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getMasteryColor() {
    switch (currentVerse.masteryLevel) {
      case MasteryLevel.beginner:
        return Colors.orange;
      case MasteryLevel.intermediate:
        return Colors.blue;
      case MasteryLevel.mastered:
        return Colors.green;
    }
  }
}