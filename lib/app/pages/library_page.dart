import 'package:flutter/material.dart';

import '../../features/words/data/local_word_repository.dart';
import '../widgets/delete_word_dialog.dart';
import '../widgets/json_import_sheet.dart';
import '../widgets/library_empty_state.dart';
import '../widgets/page_scaffold.dart';
import '../widgets/section_title.dart';
import '../widgets/theme_palette.dart';
import '../widgets/word_editor_sheet.dart';
import '../widgets/word_tile.dart';

class LibraryPage extends StatefulWidget {
  const LibraryPage({required this.repository, super.key});

  final LocalWordRepository repository;

  @override
  State<LibraryPage> createState() => _LibraryPageState();
}

class _LibraryPageState extends State<LibraryPage> {
  final _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: widget.repository.listenable(),
      builder: (context, box, _) {
        final words = widget.repository.words.where((word) {
          final query = _query.toLowerCase();
          return word.russian.toLowerCase().contains(query) ||
              word.english.toLowerCase().contains(query);
        }).toList();
        return PageScaffold(
          title: 'Мой словарь',
          children: [
            TextField(
              controller: _searchController,
              onChanged: (value) => setState(() => _query = value.trim()),
              decoration: const InputDecoration(
                hintText: 'Найти слово',
                prefixIcon: Icon(Icons.search_rounded),
              ),
            ),
            const SizedBox(height: 16),
            Align(
              alignment: Alignment.centerRight,
              child: OutlinedButton.icon(
                onPressed: () =>
                    showJsonImportSheet(context, widget.repository),
                icon: const Icon(Icons.data_object_rounded, size: 18),
                label: const Text('Импорт JSON'),
              ),
            ),
            const SizedBox(height: 12),
            if (words.isEmpty)
              LibraryEmptyState(
                hasWords: widget.repository.words.isNotEmpty,
                onAdd: () => showWordEditor(context, widget.repository),
              )
            else ...[
              SectionTitle(
                'Слова',
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '${widget.repository.words.length}',
                      style: const TextStyle(color: mutedColor),
                    ),
                    const SizedBox(width: 8),
                    TextButton.icon(
                      onPressed: () =>
                          showWordEditor(context, widget.repository),
                      icon: const Icon(Icons.add_rounded, size: 19),
                      label: const Text('Добавить'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              ...words.map(
                (word) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: WordTile(
                    word: word,
                    onEdit: () =>
                        showWordEditor(context, widget.repository, word),
                    onDelete: () =>
                        showDeleteWordDialog(context, widget.repository, word),
                  ),
                ),
              ),
            ],
          ],
        );
      },
    );
  }
}
