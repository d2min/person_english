import 'package:flutter/material.dart';

import '../../features/progress/data/local_study_progress.dart';
import '../../features/words/data/local_word_repository.dart';
import '../../features/words/domain/review_logic.dart';
import '../widgets/glass_card.dart';
import '../widgets/metric_card.dart';
import '../widgets/page_scaffold.dart';
import '../widgets/stat_line.dart';
import '../widgets/theme_palette.dart';

class StatisticsPage extends StatelessWidget {
  const StatisticsPage({
    required this.repository,
    required this.studyProgress,
    super.key,
  });

  final LocalWordRepository repository;
  final LocalStudyProgress studyProgress;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: repository.listenable(),
      builder: (context, box, _) {
        final words = repository.words;
        final attempts = words.fold<int>(0, (sum, word) => sum + word.attempts);
        final correct = words.fold<int>(
          0,
          (sum, word) => sum + word.correctAnswers,
        );
        final learned = words.where((word) => canUseLongIntervals(word)).length;
        final due = repository.dueWords.length;
        final accuracy = attempts == 0 ? 0 : (correct / attempts * 100).round();
        return ValueListenableBuilder(
          valueListenable: studyProgress.listenable(),
          builder: (context, _, _) => PageScaffold(
            title: 'Статистика',
            children: [
              GlassCard(
                color: accentSoftColor,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Точность ответов',
                      style: TextStyle(color: mutedColor),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '$accuracy%',
                          style: const TextStyle(
                            fontSize: 42,
                            color: inkColor,
                            fontWeight: FontWeight.w700,
                            letterSpacing: -1,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: LinearProgressIndicator(
                        value: attempts == 0 ? 0 : correct / attempts,
                        minHeight: 8,
                        backgroundColor: Colors.white.withValues(alpha: 0.8),
                        color: accentColor,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  Expanded(
                    child: MetricCard(
                      icon: Icons.style_rounded,
                      value: '${words.length}',
                      label: 'всего слов',
                      tint: const Color(0xFFEDF3DE),
                      iconColor: accentStrongColor,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: MetricCard(
                      icon: Icons.replay_rounded,
                      value: '$attempts',
                      label: 'повторений',
                      tint: const Color(0xFFF2F1E8),
                      iconColor: accentColor,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              GlassCard(
                child: Column(
                  children: [
                    StatLine(
                      icon: Icons.event_available_rounded,
                      label: 'Ждут повторения',
                      value: '$due',
                      color: accentColor,
                    ),
                    const Divider(height: 24),
                    StatLine(
                      icon: Icons.local_fire_department_rounded,
                      label: 'Уверенно выучено',
                      value: '$learned',
                      color: accentColor,
                    ),
                    const Divider(height: 24),
                    StatLine(
                      icon: Icons.check_rounded,
                      label: 'Верных ответов',
                      value: '$correct',
                      color: accentStrongColor,
                    ),
                    const Divider(height: 24),
                    StatLine(
                      icon: Icons.local_fire_department_rounded,
                      label: 'Серия занятий',
                      value: '${studyProgress.currentStreak}',
                      color: accentColor,
                    ),
                    const Divider(height: 24),
                    StatLine(
                      icon: Icons.today_rounded,
                      label: 'Слов сегодня',
                      value:
                          '${studyProgress.reviewedToday}/${studyProgress.dailyLimit}',
                      color: accentStrongColor,
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
