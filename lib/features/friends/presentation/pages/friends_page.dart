import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:yandex_dance/app/di/service_locator.dart';
import 'package:yandex_dance/core/enums/dance_style.dart';
import 'package:yandex_dance/core/mixins/state_manager_listener_mixin.dart';
import 'package:yandex_dance/core/ui/colors/colors.dart';
import 'package:yandex_dance/core/ui/colors/input_color.dart';
import 'package:yandex_dance/core/ui/icons/app_icons.dart';
import 'package:yandex_dance/core/ui/widgets/filter-chip/app_filter_chip.dart';
import 'package:yandex_dance/core/ui/widgets/input/app_text_field.dart';
import 'package:yandex_dance/core/ui/widgets/person_card/friend_card.dart';
import 'package:yandex_dance/features/friends/presentation/managers/friends_manager.dart';
import 'package:yandex_dance/features/friends/presentation/pages/friend_detail_page.dart';
import 'package:yandex_dance/features/friends/presentation/state/friends_state.dart';
import 'package:yandex_dance/features/profile/domain/entities/user_profile.dart';

ImageProvider<Object>? _avatarProvider(UserProfile profile) {
  final url = profile.avatarThumbUrl ?? profile.avatarUrl;
  if (url == null || url.isEmpty) return null;
  return CachedNetworkImageProvider(url);
}

class FriendsPage extends StatefulWidget {
  const FriendsPage({super.key});

  @override
  State<FriendsPage> createState() => _FriendsPageState();
}

class _FriendsPageState extends State<FriendsPage>
    with StateManagerListenerMixin<FriendsPage, FriendsState> {
  static const _allLabel = 'Все';

  late final FriendsManager _manager;
  late final TextEditingController _searchController;
  final FocusNode _searchFocusNode = FocusNode();
  bool _touched = false;

  /// `null` — выбрано «Все».
  DanceStyle? _selectedStyle;

  @override
  Stream<FriendsState> get stateStream => _manager.stream;

  @override
  String? errorMessageOf(FriendsState state) => state.errorMessage;

  @override
  void initState() {
    super.initState();
    _manager = sl<FriendsManager>();
    _searchController = TextEditingController();
    attachStateListener();
    _manager.start();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.gray500,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AppTextField(
                hint: 'Поиск',
                state: InputState.initial,
                prefixIcon: AppIcons.search,
                contoller: _searchController,
                touched: _touched,
                focusNode: _searchFocusNode,
                onChanged: (_) => setState(() => _touched = true),
                onFocusChange: () => setState(() => _touched = true),
                onUnfocus: () => setState(() => _touched = true),
              ),
              const SizedBox(height: 16),
              StreamBuilder<FriendsState>(
                stream: _manager.stream,
                initialData: _manager.state,
                builder: (context, snapshot) {
                  final state = snapshot.data ?? const FriendsState();
                  if (state.status != FriendsStatus.ready) {
                    return const SizedBox.shrink();
                  }
                  return SizedBox(
                    height: 44,
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          AppFilterChip(
                            label: _allLabel,
                            isSelected: _selectedStyle == null,
                            onTap: () {
                              setState(() => _selectedStyle = null);
                            },
                          ),
                          const SizedBox(width: 8),
                          for (final style in DanceStyle.values) ...[
                            AppFilterChip(
                              label: style.title,
                              isSelected: _selectedStyle == style,
                              onTap: () {
                                setState(() => _selectedStyle = style);
                              },
                            ),
                            const SizedBox(width: 8),
                          ],
                        ],
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 16),
              Expanded(
                child: StreamBuilder<FriendsState>(
                  stream: _manager.stream,
                  initialData: _manager.state,
                  builder: (context, snapshot) {
                    final state = snapshot.data ?? const FriendsState();
                    return _buildBody(state);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBody(FriendsState state) {
    if (state.status == FriendsStatus.loading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.purple500),
      );
    }
    if (state.status == FriendsStatus.error) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Не удалось загрузить подписки',
              style: TextStyle(color: AppColors.gray0),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () => _manager.start(),
              child: const Text('Повторить'),
            ),
          ],
        ),
      );
    }

    final query = _searchController.text.trim().toLowerCase();

    final filtered =
        state.following.where((user) {
          if (_selectedStyle != null) {
            if (!user.danceStyles.contains(_selectedStyle!)) {
              return false;
            }
          }
          if (query.isEmpty) return true;
          return (user.displayName?.toLowerCase().contains(query) ?? false) ||
              (user.city?.toLowerCase().contains(query) ?? false);
        }).toList();

    if (filtered.isEmpty) {
      return const Center(child: Text('Нет подписок'));
    }

    return ListView.separated(
      itemCount: filtered.length,
      separatorBuilder: (_, __) => const SizedBox(height: 20),
      itemBuilder: (context, index) {
        final user = filtered[index];
        final stylesLabel =
            user.danceStyles.isEmpty
                ? ''
                : user.danceStyles.map((s) => s.title).take(2).join(' · ');

        return FriendCard(
          image: _avatarProvider(user),
          name: user.displayName ?? '',
          styleName: stylesLabel,
          description: user.bio ?? '',
          onTap: () {
            Navigator.of(context)
                .push<void>(
                  MaterialPageRoute<void>(
                    builder: (_) => FriendDetailPage(userId: user.uid),
                  ),
                )
                .then((_) {
                  if (mounted) {
                    _manager.start();
                  }
                });
          },
        );
      },
    );
  }
}
