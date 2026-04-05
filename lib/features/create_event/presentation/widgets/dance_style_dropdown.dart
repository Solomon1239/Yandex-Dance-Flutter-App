import 'package:flutter/material.dart';
import 'package:yandex_dance/core/enums/dance_style.dart';
import 'package:yandex_dance/core/ui/colors/colors.dart';
import 'package:yandex_dance/core/ui/typography/app_text_theme.dart';

class DanceStyleDropdown extends StatelessWidget {
  final DanceStyle? selectedStyle;
  final void Function(DanceStyle?) onChanged;

  const DanceStyleDropdown({
    super.key,
    required this.selectedStyle,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Стиль танца', style: AppTextTheme.body3Regular20pt),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: AppColors.gray400,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.gray300, width: 1),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<DanceStyle>(
              value: selectedStyle,
              hint: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  'Выберите стиль',
                  style: AppTextTheme.body1Medium18pt.copyWith(
                    color: AppColors.gray300,
                  ),
                ),
              ),
              isExpanded: true,
              icon: const Padding(
                padding: EdgeInsets.only(right: 16),
                child: Icon(Icons.arrow_drop_down, color: AppColors.gray300),
              ),
              items:
                  DanceStyle.values.map((DanceStyle style) {
                    return DropdownMenuItem<DanceStyle>(
                      value: style,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          style.title,
                          style: AppTextTheme.body3Regular20pt,
                        ),
                      ),
                    );
                  }).toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }
}
