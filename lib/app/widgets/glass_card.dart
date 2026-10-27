import 'dart:ui';

import 'package:flutter/material.dart';

class GlassCard extends StatelessWidget {
  const GlassCard({
    required this.child,
    this.padding = const EdgeInsets.all(20),
    this.color = Colors.white,
    super.key,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
        child: Container(
          width: double.infinity,
          padding: padding,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.9),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: Colors.white.withValues(alpha: 0.8)),
            boxShadow: const [
              BoxShadow(
                color: Color(0x0A26301F),
                blurRadius: 12,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: child,
        ),
      ),
    );
  }
}
