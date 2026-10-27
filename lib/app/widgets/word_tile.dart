import 'package:flutter/material.dart';

import '../../features/words/domain/review_logic.dart';
import '../../features/words/domain/word.dart';
import 'glass_card.dart';
import 'theme_palette.dart';

class WordTile extends StatelessWidget {
  const WordTile({
    required this.word,
    required this.onEdit,
    required this.onDelete,
    super.key,
  });

  final Word word;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final masteryLabel = wordMasteryLabel(word);
    final masteryColor = word.attempts == 0
        ? masteryNewColor
        : word.accuracy >= 0.8
        ? accentStrongColor
        : switch (masteryLabel) {
            'Сложно' => masteryDifficultyColor,
            'Изучается' => masteryWarningColor,
            _ => accentStrongColor,
          };
    return GlassCard(
      padding: const EdgeInsets.fromLTRB(17, 15, 8, 15),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: const Color(0xFFEDF3DE),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.translate_rounded,
              color: accentColor,
              size: 20,
            ),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  word.russian,
                  style: const TextStyle(
                    color: inkColor,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  word.english,
                  style: const TextStyle(color: mutedColor, fontSize: 13),
                ),
                const SizedBox(height: 4),
                Text(
                  word.attempts == 0
                      ? masteryLabel
                      : '${word.accuracyPercent}% · $masteryLabel',
                  style: TextStyle(
                    color: masteryColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'edit') onEdit();
              if (value == 'delete') onDelete();
            },
            itemBuilder: (context) => const [
              PopupMenuItem(value: 'edit', child: Text('Редактировать')),
              PopupMenuItem(value: 'delete', child: Text('Удалить')),
            ],
            icon: const Icon(Icons.more_horiz_rounded, color: mutedColor),
          ),
        ],
      ),
    );
  }
}
