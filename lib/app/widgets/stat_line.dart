import 'package:flutter/material.dart';

import 'theme_palette.dart';

class StatLine extends StatelessWidget {
  const StatLine({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
    super.key,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: color),
        const SizedBox(width: 12),
        Expanded(
          child: Text(label, style: const TextStyle(color: mutedColor)),
        ),
        Text(
          value,
          style: const TextStyle(color: inkColor, fontWeight: FontWeight.w700),
        ),
      ],
    );
  }
}
