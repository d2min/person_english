import 'dart:convert';

import 'word.dart';

List<Word> parseWordsJson(String source, {DateTime? importedAt}) {
  final Object? decoded;
  try {
    decoded = jsonDecode(source);
  } on FormatException catch (error) {
    throw FormatException('Некорректный JSON: ${error.message}');
  }
  if (decoded is! List) {
    throw const FormatException('Ожидается JSON-массив слов.');
  }

  final now = importedAt ?? DateTime.now();
  return [
    for (var index = 0; index < decoded.length; index++)
      _parseWord(decoded[index], index, now),
  ];
}

Word _parseWord(Object? value, int index, DateTime importedAt) {
  if (value is! Map) {
    throw FormatException('Элемент ${index + 1} должен быть JSON-объектом.');
  }
  final map = Map<String, dynamic>.from(value);
  final russian = _requiredString(map, 'russian', index);
  final english = _requiredString(map, 'english', index);
  final russianExample = _optionalString(map, 'russianExample', index);
  final englishExample = _optionalString(map, 'englishExample', index);
  return Word(
    id: '${importedAt.microsecondsSinceEpoch}-$index',
    russian: russian,
    english: english,
    russianExample: russianExample,
    englishExample: englishExample,
    createdAt: importedAt,
  );
}

String _requiredString(Map<String, dynamic> map, String key, int index) {
  final value = map[key];
  if (value is! String || value.trim().isEmpty) {
    throw FormatException(
      'В элементе ${index + 1} поле "$key" должно быть непустой строкой.',
    );
  }
  return value.trim();
}

String _optionalString(Map<String, dynamic> map, String key, int index) {
  final value = map[key];
  if (value == null) return '';
  if (value is! String) {
    throw FormatException(
      'В элементе ${index + 1} поле "$key" должно быть строкой.',
    );
  }
  return value.trim();
}
