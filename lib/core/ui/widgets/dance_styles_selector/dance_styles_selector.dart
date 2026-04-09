import 'package:flutter/material.dart';
import 'package:yandex_dance/core/enums/dance_style.dart';
import 'package:yandex_dance/core/ui/colors/colors.dart';
import 'package:yandex_dance/core/ui/typography/app_text_theme.dart';

class DanceStylesSelector extends StatelessWidget {
  const DanceStylesSelector({
    super.key,
    required this.selectedStyles,
    required this.onToggle,
  });

  final List<DanceStyle> selectedStyles;
  final ValueChanged<DanceStyle> onToggle;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children:
          DanceStyle.values.map((style) {
            final isSelected = selectedStyles.contains(style);
            return DanceStyleChip(
              label: style.title,
              isSelected: isSelected,
              onTap: () => onToggle(style),
            );
          }).toList(),
    );
  }
}

class DanceStyleChip extends StatelessWidget {
  const DanceStyleChip({
    super.key,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeInOut,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            gradient: LinearGradient(
              colors:
                  isSelected
                      ? [AppColors.purple500, AppColors.pink500]
                      : [AppColors.gray400, AppColors.gray400],
            ),
            border: Border.all(
              color:
                  isSelected
                      ? Colors.transparent
                      : AppColors.gray300.withValues(alpha: 0.55),
            ),
          ),
          child: Text(
            label,
            style: AppTextTheme.body4Medium16pt.copyWith(
              color: isSelected ? AppColors.gray0 : AppColors.gray300,
            ),
          ),
        ),
      ),
    );
  }
}
