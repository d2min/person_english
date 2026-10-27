import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../domain/word.dart';

class LocalWordRepository {
  const LocalWordRepository(this._box);

  final Box<Word> _box;

  ValueListenable<Box<Word>> listenable() => _box.listenable();

  List<Word> get words => _box.values.toList()
    ..sort(
      (a, b) => a.russian.toLowerCase().compareTo(b.russian.toLowerCase()),
    );

  List<Word> get dueWords =>
      words.where((word) => word.isDue).toList()..sort((a, b) {
        final aDate = a.nextReviewAt ?? DateTime.fromMillisecondsSinceEpoch(0);
        final bDate = b.nextReviewAt ?? DateTime.fromMillisecondsSinceEpoch(0);
        return aDate.compareTo(bDate);
      });

  Future<void> save(Word word) => _box.put(word.id, word);

  Future<void> importWords(List<Word> words) async {
    await _box.putAll({for (final word in words) word.id: word});
  }

  Future<void> delete(String id) => _box.delete(id);

  Word? find(String id) => _box.get(id);
}
