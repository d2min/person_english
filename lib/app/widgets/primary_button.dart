import 'package:flutter/material.dart';

import 'theme_palette.dart';

class PrimaryButton extends StatelessWidget {
  const PrimaryButton({
    required this.label,
    required this.onPressed,
    this.icon,
    this.enabled = true,
    super.key,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 54,
      width: double.infinity,
      child: FilledButton.icon(
        onPressed: enabled ? onPressed : null,
        icon: Icon(icon ?? Icons.arrow_forward_rounded, size: 19),
        label: Text(label, style: const TextStyle(fontWeight: FontWeight.w700)),
        style: FilledButton.styleFrom(
          backgroundColor: accentStrongColor,
          foregroundColor: Colors.white,
          disabledBackgroundColor: const Color(0xFFE2E5DC),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
    );
  }
}
