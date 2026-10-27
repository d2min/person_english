import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../domain/study_streak.dart';
import '../../words/domain/word.dart';

class LocalStudyProgress {
  LocalStudyProgress(this._settings);

  static const _dailyLimitKey = 'daily_word_limit';
  static const _reviewDateKey = 'daily_review_date';
  static const _reviewedIdsKey = 'daily_reviewed_word_ids';
  static const _studyDaysKey = 'study_day_keys';
  static const defaultDailyLimit = 30;

  final Box<dynamic> _settings;

  ValueListenable<Box<dynamic>> listenable() => _settings.listenable();

  int get dailyLimit =>
      _settings.get(_dailyLimitKey, defaultValue: defaultDailyLimit) as int;

  String get _todayKey => studyDateKey(DateTime.now());

  Set<String> get reviewedWordIdsToday {
    if (_settings.get(_reviewDateKey) != _todayKey) return {};
    return (_settings.get(_reviewedIdsKey, defaultValue: <String>[]) as List)
        .cast<String>()
        .toSet();
  }

  int get reviewedToday => reviewedWordIdsToday.length;

  int get remainingToday =>
      (dailyLimit - reviewedToday).clamp(0, dailyLimit).toInt();

  Set<String> get studyDays {
    return (_settings.get(_studyDaysKey, defaultValue: <String>[]) as List)
        .cast<String>()
        .toSet();
  }

  int get currentStreak => calculateStudyStreak(studyDays);

  List<Word> wordsForToday(Iterable<Word> words) {
    final reviewed = reviewedWordIdsToday;
    var newWordSlots = remainingToday;
    final selected = <Word>[];
    for (final word in words) {
      if (reviewed.contains(word.id)) {
        selected.add(word);
      } else if (newWordSlots > 0) {
        selected.add(word);
        newWordSlots--;
      }
    }
    return selected;
  }

  Future<void> setDailyLimit(int limit) async {
    if (limit < 1) {
      throw ArgumentError.value(
        limit,
        'limit',
        'Дневной лимит должен быть больше нуля.',
      );
    }
    await _settings.put(_dailyLimitKey, limit);
  }

  Future<void> recordReviewedWord(String wordId) async {
    final reviewed = reviewedWordIdsToday..add(wordId);
    final days = studyDays..add(_todayKey);
    await _settings.putAll({
      _reviewDateKey: _todayKey,
      _reviewedIdsKey: reviewed.toList(),
      _studyDaysKey: days.toList()..sort(),
    });
  }
}
