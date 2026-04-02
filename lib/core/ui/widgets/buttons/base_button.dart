import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class BaseButton extends StatelessWidget {
  final String assetPath;
  final String text;
  final VoidCallback? onPressed;

  final double height;
  final double borderRadius;
  final double borderWidth;
  final Color backgroundColor;
  final Color borderColor;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry? margin;
  final double iconSize;
  final double spacing;
  final TextStyle? textStyle;

  const BaseButton({
    super.key,
    required this.assetPath,
    required this.text,
    required this.onPressed,
    this.height = 64,
    this.borderRadius = 999,
    this.borderWidth = 1.5,
    this.backgroundColor = Colors.black,
    this.borderColor = const Color(0xFF1F1F1F),
    this.padding = const EdgeInsets.symmetric(horizontal: 28),
    this.margin,
    this.iconSize = 28,
    this.spacing = 16,
    this.textStyle,
  });
  bool get _isSvg => assetPath.toLowerCase().endsWith('.svg');

  @override
  Widget build(BuildContext context) {
    final defaultTextStyle = const TextStyle(
      color: Colors.white,
      fontSize: 24,
      fontWeight: FontWeight.w600,
      height: 1,
    );

    return Padding(
      padding: margin ?? EdgeInsets.zero,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(borderRadius),
          child: Ink(
            height: height,
            padding: padding,
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(borderRadius),
              border: Border.all(
                color: borderColor,
                width: borderWidth,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _isSvg
                    ? SvgPicture.asset(
                  assetPath,
                  width: iconSize,
                  height: iconSize,
                )
                    : Image.asset(
                  assetPath,
                  width: iconSize,
                  height: iconSize,
                  fit: BoxFit.contain,
                ),
                SizedBox(width: spacing),
                Text(
                  text,
                  style: textStyle ?? defaultTextStyle,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
