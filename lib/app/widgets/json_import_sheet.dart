import 'package:flutter/material.dart';

import '../../features/words/data/local_word_repository.dart';
import '../../features/words/domain/word.dart';
import '../../features/words/domain/word_import.dart';
import 'primary_button.dart';

const _jsonExample = '''[
  {
    "russian": "яблоко",
    "english": "apple",
    "russianExample": "Я ем яблоко.",
    "englishExample": "I eat an apple."
  },
  {
    "russian": "дом",
    "english": "house"
  }
]''';

Future<void> showJsonImportSheet(
  BuildContext context,
  LocalWordRepository repository,
) async {
  final imported = await showModalBottomSheet<int>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => _JsonImportSheet(repository: repository),
  );
  if (imported == null || !context.mounted) return;
  ScaffoldMessenger.of(context)
      .showSnackBar(SnackBar(content: Text('Добавлено слов: $imported')));
}

class _JsonImportSheet extends StatefulWidget {
  const _JsonImportSheet({required this.repository});

  final LocalWordRepository repository;

  @override
  State<_JsonImportSheet> createState() => _JsonImportSheetState();
}

class _JsonImportSheetState extends State<_JsonImportSheet> {
  final _controller = TextEditingController();
  String? _error;
  bool _importing = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _import() async {
    final words = _parse();
    if (words == null) return;
    setState(() => _importing = true);
    await widget.repository.importWords(words);
    if (mounted) Navigator.pop(context, words.length);
  }

  List<Word>? _parse() {
    try {
      final words = parseWordsJson(_controller.text);
      if (words.isEmpty) {
        setState(() => _error = 'В JSON должен быть хотя бы один объект.');
        return null;
      }
      return words;
    } on FormatException catch (error) {
      setState(() => _error = error.message);
      return null;
    }
  }

  Future<void> _showFormat() {
    return showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Формат JSON'),
        content: const SingleChildScrollView(
          child: SelectableText(
            'Вставь массив объектов. Обязательны поля russian и english; '
            'russianExample и englishExample можно не указывать.\n\n'
            'Слова добавляются к существующим и не заменяют их.\n\n'
            '$_jsonExample',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Понятно'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.sizeOf(context).height * .86,
        ),
        padding: const EdgeInsets.fromLTRB(22, 14, 22, 24),
        decoration: const BoxDecoration(
          color: Color(0xFFF7F8F3),
          borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
        ),
        child: ListView(
          shrinkWrap: true,
          children: [
            Center(
              child: Container(
                width: 34,
                height: 3,
                decoration: BoxDecoration(
                  color: const Color(0xFFD9DDD1),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
            const SizedBox(height: 18),
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Импорт слов',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                ),
                TextButton(
                  onPressed: _showFormat,
                  child: const Text('Формат JSON'),
                ),
              ],
            ),
            const SizedBox(height: 6),
            const Text(
              'Вставь сюда JSON-массив. Импорт добавит слова к словарю.',
              style: TextStyle(color: Color(0xFF73796F)),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: _controller,
              minLines: 8,
              maxLines: 14,
              keyboardType: TextInputType.multiline,
              autocorrect: false,
              decoration: const InputDecoration(
                hintText: 'Вставить JSON',
                alignLabelWithHint: true,
                border: OutlineInputBorder(),
              ),
            ),
            if (_error != null) ...[
              const SizedBox(height: 9),
              Text(
                _error!,
                style: const TextStyle(color: Color(0xFFB34336), fontSize: 13),
              ),
            ],
            const SizedBox(height: 16),
            PrimaryButton(
              label: _importing ? 'Импортируем…' : 'Импортировать',
              icon: Icons.download_rounded,
              enabled: !_importing,
              onPressed: _import,
            ),
          ],
        ),
      ),
    );
  }
}
