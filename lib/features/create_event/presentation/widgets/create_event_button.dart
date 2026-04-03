import 'package:flutter/material.dart';
import 'package:yandex_dance/core/ui/colors/colors.dart';
import 'package:yandex_dance/core/ui/typography/app_text_theme.dart';

class CreateEventButton extends StatelessWidget {
  final VoidCallback onPressed;
  final String text;
  final bool isLoading;

  const CreateEventButton({
    super.key,
    required this.onPressed,
    this.text = 'Создать мероприятие',
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.purple500,
          foregroundColor: AppColors.gray0,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
          disabledBackgroundColor: AppColors.gray400,
        ),
        child:
            isLoading
                ? const SizedBox(
                  height: 24,
                  width: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(AppColors.gray0),
                  ),
                )
                : Text(
                  text,
                  style: AppTextTheme.body1Medium18pt.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
      ),
    );
  }
}
