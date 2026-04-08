import 'package:flutter/material.dart';
import 'package:yandex_dance/app/di/service_locator.dart';
import 'package:yandex_dance/core/enums/dance_style.dart';
import 'package:yandex_dance/core/ui/colors/colors.dart';
import 'package:yandex_dance/core/ui/icons/app_icons.dart';
import 'package:yandex_dance/core/ui/icons/svg_icon.dart';
import 'package:yandex_dance/core/ui/typography/app_text_theme.dart';
import 'package:yandex_dance/core/ui/widgets/buttons/app_button.dart';
import 'package:yandex_dance/core/ui/widgets/buttons/app_button_style.dart';
import 'package:yandex_dance/features/friends/presentation/widgets/friend_coach_avatar.dart';
import 'package:yandex_dance/features/friends/presentation/widgets/friend_coach_styles_pill.dart';
import 'package:yandex_dance/features/friends/presentation/widgets/friend_detail_user_sections.dart';
import 'package:yandex_dance/features/profile/domain/entities/user_profile.dart';
import 'package:yandex_dance/features/profile/domain/repositories/profile_repository.dart';
import 'package:yandex_dance/features/profile/presentation/widgets/profile_follow_stats_row.dart';

/// Карточка пользователя по [userId] (`users/{uid}` в Firestore).
class FriendDetailPage extends StatefulWidget {
  const FriendDetailPage({super.key, required this.userId});

  final String userId;

  @override
  State<FriendDetailPage> createState() => _FriendDetailPageState();
}

class _FriendDetailPageState extends State<FriendDetailPage> {
  late Stream<UserProfile?> _profileStream;

  @override
  void initState() {
    super.initState();
    _profileStream = sl<ProfileRepository>().watchProfile(widget.userId);
  }

  void _retryStream() {
    setState(() {
      _profileStream = sl<ProfileRepository>().watchProfile(widget.userId);
    });
  }

  static String _displayName(UserProfile profile) {
    final n = profile.displayName?.trim();
    if (n != null && n.isNotEmpty) return n;
    return 'Без имени';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.gray500,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _FriendDetailTopBar(
              onBack: () => Navigator.of(context).pop(),
            ),
            Expanded(
              child: StreamBuilder<UserProfile?>(
                stream: _profileStream,
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Не удалось загрузить профиль',
                              textAlign: TextAlign.center,
                              style: AppTextTheme.body4Medium16pt,
                            ),
                            const SizedBox(height: 16),
                            TextButton(
                              onPressed: _retryStream,
                              child: const Text('Повторить'),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final profile = snapshot.data;
                  if (profile == null) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Профиль не найден',
                              textAlign: TextAlign.center,
                              style: AppTextTheme.body4Medium16pt,
                            ),
                            const SizedBox(height: 16),
                            TextButton(
                              onPressed: _retryStream,
                              child: const Text('Повторить'),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  final name = _displayName(profile);
                  final metaParts = <String>[];
                  if ((profile.city ?? '').isNotEmpty) {
                    metaParts.add(profile.city!);
                  }
                  if (profile.age != null) {
                    metaParts.add('${profile.age} лет');
                  }
                  final styles =
                      profile.danceStyles.map((DanceStyle s) => s.title).toList();
                  final bio = profile.bio?.trim() ?? '';

                  return SingleChildScrollView(
                    padding: const EdgeInsets.only(bottom: 32),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const SizedBox(height: 8),
                        FriendCoachAvatar(
                          avatarUrl:
                              profile.avatarThumbUrl ??
                              profile.avatarUrl ??
                              '',
                          rating: 0,
                        ),
                        const SizedBox(height: 20),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                name,
                                textAlign: TextAlign.center,
                                style: AppTextTheme.body3Regular20pt.copyWith(
                                  fontSize: 24,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              if (metaParts.isNotEmpty) ...[
                                const SizedBox(height: 6),
                                Text(
                                  metaParts.join(' • '),
                                  textAlign: TextAlign.center,
                                  style: AppTextTheme.body2Regular14pt.copyWith(
                                    color: AppColors.gray100,
                                  ),
                                ),
                              ],
                              const SizedBox(height: 10),
                              ProfileFollowStatsRow(
                                followersCount: profile.followersCount,
                                followingCount: profile.followingCount,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        if (styles.isNotEmpty) ...[
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 24),
                            child: Center(
                              child: FriendCoachStylesPill(styles: styles),
                            ),
                          ),
                          const SizedBox(height: 20),
                        ],
                        if (bio.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 24),
                            child: Text(
                              bio,
                              textAlign: TextAlign.center,
                              style: AppTextTheme.body2Regular14pt.copyWith(
                                color: AppColors.gray100,
                                height: 1.45,
                              ),
                            ),
                          ),
                        const SizedBox(height: 28),
                        Divider(
                          color: AppColors.gray300.withValues(alpha: 0.25),
                          height: 1,
                        ),
                        const SizedBox(height: 28),
                        FriendDetailEventsSection(
                          userId: widget.userId,
                          userDisplayName: name,
                        ),
                        const SizedBox(height: 28),
                        FriendDetailVideoSection(userId: widget.userId),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FriendDetailTopBar extends StatelessWidget {
  const _FriendDetailTopBar({required this.onBack});

  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 12, 16, 0),
      child: Row(
        children: [
          AppButton(
            onTap: onBack,
            iconWidget: const SvgIcon(
              AppIcons.back,
              size: 20,
              color: AppColors.gray0,
            ),
            style: const AppButtonStyle(
              width: 40,
              height: 40,
              padding: EdgeInsets.zero,
              backgroundColor: Colors.transparent,
            ),
          ),
          const Spacer(),
        ],
      ),
    );
  }
}
