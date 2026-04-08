import 'package:flutter/material.dart';
import 'package:yandex_dance/core/ui/colors/colors.dart';
import 'package:yandex_dance/core/ui/icons/app_icons.dart';
import 'package:yandex_dance/core/ui/icons/svg_icon.dart';

class PersonPhoto extends StatelessWidget {
  const PersonPhoto({
    super.key,
    this.image,
    this.rating,
    required this.size,
    this.badgeLabel,
    this.badgeIcon = AppIcons.star,
    this.showBadge = true,
  });

  final ImageProvider<Object>? image;
  final double? rating;
  final double size;
  final String? badgeLabel;
  final String badgeIcon;
  final bool showBadge;

  @override
  Widget build(BuildContext context) {
    final borderRadius = size * 0.18;

    final badgeHorizontalPadding = size * 0.10;
    final badgeVerticalPadding = size * 0.06;
    final badgeBorderRadius = size * 0.22;
    final iconSize = size * 0.15;
    final spacing = size * 0.04;
    final fontSize = size * 0.13;

    final badgeRightInset = size * 0.02;
    final badgeBottomOffset = size * 0.10;

    if (!showBadge) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child:
            image != null
                ? Image(
                  image: image!,
                  width: size,
                  height: size,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => _PhotoPlaceholder(size: size),
                )
                : _PhotoPlaceholder(size: size),
      );
    }

    return SizedBox(
      width: size,
      height: size + badgeBottomOffset,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(borderRadius),
            child:
                image != null
                    ? Image(
                      image: image!,
                      width: size,
                      height: size,
                      fit: BoxFit.cover,
                      errorBuilder:
                          (_, __, ___) => _PhotoPlaceholder(size: size),
                    )
                    : _PhotoPlaceholder(size: size),
          ),
          Positioned(
            right: badgeRightInset,
            bottom: -badgeBottomOffset,
            child: _RatingBadge(
              badgeLabel: badgeLabel ?? (rating ?? 0).toStringAsFixed(1),
              badgeIcon: badgeIcon,
              horizontalPadding: badgeHorizontalPadding,
              verticalPadding: badgeVerticalPadding,
              borderRadius: badgeBorderRadius,
              iconSize: iconSize,
              spacing: spacing,
              fontSize: fontSize,
            ),
          ),
        ],
      ),
    );
  }
}

class _RatingBadge extends StatelessWidget {
  const _RatingBadge({
    required this.badgeLabel,
    required this.badgeIcon,
    required this.horizontalPadding,
    required this.verticalPadding,
    required this.borderRadius,
    required this.iconSize,
    required this.spacing,
    required this.fontSize,
  });

  final String badgeLabel;
  final String badgeIcon;
  final double horizontalPadding;
  final double verticalPadding;
  final double borderRadius;
  final double iconSize;
  final double spacing;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: horizontalPadding,
        vertical: verticalPadding,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        gradient: LinearGradient(
          colors: [AppColors.purple500, AppColors.pink500],
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SvgIcon(badgeIcon, size: iconSize, color: AppColors.gray0),
          SizedBox(width: spacing),
          Text(
            badgeLabel,
            style: TextStyle(
              color: AppColors.gray0,
              fontWeight: FontWeight.bold,
              fontSize: fontSize,
            ),
          ),
        ],
      ),
    );
  }
}

class _PhotoPlaceholder extends StatelessWidget {
  const _PhotoPlaceholder({required this.size});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.purple600, AppColors.pink500],
        ),
      ),
      child: Center(
        child: SvgIcon(
          AppIcons.user,
          color: AppColors.gray0.withValues(alpha: 0.9),
          size: size * 0.44,
        ),
      ),
    );
  }
}
