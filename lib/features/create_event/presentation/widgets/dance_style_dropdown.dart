import 'package:flutter/material.dart';
import 'package:yandex_dance/core/ui/colors/colors.dart';
import 'package:yandex_dance/core/ui/typography/app_text_theme.dart';

class DanceStyleDropdown extends StatelessWidget {
  final String? selectedStyle;
  final void Function(String?) onChanged;

  const DanceStyleDropdown({
    super.key,
    required this.selectedStyle,
    required this.onChanged,
  });

  final List<String> _danceStyles = const [
    'Hip-Hop',
    'Contemporary',
    'Ballet',
    'Jazz',
    'Breakdance',
    'Salsa',
    'Tango',
    'Ballroom',
  ];

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
            child: DropdownButton<String>(
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
                  _danceStyles.map((String style) {
                    return DropdownMenuItem<String>(
                      value: style,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          style,
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
