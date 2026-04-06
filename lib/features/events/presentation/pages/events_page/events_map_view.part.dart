part of '../events_page.dart';

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
                  target:
                      widget.events.isEmpty
                          ? const LatLng(
                            _fallbackMapCenterLat,
                            _fallbackMapCenterLng,
                          )
                          : _centerOf(widget.events),
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
              if (widget.events.isEmpty)
                Positioned(
                  left: 12,
                  right: 12,
                  top: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.gray500.withValues(alpha: 0.88),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppColors.gray100.withValues(alpha: 0.25),
                      ),
                    ),
                    child: const Text(
                      'Ничего не найдено. Попробуй изменить фильтры.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: AppColors.gray100,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
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
