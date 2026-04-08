import 'package:flutter/material.dart';
import 'package:yandex_dance/core/ui/colors/colors.dart';
import 'package:yandex_dance/features/friends/presentation/widgets/coach_avatar_image_provider.dart';

/// Аватар с градиентной обводкой (как у профиля).
class FriendCoachAvatar extends StatelessWidget {
  const FriendCoachAvatar({super.key, required this.avatarUrl});

  final String avatarUrl;

  @override
  Widget build(BuildContext context) {
    final hasImage = avatarUrl.trim().isNotEmpty;
    return Center(
      child: SizedBox(
        width: 132,
        height: 132,
        child: Container(
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
      ),
    );
  }
}
