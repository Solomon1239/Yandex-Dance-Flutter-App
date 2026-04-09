import 'dart:math' show Point;

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:maplibre_gl/maplibre_gl.dart';
import 'package:yandex_dance/app/di/service_locator.dart';
import 'package:yandex_dance/core/enums/dance_style.dart';
import 'package:yandex_dance/core/ui/colors/colors.dart';
import 'package:yandex_dance/core/ui/media/cached_remote_image.dart';
import 'package:yandex_dance/core/ui/colors/input_color.dart';
import 'package:yandex_dance/core/ui/icons/app_icons.dart';
import 'package:yandex_dance/core/ui/icons/svg_icon.dart';
import 'package:yandex_dance/core/ui/widgets/buttons/app_button.dart';
import 'package:yandex_dance/core/ui/widgets/buttons/app_button_style.dart';
import 'package:yandex_dance/core/ui/widgets/custom_bounce_effect.dart';
import 'package:yandex_dance/core/ui/widgets/filter-chip/app_filter_chip.dart';
import 'package:yandex_dance/core/ui/widgets/input/app_text_field.dart';
import 'package:yandex_dance/core/ui/widgets/switcher/switcher.dart';
import 'package:yandex_dance/features/auth/domain/repositories/auth_repository.dart';
import 'package:yandex_dance/features/events/domain/entities/dance_event.dart';
import 'package:yandex_dance/features/events/domain/repositories/event_repository.dart';
import 'package:yandex_dance/features/events/presentation/models/event_preview.dart';
import 'package:yandex_dance/features/events/presentation/pages/event_details_page.dart';
import 'package:yandex_dance/features/events/presentation/widgets/event_card.dart';
import 'package:yandex_dance/features/profile/domain/repositories/profile_repository.dart';

part 'events_page/events_filters_sheet.part.dart';
part 'events_page/events_list_view.part.dart';
part 'events_page/events_map_view.part.dart';

const _mapTilerMapId = '019c6663-251e-77cb-bf94-f51774aac012';
const _mapTilerApiKey = '1PpKJSBFPkUbgzPpRV1r';
const _mapTilerStyleUrl =
    'https://api.maptiler.com/maps/$_mapTilerMapId/style.json?key=$_mapTilerApiKey';
const _fallbackMapCenterLat = 55.751244;
const _fallbackMapCenterLng = 37.618423;

class EventsPage extends StatefulWidget {
  const EventsPage({super.key});

  @override
  State<EventsPage> createState() => _EventsPageState();
}

class _EventsPageState extends State<EventsPage> {
  static const _allGenresLabel = 'Все';
  static const _anyDateFilterLabel = 'Любая дата';
  static const _anyAgeFilterLabel = 'Любой возраст';

  /// Как при создании события, без «Для всех» — его нельзя выбрать отдельно в фильтре.
  static const List<String> _ageFilterOptions = [
    _anyAgeFilterLabel,
    '6+',
    '12+',
    '16+',
    '18+',
  ];

  late final TextEditingController _searchEventsController;
  late final Stream<List<DanceEvent>> _eventsStream;
  final ProfileRepository _profileRepository = sl<ProfileRepository>();
  final _searchEventsFocusNode = FocusNode();
  final _dateFormat = DateFormat('dd.MM.yyyy, HH:mm');
  bool _touched = false;
  _EventsViewMode _viewMode = _EventsViewMode.list;
  final Set<String> _selectedGenres = {_allGenresLabel};
  String _selectedDateFilter = _anyDateFilterLabel;
  String _selectedAgeFilter = _anyAgeFilterLabel;
  final Map<String, String> _creatorNames = {};
  final Map<String, String?> _creatorAvatarUrls = {};
  final Set<String> _creatorNamesLoading = {};

  Future<void> _openEventDetails(EventPreview event) {
    return Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => EventDetailsPage(event: event)));
  }

  Future<void> _openFiltersModal(List<String> genres) async {
    final result = await showModalBottomSheet<_EventsFiltersResult>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder:
          (context) => _EventsFiltersSheet(
            genres: genres,
            ageOptions: _ageFilterOptions,
            selectedGenres: _selectedGenres,
            selectedDateFilter: _selectedDateFilter,
            selectedAgeFilter: _selectedAgeFilter,
          ),
    );

    if (result == null) return;
    setState(() {
      _selectedGenres
        ..clear()
        ..addAll(result.selectedGenres);
      _selectedDateFilter = result.selectedDateFilter;
      _selectedAgeFilter = result.selectedAgeFilter;
    });
  }

  @override
  void initState() {
    super.initState();
    _searchEventsController = TextEditingController();
    _eventsStream = sl<EventRepository>().watchAllEvents();
  }

  @override
  void dispose() {
    _searchEventsController.dispose();
    _searchEventsFocusNode.dispose();
    super.dispose();
  }

  List<EventPreview> _mapEventsToPreview(List<DanceEvent> events) {
    final currentUserId = sl<AuthRepository>().currentUserId;

    return events.map((event) {
      final coordinates = _coordinatesForEvent(event);
      final authorLabel =
          _creatorNames[event.creatorId] ??
          (event.creatorId == currentUserId ? 'Вы' : 'Организатор');

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
        authorLabel: authorLabel,
        authorAvatarImage: cachedNetworkImageProviderOrNull(
          _creatorAvatarUrls[event.creatorId],
        ),
        currentParticipants: event.currentParticipants,
        maxParticipants: event.maxParticipants,
        participantsLabel:
            '${event.currentParticipants}/${event.maxParticipants}',
        description: event.description,
        latitude: coordinates.$1,
        longitude: coordinates.$2,
        coverImage: cachedNetworkImageProviderOrNull(
          event.coverThumbUrl ?? event.coverUrl,
        ),
      );
    }).toList();
  }

  void _ensureCreatorNames(List<DanceEvent> events) {
    final uniqueCreatorIds = {for (final event in events) event.creatorId};
    for (final creatorId in uniqueCreatorIds) {
      if (_creatorNames.containsKey(creatorId) ||
          _creatorNamesLoading.contains(creatorId)) {
        continue;
      }

      _creatorNamesLoading.add(creatorId);
      _profileRepository
          .getProfile(creatorId)
          .then((profile) {
            final name = profile?.displayName?.trim();
            final resolvedName =
                (name != null && name.isNotEmpty) ? name : 'Организатор';
            final avatarUrl =
                profile?.avatarThumbUrl?.trim().isNotEmpty == true
                    ? profile!.avatarThumbUrl!.trim()
                    : profile?.avatarUrl?.trim();
            if (!mounted) return;
            setState(() {
              _creatorNames[creatorId] = resolvedName;
              _creatorAvatarUrls[creatorId] = avatarUrl;
            });
          })
          .catchError((_) {
            if (!mounted) return;
            setState(() {
              _creatorNames[creatorId] = 'Организатор';
              _creatorAvatarUrls[creatorId] = null;
            });
          })
          .whenComplete(() {
            _creatorNamesLoading.remove(creatorId);
          });
    }
  }

  (double, double) _coordinatesForEvent(DanceEvent event) {
    if (event.latitude != null && event.longitude != null) {
      return (event.latitude!, event.longitude!);
    }

    final seed = event.id.codeUnits.fold<int>(
      0,
      (acc, code) => acc * 31 + code,
    );
    final positiveSeed = seed.abs();
    final latOffset = ((positiveSeed % 2001) - 1000) / 100000.0;
    final lngOffset = (((positiveSeed ~/ 2001) % 2001) - 1000) / 100000.0;
    return (
      _fallbackMapCenterLat + latOffset,
      _fallbackMapCenterLng + lngOffset,
    );
  }

  bool _matchesAgeFilter(EventPreview event) {
    if (_selectedAgeFilter == _anyAgeFilterLabel) {
      return true;
    }
    return event.ageRestrictionLabel == _selectedAgeFilter;
  }

  bool _matchesDateFilter(DateTime eventDate, DateTime now) {
    final eventDay = DateTime(eventDate.year, eventDate.month, eventDate.day);
    final today = DateTime(now.year, now.month, now.day);

    switch (_selectedDateFilter) {
      case 'Сегодня':
        return eventDay == today;
      case 'Завтра':
        return eventDay == today.add(const Duration(days: 1));
      case 'Эта неделя':
        final endOfWeek = today.add(Duration(days: 8 - today.weekday));
        return !eventDay.isBefore(today) && eventDay.isBefore(endOfWeek);
      case 'Выходные':
        return eventDate.weekday == DateTime.saturday ||
            eventDate.weekday == DateTime.sunday;
      default:
        return true;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.gray500,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: StreamBuilder<List<DanceEvent>>(
            stream: _eventsStream,
            builder: (context, snapshot) {
              final rawEvents = snapshot.data ?? const <DanceEvent>[];
              _ensureCreatorNames(rawEvents);
              final events = _mapEventsToPreview(rawEvents);
              final query = _searchEventsController.text.trim().toLowerCase();
              final genres = [
                _allGenresLabel,
                ...DanceStyle.values.map((s) => s.title),
              ];
              final filteredEvents =
                  events.where((event) {
                    final hasSpecificGenreFilter =
                        _selectedGenres.isNotEmpty &&
                        !_selectedGenres.contains(_allGenresLabel);

                    if (hasSpecificGenreFilter &&
                        !_selectedGenres.contains(event.styleLabel)) {
                      return false;
                    }

                    if (!_matchesDateFilter(event.dateTime, DateTime.now())) {
                      return false;
                    }

                    if (!_matchesAgeFilter(event)) {
                      return false;
                    }

                    if (query.isEmpty) {
                      return true;
                    }

                    return event.title.toLowerCase().contains(query) ||
                        event.styleLabel.toLowerCase().contains(query) ||
                        event.locationLabel.toLowerCase().contains(query);
                  }).toList();

              Widget content;
              Key contentKey;
              if (snapshot.connectionState == ConnectionState.waiting &&
                  !snapshot.hasData) {
                content = _EventsPageSkeleton(viewMode: _viewMode);
                contentKey = const ValueKey('events-loading');
              } else if (snapshot.hasError) {
                content = const Center(
                  child: Text('Не удалось загрузить мероприятия'),
                );
                contentKey = const ValueKey('events-error');
              } else {
                content =
                    _viewMode == _EventsViewMode.list
                        ? _EventsListView(
                          key: const ValueKey('events-list'),
                          events: filteredEvents,
                          onOpenEvent: _openEventDetails,
                        )
                        : _EventsMapView(
                          key: const ValueKey('events-map'),
                          events: filteredEvents,
                          onOpenEvent: _openEventDetails,
                        );
                contentKey = ValueKey(
                  _viewMode == _EventsViewMode.list
                      ? 'events-list'
                      : 'events-map',
                );
              }

              return Column(
                children: [
                  AppTextField(
                    hint: 'Найти',
                    state: InputState.initial,
                    prefixIcon: AppIcons.search,
                    contoller: _searchEventsController,
                    touched: _touched,
                    focusNode: _searchEventsFocusNode,
                    onChanged: (_) => setState(() => _touched = true),
                    onFocusChange: () => setState(() => _touched = true),
                    onUnfocus: () => setState(() => _touched = true),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      AppSegmentedControl(
                        height: 44,
                        expandItems: false,
                        itemWidth: 44,
                        initialIndex: _viewMode == _EventsViewMode.list ? 0 : 1,
                        items: const [
                          SvgIcon(AppIcons.list, size: 20),
                          SvgIcon(AppIcons.map, size: 20),
                        ],
                        onChanged: (index) {
                          setState(() {
                            _viewMode =
                                index == 0
                                    ? _EventsViewMode.list
                                    : _EventsViewMode.map;
                          });
                        },
                        horizontalPadding: 0,
                        itemPadding: EdgeInsets.zero,
                      ),
                      const SizedBox(width: 12),
                      AppButton(
                        iconWidget: const SvgIcon(AppIcons.funnel, size: 20),
                        label: 'Фильтры',
                        onTap: () => _openFiltersModal(genres),
                        style: const AppButtonStyle(
                          height: 44,
                          backgroundColor: Colors.transparent,
                          padding: EdgeInsets.symmetric(
                            horizontal: 18,
                            vertical: 12,
                          ),
                          border: AppButtonBorder(
                            borderRadius: 999,
                            borderWidth: 1,
                            borderColor: AppColors.gray100,
                            borderStyle: ButtonBorderStyle.solid,
                          ),
                          textColor: AppColors.gray0,
                          textStyle: TextStyle(
                            color: AppColors.gray0,
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                            height: 1,
                          ),
                          gap: 10,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Divider(color: AppColors.gray100.withValues(alpha: 0.2)),
                  const SizedBox(height: 10),
                  Expanded(
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 220),
                      child: KeyedSubtree(key: contentKey, child: content),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

enum _EventsViewMode { list, map }

class _EventsPageSkeleton extends StatelessWidget {
  const _EventsPageSkeleton({required this.viewMode});

  final _EventsViewMode viewMode;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const _SkeletonBox(height: 56, radius: 20),
        const SizedBox(height: 14),
        Row(
          children: const [
            _SkeletonBox(width: 100, height: 44, radius: 999),
            SizedBox(width: 12),
            Expanded(child: _SkeletonBox(height: 44, radius: 999)),
          ],
        ),
        const SizedBox(height: 10),
        Divider(color: AppColors.gray100.withValues(alpha: 0.2)),
        const SizedBox(height: 10),
        Expanded(
          child:
              viewMode == _EventsViewMode.list
                  ? ListView.separated(
                    itemCount: 3,
                    separatorBuilder: (_, __) => const SizedBox(height: 16),
                    itemBuilder: (_, __) => const EventCard(compact: true),
                  )
                  : const _EventsMapSkeleton(),
        ),
      ],
    );
  }
}

class _EventsMapSkeleton extends StatelessWidget {
  const _EventsMapSkeleton();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: AppColors.gray400,
      ),
      child: Stack(
        children: const [
          Positioned.fill(child: _SkeletonBox(radius: 20)),
          Positioned(
            left: 12,
            right: 12,
            top: 12,
            child: _SkeletonBox(height: 44, radius: 12),
          ),
          Positioned(right: 12, bottom: 12, child: _SkeletonCircle(size: 42)),
        ],
      ),
    );
  }
}

class _SkeletonCircle extends StatelessWidget {
  const _SkeletonCircle({required this.size});

  final double size;

  @override
  Widget build(BuildContext context) {
    return _SkeletonBox(width: size, height: size, radius: size / 2);
  }
}

class _SkeletonBox extends StatelessWidget {
  const _SkeletonBox({this.width, this.height = 16, this.radius = 12});

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
