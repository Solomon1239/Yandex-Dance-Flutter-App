import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:yandex_dance/app/di/service_locator.dart';
import 'package:yandex_dance/core/enums/dance_style.dart';
import 'package:yandex_dance/core/ui/colors/colors.dart';
import 'package:yandex_dance/core/ui/icons/app_icons.dart';
import 'package:yandex_dance/core/ui/icons/svg_icon.dart';
import 'package:yandex_dance/core/ui/typography/app_text_theme.dart';
import 'package:yandex_dance/core/ui/widgets/person_card/friend_card.dart';
import 'package:yandex_dance/core/widgets/section_title.dart';
import 'package:yandex_dance/features/auth/domain/repositories/auth_repository.dart';
import 'package:yandex_dance/features/events/domain/entities/dance_event.dart';
import 'package:yandex_dance/features/events/domain/repositories/event_repository.dart';
import 'package:yandex_dance/features/events/presentation/models/event_preview.dart';
import 'package:yandex_dance/features/events/presentation/pages/event_details_page.dart';
import 'package:yandex_dance/features/events/presentation/widgets/event_card.dart';
import 'package:yandex_dance/features/friends/presentation/pages/friend_detail_page.dart';
import 'package:yandex_dance/features/profile/domain/entities/user_profile.dart';
import 'package:yandex_dance/features/profile/domain/repositories/profile_repository.dart';

class UpcomingEventsPage extends StatefulWidget {
  const UpcomingEventsPage({super.key});

  @override
  State<UpcomingEventsPage> createState() => _UpcomingEventsPageState();
}

class _UpcomingEventsPageState extends State<UpcomingEventsPage> {
  static const _topItemsLimit = 5;

  final EventRepository _eventRepository = sl<EventRepository>();
  final ProfileRepository _profileRepository = sl<ProfileRepository>();
  final AuthRepository _authRepository = sl<AuthRepository>();
  final DateFormat _dateFormat = DateFormat('dd.MM.yyyy, HH:mm');

  late final Stream<List<DanceEvent>> _eventsStream;
  late final Stream<List<UserProfile>> _profilesStream;

  @override
  void initState() {
    super.initState();
    _eventsStream = _eventRepository.watchAllEvents();
    _profilesStream = _profileRepository.watchAllProfiles();
  }

  Future<void> _openEventDetails(EventPreview event) {
    return Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => EventDetailsPage(event: event)));
  }

  void _openDancerDetails(String coachId) {
    Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (_) => FriendDetailPage(coachId: coachId),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.gray500,
      body: SafeArea(
        child: StreamBuilder<List<DanceEvent>>(
          stream: _eventsStream,
          builder: (context, eventsSnapshot) {
            if (eventsSnapshot.connectionState == ConnectionState.waiting &&
                !eventsSnapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }

            if (eventsSnapshot.hasError) {
              return const _InfoState(
                iconPath: AppIcons.trending,
                title: 'Не удалось загрузить главную страницу',
                subtitle: 'Проверьте соединение и попробуйте ещё раз',
              );
            }

            final events = eventsSnapshot.data ?? const <DanceEvent>[];

            return StreamBuilder<List<UserProfile>>(
              stream: _profilesStream,
              initialData: const <UserProfile>[],
              builder: (context, profilesSnapshot) {
                final profiles = profilesSnapshot.data ?? const <UserProfile>[];
                final profilesById = {
                  for (final profile in profiles) profile.uid: profile,
                };
                final popularEvents = _buildPopularEvents(events, profilesById);
                final popularDancers = _buildPopularDancers(
                  events,
                  profilesById,
                );

                final profilesLoading =
                    profilesSnapshot.connectionState ==
                        ConnectionState.waiting &&
                    profiles.isEmpty;
                final hasAnyContent =
                    popularEvents.isNotEmpty || popularDancers.isNotEmpty;

                if (!hasAnyContent && !profilesLoading) {
                  return const _InfoState(
                    iconPath: AppIcons.home,
                    title: 'Пока недостаточно данных для главной',
                    subtitle:
                        'Когда появятся мероприятия и участники, здесь появятся подборки',
                  );
                }

                return SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const _SectionHeader(title: 'Популярные мероприятия'),
                      const SizedBox(height: 16),
                      if (popularEvents.isEmpty)
                        const _SectionPlaceholder(
                          iconPath: AppIcons.calendar,
                          text: 'Мероприятия пока не добавлены',
                        )
                      else
                        Column(
                          children: [
                            for (var i = 0; i < popularEvents.length; i++) ...[
                              EventCard(
                                title: popularEvents[i].preview.title,
                                styleLabel: popularEvents[i].preview.styleLabel,
                                ageRestrictionLabel:
                                    popularEvents[i]
                                        .preview
                                        .ageRestrictionLabel,
                                dateLabel: popularEvents[i].preview.dateLabel,
                                locationLabel:
                                    popularEvents[i].preview.locationLabel,
                                authorLabel:
                                    popularEvents[i].preview.authorLabel,
                                participantsLabel:
                                    popularEvents[i].preview.participantsLabel,
                                authorAvatarImage:
                                    popularEvents[i].preview.authorAvatarImage,
                                coverImage: popularEvents[i].preview.coverImage,
                                compact: true,
                                onTap:
                                    () => _openEventDetails(
                                      popularEvents[i].preview,
                                    ),
                              ),
                              if (i != popularEvents.length - 1)
                                const SizedBox(height: 16),
                            ],
                          ],
                        ),
                      const SizedBox(height: 28),
                      Divider(
                        color: AppColors.gray300.withValues(alpha: 0.25),
                        height: 1,
                      ),
                      const SizedBox(height: 28),
                      const _SectionHeader(title: 'Популярные танцоры'),
                      const SizedBox(height: 16),
                      if (profilesLoading)
                        const _SectionPlaceholder(
                          iconPath: AppIcons.user,
                          text: 'Загружаем танцоров...',
                        )
                      else if (profilesSnapshot.hasError)
                        const _SectionPlaceholder(
                          iconPath: AppIcons.user,
                          text: 'Не удалось загрузить профили танцоров',
                        )
                      else if (popularDancers.isEmpty)
                        const _SectionPlaceholder(
                          iconPath: AppIcons.user,
                          text: 'Танцоры появятся после участия в мероприятиях',
                        )
                      else
                        Column(
                          children: [
                            for (var i = 0; i < popularDancers.length; i++) ...[
                              FriendCard(
                                image: _networkImageOrNull(
                                  popularDancers[i].avatarUrl,
                                ),
                                name: popularDancers[i].name,
                                showImageBadge: false,
                                headerBadgeLabel: _formatDancerBadge(
                                  popularDancers[i].eventsCount,
                                ),
                                styleName: popularDancers[i].stylesLabel,
                                description: popularDancers[i].description,
                                onTap: () =>
                                    _openDancerDetails(popularDancers[i].uid),
                              ),
                              if (i != popularDancers.length - 1)
                                const SizedBox(height: 16),
                            ],
                          ],
                        ),
                    ],
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }

  List<_PopularEventItem> _buildPopularEvents(
    List<DanceEvent> events,
    Map<String, UserProfile> profilesById,
  ) {
    final sortedEvents = [...events]..sort((a, b) {
      final participantsComparison = b.currentParticipants.compareTo(
        a.currentParticipants,
      );
      if (participantsComparison != 0) {
        return participantsComparison;
      }
      return a.dateTime.compareTo(b.dateTime);
    });

    return sortedEvents
        .take(_topItemsLimit)
        .map(
          (event) => _PopularEventItem(
            preview: _mapEventToPreview(event, profilesById),
          ),
        )
        .toList();
  }

  List<_PopularDancerItem> _buildPopularDancers(
    List<DanceEvent> events,
    Map<String, UserProfile> profilesById,
  ) {
    final eventsCountByUserId = <String, int>{};

    for (final event in events) {
      for (final uid in event.participantIds.toSet()) {
        eventsCountByUserId.update(
          uid,
          (value) => value + 1,
          ifAbsent: () => 1,
        );
      }
    }

    final items =
        eventsCountByUserId.entries.map((entry) {
            final profile = profilesById[entry.key];
            final styles =
                profile?.danceStyles.map((style) => style.title).toList() ??
                const <String>[];

            return _PopularDancerItem(
              uid: entry.key,
              name: _resolveProfileName(profile, entry.key),
              avatarUrl: profile?.avatarThumbUrl ?? profile?.avatarUrl,
              stylesLabel:
                  styles.isEmpty ? 'Без стиля' : styles.take(2).join(' · '),
              description: _buildDancerDescription(profile, entry.value),
              eventsCount: entry.value,
            );
          }).toList()
          ..sort((a, b) {
            final eventsComparison = b.eventsCount.compareTo(a.eventsCount);
            if (eventsComparison != 0) {
              return eventsComparison;
            }
            return a.name.toLowerCase().compareTo(b.name.toLowerCase());
          });

    return items.take(_topItemsLimit).toList();
  }

  EventPreview _mapEventToPreview(
    DanceEvent event,
    Map<String, UserProfile> profilesById,
  ) {
    final creatorProfile = profilesById[event.creatorId];
    final coordinates = _coordinatesForEvent(event);
    final currentUserId = _authRepository.currentUserId;

    return EventPreview(
      id: event.id,
      title: event.title,
      styleLabel: event.danceStyle.title,
      ageRestrictionLabel:
          event.ageRestriction.trim().isEmpty
              ? 'Для всех'
              : event.ageRestriction,
      dateTime: event.dateTime,
      dateLabel: _dateFormat.format(event.dateTime),
      locationLabel: event.address,
      authorLabel:
          event.creatorId == currentUserId
              ? 'Вы'
              : _resolveProfileName(creatorProfile, event.creatorId),
      currentParticipants: event.currentParticipants,
      maxParticipants: event.maxParticipants,
      participantsLabel:
          '${event.currentParticipants}/${event.maxParticipants}',
      latitude: coordinates.$1,
      longitude: coordinates.$2,
      description: event.description,
      authorAvatarImage: _networkImageOrNull(
        creatorProfile?.avatarThumbUrl ?? creatorProfile?.avatarUrl,
      ),
      coverImage: _networkImageOrNull(event.coverThumbUrl ?? event.coverUrl),
    );
  }

  String _resolveProfileName(UserProfile? profile, String uid) {
    final displayName = profile?.displayName?.trim();
    if (displayName != null && displayName.isNotEmpty) {
      return displayName;
    }
    return 'Танцор ${_shortUid(uid)}';
  }

  String _buildDancerDescription(UserProfile? profile, int eventsCount) {
    final summary = 'Участвует в ${_formatEventsCount(eventsCount)}';
    final city = profile?.city?.trim();
    if (city != null && city.isNotEmpty) {
      return '$summary · $city';
    }

    final bio = profile?.bio?.trim();
    if (bio != null && bio.isNotEmpty) {
      return '$summary · $bio';
    }

    return summary;
  }

  String _formatEventsCount(int count) {
    final mod10 = count % 10;
    final mod100 = count % 100;

    if (mod10 == 1 && mod100 != 11) {
      return '$count мероприятии';
    }
    if (mod10 >= 2 && mod10 <= 4 && (mod100 < 12 || mod100 > 14)) {
      return '$count мероприятиях';
    }
    return '$count мероприятиях';
  }

  String _formatDancerBadge(int count) {
    final mod10 = count % 10;
    final mod100 = count % 100;

    if (mod10 == 1 && mod100 != 11) {
      return '$count событие';
    }
    if (mod10 >= 2 && mod10 <= 4 && (mod100 < 12 || mod100 > 14)) {
      return '$count события';
    }
    return '$count событий';
  }

  String _shortUid(String uid) {
    if (uid.length <= 6) {
      return uid;
    }
    return uid.substring(0, 6);
  }

  ImageProvider<Object>? _networkImageOrNull(String? url) {
    final value = url?.trim();
    if (value == null || value.isEmpty) {
      return null;
    }
    return NetworkImage(value);
  }

  (double, double) _coordinatesForEvent(DanceEvent event) {
    if (event.latitude != null && event.longitude != null) {
      return (event.latitude!, event.longitude!);
    }
    return (55.751244, 37.618423);
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return SectionTitle(title);
  }
}

class _SectionPlaceholder extends StatelessWidget {
  const _SectionPlaceholder({required this.iconPath, required this.text});

  final String iconPath;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      decoration: BoxDecoration(
        color: AppColors.gray400,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.gray300.withValues(alpha: 0.3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SvgIcon(iconPath, size: 28, color: AppColors.gray300),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              text,
              style: AppTextTheme.body2Regular14pt.copyWith(
                color: AppColors.gray100,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoState extends StatelessWidget {
  const _InfoState({
    required this.iconPath,
    required this.title,
    required this.subtitle,
  });

  final String iconPath;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SvgIcon(iconPath, size: 32, color: AppColors.gray100),
            const SizedBox(height: 16),
            Text(
              title,
              textAlign: TextAlign.center,
              style: AppTextTheme.body4Medium16pt,
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: AppTextTheme.body2Regular14pt.copyWith(
                color: AppColors.gray100,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PopularEventItem {
  const _PopularEventItem({required this.preview});

  final EventPreview preview;
}

class _PopularDancerItem {
  const _PopularDancerItem({
    required this.uid,
    required this.name,
    required this.avatarUrl,
    required this.stylesLabel,
    required this.description,
    required this.eventsCount,
  });

  final String uid;
  final String name;
  final String? avatarUrl;
  final String stylesLabel;
  final String description;
  final int eventsCount;
}
