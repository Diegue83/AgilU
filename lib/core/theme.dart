import 'package:flutter/material.dart';

class AppTheme {
  static const Color navy = Color(0xFF2F3C7E);
  static const Color coral = Color(0xFF8C2F3B);
  static const Color gold = Color(0xFFC9A961);

  static ThemeData get light => ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: navy,
          primary: navy,
          secondary: coral,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: navy,
          foregroundColor: Colors.white,
        ),
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            backgroundColor: navy,
            minimumSize: const Size.fromHeight(48),
          ),
        ),
        inputDecorationTheme: const InputDecorationTheme(
          border: OutlineInputBorder(),
        ),
      );
}
