import 'package:flutter/material.dart';
import 'package:yandex_dance/core/ui/colors/colors.dart';
import 'package:yandex_dance/core/ui/typography/app_text_theme.dart';
import 'package:yandex_dance/core/ui/widgets/filter-chip/app_filter_chip.dart';

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
        Text('Возрастное ограничение', style: AppTextTheme.body4Medium16pt),
        const SizedBox(height: 6),
        AppFilterChipGroup(
          scrollable: true,
          spacing: 6,
          selectedLabels: {selectedAgeRestriction},
          chipColors: AppFilterChipColors(
            selectedGradient: AppColors.gradient,
            selectedBorderColor: Colors.transparent,
            unselectedBackgroundColor: AppColors.gray400,
            unselectedBorderColor: AppColors.gray300,
            textColor: AppColors.gray0,
          ),
          items: [
            for (final restriction in _ageRestrictions)
              ChipItem(label: restriction, onTap: () => onChanged(restriction)),
          ],
        ),
      ],
    );
  }
}
