import 'package:flutter/material.dart';
import 'package:yandex_dance/core/ui/colors/colors.dart';
import 'package:yandex_dance/core/ui/typography/app_text_theme.dart';

/// Как [ProfileStylesPill]: одна капсула со стилями через « • ».
class FriendCoachStylesPill extends StatelessWidget {
  const FriendCoachStylesPill({super.key, required this.styles});

  final List<String> styles;

  @override
  Widget build(BuildContext context) {
    if (styles.isEmpty) return const SizedBox.shrink();
    final text = styles.join(' • ');
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.purple500.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: AppColors.purple500.withValues(alpha: 0.35),
        ),
      ),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: AppTextTheme.body4Medium16pt.copyWith(
          color: AppColors.gray0,
          height: 1.3,
        ),
      ),
    );
  }
}
