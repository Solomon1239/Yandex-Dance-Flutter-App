import 'package:flutter/material.dart';

class AppColors {
  static const Color gray0 = Color(0xFFFFFFFF);
  static const Color gray100 = Color(0xFFA1A1A1);
  static const Color gray200 = Color(0xFF9E9E9E);
  static const Color gray300 = Color(0xFF6E6E6E);
  static const Color gray400 = Color(0xFF232323);
  static const Color pink500 = Color(0xFFEC499A);
  static const Color purple500 = Color(0xFFA855F7);
  static const Color purple600 = Color(0xFF211132);

  static const Color inputTextPrimary = gray0;
  static const Color inputTextSecondary = gray100;
  static const Color inputTextTertiary = gray200;
  static const Color inputCursorColor = gray0;
  static const Color inputHintColor = gray200;
  static const Color inputBorderInitial = gray100;
  static const Color inputBorderDisabled = gray200;
  static const Color inputTextPositive = purple500;
  static const Color inputTextNegative = pink500;
  static LinearGradient gradient = LinearGradient(colors: [purple500, pink500]);
}
