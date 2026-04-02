import 'package:flutter/material.dart';
import 'package:yandex_dance/core/ui/colors/colors.dart';

class AppSegmentedControl extends StatefulWidget {
  final double height;
  final List<Widget> items;
  final int initialIndex;
  final ValueChanged<int> onChanged;
  final double horizontalPadding;
  final EdgeInsets itemPadding;
  final bool expandItems;

  const AppSegmentedControl({
    super.key,
    required this.height,
    required this.items,
    required this.onChanged,
    this.initialIndex = 0,
    required this.horizontalPadding,
    required this.itemPadding,
    this.expandItems = false,
  });

  @override
  State<AppSegmentedControl> createState() => _AppSegmentedControlState();
}

class _AppSegmentedControlState extends State<AppSegmentedControl> {
  late int selectedIndex;

  @override
  void initState() {
    super.initState();
    selectedIndex = widget.initialIndex;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: widget.height,
      padding: EdgeInsets.symmetric(horizontal: widget.horizontalPadding),
      decoration: BoxDecoration(
        color: AppColors.gray400,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        children: List.generate(widget.items.length, (index) {
          final isSelected = selectedIndex == index;

          final child = _SegmentedItem(
            isSelected: isSelected,
            onTap: () => _onItemTap(index),
            padding: widget.itemPadding,
            child: widget.items[index],
          );

          return widget.expandItems
              ? Expanded(child: child)
              : IntrinsicWidth(child: child);
        }),
      ),
    );
  }

  void _onItemTap(int index) {
    if (selectedIndex == index) return;

    setState(() {
      selectedIndex = index;
    });
    widget.onChanged(index);
  }
}

class _SegmentedItem extends StatelessWidget {
  final bool isSelected;
  final VoidCallback onTap;
  final EdgeInsets padding;
  final Widget child;

  const _SegmentedItem({
    required this.isSelected,
    required this.onTap,
    required this.padding,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: padding,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          gradient: isSelected ? AppColors.gradient : null,
          color: isSelected ? null : AppColors.gray400,
        ),
        child: Center(child: child),
      ),
    );
  }
}
