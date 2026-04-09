import 'package:flutter/material.dart';
import 'package:yandex_dance/core/ui/colors/colors.dart';
import 'package:yandex_dance/core/ui/widgets/custom_bounce_effect.dart';
import 'package:yandex_dance/core/ui/icons/app_icons.dart';
import 'package:yandex_dance/core/ui/icons/svg_icon.dart';
import 'package:yandex_dance/core/ui/typography/app_text_theme.dart';
import 'package:yandex_dance/core/ui/widgets/person_card/person_photo.dart';

class FriendCard extends StatelessWidget {
  final ImageProvider<Object>? image;
  final String name;
  final String styleName;
  final String description;
  final String? imageBadgeLabel;
  final String imageBadgeIcon;
  final bool showImageBadge;
  final String? headerBadgeLabel;
  final String headerBadgeIcon;
  final VoidCallback? onTap;
  /// Компактная вёрстка: меньше отступы, аватар и шрифты (напр. горизонтальный список на главной).
  final bool compact;

  const FriendCard({
    super.key,
    this.image,
    required this.name,
    required this.styleName,
    required this.description,
    this.imageBadgeLabel,
    this.imageBadgeIcon = AppIcons.star,
    this.showImageBadge = true,
    this.headerBadgeLabel,
    this.headerBadgeIcon = AppIcons.calendar,
    this.onTap,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final pad = compact ? 8.0 : 20.0;
    final photoSize = compact ? 64.0 : 70.0;
    final photoGap = compact ? 8.0 : 20.0;
    final radius = compact ? 20.0 : AppColors.cardRadius;
    final nameStyle =
        compact
            ? AppTextTheme.body4Medium16pt.copyWith(
              fontWeight: FontWeight.w700,
              fontSize: 14,
            )
            : AppTextTheme.body1Medium18pt.copyWith(
              fontWeight: FontWeight.w700,
            );
    final descStyle =
        AppTextTheme.body2Regular14pt.copyWith(
          color: AppColors.gray100,
          height: compact ? 1.22 : 1.45,
          fontSize: compact ? 11 : 14,
        );

    final card = Container(
      padding: EdgeInsets.all(pad),
      decoration: BoxDecoration(
        color: AppColors.cardSurface,
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: AppColors.cardBorder),
        boxShadow: AppColors.cardShadow,
      ),
      child: Row(
        crossAxisAlignment:
            compact ? CrossAxisAlignment.center : CrossAxisAlignment.start,
        children: [
          PersonPhoto(
            image: image,
            size: photoSize,
            badgeLabel: imageBadgeLabel,
            badgeIcon: imageBadgeIcon,
            showBadge: showImageBadge,
          ),
          SizedBox(width: photoGap),
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final maxMetaWidth = constraints.maxWidth;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      maxLines: compact ? 1 : 2,
                      overflow: TextOverflow.ellipsis,
                      style: nameStyle,
                    ),
                    SizedBox(height: compact ? 4 : 10),
                    Wrap(
                      spacing: compact ? 4 : 10,
                      runSpacing: compact ? 4 : 10,
                      children: [
                        if (headerBadgeLabel != null)
                          _HeaderBadge(
                            label: headerBadgeLabel!,
                            icon: headerBadgeIcon,
                            compact: compact,
                          ),
                        ConstrainedBox(
                          constraints: BoxConstraints(maxWidth: maxMetaWidth),
                          child: _StylePill(label: styleName, compact: compact),
                        ),
                      ],
                    ),
                    SizedBox(height: compact ? 2 : 12),
                    Text(
                      description,
                      maxLines: compact ? 1 : 2,
                      overflow: TextOverflow.ellipsis,
                      style: descStyle,
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );

    final callback = onTap;
    if (callback == null) {
      return card;
    }

    return CustomBounceEffect(onTap: callback, child: card);
  }
}

class _StylePill extends StatelessWidget {
  const _StylePill({required this.label, this.compact = false});

  final String label;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final hPad = compact ? 8.0 : 16.0;
    final vPad = compact ? 4.0 : 8.0;
    final textStyle =
        AppTextTheme.body3RegularPurple14pt.copyWith(
          fontWeight: FontWeight.w600,
          fontSize: compact ? 11 : 14,
        );

    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.cardChipBackground,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppColors.purple500.withValues(alpha: 0.28)),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: hPad, vertical: vPad),
        child: Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: textStyle,
        ),
      ),
    );
  }
}

class _HeaderBadge extends StatelessWidget {
  const _HeaderBadge({
    required this.label,
    required this.icon,
    this.compact = false,
  });

  final String label;
  final String icon;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final hPad = compact ? 6.0 : 12.0;
    final vPad = compact ? 4.0 : 8.0;
    final iconSize = compact ? 11.0 : 15.0;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: hPad, vertical: vPad),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SvgIcon(icon, size: iconSize, color: const Color(0xFF12C7F5)),
            SizedBox(width: compact ? 4 : 6),
            Text(
              label,
              maxLines: 1,
              style: AppTextTheme.body2Regular14pt.copyWith(
                color: AppColors.gray0,
                fontWeight: FontWeight.w600,
                fontSize: compact ? 11 : 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
