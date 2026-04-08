import 'package:flutter/material.dart';
import 'package:yandex_dance/core/ui/colors/colors.dart';
import 'package:yandex_dance/core/ui/typography/app_text_theme.dart';
import 'package:yandex_dance/features/profile/domain/entities/user_profile.dart';
import 'package:yandex_dance/features/profile/presentation/widgets/profile_follow_stats_row.dart';

class ProfileNameMeta extends StatelessWidget {
  const ProfileNameMeta({super.key, required this.profile});

  final UserProfile profile;

  @override
  Widget build(BuildContext context) {
    final metaParts = <String>[];
    if ((profile.city ?? '').isNotEmpty) metaParts.add(profile.city!);
    if (profile.age != null) metaParts.add('${profile.age} лет');

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            profile.displayName ?? 'Без имени',
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
    );
  }
}
