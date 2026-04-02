import 'package:flutter/material.dart';
import 'package:yandex_dance/core/ui/colors/input_color.dart';
import 'package:yandex_dance/core/ui/icons/app_icons.dart';
import 'package:yandex_dance/core/ui/widgets/input/app_text_field.dart';

class TestApp extends StatelessWidget {
  const TestApp({super.key});

  @override
  Widget build(BuildContext context) {
    final InputState state = InputState.typing;
    final TextEditingController contoller = TextEditingController();
    final FocusNode focusNode = FocusNode();
    final bool touched = true;
    return Scaffold(
      body: Center(
        child: AppTextField(
          label: "label",
          hint: "hint",
          state: state,
          prefixIcon: AppIcons.mail,
          contoller: contoller,
          touched: touched,
          focusNode: focusNode,
        ),
      ),
    );
  }
}
