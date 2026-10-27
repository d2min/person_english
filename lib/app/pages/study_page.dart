import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../features/progress/data/local_study_progress.dart';
import '../../features/words/data/local_word_repository.dart';
import '../../features/words/domain/review_logic.dart';
import '../../features/words/domain/study_mode.dart';
import '../../features/words/domain/word.dart';
import '../widgets/answer_feedback.dart';
import '../widgets/glass_card.dart';
import '../widgets/primary_button.dart';
import '../widgets/review_result_panel.dart';
import '../widgets/theme_palette.dart';

class StudyPage extends StatefulWidget {
  const StudyPage({
    required this.repository,
    required this.studyProgress,
    required this.words,
    this.mode = StudyMode.russianToEnglish,
    super.key,
  });

  final LocalWordRepository repository;
  final LocalStudyProgress studyProgress;
  final List<Word> words;
  final StudyMode mode;

  @override
  State<StudyPage> createState() => _StudyPageState();
}

class _StudyPageState extends State<StudyPage> {
  final _answerController = TextEditingController();
  int _index = 0;
  bool _checked = false;
  bool _correct = false;
  late final List<QuestionDirection> _directions;

  Word get _word => widget.words[_index];
  QuestionDirection get _direction => _directions[_index];
  bool get _isReverse => _direction == QuestionDirection.englishToRussian;
  String get _prompt => _isReverse ? _word.english : _word.russian;
  String get _example =>
      _isReverse ? _word.englishExample : _word.russianExample;
  String get _expected => _isReverse ? _word.russian : _word.english;

  @override
  void initState() {
    super.initState();
    _directions = buildQuestionDirections(widget.mode, widget.words.length);
  }

  @override
  void dispose() {
    _answerController.dispose();
    super.dispose();
  }

  void _checkAnswer() {
    if (_answerController.text.trim().isEmpty) return;
    setState(() {
      _checked = true;
      _correct = isAnswerCorrect(_answerController.text, _expected);
    });
    SystemSound.play(SystemSoundType.click);
    HapticFeedback.selectionClick();
  }

  Future<void> _grade(int grade) async {
    final updated = recordReview(_word, correct: _correct, grade: grade);
    await widget.repository.save(updated);
    await widget.studyProgress.recordReviewedWord(_word.id);
    SystemSound.play(SystemSoundType.click);
    HapticFeedback.lightImpact();
    if (!mounted) return;
    if (_index + 1 == widget.words.length) {
      Navigator.of(context).pop();
      return;
    }
    setState(() {
      _index++;
      _checked = false;
      _correct = false;
      _answerController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    if (widget.words.isEmpty) {
      return const Scaffold(
        body: Center(child: Text('Нет слов для повторения')),
      );
    }
    final allowOneDay = canUseOneDayInterval(_word);
    final allowSevenDays = canUseLongIntervals(_word);
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 12),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close_rounded),
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: inkColor,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: LinearProgressIndicator(
                        value: (_index + 1) / widget.words.length,
                        minHeight: 7,
                        backgroundColor: const Color(0xFFE7E9E0),
                        color: accentColor,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    '${_index + 1}/${widget.words.length}',
                    style: const TextStyle(
                      color: mutedColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(22, 12, 22, 28),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.mode == StudyMode.mixed
                          ? 'ПЕРЕВЕДИ СЛОВО'
                          : _isReverse
                          ? 'ПЕРЕВЕДИ НА РУССКИЙ'
                          : 'ПЕРЕВЕДИ НА АНГЛИЙСКИЙ',
                      style: TextStyle(
                        color: accentColor,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.4,
                      ),
                    ),
                    const SizedBox(height: 20),
                    GlassCard(
                      color: accentSoftColor,
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _prompt,
                            style: const TextStyle(
                              color: inkColor,
                              fontSize: 31,
                              fontWeight: FontWeight.w700,
                              letterSpacing: -0.5,
                            ),
                          ),
                          if (_example.isNotEmpty) ...[
                            const SizedBox(height: 12),
                            Text(
                              '«$_example»',
                              style: const TextStyle(
                                color: mutedColor,
                                height: 1.4,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 22),
                    if (!_checked)
                      TextField(
                        controller: _answerController,
                        autofocus: true,
                        textCapitalization: TextCapitalization.none,
                        autocorrect: false,
                        onSubmitted: (_) => _checkAnswer(),
                        decoration: const InputDecoration(
                          hintText: 'Твой ответ',
                          prefixIcon: Icon(Icons.edit_rounded),
                        ),
                      )
                    else
                      AnswerFeedback(
                        entered: _answerController.text,
                        expected: _expected,
                        correct: _correct,
                      ),
                    if (_checked)
                      ReviewResultPanel(
                        english: _expected,
                        englishExample: _isReverse
                            ? _word.russianExample
                            : _word.englishExample,
                        correct: _correct,
                        allowOneDay: allowOneDay,
                        allowSevenDays: allowSevenDays,
                        onGrade: _grade,
                      )
                    else ...[
                      const SizedBox(height: 16),
                      PrimaryButton(
                        label: 'Проверить ответ',
                        onPressed: _checkAnswer,
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
