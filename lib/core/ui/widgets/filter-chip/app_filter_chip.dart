import 'package:flutter/material.dart';
import 'package:yandex_dance/core/ui/colors/colors.dart';

class ChipItem {
  final String label;
  final VoidCallback onTap;
  final Widget? prefixIcon;
  final Widget? suffixIcon;

  const ChipItem({
    required this.label,
    required this.onTap,
    this.prefixIcon,
    this.suffixIcon,
  });
}

class AppFilterChipColors {
  final Gradient? selectedGradient;
  final Color? selectedBackgroundColor;
  final Color? unselectedBackgroundColor;
  final Color? selectedBorderColor;
  final Color? unselectedBorderColor;
  final Color? textColor;

  const AppFilterChipColors({
    this.selectedGradient,
    this.selectedBackgroundColor,
    this.unselectedBackgroundColor,
    this.selectedBorderColor,
    this.unselectedBorderColor,
    this.textColor,
  });
}

class AppFilterChipGroup extends StatelessWidget {
  final List<ChipItem> items;
  final Set<String> selectedLabels;
  final AppFilterChipColors? chipColors;
  final double spacing;
  final EdgeInsetsGeometry padding;
  final bool scrollable;

  const AppFilterChipGroup({
    super.key,
    required this.items,
    required this.selectedLabels,
    this.chipColors,
    this.spacing = 8,
    this.padding = EdgeInsets.zero,
    this.scrollable = false,
  });

  @override
  Widget build(BuildContext context) {
    final chips = [
      for (var i = 0; i < items.length; i++) ...[
        if (i > 0) SizedBox(width: spacing),
        AppFilterChip(
          label: items[i].label,
          isSelected: selectedLabels.contains(items[i].label),
          colors: chipColors,
          prefixIcon: items[i].prefixIcon,
          suffixIcon: items[i].suffixIcon,
          onTap: items[i].onTap,
        ),
      ],
    ];

    final content = Padding(
      padding: padding,
      child: Row(mainAxisSize: MainAxisSize.min, children: chips),
    );

    if (scrollable) {
      return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: content,
      );
    }

    return content;
  }
}

class PreviewChipGroup extends StatefulWidget {
  final bool hasSelectAllChip;
  final List<ChipItem> items;
  final AppFilterChipColors? chipColors;

  const PreviewChipGroup({
    super.key,
    this.hasSelectAllChip = false,
    required this.items,
    this.chipColors,
  });

  @override
  State<PreviewChipGroup> createState() => _PreviewChipGroupState();
}

class _PreviewChipGroupState extends State<PreviewChipGroup> {
  final Set<int> selectedIndexes = {};

  bool get isAllSelected => selectedIndexes.length == widget.items.length;

  @override
  Widget build(BuildContext context) {
    final int totalChipCount =
        widget.hasSelectAllChip ? widget.items.length + 1 : widget.items.length;

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: List.generate(totalChipCount, (index) {
        if (widget.hasSelectAllChip && index == 0) {
          return AppFilterChip(
            label: 'Все',
            isSelected: isAllSelected,
            colors: widget.chipColors,
            onTap: () {
              setState(() {
                if (isAllSelected) {
                  selectedIndexes.clear();
                } else {
                  selectedIndexes
                    ..clear()
                    ..addAll(List.generate(widget.items.length, (i) => i));
                }
              });
            },
          );
        }

        final int itemIndex = widget.hasSelectAllChip ? index - 1 : index;
        final bool isSelected = selectedIndexes.contains(itemIndex);
        final item = widget.items[itemIndex];

        return AppFilterChip(
          label: item.label,
          isSelected: isSelected,
          colors: widget.chipColors,
          prefixIcon: item.prefixIcon,
          suffixIcon: item.suffixIcon,
          onTap: () {
            setState(() {
              if (isSelected) {
                selectedIndexes.remove(itemIndex);
              } else {
                selectedIndexes.add(itemIndex);
              }
            });
            item.onTap();
          },
        );
      }),
    );
  }
}

class AppFilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final AppFilterChipColors? colors;
  final Widget? prefixIcon;
  final Widget? suffixIcon;

  const AppFilterChip({
    super.key,
    required this.label,
    required this.isSelected,
    required this.onTap,
    this.colors,
    this.prefixIcon,
    this.suffixIcon,
  });

  @override
  Widget build(BuildContext context) {
    final gradient =
        isSelected ? (colors?.selectedGradient ?? AppColors.gradient) : null;

    final backgroundColor =
        isSelected
            ? colors?.selectedBackgroundColor
            : (colors?.unselectedBackgroundColor ?? Colors.transparent);

    final borderColor =
        isSelected
            ? (colors?.selectedBorderColor ?? Colors.transparent)
            : (colors?.unselectedBorderColor ?? Colors.grey.shade500);

    final textColor = colors?.textColor ?? Colors.white;

    return Material(
      shape: const StadiumBorder(),
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(999),
        onTap: onTap,
        child: Ink(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            gradient: gradient,
            color: backgroundColor,
            borderRadius: BorderRadius.circular(999),
            border: Border.all(width: 1, color: borderColor),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (prefixIcon != null) ...[
                IconTheme(
                  data: IconThemeData(size: 16, color: textColor),
                  child: prefixIcon!,
                ),
                const SizedBox(width: 6),
              ],
              Text(
                label,
                style: TextStyle(fontWeight: FontWeight.w600, color: textColor),
              ),
              if (suffixIcon != null) ...[
                const SizedBox(width: 6),
                IconTheme(
                  data: IconThemeData(size: 16, color: textColor),
                  child: suffixIcon!,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
