import 'dart:async';

import 'package:yandex_dance/core/errors/app_exception.dart';
import 'package:yandex_dance/features/auth/domain/repositories/auth_repository.dart';
import 'package:yandex_dance/features/profile/domain/entities/user_profile.dart';
import 'package:yandex_dance/features/profile/domain/repositories/profile_repository.dart';
import 'package:yandex_dance/features/profile/presentation/state/profile_state.dart';
import 'package:yx_state/yx_state.dart';

class ProfileManager extends StateManager<ProfileState> {
  ProfileManager({
    required ProfileRepository profileRepository,
    required AuthRepository authRepository,
  }) : _profileRepository = profileRepository,
       _authRepository = authRepository,
       super(const ProfileState());

  final ProfileRepository _profileRepository;
  final AuthRepository _authRepository;

  StreamSubscription<UserProfile?>? _subscription;

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

    _subscription?.cancel();
    _subscription = _profileRepository
        .watchProfile(uid)
        .listen(_onProfileChanged);
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
    if (_subscription != null) {
      await _subscription!.cancel();
    }
    return super.close();
  }
}
