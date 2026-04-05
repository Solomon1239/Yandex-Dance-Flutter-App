import 'dart:async';

import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:yandex_dance/core/ui/colors/colors.dart';
import 'package:yandex_dance/core/ui/typography/app_text_theme.dart';
import 'package:yandex_dance/core/ui/widgets/buttons/app_button_style.dart';
import 'package:yandex_dance/core/ui/widgets/custom_bounce_effect.dart';

typedef TapHandler = FutureOr<void> Function();

class AppButton extends StatefulWidget {
  const AppButton({
    super.key,
    this.onTap,
    this.label,
    this.icon,
    this.iconWidget,
    this.style = const AppButtonStyle(),
    this.needLoading = false,
  });

  final TapHandler? onTap;
  final String? label;
  final String? icon;
  final Widget? iconWidget;
  final AppButtonStyle style;
  final bool needLoading;

  @override
  State<AppButton> createState() => _AppButtonState();
}

class _AppButtonState extends State<AppButton> {
  bool _loading = false;

  Future<void> _handleTap() async {
    if (widget.onTap == null) return;
    if (widget.needLoading) {
      if (_loading) return;
      setState(() => _loading = true);
      try {
        await widget.onTap!();
      } finally {
        if (mounted) setState(() => _loading = false);
      }
    } else {
      await widget.onTap!();
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.style;
    final b = s.border;

    final child =
        (b.borderStyle == ButtonBorderStyle.dotted && b.borderWidth > 0)
            ? _buildDottedChild(s, b)
            : _buildSolidChild(s, b);

    return AbsorbPointer(
      absorbing: _loading,
      child: CustomBounceEffect(onTap: _handleTap, child: child),
    );
  }

  Widget _buildSolidChild(AppButtonStyle s, AppButtonBorder b) {
    return Container(
      width: s.width,
      height: s.height,
      padding: s.padding,
      decoration: BoxDecoration(
        color: s.gradient == null ? s.backgroundColor : null,
        gradient: s.gradient,
        borderRadius: BorderRadius.circular(b.borderRadius),
        border:
            b.borderStyle == ButtonBorderStyle.solid && b.borderWidth > 0
                ? Border.all(color: b.borderColor, width: b.borderWidth)
                : null,
      ),
      child: _buildContent(s),
    );
  }

  Widget _buildDottedChild(AppButtonStyle s, AppButtonBorder b) {
    return DottedBorder(
      options: RoundedRectDottedBorderOptions(
        radius: Radius.circular(b.borderRadius),
        strokeWidth: b.borderWidth,
        color: b.borderColor,
        dashPattern: const [12, 12],
        strokeCap: StrokeCap.round,
      ),
      childOnTop: false,
      child: Container(
        width: s.width,
        height: s.height,
        padding: s.padding,
        decoration: BoxDecoration(
          color: s.gradient == null ? s.backgroundColor : null,
          gradient: s.gradient,
          borderRadius: BorderRadius.circular(b.borderRadius),
        ),
        child: _buildContent(s),
      ),
    );
  }

  Widget _buildContent(AppButtonStyle s) {
    if (_loading) {
      return Center(
        child: SizedBox(
          width: s.loaderSize ?? 24,
          height: s.loaderSize ?? 24,
          child: CircularProgressIndicator(
            strokeWidth: s.loaderStrokeWidth,
            color: s.loaderColor ?? s.textColor ?? AppColors.gray0,
          ),
        ),
      );
    }

    final hasLabel = widget.label != null && widget.label!.isNotEmpty;
    final hasIcon = widget.icon != null || widget.iconWidget != null;

    if (!hasLabel && !hasIcon) return const SizedBox.shrink();

    final iconWidget =
        widget.iconWidget ??
        (widget.icon != null
            ? SvgPicture.asset(
              widget.icon!,
              width: s.iconSize,
              height: s.iconSize,
              colorFilter:
                  s.iconColor != null
                      ? ColorFilter.mode(s.iconColor!, BlendMode.srcIn)
                      : null,
            )
            : null);

    final textWidget =
        hasLabel
            ? Text(
              widget.label!,
              style:
                  s.textStyle ??
                  AppTextTheme.body4Medium16pt.copyWith(
                    color: s.textColor,
                    fontWeight: FontWeight.w600,
                  ),
            )
            : null;

    final children = <Widget>[];
    if (s.iconPosition == IconPosition.prefix) {
      if (iconWidget != null) children.add(iconWidget);
      if (textWidget != null) {
        if (iconWidget != null) children.add(SizedBox(width: s.gap));
        children.add(textWidget);
      }
    } else {
      if (textWidget != null) children.add(textWidget);
      if (iconWidget != null) {
        if (textWidget != null) children.add(SizedBox(width: s.gap));
        children.add(iconWidget);
      }
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: children,
    );
  }
}
