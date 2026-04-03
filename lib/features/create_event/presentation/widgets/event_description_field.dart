import 'package:flutter/material.dart';
import 'package:yandex_dance/core/ui/colors/input_color.dart';
import 'package:yandex_dance/core/ui/typography/app_text_theme.dart';
import 'package:yandex_dance/core/ui/widgets/input/app_text_field.dart';

class EventDescriptionField extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final bool touched;
  final InputState state;
  final String? Function(String) validator;
  final void Function(String) onChanged;
  final void Function(InputState) onStateChange;

  const EventDescriptionField({
    super.key,
    required this.controller,
    required this.focusNode,
    required this.touched,
    required this.state,
    required this.validator,
    required this.onChanged,
    required this.onStateChange,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Описание', style: AppTextTheme.body3Regular20pt),
        const SizedBox(height: 8),
        AppTextField(
          hint: 'Расскажите о мероприятии',
          state: state,
          contoller: controller,
          focusNode: focusNode,
          touched: touched,
          validator: validator,
          isLongText: true,
          textInputAction: TextInputAction.done,
          onChanged: onChanged,
          onStateChange: onStateChange,
        ),
      ],
    );
  }
}
