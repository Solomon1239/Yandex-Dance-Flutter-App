import 'package:flutter_test/flutter_test.dart';
import 'package:yandex_dance/features/auth/presentation/state/auth_state.dart';

void main() {
  group('AuthState', () {
    test('copyWith clearError и смена mode', () {
      const state = AuthState(
        mode: AuthMode.login,
        isLoading: true,
        errorMessage: 'x',
      );
      final next = state.copyWith(
        mode: AuthMode.signUp,
        isLoading: false,
        clearError: true,
      );
      expect(next.mode, AuthMode.signUp);
      expect(next.isLoading, isFalse);
      expect(next.errorMessage, isNull);
    });
  });
}
