import 'package:flutter/material.dart';
import 'package:yandex_dance/core/ui/colors/colors.dart';

class BaseButton extends StatelessWidget {
  const BaseButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.prefixIcon,
    this.suffixIcon,
    this.margin,
  });

  final String text;
  final VoidCallback? onPressed;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final EdgeInsetsGeometry? margin;

  @override
  Widget build(BuildContext context) {
    const defaultTextStyle = TextStyle(
      color: AppColors.gray0,
      fontSize: 16,
      fontWeight: FontWeight.w600,
      height: 1,
    );

    return Padding(
      padding: margin ?? EdgeInsets.zero,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(0, 48),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          backgroundColor: Colors.transparent,
          side: const BorderSide(color: AppColors.gray100),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(999),
          ),
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (prefixIcon != null) ...[prefixIcon!, const SizedBox(width: 10)],
            Text(text, style: defaultTextStyle),
            if (suffixIcon != null) ...[const SizedBox(width: 10), suffixIcon!],
          ],
        ),
      ),
    );
  }
}
