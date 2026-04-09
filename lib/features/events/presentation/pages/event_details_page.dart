import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:yandex_dance/app/di/service_locator.dart';
import 'package:yandex_dance/core/enums/dance_style.dart';
import 'package:yandex_dance/core/ui/colors/colors.dart';
import 'package:yandex_dance/core/ui/media/cached_remote_image.dart';
import 'package:yandex_dance/core/ui/icons/app_icons.dart';
import 'package:yandex_dance/core/ui/icons/svg_icon.dart';
import 'package:yandex_dance/core/ui/widgets/custom_bounce_effect.dart';
import 'package:yandex_dance/core/ui/widgets/buttons/app_button.dart';
import 'package:yandex_dance/core/ui/widgets/buttons/app_button_style.dart';
import 'package:yandex_dance/core/ui/widgets/snackbar/app_snackbar.dart';
import 'package:yandex_dance/features/auth/domain/repositories/auth_repository.dart';
import 'package:yandex_dance/features/events/domain/entities/dance_event.dart';
import 'package:yandex_dance/features/events/domain/repositories/event_repository.dart';
import 'package:yandex_dance/features/events/presentation/models/event_preview.dart';
import 'package:yandex_dance/features/events/presentation/pages/edit_event_screen.dart';
import 'package:yandex_dance/features/friends/presentation/pages/friend_detail_page.dart';
import 'package:yandex_dance/features/profile/domain/repositories/profile_repository.dart';
import 'package:yandex_dance/features/profile/presentation/managers/profile_manager.dart';

class EventDetailsPage extends StatefulWidget {
  const EventDetailsPage({super.key, required this.event});

  final EventPreview event;

  @override
  State<EventDetailsPage> createState() => _EventDetailsPageState();
}

class _EventDetailsPageState extends State<EventDetailsPage> {
  final _eventRepository = sl<EventRepository>();
  final _profileRepository = sl<ProfileRepository>();
  final _authRepository = sl<AuthRepository>();
  final _dateFormat = DateFormat('dd.MM.yyyy, HH:mm');

  late final Stream<List<DanceEvent>> _eventsStream;
  DanceEvent? _eventOverride;

  Future<List<_ParticipantViewData>>? _participantsFuture;
  String _participantsKey = '';

  bool _isMembershipActionInProgress = false;
  bool _isOwnerActionInProgress = false;

  @override
  void initState() {
    super.initState();
    _eventsStream = _eventRepository.watchAllEvents();
  }

  DanceEvent? _findEventById(List<DanceEvent> events) {
    for (final event in events) {
      if (event.id == widget.event.id) return event;
    }
    return null;
  }

  bool _matchesEventOverride(DanceEvent streamEvent, DanceEvent override) {
    return streamEvent.id == override.id &&
        streamEvent.title == override.title &&
        streamEvent.description == override.description &&
        streamEvent.coverUrl == override.coverUrl &&
        streamEvent.coverThumbUrl == override.coverThumbUrl &&
        streamEvent.coverStoragePath == override.coverStoragePath &&
        streamEvent.coverThumbStoragePath == override.coverThumbStoragePath &&
        streamEvent.danceStyle == override.danceStyle &&
        streamEvent.dateTime == override.dateTime &&
        streamEvent.address == override.address &&
        streamEvent.latitude == override.latitude &&
        streamEvent.longitude == override.longitude &&
        streamEvent.maxParticipants == override.maxParticipants &&
        streamEvent.ageRestriction == override.ageRestriction;
  }

  DanceEvent? _resolveVisibleEvent(List<DanceEvent> events) {
    final streamEvent = _findEventById(events);
    final override = _eventOverride;
    if (override == null) {
      return streamEvent;
    }

    if (streamEvent != null && _matchesEventOverride(streamEvent, override)) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        setState(() {
          _eventOverride = null;
        });
      });
      return streamEvent;
    }

    return override;
  }

  void _ensureParticipantsFuture(List<String> participantIds) {
    final key = participantIds.join('|');
    if (_participantsFuture != null && _participantsKey == key) {
      return;
    }
    _participantsKey = key;
    _participantsFuture = _loadParticipants(participantIds);
  }

  Future<List<_ParticipantViewData>> _loadParticipants(List<String> ids) async {
    final result = <_ParticipantViewData>[];
    for (final uid in ids) {
      try {
        final profile = await _profileRepository.getProfile(uid);
        final name = profile?.displayName?.trim();
        result.add(
          _ParticipantViewData(
            uid: uid,
            name:
                (name != null && name.isNotEmpty)
                    ? name
                    : 'Пользователь ${_shortUid(uid)}',
            avatarUrl: profile?.avatarThumbUrl ?? profile?.avatarUrl,
          ),
        );
      } catch (_) {
        result.add(
          _ParticipantViewData(
            uid: uid,
            name: 'Пользователь ${_shortUid(uid)}',
            avatarUrl: null,
          ),
        );
      }
    }
    return result;
  }

  String _shortUid(String uid) {
    if (uid.length <= 6) return uid;
    return uid.substring(0, 6);
  }

  ImageProvider<Object>? _eventCoverImage(DanceEvent event) {
    return cachedNetworkImageProviderOrNull(
      event.coverThumbUrl ?? event.coverUrl,
    );
  }

  Future<void> _handleMembershipAction(DanceEvent event) async {
    final uid = _authRepository.currentUserId;
    if (uid == null) {
      AppSnackBar.showError(context, 'Нужна авторизация');
      return;
    }

    if (_isMembershipActionInProgress) return;
    setState(() => _isMembershipActionInProgress = true);
    try {
      if (event.isParticipant(uid)) {
        await _eventRepository.leaveEvent(eventId: event.id, uid: uid);
        sl<ProfileManager>().removeUserEventFromList(event.id);
        if (mounted) {
          AppSnackBar.showSuccess(context, 'Вы отписались от мероприятия');
        }
      } else {
        if (event.isFull) {
          if (mounted) AppSnackBar.showInfo(context, 'Свободных мест нет');
          return;
        }
        await _eventRepository.joinEvent(eventId: event.id, uid: uid);
        if (mounted) {
          AppSnackBar.showSuccess(context, 'Вы записались на мероприятие');
        }
      }
    } catch (e) {
      if (mounted) {
        AppSnackBar.showError(context, 'Ошибка: $e');
      }
    } finally {
      if (mounted) {
        setState(() => _isMembershipActionInProgress = false);
      }
    }
  }

  Future<void> _deleteEvent(DanceEvent event) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder:
          (dialogContext) => AlertDialog(
            title: const Text('Удалить мероприятие?'),
            content: const Text(
              'Действие нельзя отменить. Мероприятие и связанные файлы будут удалены.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(false),
                child: const Text('Отмена'),
              ),
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(true),
                child: const Text('Удалить'),
              ),
            ],
          ),
    );

    if (confirm != true || _isOwnerActionInProgress) return;

    setState(() => _isOwnerActionInProgress = true);
    try {
      await _eventRepository.deleteEvent(event.id);
      if (!mounted) return;
      AppSnackBar.showSuccess(context, 'Мероприятие удалено');
      Navigator.of(context).pop();
    } catch (e) {
      if (mounted) AppSnackBar.showError(context, 'Ошибка удаления: $e');
    } finally {
      if (mounted) setState(() => _isOwnerActionInProgress = false);
    }
  }

  Future<void> _editEvent(DanceEvent event) async {
    final payload = await Navigator.of(context).push<EditEventResult>(
      MaterialPageRoute(builder: (_) => EditEventScreen(event: event)),
    );
    if (payload == null || _isOwnerActionInProgress) return;

    setState(() => _isOwnerActionInProgress = true);
    try {
      var updated = event.copyWith(
        title: payload.title,
        description: payload.description,
        danceStyle: payload.danceStyle,
        dateTime: payload.dateTime,
        address: payload.address,
        latitude: payload.latitude,
        longitude: payload.longitude,
        maxParticipants: payload.maxParticipants,
        ageRestriction: payload.ageRestriction,
      );
      await _eventRepository.updateEvent(updated);
      if (payload.coverSourcePath != null) {
        updated = await _eventRepository.uploadCover(
          eventId: event.id,
          currentEvent: updated,
          sourcePath: payload.coverSourcePath!,
        );
      }
      if (mounted) {
        setState(() {
          _eventOverride = updated;
        });
      }
      if (mounted) AppSnackBar.showSuccess(context, 'Мероприятие обновлено');
    } catch (e) {
      if (mounted) AppSnackBar.showError(context, 'Ошибка сохранения: $e');
    } finally {
      if (mounted) setState(() => _isOwnerActionInProgress = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<DanceEvent>>(
      stream: _eventsStream,
      builder: (context, snapshot) {
        final event = _resolveVisibleEvent(snapshot.data ?? const []);
        final currentUid = _authRepository.currentUserId;
        final isOwner =
            event != null && currentUid != null && event.isCreator(currentUid);
        final isParticipant =
            event != null &&
            currentUid != null &&
            event.isParticipant(currentUid);

        if (event != null) {
          _ensureParticipantsFuture(event.participantIds);
        }

        return Scaffold(
          backgroundColor: AppColors.gray500,
          appBar: AppBar(
            title: const Text('Мероприятие'),
            scrolledUnderElevation: 0,
            leadingWidth: 64,
            leading: Padding(
              padding: const EdgeInsets.only(left: 12),
              child: AppButton(
                iconWidget: const SvgIcon(
                  AppIcons.back,
                  size: 20,
                  color: AppColors.gray0,
                ),
                onTap: () => Navigator.of(context).pop(),
                style: const AppButtonStyle(
                  width: 40,
                  height: 40,
                  padding: EdgeInsets.zero,
                  backgroundColor: Colors.transparent,
                ),
              ),
            ),
            actions:
                isOwner
                    ? [
                      IconButton(
                        tooltip: 'Редактировать',
                        onPressed:
                            _isOwnerActionInProgress
                                ? null
                                : () => _editEvent(event),
                        icon: const SvgIcon(
                          AppIcons.edit,
                          size: 20,
                          color: AppColors.gray0,
                        ),
                      ),
                      IconButton(
                        tooltip: 'Удалить',
                        onPressed:
                            _isOwnerActionInProgress
                                ? null
                                : () => _deleteEvent(event),
                        icon: const SvgIcon(
                          AppIcons.trash,
                          size: 20,
                          color: AppColors.gray0,
                        ),
                      ),
                    ]
                    : null,
          ),
          body: SafeArea(
            child:
                snapshot.connectionState == ConnectionState.waiting &&
                        !snapshot.hasData
                    ? const _EventDetailsSkeleton()
                    : event == null
                    ? const Center(
                      child: Text('Мероприятие не найдено или удалено'),
                    )
                    : Column(
                      children: [
                        Expanded(
                          child: SingleChildScrollView(
                            padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _Cover(
                                  styleLabel: event.danceStyle.title,
                                  coverImage: _eventCoverImage(event),
                                ),
                                const SizedBox(height: 20),
                                Text(
                                  event.title,
                                  style: Theme.of(
                                    context,
                                  ).textTheme.headlineSmall?.copyWith(
                                    color: AppColors.gray0,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                _MetaLine(
                                  icon: AppIcons.calendar,
                                  text: _dateFormat.format(event.dateTime),
                                ),
                                const SizedBox(height: 10),
                                _MetaLine(
                                  icon: AppIcons.pin,
                                  text: event.address,
                                ),
                                const SizedBox(height: 10),
                                _MetaLine(
                                  icon: AppIcons.info,
                                  text:
                                      'Возраст: ${event.ageRestriction.trim().isEmpty ? 'Для всех' : event.ageRestriction}',
                                ),
                                const SizedBox(height: 10),
                                _MetaLine(
                                  icon: AppIcons.friends,
                                  text:
                                      '${event.currentParticipants}/${event.maxParticipants} участников',
                                ),
                                const SizedBox(height: 20),
                                Text(
                                  event.description,
                                  style: Theme.of(
                                    context,
                                  ).textTheme.bodyLarge?.copyWith(
                                    color: AppColors.gray100,
                                    height: 1.5,
                                  ),
                                ),
                                const SizedBox(height: 20),
                                Text(
                                  'Кто записан',
                                  style: Theme.of(
                                    context,
                                  ).textTheme.titleMedium?.copyWith(
                                    color: AppColors.gray0,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                FutureBuilder<List<_ParticipantViewData>>(
                                  future: _participantsFuture,
                                  builder: (context, participantsSnapshot) {
                                    if (participantsSnapshot.connectionState ==
                                            ConnectionState.waiting &&
                                        !participantsSnapshot.hasData) {
                                      return const _ParticipantsSkeleton();
                                    }

                                    final participants =
                                        participantsSnapshot.data ?? const [];
                                    if (participants.isEmpty) {
                                      return Text(
                                        'Пока никто не записан',
                                        style: Theme.of(
                                          context,
                                        ).textTheme.bodyMedium?.copyWith(
                                          color: AppColors.gray100,
                                        ),
                                      );
                                    }

                                    return ListView.separated(
                                      shrinkWrap: true,
                                      physics:
                                          const NeverScrollableScrollPhysics(),
                                      itemCount: participants.length,
                                      separatorBuilder:
                                          (_, __) => const SizedBox(height: 10),
                                      itemBuilder: (context, index) {
                                        final participant = participants[index];
                                        return _ParticipantRow(
                                          participant: participant,
                                          isOwner:
                                              participant.uid ==
                                              event.creatorId,
                                          onTap: () {
                                            Navigator.of(context).push<void>(
                                              MaterialPageRoute<void>(
                                                builder:
                                                    (_) => FriendDetailPage(
                                                      userId: participant.uid,
                                                    ),
                                              ),
                                            );
                                          },
                                        );
                                      },
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                          child: AppButton(
                            label:
                                isParticipant
                                    ? 'Отписаться'
                                    : event.isFull
                                    ? 'Мест нет'
                                    : isOwner
                                    ? 'Записаться как участник'
                                    : 'Записаться',
                            style:
                                isParticipant
                                    ? const AppButtonStyle(
                                      width: double.infinity,
                                      height: 52,
                                      backgroundColor: Colors.transparent,
                                      border: AppButtonBorder(
                                        borderRadius: 999,
                                        borderWidth: 1,
                                        borderColor: AppColors.gray100,
                                        borderStyle: ButtonBorderStyle.solid,
                                      ),
                                      textColor: AppColors.gray0,
                                    )
                                    : AppButtonStyle.gradientFilled.copyWith(
                                      width: double.infinity,
                                    ),
                            onTap:
                                (!isParticipant && event.isFull)
                                    ? null
                                    : () => _handleMembershipAction(event),
                            needLoading: _isMembershipActionInProgress,
                          ),
                        ),
                      ],
                    ),
          ),
        );
      },
    );
  }
}

class _Cover extends StatelessWidget {
  const _Cover({required this.styleLabel, this.coverImage});

  final String styleLabel;
  final ImageProvider<Object>? coverImage;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1.24,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
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
                      : Container(color: AppColors.gray400),
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
            Positioned(
              top: 12,
              right: 12,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(999),
                  gradient: AppColors.gradient,
                ),
                child: Text(
                  styleLabel,
                  style: const TextStyle(
                    color: AppColors.gray0,
                    fontWeight: FontWeight.w600,
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

class _MetaLine extends StatelessWidget {
  const _MetaLine({required this.icon, required this.text});

  final String icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SvgIcon(icon, size: 20, color: AppColors.gray100),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: Theme.of(
              context,
            ).textTheme.bodyLarge?.copyWith(color: AppColors.gray100),
          ),
        ),
      ],
    );
  }
}

class _ParticipantViewData {
  const _ParticipantViewData({
    required this.uid,
    required this.name,
    required this.avatarUrl,
  });

  final String uid;
  final String name;
  final String? avatarUrl;
}

class _ParticipantRow extends StatelessWidget {
  const _ParticipantRow({
    required this.participant,
    required this.isOwner,
    required this.onTap,
  });

  final _ParticipantViewData participant;
  final bool isOwner;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final avatarUrl = participant.avatarUrl?.trim();
    final hasAvatar = avatarUrl != null && avatarUrl.isNotEmpty;

    return CustomBounceEffect(
      onTap: onTap,
      child: Row(
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: AppColors.gray400,
            backgroundImage:
                hasAvatar ? cachedNetworkImageProviderOrNull(avatarUrl) : null,
            child:
                hasAvatar
                    ? null
                    : Text(
                      participant.name.isNotEmpty
                          ? participant.name.substring(0, 1).toUpperCase()
                          : '?',
                      style: const TextStyle(
                        color: AppColors.gray0,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              isOwner ? '${participant.name} (Организатор)' : participant.name,
              style: Theme.of(
                context,
              ).textTheme.bodyLarge?.copyWith(color: AppColors.gray0),
            ),
          ),
        ],
      ),
    );
  }
}

class _EventDetailsSkeleton extends StatelessWidget {
  const _EventDetailsSkeleton();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                _DetailSkeletonBox(height: 260, radius: 24),
                SizedBox(height: 20),
                _DetailSkeletonBox(height: 32, width: 240, radius: 12),
                SizedBox(height: 16),
                _DetailMetaSkeletonRow(),
                SizedBox(height: 10),
                _DetailMetaSkeletonRow(widthFactor: 0.74),
                SizedBox(height: 10),
                _DetailMetaSkeletonRow(widthFactor: 0.58),
                SizedBox(height: 10),
                _DetailMetaSkeletonRow(widthFactor: 0.52),
                SizedBox(height: 20),
                _DetailSkeletonBox(height: 18, width: 220, radius: 10),
                SizedBox(height: 10),
                _DetailSkeletonBox(height: 18, radius: 10),
                SizedBox(height: 8),
                _DetailSkeletonBox(height: 18, radius: 10),
                SizedBox(height: 8),
                _DetailSkeletonBox(height: 18, width: 180, radius: 10),
                SizedBox(height: 20),
                _DetailSkeletonBox(height: 24, width: 120, radius: 10),
                SizedBox(height: 10),
                _ParticipantsSkeleton(),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: const _DetailSkeletonBox(height: 52, radius: 999),
        ),
      ],
    );
  }
}

class _ParticipantsSkeleton extends StatelessWidget {
  const _ParticipantsSkeleton();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: const [
        _ParticipantSkeletonRow(),
        SizedBox(height: 10),
        _ParticipantSkeletonRow(),
        SizedBox(height: 10),
        _ParticipantSkeletonRow(),
      ],
    );
  }
}

class _ParticipantSkeletonRow extends StatelessWidget {
  const _ParticipantSkeletonRow();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: const [
        _DetailSkeletonCircle(size: 36),
        SizedBox(width: 10),
        Expanded(child: _DetailSkeletonBox(height: 18, radius: 10)),
      ],
    );
  }
}

class _DetailMetaSkeletonRow extends StatelessWidget {
  const _DetailMetaSkeletonRow({this.widthFactor = 0.82});

  final double widthFactor;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _DetailSkeletonBox(width: 20, height: 20, radius: 8),
        const SizedBox(width: 10),
        Expanded(
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: widthFactor,
            child: const _DetailSkeletonBox(height: 18, radius: 10),
          ),
        ),
      ],
    );
  }
}

class _DetailSkeletonCircle extends StatelessWidget {
  const _DetailSkeletonCircle({required this.size});

  final double size;

  @override
  Widget build(BuildContext context) {
    return _DetailSkeletonBox(width: size, height: size, radius: size / 2);
  }
}

class _DetailSkeletonBox extends StatelessWidget {
  const _DetailSkeletonBox({this.width, this.height = 16, this.radius = 12});

  final double? width;
  final double height;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(radius),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.gray400.withValues(alpha: 0.95),
            AppColors.gray300.withValues(alpha: 0.42),
          ],
        ),
      ),
    );
  }
}
