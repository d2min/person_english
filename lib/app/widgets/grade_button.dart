import 'package:flutter/material.dart';

import 'theme_palette.dart';

class GradeButton extends StatelessWidget {
  const GradeButton({
    required this.title,
    required this.interval,
    required this.color,
    required this.onPressed,
    super.key,
  });

  final String title;
  final String interval;
  final Color color;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 56,
      width: double.infinity,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          backgroundColor: color.withValues(alpha: 0.72),
          side: BorderSide(color: color),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  color: inkColor,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            Text(
              interval,
              style: const TextStyle(
                color: mutedColor,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(width: 7),
            const Icon(
              Icons.chevron_right_rounded,
              size: 19,
              color: mutedColor,
            ),
          ],
        ),
      ),
    );
  }
}
