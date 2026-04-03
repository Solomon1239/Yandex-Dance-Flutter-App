import 'package:flutter/material.dart';
import 'package:yandex_dance/core/ui/colors/colors.dart';

class AppTextTheme {
  static TextStyle _outfit({required double size, required FontWeight weight, required Color color}) {
    return TextStyle(fontSize: size, fontWeight: weight, fontFamily: 'Outfit', color: color);
  }

  static final body1Medium18pt = _outfit(size: 18, weight: FontWeight.w500, color: AppColors.gray0);
  static final body2Regular14pt = _outfit(size: 14, weight: FontWeight.w400, color: AppColors.gray0);
  static final body3RegularPurple14pt = _outfit(size: 14, weight: FontWeight.w400, color: AppColors.purple500);
}
