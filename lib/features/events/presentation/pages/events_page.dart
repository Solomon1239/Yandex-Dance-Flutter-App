import 'package:flutter/material.dart';
import 'package:yandex_dance/core/ui/icons/app_icons.dart';
import 'package:yandex_dance/core/ui/icons/svg_icon.dart';
import 'package:yandex_dance/features/events/presentation/widgets/event_card.dart';

final _mockEvents = [
  _MockEvent(
    title: 'Hip-Hop Foundations',
    styleLabel: 'Hip-Hop',
    dateLabel: '5 апреля, 19:00',
    locationLabel: 'Dance Space, Москва',
    coverImage: NetworkImage(
      'https://images.unsplash.com/photo-1516280440614-37939bbacd81?auto=format&fit=crop&w=1200&q=80',
    ),
  ),
  _MockEvent(
    title: 'House Flow Session',
    styleLabel: 'House',
    dateLabel: '7 апреля, 20:30',
    locationLabel: 'Studio 21, Москва',
    coverImage: NetworkImage(
      'https://images.unsplash.com/photo-1508700115892-45ecd05ae2ad?auto=format&fit=crop&w=1200&q=80',
    ),
  ),
  _MockEvent(
    title: 'Jazz Funk Choreo',
    styleLabel: 'Jazz Funk',
    dateLabel: '9 апреля, 18:00',
    locationLabel: 'Vibe Room, Москва',
    coverImage: NetworkImage(
      'https://images.unsplash.com/photo-1504609813442-a8924e83f76e?auto=format&fit=crop&w=1200&q=80',
    ),
  ),
  _MockEvent(
    title: 'Breaking Basics Jam',
    styleLabel: 'Breaking',
    dateLabel: '12 апреля, 17:30',
    locationLabel: 'Cypher Hall, Москва',
  ),
];

class EventsPage extends StatefulWidget {
  const EventsPage({super.key});

  @override
  State<EventsPage> createState() => _EventsPageState();
}

class _EventsPageState extends State<EventsPage> {
  late final TextEditingController _searchEventsController;
  _EventsViewMode _viewMode = _EventsViewMode.list;
  final Set<String> _selectedGenres = {'Все'};

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
      appBar: AppBar(title: const Text("Все мероприятия")),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              TextField(
                controller: _searchEventsController,
                onChanged: (_) => setState(() {}),
                decoration: InputDecoration(
                  label: const Text("Поиск..."),
                  prefixIcon: const Padding(
                    padding: EdgeInsets.all(8),
                    child: SvgIcon(AppIcons.search, size: 16),
                  ),
                  prefixIconConstraints: const BoxConstraints(
                    minWidth: 60,
                    minHeight: 40,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: SegmentedButton<_EventsViewMode>(
                        segments: const [
                          ButtonSegment(
                            value: _EventsViewMode.list,
                            icon: SvgIcon(AppIcons.list, size: 20),
                          ),
                          ButtonSegment(
                            value: _EventsViewMode.map,
                            icon: SvgIcon(AppIcons.map, size: 20),
                          ),
                        ],
                        selected: {_viewMode},
                        showSelectedIcon: false,
                        onSelectionChanged: (selection) {
                          setState(() {
                            _viewMode = selection.first;
                          });
                        },
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  OutlinedButton.icon(
                    onPressed: _openFiltersModal,
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 14,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                    icon: SvgIcon(
                      AppIcons.filter,
                      size: 20,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                    label: const Text('Фильтры'),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 44,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: genres.length,
                  separatorBuilder:
                      (context, index) => const SizedBox(width: 12),
                  itemBuilder: (context, index) {
                    final genre = genres[index];
                    final isSelected = _selectedGenres.contains(genre);

                    return FilterChip(
                      label: Text(genre),
                      selected: isSelected,
                      onSelected: (_) {
                        setState(() {
                          if (genre == 'Все') {
                            _selectedGenres
                              ..clear()
                              ..add('Все');
                            return;
                          }

                          _selectedGenres.remove('Все');

                          if (isSelected) {
                            _selectedGenres.remove(genre);
                          } else {
                            _selectedGenres.add(genre);
                          }

                          if (_selectedGenres.isEmpty) {
                            _selectedGenres.add('Все');
                          }
                        });
                      },
                    );
                  },
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
    this.coverImage,
  });

  final String title;
  final String styleLabel;
  final String dateLabel;
  final String locationLabel;
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
          coverImage: event.coverImage,
        );
      },
    );
  }
}

class _EventsMapView extends StatelessWidget {
  const _EventsMapView({super.key, required this.events});

  final List<_MockEvent> events;

  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('Мероприятия на карте'));
  }
}
