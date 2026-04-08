import 'package:flutter/material.dart';
import 'package:yandex_dance/core/enums/dance_style.dart';
import 'package:yandex_dance/core/ui/colors/colors.dart';
import 'package:yandex_dance/core/ui/typography/app_text_theme.dart';
import 'package:yandex_dance/core/ui/widgets/filter-chip/app_filter_chip.dart';

class DanceStyleDropdown extends StatelessWidget {
  const DanceStyleDropdown({
    super.key,
    required this.selectedStyle,
    required this.onChanged,
    /// Чип «Все»: выбран при `selectedStyle == null`, по нажатию сбрасывает фильтр.
    this.showAllChip = false,
  });

  final DanceStyle? selectedStyle;
  final void Function(DanceStyle?) onChanged;

  /// Если `true`, в начале ряда показывается чип «Все» (удобно для фильтров).
  final bool showAllChip;

  static const _allLabel = 'Все';

  @override
  Widget build(BuildContext context) {
    final selectedLabels = <String>{
      if (showAllChip && selectedStyle == null) _allLabel,
      if (selectedStyle != null) selectedStyle!.title,
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Стиль танца', style: AppTextTheme.body4Medium16pt),
        const SizedBox(height: 6),
        AppFilterChipGroup(
          scrollable: true,
          spacing: 6,
          selectedLabels: selectedLabels,
          chipColors: AppFilterChipColors(
            selectedGradient: AppColors.gradient,
            selectedBorderColor: Colors.transparent,
            unselectedBackgroundColor: AppColors.gray400,
            unselectedBorderColor: AppColors.gray300,
            textColor: AppColors.gray0,
          ),
          items: [
            if (showAllChip)
              ChipItem(
                label: _allLabel,
                onTap: () => onChanged(null),
              ),
            for (final style in DanceStyle.values)
              ChipItem(
                label: style.title,
                onTap: () {
                  if (selectedStyle == style) {
                    onChanged(null);
                  } else {
                    onChanged(style);
                  }
                },
              ),
          ],
        ),
      ],
    );
  }
}
