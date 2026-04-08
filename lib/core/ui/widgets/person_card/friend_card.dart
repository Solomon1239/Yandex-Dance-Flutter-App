import 'package:flutter/material.dart';
import 'package:yandex_dance/core/ui/colors/colors.dart';
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
  });

  @override
  Widget build(BuildContext context) {
    final card = Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.cardSurface,
        borderRadius: BorderRadius.circular(AppColors.cardRadius),
        border: Border.all(color: AppColors.cardBorder),
        boxShadow: AppColors.cardShadow,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          PersonPhoto(
            image: image,
            size: 70,
            badgeLabel: imageBadgeLabel,
            badgeIcon: imageBadgeIcon,
            showBadge: showImageBadge,
          ),
          const SizedBox(width: 20),
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final maxMetaWidth = constraints.maxWidth;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: AppTextTheme.body1Medium18pt.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: [
                        if (headerBadgeLabel != null)
                          _HeaderBadge(
                            label: headerBadgeLabel!,
                            icon: headerBadgeIcon,
                          ),
                        ConstrainedBox(
                          constraints: BoxConstraints(maxWidth: maxMetaWidth),
                          child: _StylePill(label: styleName),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextTheme.body2Regular14pt.copyWith(
                        color: AppColors.gray100,
                        height: 1.45,
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );

    if (onTap == null) {
      return card;
    }

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppColors.cardRadius),
        child: card,
      ),
    );
  }
}

class _StylePill extends StatelessWidget {
  const _StylePill({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.cardChipBackground,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppColors.purple500.withValues(alpha: 0.28)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: AppTextTheme.body3RegularPurple14pt.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

class _HeaderBadge extends StatelessWidget {
  const _HeaderBadge({required this.label, required this.icon});

  final String label;
  final String icon;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SvgIcon(icon, size: 15, color: const Color(0xFF12C7F5)),
            const SizedBox(width: 6),
            Text(
              label,
              maxLines: 1,
              style: AppTextTheme.body2Regular14pt.copyWith(
                color: AppColors.gray0,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
