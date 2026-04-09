import 'package:flutter/material.dart';

import '../../../../core/ui/colors/colors.dart';
import '../../../../core/ui/widgets/custom_bounce_effect.dart';
import '../../../../core/ui/icons/app_icons.dart';
import '../../../../core/ui/icons/svg_icon.dart';

class EventCard extends StatelessWidget {
  const EventCard({
    super.key,
    this.title = 'Заголовок карточки',
    this.styleLabel = 'Стиль',
    this.ageRestrictionLabel = '16+',
    this.dateLabel = 'Дата и время',
    this.locationLabel = 'Локация',
    this.authorLabel = 'Вы',
    this.participantsLabel = '0/0',
    this.authorAvatarImage,
    this.coverImage,
    this.onTap,
    this.compact = false,
  });

  final String title;
  final String styleLabel;
  final String ageRestrictionLabel;
  final String dateLabel;
  final String locationLabel;
  final String authorLabel;
  final String participantsLabel;
  final ImageProvider<Object>? authorAvatarImage;
  final ImageProvider<Object>? coverImage;
  final VoidCallback? onTap;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    if (compact) {
      return _CompactEventCard(
        title: title,
        styleLabel: styleLabel,
        ageRestrictionLabel: ageRestrictionLabel,
        dateLabel: dateLabel,
        locationLabel: locationLabel,
        authorLabel: authorLabel,
        participantsLabel: participantsLabel,
        authorAvatarImage: authorAvatarImage,
        coverImage: coverImage,
        onTap: onTap,
      );
    }

    final card = Material(
      color: Colors.transparent,
      child: Ink(
        decoration: BoxDecoration(
          color: AppColors.cardSurface,
          borderRadius: BorderRadius.circular(AppColors.cardRadius),
          border: Border.all(color: AppColors.cardBorder),
          boxShadow: AppColors.cardShadow,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _EventCardCover(styleLabel: styleLabel, coverImage: coverImage),
            Padding(
              padding: const EdgeInsets.fromLTRB(22, 20, 22, 22),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: AppColors.gray0,
                      height: 1.1,
                    ),
                  ),
                  const SizedBox(height: 18),
                  _MetaRow(iconPath: AppIcons.calendar, text: dateLabel),
                  const SizedBox(height: 12),
                  _MetaRow(iconPath: AppIcons.pin, text: locationLabel),
                  const SizedBox(height: 12),
                  _MetaRow(
                    iconPath: AppIcons.info,
                    text: 'Возраст: $ageRestrictionLabel',
                  ),
                  const SizedBox(height: 12),
                  Divider(color: Colors.white.withValues(alpha: 0.1)),
                  const SizedBox(height: 12),
                  _BottomRow(
                    authorLabel: authorLabel,
                    participantsLabel: participantsLabel,
                    authorAvatarImage: authorAvatarImage,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );

    final callback = onTap;
    if (callback == null) {
      return card;
    }
    return CustomBounceEffect(onTap: callback, child: card);
  }
}

class _CompactEventCard extends StatelessWidget {
  const _CompactEventCard({
    required this.title,
    required this.styleLabel,
    required this.ageRestrictionLabel,
    required this.dateLabel,
    required this.locationLabel,
    required this.authorLabel,
    required this.participantsLabel,
    this.authorAvatarImage,
    this.coverImage,
    this.onTap,
  });

  final String title;
  final String styleLabel;
  final String ageRestrictionLabel;
  final String dateLabel;
  final String locationLabel;
  final String authorLabel;
  final String participantsLabel;
  final ImageProvider<Object>? authorAvatarImage;
  final ImageProvider<Object>? coverImage;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final card = Material(
      color: Colors.transparent,
      child: Ink(
        decoration: BoxDecoration(
          color: AppColors.cardSurface,
          borderRadius: BorderRadius.circular(AppColors.cardRadius),
          border: Border.all(color: AppColors.cardBorder),
          boxShadow: AppColors.cardShadow,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _CompactCover(coverImage: coverImage),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: AppColors.gray0,
                      fontWeight: FontWeight.w800,
                      height: 1.08,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _CompactMetaRow(
                    iconPath: AppIcons.calendar,
                    text: dateLabel,
                  ),
                  if (locationLabel.trim().isNotEmpty) ...[
                    const SizedBox(height: 8),
                    _CompactMetaRow(
                      iconPath: AppIcons.pin,
                      text: locationLabel,
                    ),
                  ],
                  const SizedBox(height: 14),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: [
                      _CompactChip(
                        label: styleLabel,
                        textColor: AppColors.purple500,
                        borderColor: AppColors.purple500.withValues(
                          alpha: 0.28,
                        ),
                        backgroundColor: AppColors.cardChipBackground,
                      ),
                      _CompactInfoPill(
                        iconPath: AppIcons.friends,
                        label: participantsLabel,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );

    final callback = onTap;
    if (callback == null) {
      return card;
    }
    return CustomBounceEffect(onTap: callback, child: card);
  }
}

class _EventCardCover extends StatelessWidget {
  const _EventCardCover({required this.styleLabel, this.coverImage});

  final String styleLabel;
  final ImageProvider<Object>? coverImage;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1.18,
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(AppColors.cardRadius),
        ),
        child: Stack(
          children: [
            Positioned.fill(
              child:
                  coverImage != null
                      ? DecoratedBox(
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image: coverImage!,
                            fit: BoxFit.cover,
                            onError: (_, __) {},
                          ),
                        ),
                      )
                      : DecoratedBox(
                        decoration: BoxDecoration(
                          color: AppColors.cardCoverPlaceholder,
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Colors.white.withValues(alpha: 0.03),
                              Colors.black.withValues(alpha: 0.08),
                            ],
                          ),
                        ),
                      ),
            ),
            if (coverImage == null)
              const Positioned.fill(
                child: Center(
                  child: SvgIcon(
                    AppIcons.notImage,
                    size: 72,
                    color: AppColors.gray300,
                  ),
                ),
              ),
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withValues(alpha: 0.16),
                      Colors.black.withValues(alpha: 0.55),
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              top: 16,
              right: 16,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: AppColors.cardChipBackground,
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(
                    color: AppColors.purple500.withValues(alpha: 0.28),
                  ),
                ),
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Text(
                    styleLabel,
                    style: TextStyle(
                      color: AppColors.purple500,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CompactCover extends StatelessWidget {
  const _CompactCover({this.coverImage});

  final ImageProvider<Object>? coverImage;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(
        top: Radius.circular(AppColors.cardRadius),
      ),
      child: AspectRatio(
        aspectRatio: 2.05,
        child: Stack(
          children: [
            Positioned.fill(
              child:
                  coverImage != null
                      ? DecoratedBox(
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image: coverImage!,
                            fit: BoxFit.cover,
                            onError: (_, __) {},
                          ),
                        ),
                      )
                      : DecoratedBox(
                        decoration: BoxDecoration(
                          color: AppColors.cardCoverPlaceholder,
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Colors.white.withValues(alpha: 0.03),
                              Colors.black.withValues(alpha: 0.08),
                            ],
                          ),
                        ),
                      ),
            ),
            if (coverImage == null)
              const Positioned.fill(
                child: Center(
                  child: SvgIcon(
                    AppIcons.notImage,
                    size: 48,
                    color: AppColors.gray300,
                  ),
                ),
              ),
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.white.withValues(alpha: 0.02),
                      Colors.transparent,
                      Colors.black.withValues(alpha: 0.22),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MetaRow extends StatelessWidget {
  const _MetaRow({required this.iconPath, required this.text});

  final String iconPath;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SvgIcon(iconPath, size: 20, color: AppColors.gray100),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: AppColors.gray100,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}

class _CompactMetaRow extends StatelessWidget {
  const _CompactMetaRow({required this.iconPath, required this.text});

  final String iconPath;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SvgIcon(iconPath, size: 16, color: AppColors.gray100),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.gray100,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}

class _CompactChip extends StatelessWidget {
  const _CompactChip({
    required this.label,
    required this.textColor,
    required this.borderColor,
    required this.backgroundColor,
  });

  final String label;
  final Color textColor;
  final Color borderColor;
  final Color backgroundColor;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: borderColor),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        child: Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: textColor,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

class _CompactInfoPill extends StatelessWidget {
  const _CompactInfoPill({required this.iconPath, required this.label});

  final String iconPath;
  final String label;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SvgIcon(iconPath, size: 15, color: const Color(0xFF12C7F5)),
            const SizedBox(width: 7),
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.gray0,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BottomRow extends StatelessWidget {
  const _BottomRow({
    required this.authorLabel,
    required this.participantsLabel,
    this.authorAvatarImage,
  });

  final String authorLabel;
  final String participantsLabel;
  final ImageProvider<Object>? authorAvatarImage;

  @override
  Widget build(BuildContext context) {
    const avatarSize = 44.0;
    const iconSize = 22.0;
    final textStyle = Theme.of(context).textTheme.bodyLarge?.copyWith(
      color: AppColors.gray0,
      fontWeight: FontWeight.w700,
    );

    return Row(
      children: [
        _AuthorAvatar(
          authorAvatarImage: authorAvatarImage,
          size: avatarSize,
          iconSize: 20,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            authorLabel,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: textStyle,
          ),
        ),
        SvgIcon(
          AppIcons.friends,
          size: iconSize,
          color: const Color(0xFF12C7F5),
        ),
        const SizedBox(width: 10),
        Text(participantsLabel, style: textStyle),
      ],
    );
  }
}

class _AuthorAvatar extends StatelessWidget {
  const _AuthorAvatar({
    this.authorAvatarImage,
    required this.size,
    required this.iconSize,
  });

  final ImageProvider<Object>? authorAvatarImage;
  final double size;
  final double iconSize;

  @override
  Widget build(BuildContext context) {
    if (authorAvatarImage != null) {
      return ClipOval(
        child: SizedBox(
          width: size,
          height: size,
          child: Image(
            image: authorAvatarImage!,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => const _AuthorAvatarFallback(),
          ),
        ),
      );
    }

    return _AuthorAvatarFallback(size: size, iconSize: iconSize);
  }
}

class _AuthorAvatarFallback extends StatelessWidget {
  const _AuthorAvatarFallback({this.size = 44, this.iconSize = 20});

  final double size;
  final double iconSize;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.purple500, AppColors.pink500],
        ),
      ),
      child: Center(
        child: SvgIcon(AppIcons.user, size: iconSize, color: AppColors.gray0),
      ),
    );
  }
}
