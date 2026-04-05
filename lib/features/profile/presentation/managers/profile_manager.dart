import 'dart:async';

import 'package:yandex_dance/core/errors/app_exception.dart';
import 'package:yandex_dance/core/services/media/media_picker_service.dart';
import 'package:yandex_dance/features/auth/domain/repositories/auth_repository.dart';
import 'package:yandex_dance/features/events/domain/entities/dance_event.dart';
import 'package:yandex_dance/features/events/domain/repositories/event_repository.dart';
import 'package:yandex_dance/features/profile/domain/entities/user_profile.dart';
import 'package:yandex_dance/features/profile/domain/repositories/profile_repository.dart';
import 'package:yandex_dance/features/profile/presentation/state/profile_state.dart';
import 'package:yx_state/yx_state.dart';

class ProfileManager extends StateManager<ProfileState> {
  ProfileManager({
    required ProfileRepository profileRepository,
    required AuthRepository authRepository,
    required EventRepository eventRepository,
    required MediaPickerService mediaPickerService,
  }) : _profileRepository = profileRepository,
       _authRepository = authRepository,
       _eventRepository = eventRepository,
       _mediaPickerService = mediaPickerService,
       super(const ProfileState());

  final ProfileRepository _profileRepository;
  final AuthRepository _authRepository;
  final EventRepository _eventRepository;
  final MediaPickerService _mediaPickerService;

  StreamSubscription<UserProfile?>? _profileSubscription;
  StreamSubscription<List<DanceEvent>>? _eventsSubscription;

  void start() {
    final uid = _authRepository.currentUserId;
    if (uid == null) {
      handle((emit) async {
        emit(
          state.copyWith(
            status: ProfileStatus.error,
            errorMessage: 'Пользователь не найден',
          ),
        );
      }, identifier: 'profile.start.noUser');
      return;
    }

    _profileSubscription?.cancel();
    _profileSubscription = _profileRepository
        .watchProfile(uid)
        .listen(_onProfileChanged);

    _eventsSubscription?.cancel();
    _eventsSubscription = _eventRepository
        .watchUserEvents(uid)
        .listen(_onEventsChanged);
  }

  Future<void> _onProfileChanged(UserProfile? profile) {
    return handle((emit) async {
      if (profile == null) {
        emit(
          state.copyWith(
            status: ProfileStatus.error,
            errorMessage: 'Профиль не найден',
          ),
        );
        return;
      }

      emit(
        state.copyWith(
          status: ProfileStatus.ready,
          profile: profile,
          clearError: true,
        ),
      );
    }, identifier: 'profile.onProfileChanged');
  }

  Future<void> _onEventsChanged(List<DanceEvent> events) {
    return handle((emit) async {
      emit(state.copyWith(events: events));
    }, identifier: 'profile.onEventsChanged');
  }

  Future<void> pickAndUploadIntroVideo() {
    return handle((emit) async {
      final uid = _authRepository.currentUserId;
      final current = state.profile;
      if (uid == null || current == null) return;

      emit(state.copyWith(clearError: true));

      try {
        final file = await _mediaPickerService.pickVideoFromGallery();
        if (file == null) return;

        await _profileRepository.uploadIntroVideo(
          uid: uid,
          currentProfile: current,
          sourcePath: file.path,
        );
      } on AppException catch (e, stackTrace) {
        addError(e, stackTrace, 'profile.pickAndUploadIntroVideo');
        emit(state.copyWith(errorMessage: e.message));
      } catch (e, stackTrace) {
        addError(e, stackTrace, 'profile.pickAndUploadIntroVideo');
        emit(state.copyWith(errorMessage: 'Не удалось загрузить видео'));
      }
    }, identifier: 'profile.pickAndUploadIntroVideo');
  }

  Future<void> deleteIntroVideo() {
    return handle((emit) async {
      final current = state.profile;
      if (current == null) return;
      if (current.introVideoUrl == null) return;

      emit(state.copyWith(clearError: true));

      try {
        await _profileRepository.deleteIntroVideo(currentProfile: current);
      } on AppException catch (e, stackTrace) {
        addError(e, stackTrace, 'profile.deleteIntroVideo');
        emit(state.copyWith(errorMessage: e.message));
      } catch (e, stackTrace) {
        addError(e, stackTrace, 'profile.deleteIntroVideo');
        emit(state.copyWith(errorMessage: 'Не удалось удалить видео'));
      }
    }, identifier: 'profile.deleteIntroVideo');
  }

  Future<void> signOut() {
    return handle((emit) async {
      try {
        emit(state.copyWith(status: ProfileStatus.loading, clearError: true));
        await _authRepository.signOut();
      } on AppException catch (e, stackTrace) {
        addError(e, stackTrace, 'profile.signOut');
        emit(
          state.copyWith(status: ProfileStatus.error, errorMessage: e.message),
        );
      }
    }, identifier: 'profile.signOut');
  }

  @override
  Future<void> close() async {
    if (_profileSubscription != null) {
      await _profileSubscription!.cancel();
    }
    if (_eventsSubscription != null) {
      await _eventsSubscription!.cancel();
    }
    return super.close();
  }
}
