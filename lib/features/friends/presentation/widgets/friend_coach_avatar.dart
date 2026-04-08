import 'package:flutter/material.dart';
import 'package:yandex_dance/core/ui/colors/colors.dart';
import 'package:yandex_dance/core/ui/typography/app_text_theme.dart';
import 'package:yandex_dance/features/friends/presentation/widgets/coach_avatar_image_provider.dart';

/// Визуально как [ProfileAvatar]: круг 132, градиентная обводка, бейдж рейтинга.
class FriendCoachAvatar extends StatelessWidget {
  const FriendCoachAvatar({
    super.key,
    required this.avatarUrl,
    required this.rating,
  });

  final String avatarUrl;
  final double rating;

  @override
  Widget build(BuildContext context) {
    final hasImage = avatarUrl.trim().isNotEmpty;
    return Center(
      child: SizedBox(
        width: 132,
        height: 132,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              width: 132,
              height: 132,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [AppColors.purple500, AppColors.pink500],
                ),
              ),
              padding: const EdgeInsets.all(3),
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.gray400,
                  image:
                      hasImage
                          ? DecorationImage(
                            image: coachAvatarImageProvider(avatarUrl),
                            fit: BoxFit.cover,
                          )
                          : null,
                ),
                child:
                    hasImage
                        ? null
                        : const Icon(
                          Icons.person,
                          size: 56,
                          color: AppColors.gray300,
                        ),
              ),
            ),
            if (rating > 0)
              Positioned(
                right: -4,
                bottom: -4,
                child: _CoachRatingBadge(rating: rating),
              ),
          ],
        ),
      ),
    );
  }
}

class _CoachRatingBadge extends StatelessWidget {
  const _CoachRatingBadge({required this.rating});

  final double rating;

  @override
  Widget build(BuildContext context) {
    final label = rating.toStringAsFixed(1);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.gray400,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppColors.gray500, width: 2),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.star_rounded, size: 16, color: AppColors.purple500),
          const SizedBox(width: 4),
          Text(
            label,
            style: AppTextTheme.body2Regular14pt.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
