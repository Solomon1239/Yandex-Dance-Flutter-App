import 'package:flutter/material.dart';
import 'package:yandex_dance/core/ui/colors/colors.dart';
import 'package:yandex_dance/core/ui/typography/app_text_theme.dart';

class AgeRestrictionField extends StatelessWidget {
  final String selectedAgeRestriction;
  final Function(String) onChanged;

  const AgeRestrictionField({
    super.key,
    required this.selectedAgeRestriction,
    required this.onChanged,
  });

  final List<String> _ageRestrictions = const [
    'Для всех',
    '6+',
    '12+',
    '16+',
    '18+',
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Возрастное ограничение', style: AppTextTheme.body3Regular20pt),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: AppColors.gray400,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.gray300, width: 1),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: selectedAgeRestriction,
              hint: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  'Выберите возрастное ограничение',
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
                  _ageRestrictions.map((String restriction) {
                    return DropdownMenuItem<String>(
                      value: restriction,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          restriction,
                          style: AppTextTheme.body3Regular20pt,
                        ),
                      ),
                    );
                  }).toList(),
              onChanged: (String? newValue) {
                if (newValue != null) {
                  onChanged(newValue);
                }
              },
            ),
          ),
        ),
      ],
    );
  }
}
