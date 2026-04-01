import 'dart:async';

import 'package:yandex_dance/features/auth/domain/entities/auth_session.dart';
import 'package:yandex_dance/features/auth/domain/repositories/auth_repository.dart';
import 'package:yandex_dance/features/profile/domain/entities/user_profile.dart';
import 'package:yandex_dance/features/profile/domain/repositories/profile_repository.dart';
import 'package:yandex_dance/features/session/presentation/state/app_session_state.dart';
import 'package:yx_state/yx_state.dart';

class AppSessionManager extends StateManager<AppSessionState> {
  AppSessionManager({
    required AuthRepository authRepository,
    required ProfileRepository profileRepository,
  }) : _authRepository = authRepository,
       _profileRepository = profileRepository,
       super(const AppSessionState());

  final AuthRepository _authRepository;
  final ProfileRepository _profileRepository;

  StreamSubscription<AuthSession?>? _authSubscription;
  StreamSubscription<UserProfile?>? _profileSubscription;

  void start() {
    _authSubscription?.cancel();
    _authSubscription = _authRepository.authStateChanges().listen(
      _onAuthChanged,
    );
  }

  Future<void> _onAuthChanged(AuthSession? session) {
    return handle((emit) async {
      if (_profileSubscription != null) {
        await _profileSubscription!.cancel();
      }

      if (session == null) {
        emit(const AppSessionState(status: AppSessionStatus.guest));
        return;
      }

      emit(
        state.copyWith(
          status: AppSessionStatus.checking,
          session: session,
          clearProfile: true,
        ),
      );

      _profileSubscription = _profileRepository
          .watchProfile(session.uid)
          .listen((profile) => _onProfileChanged(session, profile));
    }, identifier: 'session.authChanged');
  }

  Future<void> _onProfileChanged(AuthSession session, UserProfile? profile) {
    return handle((emit) async {
      if (profile == null) {
        emit(
          state.copyWith(
            status: AppSessionStatus.checking,
            session: session,
            clearProfile: true,
          ),
        );
        return;
      }

      final nextStatus =
          profile.onboardingCompleted
              ? AppSessionStatus.authorized
              : AppSessionStatus.needsStyleSelection;

      emit(
        state.copyWith(status: nextStatus, session: session, profile: profile),
      );
    }, identifier: 'session.profileChanged');
  }

  @override
  Future<void> close() async {
    if (_authSubscription != null) {
      await _authSubscription!.cancel();
    }
    if (_profileSubscription != null) {
      await _profileSubscription!.cancel();
    }
    return super.close();
  }
}
