import 'package:flutter/material.dart';
import 'package:yandex_dance/core/ui/colors/input_color.dart';
import 'package:yandex_dance/core/ui/icons/app_icons.dart';
import 'package:yandex_dance/core/ui/icons/svg_icon.dart';
import 'package:yandex_dance/core/ui/widgets/buttons/base_button.dart';
import 'package:yandex_dance/core/ui/widgets/input/app_text_field.dart';
import 'package:yandex_dance/core/ui/widgets/person_card/friend_card.dart';

final _mockCoaches = [
  _MockCoach(
    name: 'Алексей Ким',
    styles: ['Hip Hop', 'House'],
    description: 'Профессиональный тренер по хип-хопу с большим опытом выступлений',
    rating: 4.9,
    image: const NetworkImage(
      'https://images.unsplash.com/photo-1504609813442-a8924e83f76e?auto=format&fit=crop&w=800&q=80',
    ),
  ),
  _MockCoach(
    name: 'Mila Stone',
    styles: ['House', 'Jazz Funk'],
    description: 'Помогает раскрыть музыкальность, грув и уверенную работу корпуса',
    rating: 4.8,
    image: const NetworkImage(
      'https://images.unsplash.com/photo-1494790108377-be9c29b29330?auto=format&fit=crop&w=800&q=80',
    ),
  ),
  _MockCoach(
    name: 'John John',
    styles: ['Breaking'],
    description: 'Тренер по брейкингу, базам, фризам и работе в кругу',
    rating: 3.5,
    image: const NetworkImage(
      'https://images.unsplash.com/photo-1516280440614-37939bbacd81?auto=format&fit=crop&w=800&q=80',
    ),
  ),
  _MockCoach(
    name: 'Sasha Lee',
    styles: ['Jazz Funk', 'Hip Hop'],
    description: 'Ставит яркие связки и помогает прокачать подачу и пластику',
    rating: 4.7,
    image: const NetworkImage(
      'https://images.unsplash.com/photo-1438761681033-6461ffad8d80?auto=format&fit=crop&w=800&q=80',
    ),
  ),
];

class FriendsPage extends StatefulWidget {
  const FriendsPage({super.key});

  @override
  State<FriendsPage> createState() => _FriendsPageState();
}

class _FriendsPageState extends State<FriendsPage> {
  late final TextEditingController _searchCoachesController;
  final FocusNode _searchCoachesFocusNode = FocusNode();
  bool _touched = false;
  final Set<String> _selectedGenres = {'Все'};

  @override
  void initState() {
    super.initState();
    _searchCoachesController = TextEditingController();
  }

  @override
  void dispose() {
    _searchCoachesController.dispose();
    _searchCoachesFocusNode.dispose();
    super.dispose();
  }

  Future<void> _openFiltersModal() {
    return showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (context) => const SizedBox(
        height: 280,
        child: Center(
          child: Text('Фильтры скоро появятся'),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final query = _searchCoachesController.text.trim().toLowerCase();

    final genres = <String>[
      'Все',
      ...{
        for (final coach in _mockCoaches) ...coach.styles,
      },
    ];

    final filteredCoaches = _mockCoaches.where((coach) {
      final hasSpecificGenreFilter =
          _selectedGenres.isNotEmpty && !_selectedGenres.contains('Все');

      if (hasSpecificGenreFilter &&
          !coach.styles.any(_selectedGenres.contains)) {
        return false;
      }

      if (query.isEmpty) {
        return true;
      }

      return coach.name.toLowerCase().contains(query) ||
          coach.stylesLabel.toLowerCase().contains(query) ||
          coach.description.toLowerCase().contains(query);
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Все тренеры'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              AppTextField(
                hint: 'Найти тренера',
                state: InputState.initial,
                prefixIcon: AppIcons.search,
                contoller: _searchCoachesController,
                touched: _touched,
                focusNode: _searchCoachesFocusNode,
                onChanged: (_) => setState(() => _touched = true),
                onFocusChange: () => setState(() => _touched = true),
                onUnfocus: () => setState(() => _touched = true),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  BaseButton(
                    text: 'Фильтры',
                    prefixIcon: const SvgIcon(AppIcons.filter, size: 20),
                    onPressed: _openFiltersModal,
                  ),
                  const Spacer()
                ],
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 44,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: genres.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 12),
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
                child: _FriendsListView(coaches: filteredCoaches),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MockCoach {
  const _MockCoach({
    required this.name,
    required this.styles,
    required this.description,
    required this.rating,
    required this.image,
  });

  final String name;
  final List<String> styles;
  final String description;
  final double rating;
  final ImageProvider<Object> image;

  String get stylesLabel => styles.join(' · ');
}

class _FriendsListView extends StatelessWidget {
  const _FriendsListView({
    super.key,
    required this.coaches,
  });

  final List<_MockCoach> coaches;

  @override
  Widget build(BuildContext context) {
    if (coaches.isEmpty) {
      return const Center(
        child: Text('Ничего не найдено'),
      );
    }

    return ListView.separated(
      itemCount: coaches.length,
      separatorBuilder: (_, __) => const SizedBox(height: 20),
      itemBuilder: (context, index) {
        final coach = coaches[index];

        return FriendCard(
          image: coach.image,
          name: coach.name,
          styleName: coach.stylesLabel,
          description: coach.description,
          rating: coach.rating,
        );
      },
    );
  }
}