class QuizQuestion {
  final String question;
  final String questionFr;
  final List<String> options;
  final int correctAnswer;
  final String explanation;
  final String explanationFr;

  QuizQuestion({
    required this.question,
    required this.questionFr,
    required this.options,
    required this.correctAnswer,
    required this.explanation,
    required this.explanationFr,
  });
}