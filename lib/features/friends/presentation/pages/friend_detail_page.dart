import 'package:flutter/material.dart';
import 'package:yandex_dance/app/di/service_locator.dart';
import 'package:yandex_dance/core/ui/colors/colors.dart';
import 'package:yandex_dance/core/ui/icons/app_icons.dart';
import 'package:yandex_dance/core/ui/icons/svg_icon.dart';
import 'package:yandex_dance/core/ui/typography/app_text_theme.dart';
import 'package:yandex_dance/core/ui/widgets/buttons/app_button.dart';
import 'package:yandex_dance/core/ui/widgets/buttons/app_button_style.dart';
import 'package:yandex_dance/features/friends/domain/entities/friend_coach.dart';
import 'package:yandex_dance/features/friends/domain/repositories/friends_repository.dart';
import 'package:yandex_dance/features/friends/presentation/widgets/friend_coach_avatar.dart';
import 'package:yandex_dance/features/friends/presentation/widgets/friend_coach_styles_pill.dart';

class FriendDetailPage extends StatefulWidget {
  const FriendDetailPage({super.key, required this.coachId});

  final String coachId;

  @override
  State<FriendDetailPage> createState() => _FriendDetailPageState();
}

class _FriendDetailPageState extends State<FriendDetailPage> {
  final FriendsRepository _friendsRepository = sl<FriendsRepository>();

  FriendCoach? _coach;
  bool _loading = true;
  Object? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final coach = await _friendsRepository.getCoachById(widget.coachId);
      if (!mounted) return;
      setState(() {
        _coach = coach;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e;
        _loading = false;
      });
    }
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
            Expanded(child: _buildBody()),
          ],
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null) {
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
                onPressed: _load,
                child: const Text('Повторить'),
              ),
            ],
          ),
        ),
      );
    }

    if (_coach == null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Тренер не найден',
                textAlign: TextAlign.center,
                style: AppTextTheme.body4Medium16pt,
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: _load,
                child: const Text('Повторить'),
              ),
            ],
          ),
        ),
      );
    }

    final coach = _coach!;

    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 8),
          FriendCoachAvatar(
            avatarUrl: coach.avatarUrl,
            rating: coach.rating,
          ),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  coach.name,
                  textAlign: TextAlign.center,
                  style: AppTextTheme.body3Regular20pt.copyWith(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Тренер',
                  textAlign: TextAlign.center,
                  style: AppTextTheme.body2Regular14pt.copyWith(
                    color: AppColors.gray100,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          if (coach.styles.isNotEmpty) ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Center(
                child: FriendCoachStylesPill(styles: coach.styles),
              ),
            ),
            const SizedBox(height: 20),
          ],
          if (coach.description.trim().isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                coach.description,
                textAlign: TextAlign.center,
                style: AppTextTheme.body2Regular14pt.copyWith(
                  color: AppColors.gray100,
                  height: 1.45,
                ),
              ),
            ),
        ],
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
