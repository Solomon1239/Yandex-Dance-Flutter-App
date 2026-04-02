import 'package:flutter/material.dart';

class BaseButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
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
    required this.text,
    required this.onPressed,
    this.prefixIcon,
    this.suffixIcon,
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

  bool get _isEnabled => onPressed != null;

  @override
  Widget build(BuildContext context) {
    final defaultTextStyle = const TextStyle(
      color: Colors.white,
      fontSize: 24,
      fontWeight: FontWeight.w600,
      height: 1,
    );

    final content = Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        if (prefixIcon != null) ...[
          SizedBox(
            width: iconSize,
            height: iconSize,
            child: Center(child: prefixIcon),
          ),
          SizedBox(width: spacing),
        ],

        Text(
          text,
          style: (textStyle ?? defaultTextStyle).copyWith(
            color:
                _isEnabled
                    ? (textStyle ?? defaultTextStyle).color
                    : Colors.grey,
          ),
        ),

        if (suffixIcon != null) ...[
          SizedBox(width: spacing),
          SizedBox(
            width: iconSize,
            height: iconSize,
            child: Center(child: suffixIcon),
          ),
        ],
      ],
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
              color:
                  _isEnabled
                      ? backgroundColor
                      : backgroundColor.withOpacity(0.5),
              borderRadius: BorderRadius.circular(borderRadius),
              border: Border.all(color: borderColor, width: borderWidth),
            ),
            child: Center(child: content),
          ),
        ),
      ),
    );
  }
}
