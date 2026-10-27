import 'package:hive_flutter/hive_flutter.dart';

import '../domain/word.dart';

class WordAdapter extends TypeAdapter<Word> {
  @override
  final int typeId = 0;

  @override
  Word read(BinaryReader reader) {
    final fields = <int, dynamic>{};
    for (var i = 0, count = reader.readByte(); i < count; i++) {
      fields[reader.readByte()] = reader.read();
    }
    return Word(
      id: fields[0] as String,
      russian: fields[1] as String,
      english: fields[2] as String,
      russianExample: fields[3] as String? ?? '',
      englishExample: fields[4] as String? ?? '',
      createdAt: DateTime.fromMillisecondsSinceEpoch(fields[5] as int),
      attempts: fields[6] as int? ?? 0,
      correctAnswers: fields[7] as int? ?? 0,
      nextReviewAt: fields[8] == null
          ? null
          : DateTime.fromMillisecondsSinceEpoch(fields[8] as int),
      longReviewAttempts: fields[9] as int? ?? 0,
      longReviewCorrect: fields[10] as int? ?? 0,
      lastIntervalSeconds: fields[11] as int? ?? 0,
      consecutiveCorrectAnswers: fields[12] as int? ?? 0,
    );
  }

  @override
  void write(BinaryWriter writer, Word word) {
    writer
      ..writeByte(13)
      ..writeByte(0)
      ..write(word.id)
      ..writeByte(1)
      ..write(word.russian)
      ..writeByte(2)
      ..write(word.english)
      ..writeByte(3)
      ..write(word.russianExample)
      ..writeByte(4)
      ..write(word.englishExample)
      ..writeByte(5)
      ..write(word.createdAt.millisecondsSinceEpoch)
      ..writeByte(6)
      ..write(word.attempts)
      ..writeByte(7)
      ..write(word.correctAnswers)
      ..writeByte(8)
      ..write(word.nextReviewAt?.millisecondsSinceEpoch)
      ..writeByte(9)
      ..write(word.longReviewAttempts)
      ..writeByte(10)
      ..write(word.longReviewCorrect)
      ..writeByte(11)
      ..write(word.lastIntervalSeconds)
      ..writeByte(12)
      ..write(word.consecutiveCorrectAnswers);
  }
}
