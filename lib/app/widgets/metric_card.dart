import 'package:flutter/material.dart';

import 'glass_card.dart';
import 'theme_palette.dart';

class MetricCard extends StatelessWidget {
  const MetricCard({
    required this.icon,
    required this.value,
    required this.label,
    required this.tint,
    required this.iconColor,
    super.key,
  });

  final IconData icon;
  final String value;
  final String label;
  final Color tint;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: tint,
              borderRadius: BorderRadius.circular(13),
            ),
            child: Icon(icon, size: 20, color: iconColor),
          ),
          const SizedBox(height: 13),
          Text(
            value,
            style: const TextStyle(
              color: inkColor,
              fontSize: 25,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 2),
          Text(label, style: const TextStyle(color: mutedColor, fontSize: 12)),
        ],
      ),
    );
  }
}
