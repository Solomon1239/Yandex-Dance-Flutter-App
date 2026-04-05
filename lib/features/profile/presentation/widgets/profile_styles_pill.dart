import 'package:flutter/material.dart';
import 'package:yandex_dance/core/enums/dance_style.dart';
import 'package:yandex_dance/core/ui/colors/colors.dart';
import 'package:yandex_dance/core/ui/typography/app_text_theme.dart';
import 'package:yandex_dance/features/profile/domain/entities/user_profile.dart';

class ProfileStylesPill extends StatelessWidget {
  const ProfileStylesPill({super.key, required this.profile});

  final UserProfile profile;

  @override
  Widget build(BuildContext context) {
    final text = profile.danceStyles.map((s) => s.title).join(' • ');
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.purple500.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: AppColors.purple500.withValues(alpha: 0.35),
        ),
      ),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: AppTextTheme.body4Medium16pt.copyWith(
          color: AppColors.gray0,
          height: 1.3,
        ),
      ),
    );
  }
}
