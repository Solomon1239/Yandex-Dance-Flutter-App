import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:yandex_dance/app/di/service_locator.dart';
import 'package:yandex_dance/core/ui/colors/colors.dart';
import 'package:yandex_dance/core/ui/typography/app_text_theme.dart';
import 'package:yandex_dance/features/auth/domain/repositories/auth_repository.dart';
import 'package:yandex_dance/features/friends/presentation/pages/friend_detail_page.dart';
import 'package:yandex_dance/features/profile/domain/entities/user_profile.dart';
import 'package:yandex_dance/features/profile/domain/repositories/profile_repository.dart';

/// Нижнее окно: подписчики и подписки пользователя [userId].
Future<void> showUserFollowListsSheet(
  BuildContext context, {
  required String userId,
  int initialTabIndex = 0,
}) {
  return showModalBottomSheet<void>(
    context: context,
    backgroundColor: AppColors.gray500,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (ctx) {
      return DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.65,
        minChildSize: 0.4,
        maxChildSize: 0.92,
        builder: (context, scrollController) {
          return _UserFollowListsSheetContent(
            userId: userId,
            initialTabIndex: initialTabIndex,
          );
        },
      );
    },
  );
}

class _UserFollowListsSheetContent extends StatefulWidget {
  const _UserFollowListsSheetContent({
    required this.userId,
    required this.initialTabIndex,
  });

  final String userId;
  final int initialTabIndex;

  @override
  State<_UserFollowListsSheetContent> createState() =>
      _UserFollowListsSheetContentState();
}

class _UserFollowListsSheetContentState extends State<_UserFollowListsSheetContent>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  final _profileRepository = sl<ProfileRepository>();
  final _authRepository = sl<AuthRepository>();

  List<UserProfile>? _followers;
  List<UserProfile>? _following;
  Object? _error;
  bool _loading = true;

  bool get _isOwnProfile => _authRepository.currentUserId == widget.userId;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 2,
      vsync: this,
      initialIndex: widget.initialTabIndex.clamp(0, 1),
    );
    _load();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final followers = await _profileRepository.getFollowers(widget.userId);
      final following = await _profileRepository.getFollowing(widget.userId);
      if (!mounted) return;
      setState(() {
        _followers = followers;
        _following = following;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e;
        _loading = false;
      });
    }
  }

  Future<void> _unfollow(String targetUid) async {
    final uid = _authRepository.currentUserId;
    if (uid == null) return;

    final previous =
        _following == null ? null : List<UserProfile>.from(_following!);
    setState(() {
      _following = _following?.where((u) => u.uid != targetUid).toList();
    });

    try {
      await _profileRepository.unfollow(uid: uid, targetUid: targetUid);
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _following = previous;
      });
    }
  }

  void _openUser(UserProfile user) {
    Navigator.of(context)
      ..pop()
      ..push<void>(
        MaterialPageRoute<void>(
          builder: (_) => FriendDetailPage(userId: user.uid),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Center(
          child: Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: AppColors.gray300.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(999),
            ),
          ),
        ),
        Text(
          'Подписчики и подписки',
          textAlign: TextAlign.center,
          style: AppTextTheme.body3Regular20pt.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 12),
        if (_loading)
          const Expanded(
            child: Center(
              child: CircularProgressIndicator(color: AppColors.purple500),
            ),
          )
        else if (_error != null)
          Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Не удалось загрузить',
                    style: AppTextTheme.body2Regular14pt.copyWith(
                      color: AppColors.gray100,
                    ),
                  ),
                  TextButton(onPressed: _load, child: const Text('Повторить')),
                ],
              ),
            ),
          )
        else ...[
          TabBar(
            controller: _tabController,
            labelColor: AppColors.gray0,
            unselectedLabelColor: AppColors.gray100,
            indicatorColor: AppColors.purple500,
            tabs: [
              Tab(text: 'Подписчики (${_followers?.length ?? 0})'),
              Tab(text: 'Подписки (${_following?.length ?? 0})'),
            ],
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _FollowersList(
                  users: _followers ?? const [],
                  onOpen: _openUser,
                ),
                _FollowingList(
                  users: _following ?? const [],
                  onOpen: _openUser,
                  onUnfollow: _isOwnProfile ? _unfollow : null,
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

class _FollowListTile extends StatelessWidget {
  const _FollowListTile({
    required this.user,
    required this.onTap,
    this.trailing,
  });

  final UserProfile user;
  final VoidCallback onTap;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final url = user.avatarThumbUrl ?? user.avatarUrl;
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
        child: Row(
          children: [
            CircleAvatar(
              radius: 24,
              backgroundColor: AppColors.gray400,
              backgroundImage:
                  url != null && url.isNotEmpty
                      ? CachedNetworkImageProvider(url)
                      : null,
              child:
                  url == null || url.isEmpty
                      ? const Icon(Icons.person, color: AppColors.gray100)
                      : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    user.displayName?.trim().isNotEmpty == true
                        ? user.displayName!
                        : 'Без имени',
                    style: AppTextTheme.body4Medium16pt,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (user.email != null && user.email!.isNotEmpty)
                    Text(
                      user.email!,
                      style: AppTextTheme.body2Regular14pt.copyWith(
                        color: AppColors.gray100,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                ],
              ),
            ),
            if (trailing != null) trailing!,
          ],
        ),
      ),
    );
  }
}

class _FollowersList extends StatelessWidget {
  const _FollowersList({
    required this.users,
    required this.onOpen,
  });

  final List<UserProfile> users;
  final void Function(UserProfile user) onOpen;

  @override
  Widget build(BuildContext context) {
    if (users.isEmpty) {
      return Center(
        child: Text(
          'Пока нет подписчиков',
          style: AppTextTheme.body2Regular14pt.copyWith(
            color: AppColors.gray100,
          ),
        ),
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.only(top: 8, bottom: 24),
      itemCount: users.length,
      separatorBuilder: (_, __) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final user = users[index];
        return _FollowListTile(user: user, onTap: () => onOpen(user));
      },
    );
  }
}

class _FollowingList extends StatelessWidget {
  const _FollowingList({
    required this.users,
    required this.onOpen,
    this.onUnfollow,
  });

  final List<UserProfile> users;
  final void Function(UserProfile user) onOpen;
  final void Function(String uid)? onUnfollow;

  @override
  Widget build(BuildContext context) {
    if (users.isEmpty) {
      return Center(
        child: Text(
          'Нет подписок',
          style: AppTextTheme.body2Regular14pt.copyWith(
            color: AppColors.gray100,
          ),
        ),
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.only(top: 8, bottom: 24),
      itemCount: users.length,
      separatorBuilder: (_, __) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final user = users[index];
        return _FollowListTile(
          user: user,
          onTap: () => onOpen(user),
          trailing:
              onUnfollow != null
                  ? TextButton(
                    onPressed: () => onUnfollow!(user.uid),
                    child: const Text('Отписаться'),
                  )
                  : null,
        );
      },
    );
  }
}
