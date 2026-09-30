import 'package:flutter/material.dart';

class BellTheme {
  static const gold = Color(0xFFE0B04A);
  static const goldDeep = Color(0xFFB8860B);
  static const bg = Color(0xFF16110C);
  static const surface = Color(0xFF241B14);
  static const cream = Color(0xFFF4E6C8);

  static ThemeData dark() {
    final base = ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.fromSeed(
        seedColor: gold,
        brightness: Brightness.dark,
        surface: surface,
      ),
    );
    return base.copyWith(
      scaffoldBackgroundColor: bg,
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        foregroundColor: cream,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: gold,
          foregroundColor: bg,
          minimumSize: const Size.fromHeight(52),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: cream,
          minimumSize: const Size.fromHeight(52),
          side: const BorderSide(color: gold),
        ),
      ),
    );
  }
}
