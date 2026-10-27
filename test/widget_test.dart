import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:person_english/app/app.dart';
import 'package:person_english/features/progress/data/local_study_progress.dart';
import 'package:person_english/features/progress/domain/study_streak.dart';
import 'package:person_english/features/reminders/data/local_reminder_service.dart';
import 'package:person_english/features/words/data/hive_word_adapter.dart';
import 'package:person_english/features/words/data/local_word_repository.dart';
import 'package:person_english/features/words/domain/review_logic.dart';
import 'package:person_english/features/words/domain/study_mode.dart';
import 'package:person_english/features/words/domain/word.dart';
import 'package:person_english/features/words/domain/word_import.dart';

void main() {
  late Directory hiveDirectory;
  late Box<Word> box;
  late Box<dynamic> settingsBox;

  setUpAll(() async {
    hiveDirectory = await Directory.systemTemp.createTemp('person-english-');
    Hive.init(hiveDirectory.path);
    Hive.registerAdapter(WordAdapter());
  });

  setUp(() async {
    box = await Hive.openBox<Word>('words');
    settingsBox = await Hive.openBox<dynamic>('settings');
    await box.clear();
    await settingsBox.clear();
  });

  tearDown(() async {
    await box.close();
    await settingsBox.close();
  });

  tearDownAll(() async {
    await Hive.close();
    await hiveDirectory.delete(recursive: true);
  });

  testWidgets('dashboard opens with local empty dictionary', (tester) async {
    await tester.pumpWidget(
      WordApp(
        repository: LocalWordRepository(box),
        reminderService: LocalReminderService(settingsBox),
        studyProgress: LocalStudyProgress(settingsBox),
      ),
    );
    expect(find.text('Нет слов к повторению'), findsOneWidget);
    expect(find.text('0'), findsOneWidget);
    expect(find.text('Словарь'), findsOneWidget);
  });

  test('answers ignore case but preserve spaces', () {
    expect(isAnswerCorrect('Apple', 'apple'), isTrue);
    expect(isAnswerCorrect('ice cream', 'ice cream'), isTrue);
    expect(isAnswerCorrect('icecream', 'ice cream'), isFalse);
    expect(isAnswerCorrect(' apple', 'apple'), isFalse);
  });

  test('study modes choose the expected question directions', () {
    expect(
      buildQuestionDirections(StudyMode.russianToEnglish, 3),
      everyElement(QuestionDirection.russianToEnglish),
    );
    expect(
      buildQuestionDirections(StudyMode.englishToRussian, 3),
      everyElement(QuestionDirection.englishToRussian),
    );
    expect(
      buildQuestionDirections(
        StudyMode.mixed,
        12,
        nextBool: _alternatingDirection,
      ),
      [
        QuestionDirection.englishToRussian,
        QuestionDirection.russianToEnglish,
        QuestionDirection.englishToRussian,
        QuestionDirection.russianToEnglish,
        QuestionDirection.englishToRussian,
        QuestionDirection.russianToEnglish,
        QuestionDirection.englishToRussian,
        QuestionDirection.russianToEnglish,
        QuestionDirection.englishToRussian,
        QuestionDirection.russianToEnglish,
        QuestionDirection.englishToRussian,
        QuestionDirection.russianToEnglish,
      ],
    );
  });

  test('JSON import parses required and optional word fields', () {
    final imported = parseWordsJson(
      '[{"russian":" дом ","english":" house ","englishExample":"My house."}]',
      importedAt: DateTime(2026, 10, 27),
    );
    expect(imported, hasLength(1));
    expect(imported.single.russian, 'дом');
    expect(imported.single.english, 'house');
    expect(imported.single.russianExample, isEmpty);
    expect(imported.single.englishExample, 'My house.');
    expect(imported.single.createdAt, DateTime(2026, 10, 27));
  });

  test('JSON import rejects invalid rows and non-array roots', () {
    expect(() => parseWordsJson('{}'), throwsFormatException);
    expect(() => parseWordsJson('[{"russian":"дом"}]'), throwsFormatException);
    expect(
      () => parseWordsJson('[{"russian":"дом","english":""}]'),
      throwsFormatException,
    );
  });

  test('repository imports parsed words into local Hive storage', () async {
    final imported = parseWordsJson(
      '[{"russian":"яблоко","english":"apple"}]',
      importedAt: DateTime(2026, 10, 27),
    );
    await LocalWordRepository(box).importWords(imported);
    expect(box.values, hasLength(1));
    expect(box.values.single.english, 'apple');
  });

  test('reminder time is stored locally', () async {
    final service = LocalReminderService(settingsBox);
    await service.setTime(hour: 7, minute: 35);
    expect(service.hour, 7);
    expect(service.minute, 35);
    expect(service.isEnabled, isFalse);
  });

  test('daily limit counts distinct words and can be changed', () async {
    final progress = LocalStudyProgress(settingsBox);
    expect(progress.dailyLimit, 30);
    await progress.setDailyLimit(2);
    await progress.recordReviewedWord('first');
    await progress.recordReviewedWord('first');
    expect(progress.reviewedToday, 1);
    expect(progress.remainingToday, 1);
    await progress.recordReviewedWord('second');
    expect(progress.reviewedToday, 2);
    expect(progress.remainingToday, 0);
    expect(
      progress
          .wordsForToday([_word('first'), _word('second'), _word('third')])
          .map((word) => word.id),
      ['first', 'second'],
    );
    await progress.setDailyLimit(1);
    expect(progress.remainingToday, 0);
  });

  test(
    'daily word selection allows reviewed words and caps new unique words',
    () async {
      final progress = LocalStudyProgress(settingsBox);
      await progress.setDailyLimit(2);
      await progress.recordReviewedWord('first');
      await progress.recordReviewedWord('second');
      expect(
        progress
            .wordsForToday([
              _word('first'),
              _word('second'),
              _word('third'),
              _word('fourth'),
            ])
            .map((word) => word.id),
        ['first', 'second'],
      );
    },
  );

  test('study streak tolerates one missed day and expires after two', () {
    final studyDays = {'2026-03-10', '2026-03-08', '2026-03-07'};
    expect(calculateStudyStreak(studyDays, now: DateTime(2026, 3, 10)), 3);
    expect(calculateStudyStreak(studyDays, now: DateTime(2026, 3, 11)), 3);
    expect(calculateStudyStreak(studyDays, now: DateTime(2026, 3, 12)), 0);
  });

  test(
    'reminder timezone uses the device offset without a platform channel',
    () {
      final location = createDeviceLocalTimezone(
        offset: const Duration(hours: 3),
        abbreviation: 'UTC+03',
      );
      expect(location.name, 'device-local');
      expect(location.currentTimeZone.offset, const Duration(hours: 3));
      expect(location.currentTimeZone.abbreviation, 'UTC+03');
    },
  );

  test('long intervals require age and repeated long-term success', () {
    final oldEnough = DateTime(2026, 10, 27);
    final word = Word(
      id: '1',
      russian: 'слово',
      english: 'word',
      createdAt: oldEnough.subtract(const Duration(days: 8)),
      attempts: 4,
      correctAnswers: 4,
      consecutiveCorrectAnswers: 3,
      longReviewAttempts: 3,
      longReviewCorrect: 3,
    );
    expect(canUseLongIntervals(word, now: oldEnough), isTrue);
    expect(
      canUseLongIntervals(word.copyWith(longReviewCorrect: 2), now: oldEnough),
      isFalse,
    );
    expect(
      canUseLongIntervals(
        Word(
          id: word.id,
          russian: word.russian,
          english: word.english,
          createdAt: oldEnough,
          attempts: word.attempts,
          correctAnswers: word.correctAnswers,
          consecutiveCorrectAnswers: word.consecutiveCorrectAnswers,
          longReviewAttempts: word.longReviewAttempts,
          longReviewCorrect: word.longReviewCorrect,
        ),
        now: oldEnough,
      ),
      isFalse,
    );
  });

  test('incorrect answer cannot postpone review for more than ten minutes', () {
    final now = DateTime(2026, 10, 27, 15);
    final word = Word(
      id: 'weak',
      russian: 'слово',
      english: 'word',
      createdAt: now.subtract(const Duration(days: 30)),
      attempts: 5,
      correctAnswers: 5,
      consecutiveCorrectAnswers: 5,
      longReviewAttempts: 5,
      longReviewCorrect: 5,
    );

    for (final grade in [0, 1, 2, 3]) {
      final reviewed = recordReview(
        word,
        correct: false,
        grade: grade,
        now: now,
      );
      final expectedInterval = grade == 0
          ? const Duration(seconds: 10)
          : const Duration(minutes: 10);
      expect(reviewed.nextReviewAt, now.add(expectedInterval));
      expect(reviewed.lastIntervalSeconds, expectedInterval.inSeconds);
      expect(reviewed.consecutiveCorrectAnswers, 0);
    }
  });

  test(
    'longer intervals require a correct answer and learned-word eligibility',
    () {
      final now = DateTime(2026, 10, 27, 15);
      final newWord = Word(
        id: 'new',
        russian: 'слово',
        english: 'word',
        createdAt: now,
      );
      final knownWord = Word(
        id: 'known',
        russian: 'слово',
        english: 'word',
        createdAt: now.subtract(const Duration(days: 8)),
        attempts: 4,
        correctAnswers: 4,
        consecutiveCorrectAnswers: 3,
        longReviewAttempts: 3,
        longReviewCorrect: 3,
      );

      expect(
        recordReview(newWord, correct: true, grade: 2, now: now).nextReviewAt,
        now.add(const Duration(minutes: 10)),
      );
      expect(
        recordReview(newWord, correct: true, grade: 3, now: now).nextReviewAt,
        now.add(const Duration(minutes: 10)),
      );
      expect(
        recordReview(knownWord, correct: true, grade: 3, now: now).nextReviewAt,
        now.add(const Duration(days: 7)),
      );
    },
  );

  test(
    'one-day interval requires high per-word accuracy and a correct streak',
    () {
      final now = DateTime(2026, 10, 27, 15);
      final weak = Word(
        id: 'weak',
        russian: 'слово',
        english: 'word',
        createdAt: now,
        attempts: 5,
        correctAnswers: 3,
        consecutiveCorrectAnswers: 3,
      );
      final inconsistent = Word(
        id: 'inconsistent',
        russian: 'слово',
        english: 'word',
        createdAt: now,
        attempts: 5,
        correctAnswers: 5,
        consecutiveCorrectAnswers: 2,
      );
      final steady = Word(
        id: 'steady',
        russian: 'слово',
        english: 'word',
        createdAt: now,
        attempts: 5,
        correctAnswers: 4,
        consecutiveCorrectAnswers: 3,
      );

      expect(canUseOneDayInterval(weak), isFalse);
      expect(canUseOneDayInterval(inconsistent), isFalse);
      expect(canUseOneDayInterval(steady), isTrue);
      expect(wordMasteryLabel(weak), 'Изучается');
      expect(wordMasteryLabel(steady), 'Закрепляется');
      expect(
        recordReview(
          steady,
          correct: false,
          grade: 2,
          now: now,
        ).consecutiveCorrectAnswers,
        0,
      );
    },
  );

  test('Hive adapter keeps word and review data', () async {
    final word = Word(
      id: '1',
      russian: 'дом',
      english: 'house',
      russianExample: 'Это мой дом.',
      englishExample: 'This is my house.',
      createdAt: DateTime(2026, 1, 2),
      attempts: 4,
      correctAnswers: 3,
      nextReviewAt: DateTime(2026, 1, 3),
      longReviewAttempts: 2,
      longReviewCorrect: 2,
      lastIntervalSeconds: 86400,
      consecutiveCorrectAnswers: 2,
    );
    await box.put(word.id, word);
    expect(box.get(word.id)?.english, 'house');
    expect(box.get(word.id)?.longReviewCorrect, 2);
    expect(box.get(word.id)?.nextReviewAt, DateTime(2026, 1, 3));
    expect(box.get(word.id)?.consecutiveCorrectAnswers, 2);
  });
}

var _direction = true;

bool _alternatingDirection() {
  _direction = !_direction;
  return _direction;
}

Word _word(String id) =>
    Word(id: id, russian: id, english: id, createdAt: DateTime(2026));
