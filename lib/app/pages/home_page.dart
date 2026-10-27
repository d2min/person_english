import 'package:flutter/material.dart';

import '../../features/progress/data/local_study_progress.dart';
import '../../features/words/data/local_word_repository.dart';
import '../../features/words/domain/study_mode.dart';
import '../../features/words/domain/word.dart';
import '../widgets/glass_card.dart';
import '../widgets/metric_card.dart';
import '../widgets/page_scaffold.dart';
import '../widgets/primary_button.dart';
import '../widgets/section_title.dart';
import '../widgets/study_mode_button.dart';
import '../widgets/theme_palette.dart';
import 'study_page.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({
    required this.repository,
    required this.studyProgress,
    required this.onOpenLibrary,
    super.key,
  });

  final LocalWordRepository repository;
  final LocalStudyProgress studyProgress;
  final VoidCallback onOpenLibrary;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: repository.listenable(),
      builder: (context, _, _) {
        final words = repository.words;
        final accuracy = words.fold<int>(
          0,
          (sum, word) => sum + word.correctAnswers,
        );
        final attempts = words.fold<int>(0, (sum, word) => sum + word.attempts);
        return ValueListenableBuilder(
          valueListenable: studyProgress.listenable(),
          builder: (context, _, _) {
            final remainingToday = studyProgress.remainingToday;
            final due = studyProgress.wordsForToday(repository.dueWords);
            final studyWords = studyProgress.wordsForToday(words);
            return PageScaffold(
              title: 'Главная',
              children: [
                GlassCard(
                  color: accentSoftColor,
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        due.isNotEmpty
                            ? '${due.length} ${wordForm(due.length)} ждут повторения'
                            : remainingToday == 0
                            ? 'Дневной лимит достигнут'
                            : 'Нет слов к повторению',
                        style: const TextStyle(
                          color: inkColor,
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${studyProgress.reviewedToday}/${studyProgress.dailyLimit} сегодня'
                        '  ·  Серия ${studyProgress.currentStreak}',
                        style: const TextStyle(color: mutedColor, fontSize: 13),
                      ),
                      const SizedBox(height: 20),
                      PrimaryButton(
                        label: due.isNotEmpty
                            ? 'Начать повторение'
                            : remainingToday == 0
                            ? 'Лимит на сегодня исчерпан'
                            : 'Открыть словарь',
                        icon: due.isNotEmpty
                            ? Icons.play_arrow_rounded
                            : remainingToday == 0
                            ? Icons.check_rounded
                            : Icons.menu_book_rounded,
                        enabled: due.isNotEmpty || remainingToday > 0,
                        onPressed: () {
                          if (due.isEmpty) {
                            onOpenLibrary();
                          } else {
                            openStudy(context, repository, studyProgress, due);
                          }
                        },
                      ),
                      if (words.isNotEmpty) ...[
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: StudyModeButton(
                                label: 'Обратный тест',
                                icon: Icons.swap_horiz_rounded,
                                enabled: studyWords.isNotEmpty,
                                onPressed: () => openStudy(
                                  context,
                                  repository,
                                  studyProgress,
                                  studyWords,
                                  mode: StudyMode.englishToRussian,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: StudyModeButton(
                                label: 'Смешанный',
                                icon: Icons.shuffle_rounded,
                                enabled: studyWords.isNotEmpty,
                                onPressed: () => openStudy(
                                  context,
                                  repository,
                                  studyProgress,
                                  studyWords,
                                  mode: StudyMode.mixed,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                const SectionTitle('Прогресс'),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: MetricCard(
                        icon: Icons.style_rounded,
                        value: '${words.length}',
                        label: 'слов в словаре',
                        tint: const Color(0xFFEDF3DE),
                        iconColor: accentStrongColor,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: MetricCard(
                        icon: Icons.check_circle_rounded,
                        value: attempts == 0
                            ? '—'
                            : '${(accuracy / attempts * 100).round()}%',
                        label: 'точность',
                        tint: const Color(0xFFF2F1E8),
                        iconColor: accentColor,
                      ),
                    ),
                  ],
                ),
              ],
            );
          },
        );
      },
    );
  }
}

void openStudy(
  BuildContext context,
  LocalWordRepository repository,
  LocalStudyProgress studyProgress,
  List<Word> words, {
  StudyMode mode = StudyMode.russianToEnglish,
}) {
  Navigator.of(context).push(
    MaterialPageRoute<void>(
      builder: (context) => StudyPage(
        repository: repository,
        studyProgress: studyProgress,
        words: words,
        mode: mode,
      ),
    ),
  );
}

String wordForm(int count) {
  final lastTwo = count % 100;
  final last = count % 10;
  if (lastTwo >= 11 && lastTwo <= 14) return 'слов';
  if (last == 1) return 'слово';
  if (last >= 2 && last <= 4) return 'слова';
  return 'слов';
}
