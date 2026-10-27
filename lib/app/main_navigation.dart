import 'package:flutter/material.dart';

import '../features/words/data/local_word_repository.dart';
import '../features/reminders/data/local_reminder_service.dart';
import '../features/progress/data/local_study_progress.dart';
import 'pages/home_page.dart';
import 'pages/library_page.dart';
import 'pages/settings_page.dart';
import 'pages/statistics_page.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({
    required this.repository,
    required this.reminderService,
    required this.studyProgress,
    super.key,
  });

  final LocalWordRepository repository;
  final LocalReminderService reminderService;
  final LocalStudyProgress studyProgress;

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final pages = [
      DashboardPage(
        repository: widget.repository,
        studyProgress: widget.studyProgress,
        onOpenLibrary: () => setState(() => _index = 1),
      ),
      LibraryPage(repository: widget.repository),
      StatisticsPage(
        repository: widget.repository,
        studyProgress: widget.studyProgress,
      ),
      SettingsPage(
        reminderService: widget.reminderService,
        studyProgress: widget.studyProgress,
      ),
    ];
    return Scaffold(
      body: IndexedStack(index: _index, children: pages),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Container(
          margin: const EdgeInsets.fromLTRB(18, 0, 18, 12),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.92),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: const Color(0xFFE6E9DF)),
            boxShadow: const [
              BoxShadow(
                color: Color(0x0C26301F),
                blurRadius: 16,
                offset: Offset(0, 5),
              ),
            ],
          ),
          child: NavigationBar(
            height: 66,
            backgroundColor: Colors.transparent,
            elevation: 0,
            selectedIndex: _index,
            onDestinationSelected: (index) => setState(() => _index = index),
            destinations: const [
              NavigationDestination(
                icon: Icon(Icons.home_rounded),
                label: 'Главная',
              ),
              NavigationDestination(
                icon: Icon(Icons.menu_book_rounded),
                label: 'Словарь',
              ),
              NavigationDestination(
                icon: Icon(Icons.insights_rounded),
                label: 'Статистика',
              ),
              NavigationDestination(
                icon: Icon(Icons.settings_rounded),
                label: 'Настройки',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
