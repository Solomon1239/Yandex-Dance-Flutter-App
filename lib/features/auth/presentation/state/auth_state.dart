import 'package:equatable/equatable.dart';

enum AuthMode {
  login,
  signUp,
}

class AuthState extends Equatable {
  const AuthState({
    this.mode = AuthMode.login,
    this.isLoading = false,
    this.errorMessage,
  });

  final AuthMode mode;
  final bool isLoading;
  final String? errorMessage;

  AuthState copyWith({
    AuthMode? mode,
    bool? isLoading,
    String? errorMessage,
    bool clearError = false,
  }) {
    return AuthState(
      mode: mode ?? this.mode,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  List<Object?> get props => [mode, isLoading, errorMessage];
}
