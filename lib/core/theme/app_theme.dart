import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData dark() {
    const background = Color.fromARGB(255, 17, 17, 17);
    const surface = Color(0xFF232323);
    const border = Color(0xFF6E6E6E);
    const primary = Color(0xFFA855F7);
    const secondary = Color(0xFFEC499A);

    final colorScheme = ColorScheme.fromSeed(
      seedColor: primary,
      brightness: Brightness.dark,
      surface: surface,
      primary: primary,
      secondary: secondary,
    );

    final inputBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(18),
      borderSide: const BorderSide(color: border),
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: background,
      colorScheme: colorScheme,
      appBarTheme: const AppBarTheme(
        centerTitle: false,
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
      ),
      cardTheme: CardThemeData(
        color: surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: const BorderSide(color: border),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surface,
        border: inputBorder,
        enabledBorder: inputBorder,
        focusedBorder: inputBorder.copyWith(
          borderSide: const BorderSide(color: primary, width: 1.2),
        ),
      ),
      chipTheme: const ChipThemeData(
        selectedColor: primary,
        backgroundColor: surface,
        side: BorderSide(color: border),
      ),
    );
  }
}
