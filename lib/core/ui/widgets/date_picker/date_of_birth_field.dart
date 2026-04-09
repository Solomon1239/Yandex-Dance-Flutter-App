import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:yandex_dance/core/ui/colors/colors.dart';
import 'package:yandex_dance/core/ui/icons/app_icons.dart';
import 'package:yandex_dance/core/ui/typography/app_text_theme.dart';
class DateOfBirthField extends StatelessWidget {
  const DateOfBirthField({
    super.key,
    required this.value,
    required this.onTap,
    this.hint = 'Дата рождения *',
  });

  final DateTime? value;
  final VoidCallback onTap;
  final String hint;

  @override
  Widget build(BuildContext context) {
    final hasValue = value != null;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          height: 56,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: AppColors.gray400.withValues(alpha: 0.70),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: AppColors.gray300.withValues(alpha: 0.55),
            ),
          ),
          child: Row(
            children: [
              SvgPicture.asset(
                AppIcons.calendar,
                width: 20,
                height: 20,
                colorFilter: const ColorFilter.mode(
                  AppColors.gray100,
                  BlendMode.srcIn,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                hasValue ? DateFormat('dd.MM.yyyy').format(value!) : hint,
                style: AppTextTheme.body1Medium18pt.copyWith(
                  color:
                      hasValue
                          ? AppColors.gray0
                          : AppColors.gray100.withValues(alpha: 0.70),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
