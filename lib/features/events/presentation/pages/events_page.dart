import 'package:flutter/material.dart';
import 'package:maplibre_gl/maplibre_gl.dart';
import 'package:yandex_dance/core/ui/colors/colors.dart';
import 'package:yandex_dance/core/ui/colors/input_color.dart';
import 'package:yandex_dance/core/ui/icons/app_icons.dart';
import 'package:yandex_dance/core/ui/icons/svg_icon.dart';
import 'package:yandex_dance/core/ui/widgets/buttons/app_button.dart';
import 'package:yandex_dance/core/ui/widgets/buttons/app_button_style.dart';
import 'package:yandex_dance/core/ui/widgets/filter-chip/app_filter_chip.dart';
import 'package:yandex_dance/core/ui/widgets/input/app_text_field.dart';
import 'package:yandex_dance/core/ui/widgets/switcher/switcher.dart';
import 'package:yandex_dance/features/events/presentation/widgets/event_card.dart';

const _mapTilerMapId = '019c6663-251e-77cb-bf94-f51774aac012';
const _mapTilerApiKey = '1PpKJSBFPkUbgzPpRV1r';
const _mapTilerStyleUrl =
    'https://api.maptiler.com/maps/$_mapTilerMapId/style.json?key=$_mapTilerApiKey';

final _mockEvents = [
  _MockEvent(
    title: 'Hip-Hop Foundations',
    styleLabel: 'Hip-Hop',
    dateLabel: '5 апреля, 19:00',
    locationLabel: 'Dance Space, Москва',
    authorLabel: 'Вы',
    participantsLabel: '5/20',
    latitude: 55.7512,
    longitude: 37.6184,
    authorAvatarImage: NetworkImage(
      'https://images.unsplash.com/photo-1494790108377-be9c29b29330?auto=format&fit=crop&w=300&q=80',
    ),
    coverImage: NetworkImage(
      'https://images.unsplash.com/photo-1516280440614-37939bbacd81?auto=format&fit=crop&w=1200&q=80',
    ),
  ),
  _MockEvent(
    title: 'House Flow Session',
    styleLabel: 'House',
    dateLabel: '7 апреля, 20:30',
    locationLabel: 'Studio 21, Москва',
    authorLabel: 'Mila',
    participantsLabel: '11/18',
    latitude: 55.7605,
    longitude: 37.6188,
    authorAvatarImage: NetworkImage(
      'https://images.unsplash.com/photo-1438761681033-6461ffad8d80?auto=format&fit=crop&w=300&q=80',
    ),
    coverImage: NetworkImage(
      'https://images.unsplash.com/photo-1508700115892-45ecd05ae2ad?auto=format&fit=crop&w=1200&q=80',
    ),
  ),
  _MockEvent(
    title: 'Jazz Funk Choreo',
    styleLabel: 'Jazz Funk',
    dateLabel: '9 апреля, 18:00',
    locationLabel: 'Vibe Room, Москва',
    authorLabel: 'Alex',
    participantsLabel: '8/16',
    latitude: 55.7417,
    longitude: 37.6208,
    authorAvatarImage: NetworkImage(
      'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?auto=format&fit=crop&w=300&q=80',
    ),
    coverImage: NetworkImage(
      'https://images.unsplash.com/photo-1504609813442-a8924e83f76e?auto=format&fit=crop&w=1200&q=80',
    ),
  ),
  _MockEvent(
    title: 'Breaking Basics Jam',
    styleLabel: 'Breaking',
    dateLabel: '12 апреля, 17:30',
    locationLabel: 'Cypher Hall, Москва',
    authorLabel: 'Niko',
    participantsLabel: '5/20',
    latitude: 55.774,
    longitude: 37.6068,
  ),
];

class EventsPage extends StatefulWidget {
  const EventsPage({super.key});

  @override
  State<EventsPage> createState() => _EventsPageState();
}

class _EventsPageState extends State<EventsPage> {
  late final TextEditingController _searchEventsController;
  final _searchEventsFocusNode = FocusNode();
  bool _touched = false;
  _EventsViewMode _viewMode = _EventsViewMode.list;
  final Set<String> _selectedGenres = {'Все'};

  void _toggleGenre(String genre) {
    setState(() {
      if (genre == 'Все') {
        _selectedGenres
          ..clear()
          ..add('Все');
        return;
      }

      _selectedGenres.remove('Все');

      if (_selectedGenres.contains(genre)) {
        _selectedGenres.remove(genre);
      } else {
        _selectedGenres.add(genre);
      }

      if (_selectedGenres.isEmpty) {
        _selectedGenres.add('Все');
      }
    });
  }

  Future<void> _openFiltersModal() {
    return showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder:
          (context) => const SizedBox(
            height: 280,
            child: Center(child: Text('Фильтры скоро появятся')),
          ),
    );
  }

  @override
  void initState() {
    super.initState();
    _searchEventsController = TextEditingController();
  }

  @override
  void dispose() {
    _searchEventsController.dispose();
    _searchEventsFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final query = _searchEventsController.text.trim().toLowerCase();
    final genres = [
      'Все',
      ...{for (final event in _mockEvents) event.styleLabel},
    ];
    final filteredEvents =
        _mockEvents.where((event) {
          final hasSpecificGenreFilter =
              _selectedGenres.isNotEmpty && !_selectedGenres.contains('Все');

          if (hasSpecificGenreFilter &&
              !_selectedGenres.contains(event.styleLabel)) {
            return false;
          }

          if (query.isEmpty) {
            return true;
          }

          return event.title.toLowerCase().contains(query) ||
              event.styleLabel.toLowerCase().contains(query) ||
              event.locationLabel.toLowerCase().contains(query);
        }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Все мероприятия"),
        scrolledUnderElevation: 0,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
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
              const SizedBox(height: 16),
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
                    label: 'Фильтры',
                    iconWidget: const SvgIcon(AppIcons.filter, size: 20),
                    onTap: _openFiltersModal,
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
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        height: 1,
                      ),
                      gap: 10,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 44,
                child: AppFilterChipGroup(
                  scrollable: true,

                  spacing: 6,
                  items: [
                    for (final genre in genres)
                      ChipItem(label: genre, onTap: () => _toggleGenre(genre)),
                  ],
                  selectedLabels: _selectedGenres,
                ),
              ),
              const SizedBox(height: 24),
              Expanded(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 220),
                  child:
                      _viewMode == _EventsViewMode.list
                          ? _EventsListView(
                            key: const ValueKey('events-list'),
                            events: filteredEvents,
                          )
                          : _EventsMapView(
                            key: const ValueKey('events-map'),
                            events: filteredEvents,
                          ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

enum _EventsViewMode { list, map }

class _MockEvent {
  const _MockEvent({
    required this.title,
    required this.styleLabel,
    required this.dateLabel,
    required this.locationLabel,
    required this.authorLabel,
    required this.participantsLabel,
    required this.latitude,
    required this.longitude,
    this.authorAvatarImage,
    this.coverImage,
  });

  final String title;
  final String styleLabel;
  final String dateLabel;
  final String locationLabel;
  final String authorLabel;
  final String participantsLabel;
  final double latitude;
  final double longitude;
  final ImageProvider<Object>? authorAvatarImage;
  final ImageProvider<Object>? coverImage;
}

class _EventsListView extends StatelessWidget {
  const _EventsListView({super.key, required this.events});

  final List<_MockEvent> events;

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
          dateLabel: event.dateLabel,
          locationLabel: event.locationLabel,
          authorLabel: event.authorLabel,
          participantsLabel: event.participantsLabel,
          authorAvatarImage: event.authorAvatarImage,
          coverImage: event.coverImage,
        );
      },
    );
  }
}

class _EventsMapView extends StatefulWidget {
  const _EventsMapView({super.key, required this.events});

  final List<_MockEvent> events;

  @override
  State<_EventsMapView> createState() => _EventsMapViewState();
}

class _EventsMapViewState extends State<_EventsMapView> {
  MapLibreMapController? _mapController;
  var _isStyleLoaded = false;

  @override
  void didUpdateWidget(covariant _EventsMapView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.events != widget.events) {
      _syncMarkersAndCamera();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.events.isEmpty) {
      return const Center(child: Text('Ничего не найдено'));
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: Stack(
        children: [
          MapLibreMap(
            styleString: _mapTilerStyleUrl,
            initialCameraPosition: CameraPosition(
              target: _centerOf(widget.events),
              zoom: 12,
            ),
            onMapCreated: (controller) {
              _mapController = controller;
              _syncMarkersAndCamera();
            },
            onStyleLoadedCallback: () {
              _isStyleLoaded = true;
              _syncMarkersAndCamera();
            },
          ),
          Positioned(
            left: 12,
            right: 12,
            bottom: 12,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.gray500.withValues(alpha: 0.9),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '${widget.events.length} мероприятий на карте',
                style: const TextStyle(
                  color: AppColors.gray0,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _syncMarkersAndCamera() async {
    final controller = _mapController;
    if (controller == null || !_isStyleLoaded) return;

    await controller.clearCircles();
    for (final event in widget.events) {
      await controller.addCircle(
        CircleOptions(
          geometry: LatLng(event.latitude, event.longitude),
          circleRadius: 8,
          circleColor: '#EC499A',
          circleStrokeColor: '#FFFFFF',
          circleStrokeWidth: 2,
          circleOpacity: 0.95,
        ),
      );
    }

    if (widget.events.isEmpty) return;

    if (widget.events.length == 1) {
      final event = widget.events.first;
      await controller.animateCamera(
        CameraUpdate.newLatLngZoom(LatLng(event.latitude, event.longitude), 13),
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

  LatLng _centerOf(List<_MockEvent> source) {
    var latSum = 0.0;
    var lngSum = 0.0;
    for (final event in source) {
      latSum += event.latitude;
      lngSum += event.longitude;
    }
    return LatLng(latSum / source.length, lngSum / source.length);
  }

  LatLngBounds _boundsOf(List<_MockEvent> source) {
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
