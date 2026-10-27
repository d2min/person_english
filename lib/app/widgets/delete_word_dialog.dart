import 'package:flutter/material.dart';

import '../../features/words/data/local_word_repository.dart';
import '../../features/words/domain/word.dart';

Future<void> showDeleteWordDialog(
  BuildContext context,
  LocalWordRepository repository,
  Word word,
) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Удалить слово?'),
      content: Text('«${word.russian}» будет удалено из словаря.'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('Отмена'),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(context, true),
          child: const Text('Удалить'),
        ),
      ],
    ),
  );
  if (confirmed == true) await repository.delete(word.id);
}
