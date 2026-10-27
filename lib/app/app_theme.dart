import 'package:flutter/material.dart';

import 'widgets/theme_palette.dart';

ThemeData buildAppTheme() {
  const background = Color(0xFFF7F8F3);
  return ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    scaffoldBackgroundColor: background,
    colorScheme: ColorScheme.fromSeed(
      seedColor: accentStrongColor,
      brightness: Brightness.light,
      surface: background,
    ),
    textTheme: const TextTheme(
      headlineMedium: TextStyle(
        color: inkColor,
        fontSize: 30,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.5,
      ),
      headlineSmall: TextStyle(
        color: inkColor,
        fontSize: 23,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.3,
      ),
      titleLarge: TextStyle(
        color: inkColor,
        fontSize: 18,
        fontWeight: FontWeight.w700,
      ),
      bodyLarge: TextStyle(color: inkColor, fontSize: 16),
      bodyMedium: TextStyle(color: mutedColor, fontSize: 14),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white.withValues(alpha: 0.88),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFFE6E9DF)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: accentColor, width: 1.4),
      ),
    ),
  );
}
