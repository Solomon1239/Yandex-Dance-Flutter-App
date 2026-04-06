import 'package:flutter/material.dart';
import 'package:yandex_dance/core/ui/widgets/buttons/app_button.dart';
import 'package:yandex_dance/core/ui/widgets/buttons/app_button_style.dart';

class CreateEventButton extends StatelessWidget {
  final Future<void> Function() onPressed;
  final String text;

  const CreateEventButton({
    super.key,
    required this.onPressed,
    this.text = 'Создать мероприятие',
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: AppButton(
        onTap: onPressed,
        needLoading: true,
        label: text,
        style: AppButtonStyle.gradientFilled,
      ),
    );
  }
}
