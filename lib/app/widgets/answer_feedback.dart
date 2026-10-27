import 'package:flutter/material.dart';

import 'glass_card.dart';

class AnswerFeedback extends StatelessWidget {
  const AnswerFeedback({
    required this.entered,
    required this.expected,
    required this.correct,
    super.key,
  });

  final String entered;
  final String expected;
  final bool correct;

  @override
  Widget build(BuildContext context) {
    final typedRunes = entered.runes.toList();
    final expectedRunes = expected.runes.toList();
    final displayRunes = typedRunes.isEmpty ? <int>[32] : typedRunes;
    return GlassCard(
      padding: const EdgeInsets.all(17),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            correct ? 'Отлично, верно!' : 'Почти! Сравни ответ:',
            style: TextStyle(
              color: correct
                  ? const Color(0xFF32966A)
                  : const Color(0xFFD65F55),
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 11),
          Wrap(
            children: [
              for (var i = 0; i < displayRunes.length; i++)
                Text(
                  String.fromCharCode(displayRunes[i]),
                  style: TextStyle(
                    color:
                        i < expectedRunes.length &&
                            String.fromCharCode(displayRunes[i])
                                    .toLowerCase() ==
                                String.fromCharCode(expectedRunes[i])
                                    .toLowerCase()
                        ? const Color(0xFF32966A)
                        : const Color(0xFFD65F55),
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
