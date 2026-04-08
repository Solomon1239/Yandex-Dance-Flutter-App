import 'package:flutter/material.dart';
import 'package:yandex_dance/app/di/service_locator.dart';
import 'package:yandex_dance/core/ui/colors/colors.dart';
import 'package:yandex_dance/core/ui/typography/app_text_theme.dart';
import 'package:yandex_dance/core/utils/russian_plural.dart';
import 'package:yandex_dance/features/friends/presentation/widgets/user_follow_lists_sheet.dart';
import 'package:yandex_dance/features/profile/domain/repositories/profile_repository.dart';

Widget _tappableHalf({VoidCallback? onTap, required Widget child}) {
  if (onTap == null) return child;
  return Material(
    color: Colors.transparent,
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: child,
      ),
    ),
  );
}

/// Блок «подписчики / подписки» в скруглённой карточке с тенью.
class ProfileFollowStatsRow extends StatelessWidget {
  const ProfileFollowStatsRow({
    super.key,
    required this.followersCount,
    required this.followingCount,
    this.onFollowersTap,
    this.onFollowingTap,
  });

  final int followersCount;
  final int followingCount;
  final VoidCallback? onFollowersTap;
  final VoidCallback? onFollowingTap;

  static String followersPhrase(int n) {
    final word = _followersWord(n);
    return '$n $word';
  }

  static String followingPhrase(int n) {
    final word = _followingWord(n);
    return '$n $word';
  }

  static String _followersWord(int n) {
    return russianPlural(
      n: n,
      one: 'подписчик',
      few: 'подписчика',
      many: 'подписчиков',
    );
  }

  static String _followingWord(int n) {
    return russianPlural(
      n: n,
      one: 'подписка',
      few: 'подписки',
      many: 'подписок',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.cardSurface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.cardBorder),
        boxShadow: AppColors.cardShadow,
      ),
      child: Row(
        children: [
          Expanded(
            child: _tappableHalf(
              onTap: onFollowersTap,
              child: _StatCell(
                count: followersCount,
                label: _followersWord(followersCount),
              ),
            ),
          ),
          Container(
            width: 1,
            height: 40,
            margin: const EdgeInsets.symmetric(horizontal: 12),
            color: AppColors.gray300.withValues(alpha: 0.35),
          ),
          Expanded(
            child: _tappableHalf(
              onTap: onFollowingTap,
              child: _StatCell(
                count: followingCount,
                label: _followingWord(followingCount),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Счётчики в реальном времени: подписки — из [followingCount] (документ
/// пользователя, [watchProfile]); подписчики — [ProfileRepository.watchFollowersCount].
class ProfileFollowStatsLive extends StatelessWidget {
  const ProfileFollowStatsLive({
    super.key,
    required this.userId,
    required this.followingCount,
  });

  final String userId;
  final int followingCount;

  @override
  Widget build(BuildContext context) {
    final repo = sl<ProfileRepository>();
    return StreamBuilder<int>(
      stream: repo.watchFollowersCount(userId),
      builder: (context, snapshot) {
        final followers = snapshot.data ?? 0;
        return ProfileFollowStatsRow(
          followersCount: followers,
          followingCount: followingCount,
          onFollowersTap: () {
            showUserFollowListsSheet(
              context,
              userId: userId,
              initialTabIndex: 0,
            );
          },
          onFollowingTap: () {
            showUserFollowListsSheet(
              context,
              userId: userId,
              initialTabIndex: 1,
            );
          },
        );
      },
    );
  }
}

class _StatCell extends StatelessWidget {
  const _StatCell({required this.count, required this.label});

  final int count;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          '$count',
          textAlign: TextAlign.center,
          style: AppTextTheme.body1Medium18pt.copyWith(
            fontWeight: FontWeight.w700,
            fontSize: 20,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: AppTextTheme.body2Regular14pt.copyWith(
            color: AppColors.gray100,
            fontSize: 13,
          ),
        ),
      ],
    );
  }
}
