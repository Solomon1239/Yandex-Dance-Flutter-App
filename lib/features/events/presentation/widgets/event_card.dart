import 'package:flutter/material.dart';

import '../../../../core/ui/colors/colors.dart';
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
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(32),
        child: Ink(
          decoration: BoxDecoration(
            color: const Color(0xFF101010),
            borderRadius: BorderRadius.circular(32),
            border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
            boxShadow: const [
              BoxShadow(
                color: Color(0x40000000),
                blurRadius: 30,
                offset: Offset(0, 18),
              ),
            ],
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
                      style: Theme.of(
                        context,
                      ).textTheme.headlineSmall?.copyWith(
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
      ),
    );
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
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
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
                          color: const Color(0xFF181818),
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
                  color: const Color(0xFF25211F),
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
    return Row(
      children: [
        _AuthorAvatar(authorAvatarImage: authorAvatarImage),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            authorLabel,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: AppColors.gray0,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        SvgIcon(AppIcons.friends, size: 22, color: const Color(0xFF12C7F5)),
        const SizedBox(width: 10),
        Text(
          participantsLabel,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: AppColors.gray0,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class _AuthorAvatar extends StatelessWidget {
  const _AuthorAvatar({this.authorAvatarImage});

  final ImageProvider<Object>? authorAvatarImage;

  @override
  Widget build(BuildContext context) {
    if (authorAvatarImage != null) {
      return ClipOval(
        child: SizedBox(
          width: 44,
          height: 44,
          child: Image(
            image: authorAvatarImage!,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => const _AuthorAvatarFallback(),
          ),
        ),
      );
    }

    return const _AuthorAvatarFallback();
  }
}

class _AuthorAvatarFallback extends StatelessWidget {
  const _AuthorAvatarFallback();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 44,
      height: 44,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.purple500, AppColors.pink500],
        ),
      ),
      child: const Center(
        child: SvgIcon(AppIcons.user, size: 20, color: AppColors.gray0),
      ),
    );
  }
}
