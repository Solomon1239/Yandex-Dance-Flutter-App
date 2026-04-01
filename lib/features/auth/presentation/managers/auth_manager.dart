import 'package:yandex_dance/core/errors/app_exception.dart';
import 'package:yandex_dance/features/auth/domain/repositories/auth_repository.dart';
import 'package:yandex_dance/features/auth/presentation/state/auth_state.dart';
import 'package:yx_state/yx_state.dart';

class AuthManager extends StateManager<AuthState> {
  AuthManager(this._authRepository) : super(const AuthState());

  final AuthRepository _authRepository;

  Future<void> setMode(AuthMode mode) {
    return handle((emit) async {
      emit(state.copyWith(mode: mode, clearError: true));
    }, identifier: 'auth.setMode');
  }

  Future<void> submitEmail({required String email, required String password}) {
    return handle((emit) async {
      emit(state.copyWith(isLoading: true, clearError: true));

      try {
        if (state.mode == AuthMode.login) {
          await _authRepository.signInWithEmail(
            email: email,
            password: password,
          );
        } else {
          await _authRepository.signUpWithEmail(
            email: email,
            password: password,
          );
        }

        emit(state.copyWith(isLoading: false));
      } on AppException catch (e, stackTrace) {
        addError(e, stackTrace, 'auth.submitEmail');
        emit(state.copyWith(isLoading: false, errorMessage: e.message));
      } catch (e, stackTrace) {
        addError(e, stackTrace, 'auth.submitEmail');
        emit(
          state.copyWith(
            isLoading: false,
            errorMessage: 'Произошла неизвестная ошибка',
          ),
        );
      }
    }, identifier: 'auth.submitEmail');
  }

  Future<void> signInWithGoogle() {
    return handle((emit) async {
      emit(state.copyWith(isLoading: true, clearError: true));

      try {
        await _authRepository.signInWithGoogle();
        emit(state.copyWith(isLoading: false));
      } on AppException catch (e, stackTrace) {
        addError(e, stackTrace, 'auth.signInWithGoogle');
        emit(state.copyWith(isLoading: false, errorMessage: e.message));
      }
    }, identifier: 'auth.signInWithGoogle');
  }

  Future<void> signInWithApple() {
    return handle((emit) async {
      emit(state.copyWith(isLoading: true, clearError: true));

      try {
        await _authRepository.signInWithApple();
        emit(state.copyWith(isLoading: false));
      } on AppException catch (e, stackTrace) {
        addError(e, stackTrace, 'auth.signInWithApple');
        emit(state.copyWith(isLoading: false, errorMessage: e.message));
      }
    }, identifier: 'auth.signInWithApple');
  }
}
