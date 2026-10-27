import 'package:flutter/material.dart';

import 'glass_card.dart';
import 'primary_button.dart';
import 'theme_palette.dart';

class LibraryEmptyState extends StatelessWidget {
  const LibraryEmptyState({
    required this.hasWords,
    required this.onAdd,
    super.key,
  });

  final bool hasWords;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const Icon(Icons.menu_book_rounded, size: 40, color: accentColor),
          const SizedBox(height: 12),
          Text(
            hasWords ? 'Ничего не найдено' : 'Словарь пока пуст',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 6),
          Text(
            hasWords
                ? 'Попробуй изменить поисковый запрос.'
                : 'Добавь первое слово.',
            textAlign: TextAlign.center,
            style: const TextStyle(color: mutedColor),
          ),
          if (!hasWords) ...[
            const SizedBox(height: 18),
            PrimaryButton(
              label: 'Добавить слово',
              icon: Icons.add_rounded,
              onPressed: onAdd,
            ),
          ],
        ],
      ),
    );
  }
}
