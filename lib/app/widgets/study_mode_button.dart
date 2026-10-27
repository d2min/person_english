import 'package:flutter/material.dart';

import 'theme_palette.dart';

class StudyModeButton extends StatelessWidget {
  const StudyModeButton({
    required this.label,
    required this.icon,
    required this.onPressed,
    this.enabled = true,
    super.key,
  });

  final String label;
  final IconData icon;
  final VoidCallback? onPressed;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 54,
      width: double.infinity,
      child: FilledButton.icon(
        onPressed: enabled ? onPressed : null,
        icon: Icon(icon, size: 18),
        label: Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
        ),
        style: FilledButton.styleFrom(
          backgroundColor: accentStrongColor,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
    );
  }
}
