import 'package:flutter/material.dart';
import 'package:yandex_dance/core/ui/colors/colors.dart';

class PersonPhoto extends StatelessWidget {
  const PersonPhoto({
    super.key,
    required this.image,
    required this.rating,
    required this.size,
  });

  final ImageProvider image;
  final double rating;
  final double size;

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

    return SizedBox(
      width: size,
      height: size + badgeBottomOffset,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(borderRadius),
            child: Image(
              image: image,
              width: size,
              height: size,
              fit: BoxFit.cover,
            ),
          ),
          Positioned(
            right: badgeRightInset,
            bottom: -badgeBottomOffset,
            child: _RatingBadge(
              rating: rating,
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
    required this.rating,
    required this.horizontalPadding,
    required this.verticalPadding,
    required this.borderRadius,
    required this.iconSize,
    required this.spacing,
    required this.fontSize,
  });

  final double rating;
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
          colors: [
            AppColors.purple500,
            AppColors.pink500,
          ],
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.star,
            color: AppColors.gray0,
            size: iconSize,
          ),
          SizedBox(width: spacing),
          Text(
            rating.toStringAsFixed(1),
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