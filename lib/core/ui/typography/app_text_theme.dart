import 'package:flutter/material.dart';

class AppTextTheme {
  static TextStyle _outfit({required double size, required FontWeight weight}) {
    return TextStyle(fontSize: size, fontWeight: weight, fontFamily: 'Outfit');
  }

  static final body1Medium18pt = _outfit(size: 18, weight: FontWeight.w500);
  static final body2Regular14pt = _outfit(size: 14, weight: FontWeight.w400);
}
