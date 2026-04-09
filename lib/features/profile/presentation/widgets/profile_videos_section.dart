import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:yandex_dance/core/ui/colors/colors.dart';
import 'package:yandex_dance/core/ui/typography/app_text_theme.dart';
import 'package:yandex_dance/core/ui/widgets/buttons/app_button.dart';
import 'package:yandex_dance/core/ui/widgets/buttons/app_button_style.dart';
import 'package:yandex_dance/features/profile/domain/entities/user_profile.dart';
import 'package:yandex_dance/features/profile/presentation/pages/video_player_page.dart';

class ProfileVideosSection extends StatelessWidget {
  const ProfileVideosSection({
    super.key,
    required this.profile,
    required this.isUploadingVideo,
    required this.onUpload,
    required this.onDelete,
  });

  final UserProfile profile;
  final bool isUploadingVideo;
  final Future<void> Function() onUpload;
  final Future<void> Function() onDelete;

  @override
  Widget build(BuildContext context) {
    final hasVideo = profile.introVideoUrl != null;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Text('Видео', style: AppTextTheme.body3Regular20pt),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 200,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 24),
            children: [
              if (hasVideo) ...[
                SizedBox(
                  width: 140,
                  height: 200,
                  child: Stack(
                    children: [
                      _VideoTile(
                        thumbUrl: profile.introVideoThumbUrl,
                        videoUrl: profile.introVideoUrl!,
                      ),
                      Positioned(
                        top: 8,
                        right: 8,
                        child: AppButton(
                          onTap: onDelete,
                          iconWidget: const Icon(
                            Icons.close_rounded,
                            color: AppColors.gray0,
                            size: 18,
                          ),
                          style: const AppButtonStyle(
                            width: 28,
                            height: 28,
                            padding: EdgeInsets.zero,
                            backgroundColor: Color(0xFFEF4444),
                            border: AppButtonBorder(
                              borderStyle: ButtonBorderStyle.solid,
                              borderWidth: 0,
                              borderColor: Colors.transparent,
                              borderRadius: 999,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
              ],
              _UploadVideoTile(onTap: onUpload, isUploading: isUploadingVideo),
            ],
          ),
        ),
      ],
    );
  }
}

class _VideoTile extends StatelessWidget {
  const _VideoTile({required this.thumbUrl, required this.videoUrl});

  final String? thumbUrl;
  final String videoUrl;

  @override
  Widget build(BuildContext context) {
    return AppButton(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) => VideoPlayerPage(url: videoUrl),
            fullscreenDialog: true,
          ),
        );
      },
      iconWidget: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: SizedBox(
          width: 140,
          height: 200,
          child: Stack(
            fit: StackFit.expand,
            children: [
              if (thumbUrl != null && thumbUrl!.isNotEmpty)
                CachedNetworkImage(
                  imageUrl: thumbUrl!,
                  fit: BoxFit.cover,
                  placeholder: (_, __) => Container(color: AppColors.gray400),
                  errorWidget:
                      (_, __, ___) => Container(color: AppColors.gray400),
                )
              else
                Container(color: AppColors.gray400),
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withValues(alpha: 0.45),
                    ],
                  ),
                ),
              ),
              Center(
                child: Container(
                  width: 52,
                  height: 52,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [AppColors.purple500, AppColors.pink500],
                    ),
                  ),
                  child: const Icon(
                    Icons.play_arrow_rounded,
                    color: AppColors.gray0,
                    size: 32,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      style: const AppButtonStyle(
        width: 140,
        height: 200,
        padding: EdgeInsets.zero,
        backgroundColor: Colors.transparent,
      ),
    );
  }
}

class _UploadVideoTile extends StatelessWidget {
  const _UploadVideoTile({required this.onTap, required this.isUploading});

  final Future<void> Function() onTap;
  final bool isUploading;

  @override
  Widget build(BuildContext context) {
    return AppButton(
      onTap: onTap,
      needLoading: true,
      iconWidget: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [AppColors.purple500, AppColors.pink500],
              ),
            ),
            child: const Icon(
              Icons.add_rounded,
              color: AppColors.gray0,
              size: 28,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            isUploading ? 'Загружаем...' : 'Загрузить',
            style: AppTextTheme.body2Regular14pt.copyWith(
              color: AppColors.gray100,
            ),
          ),
        ],
      ),
      style: AppButtonStyle(
        width: 140,
        height: 200,
        padding: EdgeInsets.zero,
        backgroundColor: AppColors.gray400,
        loaderColor: AppColors.purple500,
        border: AppButtonBorder(
          borderStyle: ButtonBorderStyle.solid,
          borderWidth: 1,
          borderColor: AppColors.purple500.withValues(alpha: 0.4),
          borderRadius: 20,
        ),
      ),
    );
  }
}
