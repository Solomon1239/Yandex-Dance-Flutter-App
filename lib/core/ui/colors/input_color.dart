import 'package:flutter/material.dart';
import 'package:yandex_dance/core/ui/colors/colors.dart';

enum InputState { initial, typing, filled, disabled, success, error }

class InputColorResolver {
  final InputState state;
  final BuildContext context;

  InputColorResolver({required this.state, required this.context});

  // Resolve colors from our palette directly.
  Color get cursorColor => AppColors.inputCursorColor;
  Color get hintColor => AppColors.inputHintColor;

  Color get textColor {
    switch (state) {
      case InputState.initial:
        return AppColors.inputTextTertiary;
      case InputState.typing:
      case InputState.filled:
        return AppColors.inputTextPrimary;
      case InputState.disabled:
        return AppColors.inputTextTertiary;
      case InputState.success:
        return AppColors.inputTextPositive;
      case InputState.error:
        return AppColors.inputTextNegative;
    }
  }

  Color get borderColor {
    switch (state) {
      case InputState.initial:
        return AppColors.inputBorderInitial;
      case InputState.typing:
      case InputState.filled:
        return AppColors.inputTextPrimary;
      case InputState.disabled:
        return AppColors.inputBorderDisabled;
      case InputState.success:
        return AppColors.inputTextPositive;
      case InputState.error:
        return AppColors.inputTextNegative;
    }
  }
}
