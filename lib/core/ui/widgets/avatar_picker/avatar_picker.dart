import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:yandex_dance/core/ui/colors/colors.dart';
import 'package:yandex_dance/core/ui/typography/app_text_theme.dart';

class AvatarPicker extends StatelessWidget {
  const AvatarPicker({
    super.key,
    required this.onTap,
    this.file,
    this.networkImageUrl,
    this.isLoading = false,
    this.radius = 56,
    this.label = 'Загрузить фото',
  });

  final VoidCallback onTap;
  final File? file;
  final String? networkImageUrl;
  final bool isLoading;
  final double radius;
  final String label;

  @override
  Widget build(BuildContext context) {
    final badgeSize = radius * 0.64;
    ImageProvider? image;
    if (file != null) {
      image = FileImage(file!);
    } else if (networkImageUrl != null) {
      image = CachedNetworkImageProvider(networkImageUrl!);
    }

    return Column(
      children: [
        Center(
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: isLoading ? null : onTap,
              customBorder: const CircleBorder(),
              child: Stack(
                children: [
                  CircleAvatar(
                    radius: radius,
                    backgroundColor: AppColors.gray400,
                    backgroundImage: image,
                    child:
                        image == null
                            ? Icon(
                              Icons.person,
                              size: radius * 0.86,
                              color: AppColors.gray300,
                            )
                            : null,
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      width: badgeSize,
                      height: badgeSize,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: [AppColors.purple500, AppColors.pink500],
                        ),
                      ),
                      child: Icon(
                        Icons.camera_alt,
                        size: badgeSize * 0.5,
                        color: AppColors.gray0,
                      ),
                    ),
                  ),
                  if (isLoading)
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.black.withValues(alpha: 0.42),
                        ),
                        child: Center(
                          child: SizedBox(
                            width: radius * 0.62,
                            height: radius * 0.62,
                            child: const CircularProgressIndicator(
                              strokeWidth: 3,
                              color: AppColors.gray0,
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          isLoading ? 'Загружаем фото...' : label,
          textAlign: TextAlign.center,
          style: AppTextTheme.body2Regular14pt.copyWith(
            color: AppColors.gray300,
          ),
        ),
      ],
    );
  }
}
