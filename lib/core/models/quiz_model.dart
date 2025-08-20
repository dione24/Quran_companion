enum QuizCategory {
  surahFacts,
  prophets,
  islamicHistory,
  general,
}

enum QuizDifficulty {
  easy,
  medium,
  hard,
}

class QuizQuestion {
  final String id;
  final QuizCategory category;
  final String questionFr;
  final String questionEn;
  final List<String> options;
  final int correctAnswer;
  final QuizDifficulty difficulty;
  final String? explanationFr;
  final String? explanationEn;

  QuizQuestion({
    required this.id,
    required this.category,
    required this.questionFr,
    required this.questionEn,
    required this.options,
    required this.correctAnswer,
    required this.difficulty,
    this.explanationFr,
    this.explanationEn,
  });

  factory QuizQuestion.fromJson(Map<String, dynamic> json) {
    return QuizQuestion(
      id: json['id'],
      category: QuizCategory.values.firstWhere(
        (c) => c.name == json['category'],
        orElse: () => QuizCategory.general,
      ),
      questionFr: json['question_fr'],
      questionEn: json['question_en'],
      options: List<String>.from(json['options']),
      correctAnswer: json['correct_answer'],
      difficulty: QuizDifficulty.values.firstWhere(
        (d) => d.name == json['difficulty'],
        orElse: () => QuizDifficulty.medium,
      ),
      explanationFr: json['explanation_fr'],
      explanationEn: json['explanation_en'],
    );
  }

  String getQuestion(String locale) {
    return locale == 'fr' ? questionFr : questionEn;
  }

  String? getExplanation(String locale) {
    return locale == 'fr' ? explanationFr : explanationEn;
  }
}

class QuizResult {
  final String id;
  final QuizCategory category;
  final int score;
  final int totalQuestions;
  final int correctAnswers;
  final int timeSpentSeconds;
  final DateTime completedAt;
  final QuizDifficulty difficulty;

  QuizResult({
    required this.id,
    required this.category,
    required this.score,
    required this.totalQuestions,
    required this.correctAnswers,
    required this.timeSpentSeconds,
    required this.completedAt,
    required this.difficulty,
  });

  double get accuracy => (correctAnswers / totalQuestions) * 100;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'category': category.name,
      'score': score,
      'totalQuestions': totalQuestions,
      'correctAnswers': correctAnswers,
      'timeSpentSeconds': timeSpentSeconds,
      'completedAt': completedAt.toIso8601String(),
      'difficulty': difficulty.name,
    };
  }

  factory QuizResult.fromMap(Map<dynamic, dynamic> map) {
    return QuizResult(
      id: map['id'],
      category: QuizCategory.values.firstWhere(
        (c) => c.name == map['category'],
        orElse: () => QuizCategory.general,
      ),
      score: map['score'],
      totalQuestions: map['totalQuestions'],
      correctAnswers: map['correctAnswers'],
      timeSpentSeconds: map['timeSpentSeconds'],
      completedAt: DateTime.parse(map['completedAt']),
      difficulty: QuizDifficulty.values.firstWhere(
        (d) => d.name == map['difficulty'],
        orElse: () => QuizDifficulty.medium,
      ),
    );
  }
}

class QuizSession {
  final List<QuizQuestion> questions;
  final Map<int, int> answers;
  final DateTime startTime;
  DateTime? endTime;
  int currentQuestionIndex;
  final QuizCategory category;
  final QuizDifficulty difficulty;
  final bool isTimedMode;
  final int? timeLimitSeconds;

  QuizSession({
    required this.questions,
    required this.category,
    required this.difficulty,
    this.isTimedMode = false,
    this.timeLimitSeconds,
  })  : answers = {},
        startTime = DateTime.now(),
        currentQuestionIndex = 0;

  QuizQuestion get currentQuestion => questions[currentQuestionIndex];
  
  bool get isComplete => currentQuestionIndex >= questions.length;
  
  int get correctAnswers {
    int correct = 0;
    answers.forEach((index, answer) {
      if (questions[index].correctAnswer == answer) {
        correct++;
      }
    });
    return correct;
  }
  
  int get score {
    // Base score calculation with difficulty multiplier
    int baseScore = correctAnswers * 10;
    double difficultyMultiplier = 1.0;
    
    switch (difficulty) {
      case QuizDifficulty.easy:
        difficultyMultiplier = 1.0;
        break;
      case QuizDifficulty.medium:
        difficultyMultiplier = 1.5;
        break;
      case QuizDifficulty.hard:
        difficultyMultiplier = 2.0;
        break;
    }
    
    // Time bonus for timed mode
    double timeBonus = 1.0;
    if (isTimedMode && endTime != null) {
      final timeTaken = endTime!.difference(startTime).inSeconds;
      if (timeLimitSeconds != null && timeTaken < timeLimitSeconds!) {
        timeBonus = 1.0 + ((timeLimitSeconds! - timeTaken) / timeLimitSeconds!) * 0.5;
      }
    }
    
    return (baseScore * difficultyMultiplier * timeBonus).round();
  }
  
  void answerQuestion(int answerIndex) {
    answers[currentQuestionIndex] = answerIndex;
  }
  
  void nextQuestion() {
    if (currentQuestionIndex < questions.length - 1) {
      currentQuestionIndex++;
    }
  }
  
  void previousQuestion() {
    if (currentQuestionIndex > 0) {
      currentQuestionIndex--;
    }
  }
  
  void completeQuiz() {
    endTime = DateTime.now();
  }
  
  QuizResult getResult() {
    return QuizResult(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      category: category,
      score: score,
      totalQuestions: questions.length,
      correctAnswers: correctAnswers,
      timeSpentSeconds: endTime != null 
          ? endTime!.difference(startTime).inSeconds 
          : DateTime.now().difference(startTime).inSeconds,
      completedAt: endTime ?? DateTime.now(),
      difficulty: difficulty,
    );
  }
}