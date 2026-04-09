import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:yandex_dance/app/di/service_locator.dart';
import 'package:yandex_dance/features/auth/domain/repositories/auth_repository.dart';
import 'package:yandex_dance/features/events/presentation/pages/event_details_page.dart';
import 'package:yandex_dance/features/events/presentation/utils/dance_event_to_event_preview.dart';
import 'package:yandex_dance/core/mixins/state_manager_listener_mixin.dart';
import 'package:yandex_dance/core/ui/colors/colors.dart';
import 'package:yandex_dance/core/ui/typography/app_text_theme.dart';
import 'package:yandex_dance/features/profile/presentation/managers/profile_manager.dart';
import 'package:yandex_dance/features/profile/presentation/state/profile_state.dart';
import 'package:yandex_dance/features/profile/presentation/widgets/profile_avatar.dart';
import 'package:yandex_dance/features/profile/presentation/widgets/profile_events_section.dart';
import 'package:yandex_dance/features/profile/presentation/widgets/profile_header.dart';
import 'package:yandex_dance/features/profile/presentation/widgets/profile_name_meta.dart';
import 'package:yandex_dance/features/profile/presentation/widgets/profile_settings_sheet.dart';
import 'package:yandex_dance/features/profile/presentation/widgets/profile_styles_pill.dart';
import 'package:yandex_dance/features/profile/presentation/widgets/profile_videos_section.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage>
    with StateManagerListenerMixin<ProfilePage, ProfileState> {
  late final ProfileManager _manager;

  @override
  Stream<ProfileState> get stateStream => _manager.stream;

  @override
  String? errorMessageOf(ProfileState state) => state.errorMessage;

  @override
  void initState() {
    super.initState();
    _manager = sl<ProfileManager>()..start();
    attachStateListener();
  }

  @override
  void dispose() {
    // [ProfileManager] — singleton; подписки сбрасываются в [ProfileManager.signOut].
    super.dispose();
  }

  Future<void> _showSettingsMenu() async {
    final action = await showProfileSettingsSheet(context);
    if (!mounted || action == null) return;
    switch (action) {
      case ProfileSettingsAction.edit:
        context.push('/profile/edit');
        break;
      case ProfileSettingsAction.signOut:
        _manager.signOut();
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<ProfileState>(
      stream: _manager.stream,
      initialData: _manager.state,
      builder: (context, snapshot) {
        final state = snapshot.data ?? _manager.state;

        switch (state.status) {
          case ProfileStatus.loading:
            return const Scaffold(
              backgroundColor: AppColors.gray500,
              body: Center(child: CircularProgressIndicator()),
            );

          case ProfileStatus.error:
            return Scaffold(
              backgroundColor: AppColors.gray500,
              body: Center(
                child: Text(
                  state.errorMessage ?? 'Ошибка',
                  style: AppTextTheme.body4Medium16pt,
                ),
              ),
            );

          case ProfileStatus.ready:
            final profile = state.profile!;
            return Scaffold(
              backgroundColor: AppColors.gray500,
              body: SafeArea(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.only(bottom: 32),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      ProfileHeader(onSettingsTap: _showSettingsMenu),
                      const SizedBox(height: 8),
                      ProfileAvatar(profile: profile),
                      const SizedBox(height: 20),
                      ProfileNameMeta(profile: profile),
                      const SizedBox(height: 16),
                      if (profile.danceStyles.isNotEmpty) ...[
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          child: Center(
                            child: ProfileStylesPill(profile: profile),
                          ),
                        ),
                        const SizedBox(height: 20),
                      ],
                      if ((profile.bio ?? '').isNotEmpty) ...[
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          child: Text(
                            profile.bio!,
                            textAlign: TextAlign.center,
                            style: AppTextTheme.body2Regular14pt.copyWith(
                              color: AppColors.gray100,
                              height: 1.45,
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                      ],
                      ProfileEventsSection(
                        events: state.events,
                        onSeeAll: () => context.go('/events'),
                        onEventTap: (event) {
                          final uid = sl<AuthRepository>().currentUserId;
                          final authorLabel =
                              uid != null && event.creatorId == uid
                                  ? 'Вы'
                                  : 'Организатор';
                          final preview = eventPreviewFromDanceEvent(
                            event,
                            authorLabel: authorLabel,
                          );
                          Navigator.of(context).push<void>(
                            MaterialPageRoute<void>(
                              builder: (_) => EventDetailsPage(event: preview),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 24),
                      ProfileVideosSection(
                        profile: profile,
                        isUploadingVideo: state.isUploadingVideo,
                        onUpload: _manager.pickAndUploadIntroVideo,
                        onDelete: _manager.deleteIntroVideo,
                      ),
                    ],
                  ),
                ),
              ),
            );
        }
      },
    );
  }
}
