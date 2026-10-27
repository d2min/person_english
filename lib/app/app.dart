import 'package:flutter/material.dart';

import '../features/reminders/data/local_reminder_service.dart';
import '../features/progress/data/local_study_progress.dart';
import '../features/words/data/local_word_repository.dart';
import 'app_theme.dart';
import 'main_navigation.dart';

class WordApp extends StatelessWidget {
  const WordApp({
    required this.repository,
    required this.reminderService,
    required this.studyProgress,
    super.key,
  });

  final LocalWordRepository repository;
  final LocalReminderService reminderService;
  final LocalStudyProgress studyProgress;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Словарь',
      debugShowCheckedModeBanner: false,
      theme: buildAppTheme(),
      home: MainNavigation(
        repository: repository,
        reminderService: reminderService,
        studyProgress: studyProgress,
      ),
    );
  }
}
