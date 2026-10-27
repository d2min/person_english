import 'package:flutter/material.dart';

import 'glass_card.dart';
import 'grade_button.dart';
import 'section_title.dart';
import 'theme_palette.dart';

class ReviewResultPanel extends StatelessWidget {
  const ReviewResultPanel({
    required this.english,
    required this.englishExample,
    required this.correct,
    required this.allowOneDay,
    required this.allowSevenDays,
    required this.onGrade,
    super.key,
  });

  final String english;
  final String englishExample;
  final bool correct;
  final bool allowOneDay;
  final bool allowSevenDays;
  final ValueChanged<int> onGrade;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 14),
        GlassCard(
          padding: const EdgeInsets.all(17),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Правильный ответ',
                style: TextStyle(color: mutedColor, fontSize: 12),
              ),
              const SizedBox(height: 4),
              Text(
                english,
                style: const TextStyle(
                  fontSize: 21,
                  color: inkColor,
                  fontWeight: FontWeight.w700,
                ),
              ),
              if (englishExample.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  englishExample,
                  style: const TextStyle(color: mutedColor, height: 1.4),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 22),
        const SectionTitle('Как хорошо вспомнил?'),
        const SizedBox(height: 11),
        GradeButton(
          title: 'Снова',
          interval: '10 секунд',
          color: const Color(0xFFFFE9E7),
          onPressed: () => onGrade(0),
        ),
        const SizedBox(height: 8),
        GradeButton(
          title: 'С трудом',
          interval: '10 минут',
          color: const Color(0xFFFFF1E5),
          onPressed: () => onGrade(1),
        ),
        const SizedBox(height: 8),
        if (correct && allowOneDay) ...[
          GradeButton(
            title: 'Хорошо',
            interval: '1 день',
            color: const Color(0xFFEDF3DE),
            onPressed: () => onGrade(2),
          ),
        ],
        if (correct && allowSevenDays) ...[
          const SizedBox(height: 8),
          GradeButton(
            title: 'Легко',
            interval: '7 дней',
            color: accentSoftColor,
            onPressed: () => onGrade(3),
          ),
        ],
        if (correct && !allowOneDay) ...[
          const SizedBox(height: 10),
          const Text(
            'Для переноса на сутки нужны минимум 3 попытки, точность от 80% '
            'и 3 правильных ответа подряд.',
            style: TextStyle(color: mutedColor, fontSize: 12, height: 1.4),
          ),
        ],
      ],
    );
  }
}
