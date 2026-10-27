import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'app/app.dart';
import 'features/progress/data/local_study_progress.dart';
import 'features/reminders/data/local_reminder_service.dart';
import 'features/words/data/hive_word_adapter.dart';
import 'features/words/data/local_word_repository.dart';
import 'features/words/domain/word.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  Hive.registerAdapter(WordAdapter());
  final box = await Hive.openBox<Word>('words');
  final settingsBox = await Hive.openBox<dynamic>('settings');
  final reminderService = LocalReminderService(settingsBox);
  await reminderService.initialize();
  runApp(
    WordApp(
      repository: LocalWordRepository(box),
      reminderService: reminderService,
      studyProgress: LocalStudyProgress(settingsBox),
    ),
  );
}
