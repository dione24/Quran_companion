enum MasteryLevel {
  beginner,
  intermediate,
  mastered,
}

class MemorizationVerse {
  final String id;
  final int surahNumber;
  final String surahName;
  final int verseNumber;
  final String arabicText;
  final String translation;
  MasteryLevel masteryLevel;
  DateTime lastReviewDate;
  DateTime nextReviewDate;
  int reviewCount;
  int correctCount;
  int incorrectCount;
  bool isHidden;

  MemorizationVerse({
    required this.id,
    required this.surahNumber,
    required this.surahName,
    required this.verseNumber,
    required this.arabicText,
    required this.translation,
    this.masteryLevel = MasteryLevel.beginner,
    DateTime? lastReviewDate,
    DateTime? nextReviewDate,
    this.reviewCount = 0,
    this.correctCount = 0,
    this.incorrectCount = 0,
    this.isHidden = false,
  })  : lastReviewDate = lastReviewDate ?? DateTime.now(),
        nextReviewDate = nextReviewDate ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'surahNumber': surahNumber,
      'surahName': surahName,
      'verseNumber': verseNumber,
      'arabicText': arabicText,
      'translation': translation,
      'masteryLevel': masteryLevel.index,
      'lastReviewDate': lastReviewDate.toIso8601String(),
      'nextReviewDate': nextReviewDate.toIso8601String(),
      'reviewCount': reviewCount,
      'correctCount': correctCount,
      'incorrectCount': incorrectCount,
      'isHidden': isHidden,
    };
  }

  factory MemorizationVerse.fromMap(Map<dynamic, dynamic> map) {
    return MemorizationVerse(
      id: map['id'],
      surahNumber: map['surahNumber'],
      surahName: map['surahName'],
      verseNumber: map['verseNumber'],
      arabicText: map['arabicText'],
      translation: map['translation'],
      masteryLevel: MasteryLevel.values[map['masteryLevel']],
      lastReviewDate: DateTime.parse(map['lastReviewDate']),
      nextReviewDate: DateTime.parse(map['nextReviewDate']),
      reviewCount: map['reviewCount'],
      correctCount: map['correctCount'],
      incorrectCount: map['incorrectCount'],
      isHidden: map['isHidden'] ?? false,
    );
  }

  double get accuracy {
    final total = correctCount + incorrectCount;
    if (total == 0) return 0;
    return (correctCount / total) * 100;
  }

  String get masteryLevelText {
    switch (masteryLevel) {
      case MasteryLevel.beginner:
        return 'Débutant';
      case MasteryLevel.intermediate:
        return 'Intermédiaire';
      case MasteryLevel.mastered:
        return 'Maîtrisé';
    }
  }
}