import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../providers/quran_provider.dart';
import '../models/quiz_question.dart';

class QuizScreen extends StatefulWidget {
  const QuizScreen({super.key});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;
  
  List<QuizQuestion> _questions = [];
  int _currentQuestionIndex = 0;
  int _score = 0;
  bool _isAnswered = false;
  int? _selectedAnswer;
  bool _isLoading = true;
  bool _quizCompleted = false;
  
  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
    _loadQuestions();
  }
  
  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
  
  Future<void> _loadQuestions() async {
    final quranProvider = context.read<QuranProvider>();
    
    // Make sure surahs are loaded
    if (quranProvider.surahs.isEmpty) {
      await quranProvider.loadSurahs();
    }
    
    // Generate quiz questions
    _questions = _generateQuestions(quranProvider);
    
    setState(() {
      _isLoading = false;
    });
    
    _animationController.forward();
  }
  
  List<QuizQuestion> _generateQuestions(QuranProvider provider) {
    final questions = <QuizQuestion>[];
    final random = Random();
    final surahs = provider.surahs;
    
    if (surahs.isEmpty) return questions;
    
    // Question types
    final questionTypes = [
      () => _generateSurahNumberQuestion(surahs, random),
      () => _generateSurahVersesQuestion(surahs, random),
      () => _generateRevelationTypeQuestion(surahs, random),
      () => _generateSurahOrderQuestion(surahs, random),
      () => _generateSurahNameQuestion(surahs, random),
    ];
    
    // Generate 10 questions
    for (int i = 0; i < 10; i++) {
      final questionGenerator = questionTypes[random.nextInt(questionTypes.length)];
      questions.add(questionGenerator());
    }
    
    return questions;
  }
  
  QuizQuestion _generateSurahNumberQuestion(List<dynamic> surahs, Random random) {
    final correctSurah = surahs[random.nextInt(surahs.length)];
    final options = <String>[];
    
    // Add correct answer
    options.add(correctSurah.number.toString());
    
    // Add wrong answers
    while (options.length < 4) {
      final wrongNumber = random.nextInt(114) + 1;
      if (!options.contains(wrongNumber.toString())) {
        options.add(wrongNumber.toString());
      }
    }
    
    options.shuffle();
    
    return QuizQuestion(
      question: 'What is the number of Surah ${correctSurah.englishName}?',
      questionFr: 'Quel est le numéro de la sourate ${correctSurah.englishName} ?',
      options: options,
      correctAnswer: options.indexOf(correctSurah.number.toString()),
      explanation: 'Surah ${correctSurah.englishName} is the ${correctSurah.number}${_getOrdinalSuffix(correctSurah.number)} surah in the Quran.',
      explanationFr: 'La sourate ${correctSurah.englishName} est la ${correctSurah.number}e sourate du Coran.',
    );
  }
  
  QuizQuestion _generateSurahVersesQuestion(List<dynamic> surahs, Random random) {
    final correctSurah = surahs[random.nextInt(surahs.length)];
    final options = <String>[];
    
    // Add correct answer
    options.add(correctSurah.numberOfAyahs.toString());
    
    // Add wrong answers
    while (options.length < 4) {
      final wrongNumber = random.nextInt(286) + 1; // Max verses in a surah
      if (!options.contains(wrongNumber.toString())) {
        options.add(wrongNumber.toString());
      }
    }
    
    options.shuffle();
    
    return QuizQuestion(
      question: 'How many verses are in Surah ${correctSurah.englishName}?',
      questionFr: 'Combien de versets contient la sourate ${correctSurah.englishName} ?',
      options: options,
      correctAnswer: options.indexOf(correctSurah.numberOfAyahs.toString()),
      explanation: 'Surah ${correctSurah.englishName} contains ${correctSurah.numberOfAyahs} verses.',
      explanationFr: 'La sourate ${correctSurah.englishName} contient ${correctSurah.numberOfAyahs} versets.',
    );
  }
  
  QuizQuestion _generateRevelationTypeQuestion(List<dynamic> surahs, Random random) {
    final correctSurah = surahs[random.nextInt(surahs.length)];
    final options = ['Meccan', 'Medinan'];
    
    return QuizQuestion(
      question: 'Is Surah ${correctSurah.englishName} Meccan or Medinan?',
      questionFr: 'La sourate ${correctSurah.englishName} est-elle mecquoise ou médinoise ?',
      options: options,
      correctAnswer: correctSurah.revelationType == 'Meccan' ? 0 : 1,
      explanation: 'Surah ${correctSurah.englishName} is a ${correctSurah.revelationType} surah.',
      explanationFr: 'La sourate ${correctSurah.englishName} est une sourate ${correctSurah.revelationType == "Meccan" ? "mecquoise" : "médinoise"}.',
    );
  }
  
  QuizQuestion _generateSurahOrderQuestion(List<dynamic> surahs, Random random) {
    final surahIndex = random.nextInt(surahs.length - 1);
    final currentSurah = surahs[surahIndex];
    final nextSurah = surahs[surahIndex + 1];
    
    final options = <String>[];
    options.add(nextSurah.englishName);
    
    // Add wrong answers
    while (options.length < 4) {
      final wrongSurah = surahs[random.nextInt(surahs.length)];
      if (!options.contains(wrongSurah.englishName) && 
          wrongSurah.englishName != currentSurah.englishName) {
        options.add(wrongSurah.englishName);
      }
    }
    
    options.shuffle();
    
    return QuizQuestion(
      question: 'Which surah comes after ${currentSurah.englishName}?',
      questionFr: 'Quelle sourate vient après ${currentSurah.englishName} ?',
      options: options,
      correctAnswer: options.indexOf(nextSurah.englishName),
      explanation: 'Surah ${nextSurah.englishName} comes after ${currentSurah.englishName}.',
      explanationFr: 'La sourate ${nextSurah.englishName} vient après ${currentSurah.englishName}.',
    );
  }
  
  QuizQuestion _generateSurahNameQuestion(List<dynamic> surahs, Random random) {
    final correctSurah = surahs[random.nextInt(surahs.length)];
    final options = <String>[];
    
    options.add(correctSurah.englishName);
    
    // Add wrong answers
    while (options.length < 4) {
      final wrongSurah = surahs[random.nextInt(surahs.length)];
      if (!options.contains(wrongSurah.englishName)) {
        options.add(wrongSurah.englishName);
      }
    }
    
    options.shuffle();
    
    return QuizQuestion(
      question: 'What is the name of the ${correctSurah.number}${_getOrdinalSuffix(correctSurah.number)} surah?',
      questionFr: 'Quel est le nom de la ${correctSurah.number}e sourate ?',
      options: options,
      correctAnswer: options.indexOf(correctSurah.englishName),
      explanation: 'The ${correctSurah.number}${_getOrdinalSuffix(correctSurah.number)} surah is ${correctSurah.englishName}.',
      explanationFr: 'La ${correctSurah.number}e sourate est ${correctSurah.englishName}.',
    );
  }
  
  String _getOrdinalSuffix(int number) {
    if (number >= 11 && number <= 13) return 'th';
    switch (number % 10) {
      case 1: return 'st';
      case 2: return 'nd';
      case 3: return 'rd';
      default: return 'th';
    }
  }
  
  void _answerQuestion(int answerIndex) {
    if (_isAnswered) return;
    
    setState(() {
      _isAnswered = true;
      _selectedAnswer = answerIndex;
      
      if (answerIndex == _questions[_currentQuestionIndex].correctAnswer) {
        _score++;
      }
    });
  }
  
  void _nextQuestion() {
    if (_currentQuestionIndex < _questions.length - 1) {
      _animationController.reverse().then((_) {
        setState(() {
          _currentQuestionIndex++;
          _isAnswered = false;
          _selectedAnswer = null;
        });
        _animationController.forward();
      });
    } else {
      setState(() {
        _quizCompleted = true;
      });
    }
  }
  
  void _resetQuiz() {
    setState(() {
      _currentQuestionIndex = 0;
      _score = 0;
      _isAnswered = false;
      _selectedAnswer = null;
      _quizCompleted = false;
    });
    _loadQuestions();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';
    final isFrench = Localizations.localeOf(context).languageCode == 'fr';
    
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: Text(l10n.quiz)),
        body: const Center(child: CircularProgressIndicator()),
      );
    }
    
    if (_quizCompleted) {
      return Scaffold(
        appBar: AppBar(title: Text(l10n.quiz)),
        body: Center(
          child: Card(
            margin: const EdgeInsets.all(24),
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    _score >= 7 ? Icons.celebration : Icons.sentiment_satisfied,
                    size: 80,
                    color: _score >= 7 ? Colors.amber : Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Quiz Completed!',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '${l10n.score}: $_score / ${_questions.length}',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _getScoreMessage(_score, _questions.length),
                    style: Theme.of(context).textTheme.bodyLarge,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Exit'),
                      ),
                      ElevatedButton(
                        onPressed: _resetQuiz,
                        child: const Text('Try Again'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }
    
    final question = _questions[_currentQuestionIndex];
    
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.quiz),
        actions: [
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                '${_currentQuestionIndex + 1} / ${_questions.length}',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
          ),
        ],
      ),
      body: FadeTransition(
        opacity: _animation,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Progress indicator
              LinearProgressIndicator(
                value: (_currentQuestionIndex + 1) / _questions.length,
                backgroundColor: Theme.of(context).colorScheme.surfaceVariant,
              ),
              const SizedBox(height: 24),
              
              // Score
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        l10n.score,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      Text(
                        '$_score / ${_questions.length}',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              
              // Question
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Text(
                    isFrench ? question.questionFr : question.question,
                    style: Theme.of(context).textTheme.titleLarge,
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              
              // Options
              Expanded(
                child: ListView.builder(
                  itemCount: question.options.length,
                  itemBuilder: (context, index) {
                    final isCorrect = index == question.correctAnswer;
                    final isSelected = index == _selectedAnswer;
                    
                    Color? backgroundColor;
                    if (_isAnswered) {
                      if (isCorrect) {
                        backgroundColor = Colors.green.withOpacity(0.3);
                      } else if (isSelected && !isCorrect) {
                        backgroundColor = Colors.red.withOpacity(0.3);
                      }
                    }
                    
                    return Card(
                      color: backgroundColor,
                      child: ListTile(
                        onTap: () => _answerQuestion(index),
                        leading: CircleAvatar(
                          backgroundColor: _isAnswered && isCorrect
                              ? Colors.green
                              : _isAnswered && isSelected && !isCorrect
                                  ? Colors.red
                                  : Theme.of(context).colorScheme.primary,
                          child: Text(
                            String.fromCharCode(65 + index), // A, B, C, D
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                        title: Text(
                          question.options[index],
                          style: TextStyle(
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                        trailing: _isAnswered
                            ? Icon(
                                isCorrect
                                    ? Icons.check_circle
                                    : isSelected
                                        ? Icons.cancel
                                        : null,
                                color: isCorrect ? Colors.green : Colors.red,
                              )
                            : null,
                      ),
                    );
                  },
                ),
              ),
              
              // Explanation
              if (_isAnswered) ...[
                Card(
                  color: Theme.of(context).colorScheme.secondaryContainer,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.lightbulb,
                              color: Theme.of(context).colorScheme.onSecondaryContainer,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Explanation',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.onSecondaryContainer,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          isFrench ? question.explanationFr : question.explanation,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onSecondaryContainer,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _nextQuestion,
                  child: Text(
                    _currentQuestionIndex < _questions.length - 1
                        ? l10n.nextQuestion
                        : 'Finish Quiz',
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
  
  String _getScoreMessage(int score, int total) {
    final percentage = (score / total) * 100;
    if (percentage >= 90) {
      return 'Excellent! You have great knowledge of the Quran!';
    } else if (percentage >= 70) {
      return 'Good job! Keep learning and improving!';
    } else if (percentage >= 50) {
      return 'Not bad! There\'s room for improvement.';
    } else {
      return 'Keep studying and try again!';
    }
  }
}