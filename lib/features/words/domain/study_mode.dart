import 'dart:math';

enum StudyMode {
  russianToEnglish,
  englishToRussian,
  mixed;

  String get label => switch (this) {
    StudyMode.russianToEnglish => 'Русский → English',
    StudyMode.englishToRussian => 'English → русский',
    StudyMode.mixed => 'Смешанный',
  };
}

enum QuestionDirection { russianToEnglish, englishToRussian }

List<QuestionDirection> buildQuestionDirections(
  StudyMode mode,
  int count, {
  bool Function()? nextBool,
}) {
  final random = Random();
  return List.generate(count, (_) {
    return switch (mode) {
      StudyMode.russianToEnglish => QuestionDirection.russianToEnglish,
      StudyMode.englishToRussian => QuestionDirection.englishToRussian,
      StudyMode.mixed =>
        (nextBool ?? random.nextBool)()
            ? QuestionDirection.russianToEnglish
            : QuestionDirection.englishToRussian,
    };
  });
}
