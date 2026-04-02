import 'package:flutter/material.dart';
import 'package:yandex_dance/core/ui/colors/colors.dart';
import 'package:yandex_dance/core/ui/colors/input_color.dart';

class TextFieldSuffixIcon extends StatelessWidget {
  const TextFieldSuffixIcon({
    super.key,
    required this.isPassword,
    required this.isObscured,
    required this.currentState,
    required this.onToggleObscure,
  });

  final bool isPassword;
  final bool isObscured;
  final InputState currentState;
  final VoidCallback onToggleObscure;

  @override
  Widget build(BuildContext context) {
    final resolver = InputColorResolver(state: currentState, context: context);

    if (currentState == InputState.success) {
      return IconButton(
        padding: EdgeInsets.zero,
        constraints: const BoxConstraints(
          minWidth: 20,
          minHeight: 20,
          maxWidth: 20,
          maxHeight: 20,
        ),
        onPressed: () {},
        icon: Icon(Icons.check, color: AppColors.gray100),
      );
    }

    if (isPassword) {
      return IconButton(
        padding: EdgeInsets.zero,
        constraints: const BoxConstraints(
          minWidth: 20,
          minHeight: 20,
          maxWidth: 20,
          maxHeight: 20,
        ),
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        onPressed: onToggleObscure,
        icon: Icon(
          isObscured ? Icons.visibility_off : Icons.visibility,
          color: resolver.textColor,
        ),
      );
    }

    return SizedBox.shrink();
  }
}
