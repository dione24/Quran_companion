import 'dart:convert';
import 'dart:math';
import 'package:flutter/services.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/quiz_model.dart';

class QuizService {
  static const String scoresBoxName = 'quiz_scores';
  late Box<Map> _scoresBox;
  List<QuizQuestion>? _questions;
  final Random _random = Random();

  Future<void> init() async {
    _scoresBox = await Hive.openBox<Map>(scoresBoxName);
    await loadQuestions();
  }

  Future<void> loadQuestions() async {
    try {
      final String jsonString = await rootBundle.loadString('assets/data/quiz/questions.json');
      final Map<String, dynamic> data = json.decode(jsonString);
      _questions = (data['questions'] as List)
          .map((q) => QuizQuestion.fromJson(q))
          .toList();
    } catch (e) {
      print('Error loading quiz questions: $e');
      _questions = _generateDefaultQuestions();
    }
  }

  List<QuizQuestion> _generateDefaultQuestions() {
    return [
      QuizQuestion(
        id: '1',
        category: QuizCategory.surahFacts,
        questionFr: 'Quelle est la plus longue sourate du Coran?',
        questionEn: 'What is the longest surah in the Quran?',
        options: ['Al-Baqarah', 'Al-Imran', 'An-Nisa', 'Al-Maidah'],
        correctAnswer: 0,
        difficulty: QuizDifficulty.easy,
      ),
      QuizQuestion(
        id: '2',
        category: QuizCategory.prophets,
        questionFr: 'Quel prophète a construit l\'arche?',
        questionEn: 'Which prophet built the ark?',
        options: ['Ibrahim', 'Nuh', 'Musa', 'Isa'],
        correctAnswer: 1,
        difficulty: QuizDifficulty.easy,
      ),
      QuizQuestion(
        id: '3',
        category: QuizCategory.islamicHistory,
        questionFr: 'En quelle année a eu lieu l\'Hégire?',
        questionEn: 'In which year did the Hijra occur?',
        options: ['620 CE', '622 CE', '624 CE', '626 CE'],
        correctAnswer: 1,
        difficulty: QuizDifficulty.medium,
      ),
      QuizQuestion(
        id: '4',
        category: QuizCategory.surahFacts,
        questionFr: 'Combien de sourates y a-t-il dans le Coran?',
        questionEn: 'How many surahs are there in the Quran?',
        options: ['100', '114', '120', '124'],
        correctAnswer: 1,
        difficulty: QuizDifficulty.easy,
      ),
      QuizQuestion(
        id: '5',
        category: QuizCategory.prophets,
        questionFr: 'Qui était le père du prophète Ibrahim?',
        questionEn: 'Who was the father of Prophet Ibrahim?',
        options: ['Azar', 'Tariq', 'Ismail', 'Yaqub'],
        correctAnswer: 0,
        difficulty: QuizDifficulty.hard,
      ),
    ];
  }

  List<QuizQuestion> generateQuiz({
    QuizCategory? category,
    QuizDifficulty? difficulty,
    int questionCount = 10,
  }) {
    if (_questions == null || _questions!.isEmpty) {
      return [];
    }

    List<QuizQuestion> filteredQuestions = List.from(_questions!);

    // Filter by category
    if (category != null) {
      filteredQuestions = filteredQuestions
          .where((q) => q.category == category)
          .toList();
    }

    // Filter by difficulty
    if (difficulty != null) {
      filteredQuestions = filteredQuestions
          .where((q) => q.difficulty == difficulty)
          .toList();
    }

    // Shuffle and take required number of questions
    filteredQuestions.shuffle(_random);
    return filteredQuestions.take(questionCount).toList();
  }

  List<QuizQuestion> generateDynamicQuiz(Map<String, dynamic> quranData, int questionCount) {
    final List<QuizQuestion> dynamicQuestions = [];
    
    // Generate questions based on Quran data
    // Example: Questions about surah order, verse counts, etc.
    
    for (int i = 0; i < questionCount && i < 5; i++) {
      final surahIndex = _random.nextInt(114);
      final surahData = quranData['surahs'][surahIndex];
      
      switch (i % 3) {
        case 0:
          // Question about verse count
          dynamicQuestions.add(QuizQuestion(
            id: 'dynamic_$i',
            category: QuizCategory.surahFacts,
            questionFr: 'Combien de versets contient la sourate ${surahData['name']}?',
            questionEn: 'How many verses are in Surah ${surahData['name']}?',
            options: _generateNumberOptions(surahData['verses'].length),
            correctAnswer: 0,
            difficulty: QuizDifficulty.medium,
          ));
          break;
        case 1:
          // Question about revelation place
          dynamicQuestions.add(QuizQuestion(
            id: 'dynamic_$i',
            category: QuizCategory.surahFacts,
            questionFr: 'Où a été révélée la sourate ${surahData['name']}?',
            questionEn: 'Where was Surah ${surahData['name']} revealed?',
            options: ['Mecque', 'Médine'],
            correctAnswer: surahData['revelationPlace'] == 'Mecca' ? 0 : 1,
            difficulty: QuizDifficulty.easy,
          ));
          break;
        case 2:
          // Question about surah order
          dynamicQuestions.add(QuizQuestion(
            id: 'dynamic_$i',
            category: QuizCategory.surahFacts,
            questionFr: 'Quel est le numéro de la sourate ${surahData['name']}?',
            questionEn: 'What is the number of Surah ${surahData['name']}?',
            options: _generateNumberOptions(surahIndex + 1),
            correctAnswer: 0,
            difficulty: QuizDifficulty.hard,
          ));
          break;
      }
    }
    
    return dynamicQuestions;
  }

  List<String> _generateNumberOptions(int correctAnswer) {
    final List<String> options = [correctAnswer.toString()];
    final Set<int> used = {correctAnswer};
    
    while (options.length < 4) {
      final offset = _random.nextInt(20) - 10;
      final option = correctAnswer + offset;
      if (option > 0 && !used.contains(option)) {
        options.add(option.toString());
        used.add(option);
      }
    }
    
    options.shuffle(_random);
    return options;
  }

  Future<void> saveQuizResult(QuizResult result) async {
    final String key = '${result.category.name}_${DateTime.now().millisecondsSinceEpoch}';
    await _scoresBox.put(key, result.toMap());
    await _updateStats(result);
  }

  Future<void> _updateStats(QuizResult result) async {
    final stats = await getQuizStats();
    
    // Update high score
    if (result.score > stats['highScore']) {
      await _scoresBox.put('highScore', result.score);
    }
    
    // Update total quizzes
    final totalQuizzes = stats['totalQuizzes'] + 1;
    await _scoresBox.put('totalQuizzes', totalQuizzes);
    
    // Update average score
    final currentAverage = stats['averageScore'];
    final newAverage = ((currentAverage * (totalQuizzes - 1)) + result.score) / totalQuizzes;
    await _scoresBox.put('averageScore', newAverage);
    
    // Update streak
    final lastQuizDate = stats['lastQuizDate'];
    final today = DateTime.now();
    if (lastQuizDate != null) {
      final daysSinceLastQuiz = today.difference(DateTime.parse(lastQuizDate)).inDays;
      if (daysSinceLastQuiz == 1) {
        await _scoresBox.put('currentStreak', stats['currentStreak'] + 1);
      } else if (daysSinceLastQuiz > 1) {
        await _scoresBox.put('currentStreak', 1);
      }
    } else {
      await _scoresBox.put('currentStreak', 1);
    }
    
    await _scoresBox.put('lastQuizDate', today.toIso8601String());
  }

  Future<Map<String, dynamic>> getQuizStats() async {
    return {
      'highScore': _scoresBox.get('highScore', defaultValue: 0),
      'totalQuizzes': _scoresBox.get('totalQuizzes', defaultValue: 0),
      'averageScore': _scoresBox.get('averageScore', defaultValue: 0.0),
      'currentStreak': _scoresBox.get('currentStreak', defaultValue: 0),
      'lastQuizDate': _scoresBox.get('lastQuizDate'),
    };
  }

  List<QuizResult> getQuizHistory({int limit = 10}) {
    final List<QuizResult> results = [];
    
    for (final key in _scoresBox.keys) {
      if (key.toString().contains('_')) {
        final data = _scoresBox.get(key);
        if (data != null) {
          results.add(QuizResult.fromMap(data));
        }
      }
    }
    
    results.sort((a, b) => b.completedAt.compareTo(a.completedAt));
    return results.take(limit).toList();
  }

  Map<QuizCategory, int> getCategoryScores() {
    final Map<QuizCategory, int> scores = {};
    
    for (final category in QuizCategory.values) {
      scores[category] = 0;
    }
    
    for (final key in _scoresBox.keys) {
      if (key.toString().contains('_')) {
        final data = _scoresBox.get(key);
        if (data != null) {
          final result = QuizResult.fromMap(data);
          scores[result.category] = (scores[result.category] ?? 0) + result.score;
        }
      }
    }
    
    return scores;
  }
}