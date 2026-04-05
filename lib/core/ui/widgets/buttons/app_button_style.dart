import 'package:flutter/material.dart';
import 'package:yandex_dance/core/ui/colors/colors.dart';

enum ButtonBorderStyle { none, solid, dotted }

enum IconPosition { prefix, suffix }

class AppButtonBorder {
  const AppButtonBorder({
    this.borderRadius = 20,
    this.borderWidth = 0,
    this.borderColor = Colors.transparent,
    this.borderStyle = ButtonBorderStyle.none,
  });

  final double borderRadius;
  final double borderWidth;
  final Color borderColor;
  final ButtonBorderStyle borderStyle;

  AppButtonBorder copyWith({
    double? borderRadius,
    double? borderWidth,
    Color? borderColor,
    ButtonBorderStyle? borderStyle,
  }) {
    return AppButtonBorder(
      borderRadius: borderRadius ?? this.borderRadius,
      borderWidth: borderWidth ?? this.borderWidth,
      borderColor: borderColor ?? this.borderColor,
      borderStyle: borderStyle ?? this.borderStyle,
    );
  }
}

class AppButtonStyle {
  const AppButtonStyle({
    this.width,
    this.height = 56,
    this.backgroundColor,
    this.gradient,
    this.padding = const EdgeInsets.symmetric(horizontal: 16),
    this.border = const AppButtonBorder(),
    this.textColor = AppColors.gray0,
    this.textStyle,
    this.iconColor,
    this.iconSize = 24,
    this.iconPosition = IconPosition.prefix,
    this.gap = 12,
    this.loaderColor,
    this.loaderSize,
    this.loaderStrokeWidth = 2.5,
  });

  final double? width;
  final double? height;
  final Color? backgroundColor;
  final Gradient? gradient;
  final EdgeInsetsGeometry padding;
  final AppButtonBorder border;
  final Color? textColor;
  final TextStyle? textStyle;
  final Color? iconColor;
  final double? iconSize;
  final IconPosition iconPosition;
  final double gap;
  final Color? loaderColor;
  final double? loaderSize;
  final double loaderStrokeWidth;

  AppButtonStyle copyWith({
    double? width,
    double? height,
    Color? backgroundColor,
    Gradient? gradient,
    EdgeInsetsGeometry? padding,
    AppButtonBorder? border,
    Color? textColor,
    TextStyle? textStyle,
    Color? iconColor,
    double? iconSize,
    IconPosition? iconPosition,
    double? gap,
    Color? loaderColor,
    double? loaderSize,
    double? loaderStrokeWidth,
  }) {
    return AppButtonStyle(
      width: width ?? this.width,
      height: height ?? this.height,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      gradient: gradient ?? this.gradient,
      padding: padding ?? this.padding,
      border: border ?? this.border,
      textColor: textColor ?? this.textColor,
      textStyle: textStyle ?? this.textStyle,
      iconColor: iconColor ?? this.iconColor,
      iconSize: iconSize ?? this.iconSize,
      iconPosition: iconPosition ?? this.iconPosition,
      gap: gap ?? this.gap,
      loaderColor: loaderColor ?? this.loaderColor,
      loaderSize: loaderSize ?? this.loaderSize,
      loaderStrokeWidth: loaderStrokeWidth ?? this.loaderStrokeWidth,
    );
  }

  // ── Presets ──

  static const gradientFilled = AppButtonStyle(
    gradient: LinearGradient(
      colors: [AppColors.purple500, AppColors.pink500],
    ),
    textColor: AppColors.gray0,
  );

  static const outlined = AppButtonStyle(
    backgroundColor: AppColors.gray400,
    border: AppButtonBorder(
      borderStyle: ButtonBorderStyle.solid,
      borderWidth: 1,
      borderColor: AppColors.gray300,
    ),
    textColor: AppColors.gray0,
  );

  static const ghost = AppButtonStyle(
    backgroundColor: Colors.transparent,
    textColor: AppColors.gray0,
    height: 48,
  );
}
