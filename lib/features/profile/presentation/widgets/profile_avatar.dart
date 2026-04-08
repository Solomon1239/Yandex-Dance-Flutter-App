import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:yandex_dance/core/ui/colors/colors.dart';
import 'package:yandex_dance/features/profile/domain/entities/user_profile.dart';

class ProfileAvatar extends StatelessWidget {
  const ProfileAvatar({super.key, required this.profile});

  final UserProfile profile;

  @override
  Widget build(BuildContext context) {
    final hasThumb = profile.avatarThumbUrl != null;
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
                  hasThumb
                      ? DecorationImage(
                        image: CachedNetworkImageProvider(
                          profile.avatarThumbUrl!,
                        ),
                        fit: BoxFit.cover,
                      )
                      : null,
            ),
            child:
                hasThumb
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
