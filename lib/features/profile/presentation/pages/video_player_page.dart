import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:yandex_dance/core/ui/colors/colors.dart';
import 'package:yandex_dance/core/ui/widgets/custom_bounce_effect.dart';
import 'package:yandex_dance/core/ui/widgets/buttons/app_button.dart';
import 'package:yandex_dance/core/ui/widgets/buttons/app_button_style.dart';

class VideoPlayerPage extends StatefulWidget {
  const VideoPlayerPage({super.key, required this.url});

  final String url;

  @override
  State<VideoPlayerPage> createState() => _VideoPlayerPageState();
}

class _VideoPlayerPageState extends State<VideoPlayerPage> {
  late final VideoPlayerController _controller;
  bool _initialized = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.networkUrl(Uri.parse(widget.url))
      ..setLooping(true);
    _controller
        .initialize()
        .then((_) {
          if (!mounted) return;
          setState(() => _initialized = true);
          _controller.play();
        })
        .catchError((Object e) {
          if (!mounted) return;
          setState(() => _error = 'Не удалось загрузить видео');
        });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _togglePlay() {
    if (!_initialized) return;
    setState(() {
      if (_controller.value.isPlaying) {
        _controller.pause();
      } else {
        _controller.play();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            Center(
              child:
                  _error != null
                      ? Text(
                        _error!,
                        style: const TextStyle(color: AppColors.gray0),
                      )
                      : !_initialized
                      ? const CircularProgressIndicator(
                        color: AppColors.purple500,
                      )
                      : CustomBounceEffect(
                        onTap: _togglePlay,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            AspectRatio(
                              aspectRatio: _controller.value.aspectRatio,
                              child: VideoPlayer(_controller),
                            ),
                            if (!_controller.value.isPlaying)
                              Container(
                                width: 72,
                                height: 72,
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: LinearGradient(
                                    colors: [
                                      AppColors.purple500,
                                      AppColors.pink500,
                                    ],
                                  ),
                                ),
                                child: const Icon(
                                  Icons.play_arrow_rounded,
                                  color: AppColors.gray0,
                                  size: 44,
                                ),
                              ),
                          ],
                        ),
                      ),
            ),
            Positioned(
              top: 8,
              left: 8,
              child: AppButton(
                onTap: () => Navigator.of(context).pop(),
                iconWidget: const Icon(
                  Icons.close_rounded,
                  color: AppColors.gray0,
                  size: 28,
                ),
                style: const AppButtonStyle(
                  width: 48,
                  height: 48,
                  padding: EdgeInsets.zero,
                  backgroundColor: Colors.transparent,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
