import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:yandex_dance/app/di/service_locator.dart';
import 'package:yandex_dance/core/enums/dance_style.dart';
import 'package:yandex_dance/core/ui/colors/colors.dart';
import 'package:yandex_dance/core/ui/typography/app_text_theme.dart';
import 'package:yandex_dance/core/ui/widgets/buttons/app_button.dart';
import 'package:yandex_dance/core/ui/widgets/buttons/app_button_style.dart';
import 'package:yandex_dance/features/events/domain/entities/dance_event.dart';
import 'package:yandex_dance/features/events/domain/repositories/event_repository.dart';
import 'package:yandex_dance/features/events/presentation/pages/event_details_page.dart';
import 'package:yandex_dance/features/events/presentation/utils/dance_event_to_event_preview.dart';
import 'package:yandex_dance/features/events/presentation/widgets/event_card.dart';
import 'package:yandex_dance/features/profile/domain/entities/user_profile.dart';
import 'package:yandex_dance/features/profile/domain/repositories/profile_repository.dart';
import 'package:yandex_dance/features/profile/presentation/pages/video_player_page.dart';

class FriendDetailEventsSection extends StatelessWidget {
  const FriendDetailEventsSection({
    super.key,
    required this.userId,
    required this.userDisplayName,
  });

  final String userId;
  final String userDisplayName;

  static final _dateFormat = DateFormat('dd.MM.yyyy, HH:mm');

  @override
  Widget build(BuildContext context) {
    final eventRepository = sl<EventRepository>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Text('Мероприятия', style: AppTextTheme.body3Regular20pt),
        ),
        const SizedBox(height: 12),
        StreamBuilder<List<DanceEvent>>(
          stream: eventRepository.watchUserEvents(userId),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting &&
                !snapshot.hasData) {
              return const Padding(
                padding: EdgeInsets.symmetric(vertical: 24),
                child: Center(
                  child: CircularProgressIndicator(color: AppColors.purple500),
                ),
              );
            }
            if (snapshot.hasError) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Text(
                  'Не удалось загрузить мероприятия',
                  style: AppTextTheme.body2Regular14pt.copyWith(
                    color: AppColors.gray100,
                  ),
                ),
              );
            }

            final now = DateTime.now();
            final upcoming =
                (snapshot.data ?? const <DanceEvent>[])
                    .where((e) => e.dateTime.isAfter(now))
                    .toList()
                  ..sort((a, b) => a.dateTime.compareTo(b.dateTime));

            if (upcoming.isEmpty) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Text(
                  'Нет предстоящих мероприятий',
                  style: AppTextTheme.body2Regular14pt.copyWith(
                    color: AppColors.gray100,
                  ),
                ),
              );
            }

            return Column(
              children: [
                for (var i = 0; i < upcoming.length; i++) ...[
                  EventCard(
                    title: upcoming[i].title,
                    styleLabel: upcoming[i].danceStyle.title,
                    ageRestrictionLabel:
                        upcoming[i].ageRestriction.trim().isEmpty
                            ? 'Для всех'
                            : upcoming[i].ageRestriction,
                    dateLabel: _dateFormat.format(upcoming[i].dateTime),
                    locationLabel: upcoming[i].address,
                    authorLabel:
                        upcoming[i].creatorId == userId
                            ? userDisplayName
                            : 'Организатор',
                    participantsLabel:
                        '${upcoming[i].currentParticipants}/${upcoming[i].maxParticipants}',
                    authorAvatarImage: null,
                    coverImage: networkImageOrNull(
                      upcoming[i].coverThumbUrl ?? upcoming[i].coverUrl,
                    ),
                    compact: true,
                    onTap:
                        () => _openEventDetails(
                          context,
                          upcoming[i],
                          userId,
                          userDisplayName,
                        ),
                  ),
                  if (i != upcoming.length - 1) const SizedBox(height: 16),
                ],
              ],
            );
          },
        ),
      ],
    );
  }
}

void _openEventDetails(
  BuildContext context,
  DanceEvent event,
  String userId,
  String userDisplayName,
) {
  final authorLabel =
      event.creatorId == userId ? userDisplayName : 'Организатор';
  final preview = eventPreviewFromDanceEvent(event, authorLabel: authorLabel);
  Navigator.of(context).push<void>(
    MaterialPageRoute<void>(builder: (_) => EventDetailsPage(event: preview)),
  );
}

/// Intro-видео из профиля пользователя по [userId] в `users/{uid}`.
class FriendDetailVideoSection extends StatelessWidget {
  const FriendDetailVideoSection({super.key, required this.userId});

  final String userId;

  @override
  Widget build(BuildContext context) {
    final profileRepository = sl<ProfileRepository>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Text('Видео', style: AppTextTheme.body3Regular20pt),
        ),
        const SizedBox(height: 12),
        StreamBuilder<UserProfile?>(
          stream: profileRepository.watchProfile(userId),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting &&
                !snapshot.hasData) {
              return const Padding(
                padding: EdgeInsets.symmetric(vertical: 16),
                child: Center(
                  child: CircularProgressIndicator(color: AppColors.purple500),
                ),
              );
            }
            if (snapshot.hasError) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Text(
                  'Не удалось загрузить видео',
                  style: AppTextTheme.body2Regular14pt.copyWith(
                    color: AppColors.gray100,
                  ),
                ),
              );
            }

            final profile = snapshot.data;
            final hasVideo = profile?.introVideoUrl != null;

            if (!hasVideo || profile == null) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Text(
                  'Видео ещё не добавлено',
                  style: AppTextTheme.body2Regular14pt.copyWith(
                    color: AppColors.gray100,
                  ),
                ),
              );
            }

            return SizedBox(
              height: 200,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 24),
                children: [
                  _FriendIntroVideoTile(
                    thumbUrl: profile.introVideoThumbUrl,
                    videoUrl: profile.introVideoUrl!,
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }
}

class _FriendIntroVideoTile extends StatelessWidget {
  const _FriendIntroVideoTile({required this.thumbUrl, required this.videoUrl});

  final String? thumbUrl;
  final String videoUrl;

  @override
  Widget build(BuildContext context) {
    return AppButton(
      onTap: () {
        Navigator.of(context, rootNavigator: true).push<void>(
          MaterialPageRoute<void>(
            builder: (_) => VideoPlayerPage(url: videoUrl),
            fullscreenDialog: true,
          ),
        );
      },
      iconWidget: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: SizedBox(
          width: 140,
          height: 200,
          child: Stack(
            fit: StackFit.expand,
            children: [
              if (thumbUrl != null && thumbUrl!.isNotEmpty)
                CachedNetworkImage(
                  imageUrl: thumbUrl!,
                  fit: BoxFit.cover,
                  placeholder: (_, __) => Container(color: AppColors.gray400),
                  errorWidget:
                      (_, __, ___) => Container(color: AppColors.gray400),
                )
              else
                Container(color: AppColors.gray400),
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withValues(alpha: 0.45),
                    ],
                  ),
                ),
              ),
              Center(
                child: Container(
                  width: 52,
                  height: 52,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [AppColors.purple500, AppColors.pink500],
                    ),
                  ),
                  child: const Icon(
                    Icons.play_arrow_rounded,
                    color: AppColors.gray0,
                    size: 32,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      style: const AppButtonStyle(
        width: 140,
        height: 200,
        padding: EdgeInsets.zero,
        backgroundColor: Colors.transparent,
      ),
    );
  }
}
