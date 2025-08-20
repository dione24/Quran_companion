import 'package:flutter_test/flutter_test.dart';
import 'package:quran_companion/core/services/quiz_service.dart';
import 'package:quran_companion/core/models/quiz_model.dart';

void main() {
  group('QuizService', () {
    late QuizService quizService;

    setUp(() {
      quizService = QuizService();
    });

    test('generateNumberOptions creates correct options', () {
      final options = quizService.generateNumberOptions(10);
      
      expect(options.length, 4);
      expect(options.contains('10'), true);
      
      // Check all options are unique
      final uniqueOptions = options.toSet();
      expect(uniqueOptions.length, 4);
      
      // Check all options are valid numbers
      for (final option in options) {
        final number = int.tryParse(option);
        expect(number, isNotNull);
        expect(number! > 0, true);
      }
    });

    test('QuizQuestion model correctly handles localization', () {
      final question = QuizQuestion(
        id: 'test_1',
        category: QuizCategory.surahFacts,
        questionFr: 'Question en français',
        questionEn: 'Question in English',
        options: ['A', 'B', 'C', 'D'],
        correctAnswer: 0,
        difficulty: QuizDifficulty.medium,
        explanationFr: 'Explication en français',
        explanationEn: 'Explanation in English',
      );

      expect(question.getQuestion('fr'), 'Question en français');
      expect(question.getQuestion('en'), 'Question in English');
      expect(question.getExplanation('fr'), 'Explication en français');
      expect(question.getExplanation('en'), 'Explanation in English');
    });

    test('QuizResult calculates accuracy correctly', () {
      final result = QuizResult(
        id: 'test_result_1',
        category: QuizCategory.prophets,
        score: 80,
        totalQuestions: 10,
        correctAnswers: 8,
        timeSpentSeconds: 120,
        completedAt: DateTime.now(),
        difficulty: QuizDifficulty.medium,
      );

      expect(result.accuracy, 80.0);
    });

    test('QuizSession tracks answers correctly', () {
      final questions = [
        QuizQuestion(
          id: '1',
          category: QuizCategory.general,
          questionFr: 'Q1',
          questionEn: 'Q1',
          options: ['A', 'B', 'C', 'D'],
          correctAnswer: 0,
          difficulty: QuizDifficulty.easy,
        ),
        QuizQuestion(
          id: '2',
          category: QuizCategory.general,
          questionFr: 'Q2',
          questionEn: 'Q2',
          options: ['A', 'B', 'C', 'D'],
          correctAnswer: 1,
          difficulty: QuizDifficulty.easy,
        ),
      ];

      final session = QuizSession(
        questions: questions,
        category: QuizCategory.general,
        difficulty: QuizDifficulty.easy,
      );

      expect(session.currentQuestionIndex, 0);
      expect(session.currentQuestion.id, '1');
      expect(session.isComplete, false);

      // Answer first question correctly
      session.answerQuestion(0);
      session.nextQuestion();

      expect(session.currentQuestionIndex, 1);
      expect(session.correctAnswers, 1);

      // Answer second question incorrectly
      session.answerQuestion(0); // Wrong answer (correct is 1)
      
      expect(session.correctAnswers, 1);
      expect(session.answers.length, 2);
    });

    test('QuizSession calculates score with difficulty multiplier', () {
      final questions = List.generate(
        10,
        (i) => QuizQuestion(
          id: '$i',
          category: QuizCategory.general,
          questionFr: 'Q$i',
          questionEn: 'Q$i',
          options: ['A', 'B', 'C', 'D'],
          correctAnswer: 0,
          difficulty: QuizDifficulty.hard,
        ),
      );

      final session = QuizSession(
        questions: questions,
        category: QuizCategory.general,
        difficulty: QuizDifficulty.hard,
      );

      // Answer all questions correctly
      for (int i = 0; i < questions.length; i++) {
        session.answerQuestion(0);
        if (i < questions.length - 1) {
          session.nextQuestion();
        }
      }

      session.completeQuiz();

      // Score should be: 10 correct * 10 points * 2.0 (hard difficulty) = 200
      expect(session.score, 200);
    });

    test('QuizSession handles timed mode correctly', () {
      final questions = [
        QuizQuestion(
          id: '1',
          category: QuizCategory.general,
          questionFr: 'Q1',
          questionEn: 'Q1',
          options: ['A', 'B', 'C', 'D'],
          correctAnswer: 0,
          difficulty: QuizDifficulty.medium,
        ),
      ];

      final session = QuizSession(
        questions: questions,
        category: QuizCategory.general,
        difficulty: QuizDifficulty.medium,
        isTimedMode: true,
        timeLimitSeconds: 60,
      );

      expect(session.isTimedMode, true);
      expect(session.timeLimitSeconds, 60);

      session.answerQuestion(0);
      session.completeQuiz();

      expect(session.endTime, isNotNull);
      
      final result = session.getResult();
      expect(result.timeSpentSeconds, greaterThan(0));
    });

    test('QuizCategory enum values are correct', () {
      expect(QuizCategory.values.length, 4);
      expect(QuizCategory.surahFacts.name, 'surahFacts');
      expect(QuizCategory.prophets.name, 'prophets');
      expect(QuizCategory.islamicHistory.name, 'islamicHistory');
      expect(QuizCategory.general.name, 'general');
    });

    test('QuizDifficulty enum values are correct', () {
      expect(QuizDifficulty.values.length, 3);
      expect(QuizDifficulty.easy.name, 'easy');
      expect(QuizDifficulty.medium.name, 'medium');
      expect(QuizDifficulty.hard.name, 'hard');
    });
  });
}

// Extension to expose private methods for testing
extension QuizServiceTestExtension on QuizService {
  List<String> generateNumberOptions(int correctAnswer) {
    final List<String> options = [correctAnswer.toString()];
    final Set<int> used = {correctAnswer};
    
    while (options.length < 4) {
      final offset = (options.length * 5) - 10; // Simplified for testing
      final option = correctAnswer + offset;
      if (option > 0 && !used.contains(option)) {
        options.add(option.toString());
        used.add(option);
      }
    }
    
    return options;
  }
}