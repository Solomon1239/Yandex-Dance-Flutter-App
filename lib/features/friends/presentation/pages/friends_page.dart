import 'package:flutter/material.dart';
import 'package:yandex_dance/app/di/service_locator.dart';
import 'package:yandex_dance/core/enums/dance_style.dart';
import 'package:yandex_dance/core/ui/colors/colors.dart';
import 'package:yandex_dance/core/ui/colors/input_color.dart';
import 'package:yandex_dance/core/ui/icons/app_icons.dart';
import 'package:yandex_dance/core/ui/widgets/input/app_text_field.dart';
import 'package:yandex_dance/core/ui/widgets/person_card/friend_card.dart';
import 'package:yandex_dance/features/create_event/presentation/widgets/dance_style_dropdown.dart';
import 'package:yandex_dance/features/friends/domain/entities/friend_coach.dart';
import 'package:yandex_dance/features/friends/domain/repositories/friends_repository.dart';
import 'package:yandex_dance/features/friends/presentation/pages/friend_detail_page.dart';
import 'package:yandex_dance/features/friends/presentation/widgets/coach_avatar_image_provider.dart';

bool _coachMatchesDanceStyle(FriendCoach coach, DanceStyle style) {
  final key = style.title.toLowerCase().replaceAll(RegExp(r'[\s-]'), '');
  return coach.styles.any(
    (s) =>
        s.toLowerCase().replaceAll(RegExp(r'[\s-]'), '') == key ||
        s.toLowerCase().contains(style.title.toLowerCase()) ||
        style.title.toLowerCase().contains(s.toLowerCase()),
  );
}

class FriendsPage extends StatefulWidget {
  const FriendsPage({super.key});

  @override
  State<FriendsPage> createState() => _FriendsPageState();
}

class _FriendsPageState extends State<FriendsPage> {
  final FriendsRepository _friendsRepository = sl<FriendsRepository>();

  late final TextEditingController _searchCoachesController;
  final FocusNode _searchCoachesFocusNode = FocusNode();
  bool _touched = false;
  DanceStyle? _selectedDanceStyle;

  List<FriendCoach> _coaches = const [];
  bool _loading = true;
  Object? _loadError;

  @override
  void initState() {
    super.initState();
    _searchCoachesController = TextEditingController();
    _loadCoaches();
  }

  Future<void> _loadCoaches() async {
    setState(() {
      _loading = true;
      _loadError = null;
    });
    try {
      final list = await _friendsRepository.getCoaches();
      if (!mounted) return;
      setState(() {
        _coaches = list;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loadError = e;
        _loading = false;
      });
    }
  }

  @override
  void dispose() {
    _searchCoachesController.dispose();
    _searchCoachesFocusNode.dispose();
    super.dispose();
  }

  void _openCoach(String coachId) {
    Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (_) => FriendDetailPage(coachId: coachId),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final query = _searchCoachesController.text.trim().toLowerCase();

    final filteredCoaches =
        _coaches.where((coach) {
          if (_selectedDanceStyle != null &&
              !_coachMatchesDanceStyle(coach, _selectedDanceStyle!)) {
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
      backgroundColor: AppColors.gray500,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
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
              DanceStyleDropdown(
                selectedStyle: _selectedDanceStyle,
                showAllChip: true,
                onChanged:
                    (style) => setState(() => _selectedDanceStyle = style),
              ),
              const SizedBox(height: 24),
              Expanded(
                child: _buildBody(filteredCoaches),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBody(List<FriendCoach> filteredCoaches) {
    if (_loading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.purple500),
      );
    }
    if (_loadError != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Не удалось загрузить список',
              style: TextStyle(color: AppColors.gray0),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: _loadCoaches,
              child: const Text('Повторить'),
            ),
          ],
        ),
      );
    }

    if (filteredCoaches.isEmpty) {
      return const Center(child: Text('Ничего не найдено'));
    }

    return ListView.separated(
      itemCount: filteredCoaches.length,
      separatorBuilder: (_, __) => const SizedBox(height: 20),
      itemBuilder: (context, index) {
        final coach = filteredCoaches[index];
        return FriendCard(
          image: coachAvatarImageProvider(coach.avatarUrl),
          name: coach.name,
          styleName: coach.stylesLabel,
          description: coach.description,
          rating: coach.rating,
          onTap: () => _openCoach(coach.id),
        );
      },
    );
  }
}
