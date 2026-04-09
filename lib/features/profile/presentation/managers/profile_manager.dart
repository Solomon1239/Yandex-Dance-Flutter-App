import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
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
  String? _eventsStreamUid;

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
        .listen(
          _onProfileChanged,
          onError: (Object e, StackTrace st) {
            addError(e, st, 'profile.watchProfile');
          },
          cancelOnError: false,
        );

    _bindUserEventsStream(uid);
  }

  void _bindUserEventsStream(String uid) {
    _eventsSubscription?.cancel();
    _eventsStreamUid = uid;
    _eventsSubscription = _eventRepository
        .watchUserEvents(uid)
        .listen(
          _onEventsChanged,
          onError: (Object e, StackTrace st) {
            addError(e, st, 'profile.watchUserEvents');
            debugPrint('profile.watchUserEvents error: $e');
            // Подписка могла умереть; переподключаемся (индекс, сеть).
            Future<void>.delayed(const Duration(seconds: 2), () {
              final current = _authRepository.currentUserId;
              if (current != null && current == _eventsStreamUid) {
                _bindUserEventsStream(current);
              }
            });
          },
          cancelOnError: false,
        );
  }

  /// После успешной отписки на экране мероприятия — убрать карточку сразу,
  /// не дожидаясь снимка Firestore (и если стрим временно не обновился).
  void removeUserEventFromList(String eventId) {
    handle((emit) async {
      final next = state.events
          .where((e) => e.id != eventId)
          .toList(growable: false);
      if (next.length == state.events.length) return;
      emit(state.copyWith(events: next));
    }, identifier: 'profile.removeUserEventFromList');
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
          isUploadingVideo: false,
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

      emit(state.copyWith(isUploadingVideo: true, clearError: true));

      try {
        final file = await _mediaPickerService.pickVideoFromGallery();
        if (file == null) {
          emit(state.copyWith(isUploadingVideo: false));
          return;
        }

        await _profileRepository.uploadIntroVideo(
          uid: uid,
          currentProfile: current,
          sourcePath: file.path,
        );
      } on AppException catch (e, stackTrace) {
        addError(e, stackTrace, 'profile.pickAndUploadIntroVideo');
        emit(state.copyWith(isUploadingVideo: false, errorMessage: e.message));
      } on FirebaseException catch (e, stackTrace) {
        addError(e, stackTrace, 'profile.pickAndUploadIntroVideo');
        final message = e.message?.trim();
        emit(
          state.copyWith(
            isUploadingVideo: false,
            errorMessage:
                message == null || message.isEmpty
                    ? 'Firebase ошибка (${e.code})'
                    : 'Firebase ошибка (${e.code}): $message',
          ),
        );
      } catch (e, stackTrace) {
        addError(e, stackTrace, 'profile.pickAndUploadIntroVideo');
        emit(
          state.copyWith(
            isUploadingVideo: false,
            errorMessage: 'Не удалось загрузить видео: $e',
          ),
        );
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
        await _profileSubscription?.cancel();
        await _eventsSubscription?.cancel();
        _profileSubscription = null;
        _eventsSubscription = null;
        _eventsStreamUid = null;
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
