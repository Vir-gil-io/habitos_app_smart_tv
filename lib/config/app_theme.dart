import 'package:flutter/material.dart';

class AppTheme {
  static const Color primary = Color(0xFF6C5CE7);
  static const Color primaryLight = Color(0xFF9D8DF1);
  static const Color completed = Color(0xFF00B894);
  static const Color pending = Color(0xFFE17055);
  static const Color streak = Color(0xFFFF7675);

  static const Color background = Color(0xFFF8F6FF);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color textPrimary = Color(0xFF2D3436);
  static const Color textSecondary = Color(0xFF636E72);
  static const Color divider = Color(0xFFDFE6E9);

  static const Color backgroundDark = Color(0xFF121218);
  static const Color surfaceDark = Color(0xFF1E1E28);
  static const Color textPrimaryDark = Color(0xFFF1F1F5);
  static const Color textSecondaryDark = Color(0xFFA0A0AC);
  static const Color dividerDark = Color(0xFF33333F);

  ThemeData getTheme() => ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        colorScheme: ColorScheme.fromSeed(
          seedColor: primary,
          brightness: Brightness.light,
          primary: primary,
          secondary: completed,
          surface: surface,
        ),
        scaffoldBackgroundColor: background,
        cardTheme: CardThemeData(
          color: surface,
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
        textTheme: const TextTheme(
          labelSmall: TextStyle(fontSize: 12, color: textSecondary),
          bodyMedium: TextStyle(fontSize: 14, color: textSecondary),
        ),
      );

  ThemeData getDarkTheme() => ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorScheme: ColorScheme.fromSeed(
          seedColor: primary,
          brightness: Brightness.dark,
          primary: primaryLight,
          secondary: completed,
          surface: surfaceDark,
        ),
        scaffoldBackgroundColor: backgroundDark,
        cardTheme: CardThemeData(
          color: surfaceDark,
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
        textTheme: const TextTheme(
          labelSmall: TextStyle(fontSize: 12, color: textSecondaryDark),
          bodyMedium: TextStyle(fontSize: 14, color: textSecondaryDark),
        ),
      );
}