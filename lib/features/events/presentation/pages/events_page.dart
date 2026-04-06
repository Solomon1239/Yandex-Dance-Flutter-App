import 'dart:math' show Point;

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:maplibre_gl/maplibre_gl.dart';
import 'package:yandex_dance/app/di/service_locator.dart';
import 'package:yandex_dance/core/enums/dance_style.dart';
import 'package:yandex_dance/core/ui/colors/colors.dart';
import 'package:yandex_dance/core/ui/colors/input_color.dart';
import 'package:yandex_dance/core/ui/icons/app_icons.dart';
import 'package:yandex_dance/core/ui/icons/svg_icon.dart';
import 'package:yandex_dance/core/ui/widgets/buttons/app_button.dart';
import 'package:yandex_dance/core/ui/widgets/buttons/app_button_style.dart';
import 'package:yandex_dance/core/ui/widgets/filter-chip/app_filter_chip.dart';
import 'package:yandex_dance/core/ui/widgets/input/app_text_field.dart';
import 'package:yandex_dance/core/ui/widgets/switcher/switcher.dart';
import 'package:yandex_dance/features/auth/domain/repositories/auth_repository.dart';
import 'package:yandex_dance/features/events/domain/entities/dance_event.dart';
import 'package:yandex_dance/features/events/domain/repositories/event_repository.dart';
import 'package:yandex_dance/features/events/presentation/models/event_preview.dart';
import 'package:yandex_dance/features/events/presentation/pages/event_details_page.dart';
import 'package:yandex_dance/features/events/presentation/widgets/event_card.dart';

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
  static const _allSeatsFilterLabel = 'Все места';
  static const _availableSeatsFilterLabel = 'Есть места';

  late final TextEditingController _searchEventsController;
  late final Stream<List<DanceEvent>> _eventsStream;
  final _searchEventsFocusNode = FocusNode();
  final _dateFormat = DateFormat('dd.MM.yyyy, HH:mm');
  bool _touched = false;
  _EventsViewMode _viewMode = _EventsViewMode.list;
  final Set<String> _selectedGenres = {_allGenresLabel};
  String _selectedDateFilter = _anyDateFilterLabel;
  String _selectedSeatsFilter = _allSeatsFilterLabel;

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
            selectedGenres: _selectedGenres,
            selectedDateFilter: _selectedDateFilter,
            selectedSeatsFilter: _selectedSeatsFilter,
          ),
    );

    if (result == null) return;
    setState(() {
      _selectedGenres
        ..clear()
        ..addAll(result.selectedGenres);
      _selectedDateFilter = result.selectedDateFilter;
      _selectedSeatsFilter = result.selectedSeatsFilter;
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
          event.creatorId == currentUserId ? 'Вы' : 'Организатор';

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
        currentParticipants: event.currentParticipants,
        maxParticipants: event.maxParticipants,
        participantsLabel:
            '${event.currentParticipants}/${event.maxParticipants}',
        description: event.description,
        latitude: coordinates.$1,
        longitude: coordinates.$2,
        coverImage: _networkImageOrNull(event.coverThumbUrl ?? event.coverUrl),
      );
    }).toList();
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
      appBar: AppBar(
        title: const Text("Все мероприятия"),
        scrolledUnderElevation: 0,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: StreamBuilder<List<DanceEvent>>(
            stream: _eventsStream,
            builder: (context, snapshot) {
              final events = _mapEventsToPreview(snapshot.data ?? const []);
              final query = _searchEventsController.text.trim().toLowerCase();
              final genres = [
                _allGenresLabel,
                ...{for (final event in events) event.styleLabel},
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

                    if (_selectedSeatsFilter == _availableSeatsFilterLabel &&
                        !event.hasFreeSpots) {
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
                content = const Center(child: CircularProgressIndicator());
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

class _EventsListView extends StatelessWidget {
  const _EventsListView({
    super.key,
    required this.events,
    required this.onOpenEvent,
  });

  final List<EventPreview> events;
  final ValueChanged<EventPreview> onOpenEvent;

  @override
  Widget build(BuildContext context) {
    if (events.isEmpty) {
      return const Center(child: Text('Ничего не найдено'));
    }

    return ListView.separated(
      itemCount: events.length,
      separatorBuilder: (context, index) => const SizedBox(height: 20),
      itemBuilder: (context, index) {
        final event = events[index];

        return EventCard(
          title: event.title,
          styleLabel: event.styleLabel,
          ageRestrictionLabel: event.ageRestrictionLabel,
          dateLabel: event.dateLabel,
          locationLabel: event.locationLabel,
          authorLabel: event.authorLabel,
          participantsLabel: event.participantsLabel,
          authorAvatarImage: event.authorAvatarImage,
          coverImage: event.coverImage,
          onTap: () => onOpenEvent(event),
        );
      },
    );
  }
}

class _EventsMapView extends StatefulWidget {
  const _EventsMapView({
    super.key,
    required this.events,
    required this.onOpenEvent,
  });

  final List<EventPreview> events;
  final ValueChanged<EventPreview> onOpenEvent;

  @override
  State<_EventsMapView> createState() => _EventsMapViewState();
}

class _EventsMapViewState extends State<_EventsMapView> {
  static const _eventsSourceId = 'events-source';
  static const _clusterCircleLayerId = 'events-clusters';
  static const _clusterCountLayerId = 'events-cluster-count';
  static const _eventPointsLayerId = 'events-points';

  MapLibreMapController? _mapController;
  EventPreview? _selectedEvent;
  Offset? _selectedPlateOffset;
  Size _mapSize = Size.zero;
  var _isStyleLoaded = false;
  var _isSourceAndLayersReady = false;
  var _isSyncingSource = false;
  var _sourceSyncRequested = false;
  var _isPlateOffsetUpdating = false;
  var _plateOffsetUpdatePending = false;
  var _isProgrammaticZoomToEvent = false;

  @override
  void didUpdateWidget(covariant _EventsMapView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.events != widget.events) {
      _ensureSelectedEventIsVisible();
      _fitCameraToEvents();
      _upsertEventsSourceAndLayers();
      _schedulePlateOffsetUpdate();
    }
  }

  @override
  void dispose() {
    _mapController?.removeListener(_onCameraChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.events.isEmpty) {
      return const Center(child: Text('Ничего не найдено'));
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final nextSize = Size(constraints.maxWidth, constraints.maxHeight);
          if (_mapSize != nextSize) {
            _mapSize = nextSize;
            _schedulePlateOffsetUpdate();
          }

          return Stack(
            children: [
              MapLibreMap(
                styleString: _mapTilerStyleUrl,
                trackCameraPosition: true,
                gestureRecognizers: <Factory<OneSequenceGestureRecognizer>>{
                  Factory<OneSequenceGestureRecognizer>(
                    () => EagerGestureRecognizer(),
                  ),
                },
                zoomGesturesEnabled: true,
                scrollGesturesEnabled: true,
                rotateGesturesEnabled: true,
                tiltGesturesEnabled: true,
                initialCameraPosition: CameraPosition(
                  target: _centerOf(widget.events),
                  zoom: 12,
                ),
                onMapCreated: (controller) {
                  _mapController?.removeListener(_onCameraChanged);
                  _mapController = controller;
                  controller.addListener(_onCameraChanged);
                  _upsertEventsSourceAndLayers();
                },
                onStyleLoadedCallback: () {
                  _isStyleLoaded = true;
                  _isSourceAndLayersReady = false;
                  _fitCameraToEvents();
                  _upsertEventsSourceAndLayers();
                },
                onCameraIdle: _schedulePlateOffsetUpdate,
                onMapClick: (point, __) {
                  _handleMapTap(point);
                },
              ),
              if (_selectedEvent != null && _selectedPlateOffset != null)
                Positioned(
                  left: _selectedPlateOffset!.dx,
                  top: _selectedPlateOffset!.dy,
                  child: _EventPreviewPlate(
                    event: _selectedEvent!,
                    onTap: () => widget.onOpenEvent(_selectedEvent!),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  void _onCameraChanged() {
    if (!mounted || _selectedEvent == null) {
      return;
    }
    if (_isProgrammaticZoomToEvent && _selectedPlateOffset == null) {
      return;
    }
    _schedulePlateOffsetUpdate();
  }

  Future<void> _upsertEventsSourceAndLayers() async {
    if (_isSyncingSource) {
      _sourceSyncRequested = true;
      return;
    }

    _isSyncingSource = true;
    try {
      do {
        _sourceSyncRequested = false;
        await _upsertEventsSourceAndLayersInternal();
      } while (_sourceSyncRequested);
    } finally {
      _isSyncingSource = false;
    }
  }

  Future<void> _upsertEventsSourceAndLayersInternal() async {
    final controller = _mapController;
    if (controller == null || !_isStyleLoaded) return;

    final geoJson = _buildEventsGeoJson();

    if (!_isSourceAndLayersReady) {
      try {
        await controller.addSource(
          _eventsSourceId,
          GeojsonSourceProperties(
            data: geoJson,
            cluster: true,
            clusterRadius: 64,
            clusterMaxZoom: 14,
          ),
        );

        await controller.addLayer(
          _eventsSourceId,
          _clusterCircleLayerId,
          const CircleLayerProperties(
            circleRadius: [
              'step',
              ['get', 'point_count'],
              18,
              10,
              22,
              25,
              26,
              50,
              30,
            ],
            circleColor: '#EC499A',
            circleStrokeColor: '#FFFFFF',
            circleStrokeWidth: 2,
            circleOpacity: 0.95,
          ),
          filter: const ['has', 'point_count'],
          enableInteraction: false,
        );

        await controller.addLayer(
          _eventsSourceId,
          _clusterCountLayerId,
          const SymbolLayerProperties(
            textField: ['get', 'point_count_abbreviated'],
            textSize: 14,
            textColor: '#FFFFFF',
            textAllowOverlap: true,
            textIgnorePlacement: true,
          ),
          filter: const ['has', 'point_count'],
          enableInteraction: false,
        );

        await controller.addLayer(
          _eventsSourceId,
          _eventPointsLayerId,
          const CircleLayerProperties(
            circleRadius: [
              'case',
              [
                '==',
                ['get', 'selected'],
                true,
              ],
              11,
              8,
            ],
            circleColor: [
              'case',
              [
                '==',
                ['get', 'selected'],
                true,
              ],
              '#A855F7',
              '#EC499A',
            ],
            circleStrokeColor: '#FFFFFF',
            circleStrokeWidth: 2,
            circleOpacity: 0.95,
          ),
          filter: const [
            '!',
            ['has', 'point_count'],
          ],
          enableInteraction: false,
        );
        _isSourceAndLayersReady = true;
      } catch (_) {
        await controller.setGeoJsonSource(_eventsSourceId, geoJson);
        _isSourceAndLayersReady = true;
      }
      return;
    }

    await controller.setGeoJsonSource(_eventsSourceId, geoJson);
  }

  Future<void> _handleMapTap(Point<double> point) async {
    final controller = _mapController;
    if (controller == null || !_isStyleLoaded || !_isSourceAndLayersReady) {
      return;
    }

    List<dynamic> renderedFeatures;
    try {
      renderedFeatures = await controller.queryRenderedFeatures(point, const [
        _eventPointsLayerId,
        _clusterCircleLayerId,
        _clusterCountLayerId,
      ], null);
    } catch (_) {
      return;
    }

    for (final rawFeature in renderedFeatures) {
      final feature = _normalizeFeature(rawFeature);
      if (feature == null) continue;

      if (_isClusterFeature(feature)) {
        _clearSelectedEvent();
        await _zoomToCluster(feature);
        return;
      }

      final eventId = _extractEventId(feature);
      if (eventId == null) {
        continue;
      }

      final event = _findEventById(eventId);
      if (event == null) {
        continue;
      }

      await _focusEvent(event);
      return;
    }

    _clearSelectedEvent();
  }

  Future<void> _zoomToCluster(Map<String, dynamic> feature) async {
    final controller = _mapController;
    if (controller == null) return;

    final clusterCenter = _extractFeatureCoordinates(feature);
    if (clusterCenter == null) return;

    final properties = _extractFeatureProperties(feature);
    final pointCount = _asInt(properties['point_count']) ?? 0;
    final currentZoom = controller.cameraPosition?.zoom ?? 12.0;
    final zoomStep =
        pointCount >= 50
            ? 2.4
            : pointCount >= 20
            ? 2.0
            : 1.6;
    final targetZoom = (currentZoom + zoomStep).clamp(0.0, 18.8).toDouble();

    await controller.animateCamera(
      CameraUpdate.newLatLngZoom(clusterCenter, targetZoom),
      duration: const Duration(milliseconds: 420),
    );
  }

  Future<void> _focusEvent(EventPreview event) async {
    final controller = _mapController;
    if (controller == null) return;

    _isProgrammaticZoomToEvent = true;
    setState(() {
      _selectedEvent = event;
      _selectedPlateOffset = null;
    });

    await _upsertEventsSourceAndLayers();
    try {
      await controller.animateCamera(
        CameraUpdate.newLatLngZoom(
          LatLng(event.latitude, event.longitude),
          18.8,
        ),
        duration: const Duration(milliseconds: 550),
      );
    } finally {
      _isProgrammaticZoomToEvent = false;
    }
    _schedulePlateOffsetUpdate();
  }

  void _clearSelectedEvent() {
    if (_selectedEvent == null && _selectedPlateOffset == null) {
      return;
    }

    setState(() {
      _selectedEvent = null;
      _selectedPlateOffset = null;
    });
    _upsertEventsSourceAndLayers();
  }

  Map<String, dynamic>? _normalizeFeature(dynamic rawFeature) {
    if (rawFeature is! Map) {
      return null;
    }

    return rawFeature.map((key, value) => MapEntry(key.toString(), value));
  }

  Map<String, dynamic> _extractFeatureProperties(Map<String, dynamic> feature) {
    final properties = feature['properties'];
    if (properties is! Map) {
      return const {};
    }

    return properties.map((key, value) => MapEntry(key.toString(), value));
  }

  bool _isClusterFeature(Map<String, dynamic> feature) {
    final properties = _extractFeatureProperties(feature);
    final cluster = properties['cluster'];
    return cluster == true || properties.containsKey('point_count');
  }

  String? _extractEventId(Map<String, dynamic> feature) {
    final properties = _extractFeatureProperties(feature);
    final rawEventId = properties['event_id'];
    if (rawEventId == null) return null;
    return rawEventId.toString();
  }

  LatLng? _extractFeatureCoordinates(Map<String, dynamic> feature) {
    final geometry = feature['geometry'];
    if (geometry is! Map) return null;

    final coordinates = geometry['coordinates'];
    if (coordinates is! List || coordinates.length < 2) return null;

    final longitude = _asDouble(coordinates[0]);
    final latitude = _asDouble(coordinates[1]);
    if (longitude == null || latitude == null) {
      return null;
    }

    return LatLng(latitude, longitude);
  }

  EventPreview? _findEventById(String id) {
    for (final event in widget.events) {
      if (event.id == id) {
        return event;
      }
    }
    return null;
  }

  void _schedulePlateOffsetUpdate() {
    if (!mounted || _selectedEvent == null || _mapSize == Size.zero) {
      return;
    }
    if (_isProgrammaticZoomToEvent && _selectedPlateOffset == null) {
      return;
    }

    if (_isPlateOffsetUpdating) {
      _plateOffsetUpdatePending = true;
      return;
    }

    _isPlateOffsetUpdating = true;
    _updateSelectedPlateOffset().whenComplete(() {
      _isPlateOffsetUpdating = false;
      if (!mounted) return;

      if (_plateOffsetUpdatePending) {
        _plateOffsetUpdatePending = false;
        _schedulePlateOffsetUpdate();
      }
    });
  }

  Map<String, dynamic> _buildEventsGeoJson() {
    return {
      'type': 'FeatureCollection',
      'features': [
        for (final event in widget.events)
          {
            'type': 'Feature',
            'geometry': {
              'type': 'Point',
              'coordinates': [event.longitude, event.latitude],
            },
            'properties': {
              'event_id': event.id,
              'selected': _selectedEvent?.id == event.id,
            },
          },
      ],
    };
  }

  int? _asInt(dynamic value) {
    if (value is int) return value;
    if (value is double) return value.round();
    if (value is String) return int.tryParse(value);
    return null;
  }

  double? _asDouble(dynamic value) {
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }

  Future<void> _updateSelectedPlateOffset() async {
    final controller = _mapController;
    final selectedEvent = _selectedEvent;
    if (controller == null || selectedEvent == null || _mapSize == Size.zero) {
      return;
    }

    Point<dynamic> point;
    try {
      point = await controller.toScreenLocation(
        LatLng(selectedEvent.latitude, selectedEvent.longitude),
      );
    } catch (_) {
      return;
    }
    if (!mounted) return;

    final pointX = point.x.toDouble();
    final pointY = point.y.toDouble();
    final isPointVisible =
        pointX >= 0 &&
        pointX <= _mapSize.width &&
        pointY >= 0 &&
        pointY <= _mapSize.height;
    if (!isPointVisible) {
      if (_selectedPlateOffset != null) {
        setState(() {
          _selectedPlateOffset = null;
        });
      }
      return;
    }

    const plateWidth = 252.0;
    const plateHeight = 84.0;
    const margin = 8.0;

    final maxLeft = (_mapSize.width - plateWidth - margin);
    final maxTop = (_mapSize.height - plateHeight - margin);
    final clampedMaxLeft = maxLeft < margin ? margin : maxLeft;
    final clampedMaxTop = maxTop < margin ? margin : maxTop;

    final left = (pointX - plateWidth / 2).clamp(margin, clampedMaxLeft);
    final top = (pointY - plateHeight - 20).clamp(margin, clampedMaxTop);

    final nextOffset = Offset(left, top);
    final currentOffset = _selectedPlateOffset;
    if (currentOffset != null &&
        (currentOffset - nextOffset).distanceSquared < 0.25) {
      return;
    }

    setState(() {
      _selectedPlateOffset = nextOffset;
    });
  }

  Future<void> _fitCameraToEvents() async {
    final controller = _mapController;
    if (controller == null || !_isStyleLoaded || widget.events.isEmpty) {
      return;
    }

    if (widget.events.length == 1) {
      await controller.animateCamera(
        CameraUpdate.newLatLngZoom(
          LatLng(widget.events.first.latitude, widget.events.first.longitude),
          13,
        ),
      );
      return;
    }

    final bounds = _boundsOf(widget.events);
    await controller.animateCamera(
      CameraUpdate.newLatLngBounds(
        bounds,
        left: 40,
        top: 40,
        right: 40,
        bottom: 80,
      ),
    );
  }

  void _ensureSelectedEventIsVisible() {
    if (_selectedEvent == null) return;
    final exists = widget.events.any((e) => e.id == _selectedEvent!.id);
    if (!exists) {
      _selectedEvent = null;
      _selectedPlateOffset = null;
    }
  }

  LatLng _centerOf(List<EventPreview> source) {
    var latSum = 0.0;
    var lngSum = 0.0;
    for (final event in source) {
      latSum += event.latitude;
      lngSum += event.longitude;
    }
    return LatLng(latSum / source.length, lngSum / source.length);
  }

  LatLngBounds _boundsOf(List<EventPreview> source) {
    var minLat = source.first.latitude;
    var maxLat = source.first.latitude;
    var minLng = source.first.longitude;
    var maxLng = source.first.longitude;

    for (final event in source) {
      minLat = event.latitude < minLat ? event.latitude : minLat;
      maxLat = event.latitude > maxLat ? event.latitude : maxLat;
      minLng = event.longitude < minLng ? event.longitude : minLng;
      maxLng = event.longitude > maxLng ? event.longitude : maxLng;
    }

    return LatLngBounds(
      southwest: LatLng(minLat, minLng),
      northeast: LatLng(maxLat, maxLng),
    );
  }
}

class _EventsFiltersResult {
  const _EventsFiltersResult({
    required this.selectedGenres,
    required this.selectedDateFilter,
    required this.selectedSeatsFilter,
  });

  final Set<String> selectedGenres;
  final String selectedDateFilter;
  final String selectedSeatsFilter;
}

class _EventsFiltersSheet extends StatefulWidget {
  const _EventsFiltersSheet({
    required this.genres,
    required this.selectedGenres,
    required this.selectedDateFilter,
    required this.selectedSeatsFilter,
  });

  final List<String> genres;
  final Set<String> selectedGenres;
  final String selectedDateFilter;
  final String selectedSeatsFilter;

  @override
  State<_EventsFiltersSheet> createState() => _EventsFiltersSheetState();
}

class _EventsFiltersSheetState extends State<_EventsFiltersSheet> {
  static const _allGenresLabel = 'Все';
  static const _anyDateLabel = 'Любая дата';
  static const _allSeatsLabel = 'Все места';
  static const _availableSeatsLabel = 'Есть места';

  late Set<String> _selectedGenres;
  late String _selectedDateFilter;
  late String _selectedSeatsFilter;

  @override
  void initState() {
    super.initState();
    _selectedGenres = Set<String>.from(widget.selectedGenres);
    _selectedDateFilter = widget.selectedDateFilter;
    _selectedSeatsFilter = widget.selectedSeatsFilter;
  }

  void _toggleGenre(String genre) {
    setState(() {
      if (genre == _allGenresLabel) {
        _selectedGenres
          ..clear()
          ..add(_allGenresLabel);
        return;
      }

      _selectedGenres.remove(_allGenresLabel);
      if (_selectedGenres.contains(genre)) {
        _selectedGenres.remove(genre);
      } else {
        _selectedGenres.add(genre);
      }

      if (_selectedGenres.isEmpty) {
        _selectedGenres.add(_allGenresLabel);
      }
    });
  }

  void _reset() {
    setState(() {
      _selectedGenres = {_allGenresLabel};
      _selectedDateFilter = _anyDateLabel;
      _selectedSeatsFilter = _allSeatsLabel;
    });
  }

  @override
  Widget build(BuildContext context) {
    final insetBottom = MediaQuery.of(context).viewInsets.bottom;
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(16, 8, 16, 16 + insetBottom),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Стили', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              AppFilterChipGroup(
                scrollable: true,
                items: [
                  for (final genre in widget.genres)
                    ChipItem(label: genre, onTap: () => _toggleGenre(genre)),
                ],
                selectedLabels: _selectedGenres,
              ),
              const SizedBox(height: 14),
              Text('Даты', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              AppFilterChipGroup(
                scrollable: true,
                items: [
                  ChipItem(
                    label: _anyDateLabel,
                    onTap:
                        () =>
                            setState(() => _selectedDateFilter = _anyDateLabel),
                  ),
                  ChipItem(
                    label: 'Сегодня',
                    onTap:
                        () => setState(() => _selectedDateFilter = 'Сегодня'),
                  ),
                  ChipItem(
                    label: 'Завтра',
                    onTap: () => setState(() => _selectedDateFilter = 'Завтра'),
                  ),
                  ChipItem(
                    label: 'Эта неделя',
                    onTap:
                        () =>
                            setState(() => _selectedDateFilter = 'Эта неделя'),
                  ),
                  ChipItem(
                    label: 'Выходные',
                    onTap:
                        () => setState(() => _selectedDateFilter = 'Выходные'),
                  ),
                ],
                selectedLabels: {_selectedDateFilter},
              ),
              const SizedBox(height: 14),
              Text('Места', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              AppFilterChipGroup(
                scrollable: true,
                items: [
                  ChipItem(
                    label: _allSeatsLabel,
                    onTap:
                        () => setState(
                          () => _selectedSeatsFilter = _allSeatsLabel,
                        ),
                  ),
                  ChipItem(
                    label: _availableSeatsLabel,
                    onTap:
                        () => setState(
                          () => _selectedSeatsFilter = _availableSeatsLabel,
                        ),
                  ),
                ],
                selectedLabels: {_selectedSeatsFilter},
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  Expanded(
                    child: AppButton(
                      label: 'Сбросить',
                      onTap: _reset,
                      style: const AppButtonStyle(
                        height: 44,
                        backgroundColor: Colors.transparent,
                        border: AppButtonBorder(
                          borderRadius: 999,
                          borderWidth: 1,
                          borderColor: AppColors.gray100,
                          borderStyle: ButtonBorderStyle.solid,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: AppButton(
                      label: 'Применить',
                      onTap: () {
                        Navigator.of(context).pop(
                          _EventsFiltersResult(
                            selectedGenres: _selectedGenres,
                            selectedDateFilter: _selectedDateFilter,
                            selectedSeatsFilter: _selectedSeatsFilter,
                          ),
                        );
                      },
                      style: AppButtonStyle.gradientFilled.copyWith(height: 44),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EventPreviewPlate extends StatelessWidget {
  const _EventPreviewPlate({required this.event, required this.onTap});

  final EventPreview event;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        width: 252,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.gray400.withValues(alpha: 0.96),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.gray100.withValues(alpha: 0.32)),
          boxShadow: const [
            BoxShadow(
              color: Color.fromARGB(110, 0, 0, 0),
              blurRadius: 14,
              offset: Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 8,
              height: 48,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(999),
                gradient: AppColors.gradient,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    event.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppColors.gray0,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${event.dateLabel} • ${event.styleLabel}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppColors.gray100,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    event.locationLabel,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppColors.gray100,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 6),
            Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                color: AppColors.gray0.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: Icon(
                  Icons.chevron_right,
                  size: 16,
                  color: AppColors.gray0,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
