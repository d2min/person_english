class Word {
  const Word({
    required this.id,
    required this.russian,
    required this.english,
    required this.createdAt,
    this.russianExample = '',
    this.englishExample = '',
    this.attempts = 0,
    this.correctAnswers = 0,
    this.nextReviewAt,
    this.longReviewAttempts = 0,
    this.longReviewCorrect = 0,
    this.lastIntervalSeconds = 0,
    this.consecutiveCorrectAnswers = 0,
  });

  final String id;
  final String russian;
  final String english;
  final String russianExample;
  final String englishExample;
  final DateTime createdAt;
  final DateTime? nextReviewAt;
  final int attempts;
  final int correctAnswers;
  final int longReviewAttempts;
  final int longReviewCorrect;
  final int lastIntervalSeconds;
  final int consecutiveCorrectAnswers;

  double get accuracy => attempts == 0 ? 0 : correctAnswers / attempts;
  int get accuracyPercent => (accuracy * 100).round();

  double get longReviewAccuracy =>
      longReviewAttempts == 0 ? 0 : longReviewCorrect / longReviewAttempts;

  bool get isDue =>
      nextReviewAt == null || !nextReviewAt!.isAfter(DateTime.now());

  Word copyWith({
    String? russian,
    String? english,
    String? russianExample,
    String? englishExample,
    DateTime? nextReviewAt,
    int? attempts,
    int? correctAnswers,
    int? longReviewAttempts,
    int? longReviewCorrect,
    int? lastIntervalSeconds,
    int? consecutiveCorrectAnswers,
  }) {
    return Word(
      id: id,
      russian: russian ?? this.russian,
      english: english ?? this.english,
      russianExample: russianExample ?? this.russianExample,
      englishExample: englishExample ?? this.englishExample,
      createdAt: createdAt,
      nextReviewAt: nextReviewAt ?? this.nextReviewAt,
      attempts: attempts ?? this.attempts,
      correctAnswers: correctAnswers ?? this.correctAnswers,
      longReviewAttempts: longReviewAttempts ?? this.longReviewAttempts,
      longReviewCorrect: longReviewCorrect ?? this.longReviewCorrect,
      lastIntervalSeconds: lastIntervalSeconds ?? this.lastIntervalSeconds,
      consecutiveCorrectAnswers:
          consecutiveCorrectAnswers ?? this.consecutiveCorrectAnswers,
    );
  }
}
