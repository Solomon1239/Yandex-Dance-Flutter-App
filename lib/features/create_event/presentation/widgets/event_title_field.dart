import 'package:flutter/material.dart';
import 'package:yandex_dance/core/ui/colors/input_color.dart';
import 'package:yandex_dance/core/ui/typography/app_text_theme.dart';
import 'package:yandex_dance/core/ui/widgets/input/app_text_field.dart';

class EventTitleField extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final bool touched;
  final InputState state;
  final String? Function(String) validator;
  final FocusNode nextFocusNode;
  final void Function(String) onChanged;
  final void Function(InputState) onStateChange;

  const EventTitleField({
    super.key,
    required this.controller,
    required this.focusNode,
    required this.touched,
    required this.state,
    required this.validator,
    required this.nextFocusNode,
    required this.onChanged,
    required this.onStateChange,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Название мероприятия', style: AppTextTheme.body4Medium16pt),
        const SizedBox(height: 6),
        AppTextField(
          hint: 'Введите название',
          state: state,
          contoller: controller,
          focusNode: focusNode,
          touched: touched,
          validator: validator,
          textInputAction: TextInputAction.next,
          nextFocusNode: nextFocusNode,
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          hintStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          onChanged: onChanged,
          onStateChange: onStateChange,
        ),
      ],
    );
  }
}
