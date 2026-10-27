import 'package:flutter/material.dart';

import '../../features/words/data/local_word_repository.dart';
import '../../features/words/domain/word.dart';
import 'primary_button.dart';

Future<void> showWordEditor(
  BuildContext context,
  LocalWordRepository repository, [
  Word? word,
]) async {
  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => WordEditorSheet(repository: repository, word: word),
  );
}

class WordEditorSheet extends StatefulWidget {
  const WordEditorSheet({required this.repository, this.word, super.key});

  final LocalWordRepository repository;
  final Word? word;

  @override
  State<WordEditorSheet> createState() => _WordEditorSheetState();
}

class _WordEditorSheetState extends State<WordEditorSheet> {
  final _formKey = GlobalKey<FormState>();
  late final _russian = TextEditingController(text: widget.word?.russian ?? '');
  late final _english = TextEditingController(text: widget.word?.english ?? '');
  late final _russianExample = TextEditingController(
    text: widget.word?.russianExample ?? '',
  );
  late final _englishExample = TextEditingController(
    text: widget.word?.englishExample ?? '',
  );
  bool _saving = false;

  @override
  void dispose() {
    _russian.dispose();
    _english.dispose();
    _russianExample.dispose();
    _englishExample.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    final original = widget.word;
    final word = Word(
      id: original?.id ?? DateTime.now().microsecondsSinceEpoch.toString(),
      russian: _russian.text.trim(),
      english: _english.text.trim(),
      russianExample: _russianExample.text.trim(),
      englishExample: _englishExample.text.trim(),
      createdAt: original?.createdAt ?? DateTime.now(),
      nextReviewAt: original?.nextReviewAt,
      attempts: original?.attempts ?? 0,
      correctAnswers: original?.correctAnswers ?? 0,
      longReviewAttempts: original?.longReviewAttempts ?? 0,
      longReviewCorrect: original?.longReviewCorrect ?? 0,
      lastIntervalSeconds: original?.lastIntervalSeconds ?? 0,
      consecutiveCorrectAnswers: original?.consecutiveCorrectAnswers ?? 0,
    );
    await widget.repository.save(word);
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.sizeOf(context).height * .9,
        ),
        padding: const EdgeInsets.fromLTRB(22, 12, 22, 24),
        decoration: const BoxDecoration(
          color: Color(0xFFF7F8F3),
          borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
        ),
        child: Form(
          key: _formKey,
          child: ListView(
            shrinkWrap: true,
            children: [
              Center(
                child: Container(
                  width: 38,
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xFFD9DDD1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Text(
                widget.word == null ? 'Новое слово' : 'Редактировать слово',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 18),
              _EditorField(
                controller: _russian,
                label: 'Русское слово',
                required: true,
              ),
              const SizedBox(height: 11),
              _EditorField(
                controller: _english,
                label: 'Перевод на английский',
                required: true,
              ),
              const SizedBox(height: 11),
              _EditorField(
                controller: _russianExample,
                label: 'Пример на русском (необязательно)',
                maxLines: 2,
              ),
              const SizedBox(height: 11),
              _EditorField(
                controller: _englishExample,
                label: 'Пример на английском (необязательно)',
                maxLines: 2,
              ),
              const SizedBox(height: 17),
              PrimaryButton(
                label: _saving ? 'Сохраняем…' : 'Сохранить',
                icon: Icons.check_rounded,
                enabled: !_saving,
                onPressed: _save,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EditorField extends StatelessWidget {
  const _EditorField({
    required this.controller,
    required this.label,
    this.required = false,
    this.maxLines = 1,
  });

  final TextEditingController controller;
  final String label;
  final bool required;
  final int maxLines;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      textCapitalization: TextCapitalization.sentences,
      decoration: InputDecoration(labelText: label),
      validator: required
          ? (value) => value == null || value.trim().isEmpty
                ? 'Заполни это поле'
                : null
          : null,
    );
  }
}
