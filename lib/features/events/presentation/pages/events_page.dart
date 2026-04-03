import 'package:flutter/material.dart';
import 'package:yandex_dance/core/ui/colors/input_color.dart';
import 'package:yandex_dance/core/ui/icons/app_icons.dart';
import 'package:yandex_dance/core/ui/icons/svg_icon.dart';
import 'package:yandex_dance/core/ui/typography/app_text_theme.dart';
import 'package:yandex_dance/core/ui/widgets/buttons/base_button.dart';
import 'package:yandex_dance/core/ui/widgets/input/app_text_field.dart';
import 'package:yandex_dance/core/ui/widgets/switcher/switcher.dart';
import 'package:yandex_dance/features/events/presentation/widgets/event_card.dart';

final _mockEvents = [
  _MockEvent(
    title: 'Hip-Hop Foundations',
    styleLabel: 'Hip-Hop',
    dateLabel: '5 апреля, 19:00',
    locationLabel: 'Dance Space, Москва',
    authorLabel: 'Вы',
    participantsLabel: '5/20',
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
      appBar: AppBar(title: const Text("Все мероприятия")),
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
                  Expanded(
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: AppSegmentedControl(
                        height: 44,
                        expandItems: true,
                        items: [
                          SvgIcon(AppIcons.list, size: 20),
                          SvgIcon(AppIcons.map, size: 20),
                        ],
                        onChanged: (index) {},
                        horizontalPadding: 0,
                        itemPadding: EdgeInsets.symmetric(horizontal: 0),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  BaseButton(
                    text: 'Фильтры',
                    prefixIcon: const SvgIcon(AppIcons.filter, size: 20),
                    onPressed: _openFiltersModal,
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
    required this.authorLabel,
    required this.participantsLabel,
    this.authorAvatarImage,
    this.coverImage,
  });

  final String title;
  final String styleLabel;
  final String dateLabel;
  final String locationLabel;
  final String authorLabel;
  final String participantsLabel;
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

class _EventsMapView extends StatelessWidget {
  const _EventsMapView({super.key, required this.events});

  final List<_MockEvent> events;

  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('Мероприятия на карте'));
  }
}
