import 'word.dart';

const reviewIntervals = <Duration>[
  Duration(seconds: 10),
  Duration(minutes: 10),
  Duration(days: 1),
  Duration(days: 7),
];

bool canUseLongIntervals(Word word, {DateTime? now}) {
  final currentTime = now ?? DateTime.now();
  final oldEnough = currentTime.difference(word.createdAt).inDays >= 7;
  return canUseOneDayInterval(word) &&
      oldEnough &&
      word.longReviewAttempts >= 3 &&
      word.longReviewAccuracy >= 0.8;
}

bool canUseOneDayInterval(Word word) =>
    word.attempts >= 3 &&
    word.accuracy >= 0.8 &&
    word.consecutiveCorrectAnswers >= 3;

String wordMasteryLabel(Word word, {DateTime? now}) {
  if (word.attempts == 0) return 'Новое';
  if (canUseLongIntervals(word, now: now)) return 'Выучено';
  if (canUseOneDayInterval(word)) return 'Закрепляется';
  if (word.accuracy < 0.5) return 'Сложно';
  return 'Изучается';
}

bool isAnswerCorrect(String entered, String expected) =>
    entered.toLowerCase() == expected.toLowerCase();

Word recordReview(
  Word word, {
  required bool correct,
  required int grade,
  DateTime? now,
}) {
  if (grade < 0 || grade >= reviewIntervals.length) {
    throw RangeError.range(grade, 0, reviewIntervals.length - 1, 'grade');
  }
  final canUseOneDay = correct && canUseOneDayInterval(word);
  final canUseSevenDays = canUseOneDay && canUseLongIntervals(word, now: now);
  final effectiveGrade = !correct
      ? grade.clamp(0, 1)
      : grade == 3 && !canUseSevenDays
      ? canUseOneDay
            ? 2
            : 1
      : grade == 2 && !canUseOneDay
      ? 1
      : grade;
  final reviewTime = now ?? DateTime.now();
  final wasLongReview = word.lastIntervalSeconds >= Duration(days: 1).inSeconds;
  return word.copyWith(
    attempts: word.attempts + 1,
    correctAnswers: word.correctAnswers + (correct ? 1 : 0),
    longReviewAttempts: word.longReviewAttempts + (wasLongReview ? 1 : 0),
    longReviewCorrect:
        word.longReviewCorrect + (wasLongReview && correct ? 1 : 0),
    consecutiveCorrectAnswers: correct ? word.consecutiveCorrectAnswers + 1 : 0,
    lastIntervalSeconds: reviewIntervals[effectiveGrade].inSeconds,
    nextReviewAt: reviewTime.add(reviewIntervals[effectiveGrade]),
  );
}
