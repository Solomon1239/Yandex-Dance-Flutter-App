import 'package:flutter_test/flutter_test.dart';
import 'package:yandex_dance/features/profile/presentation/state/profile_state.dart';

void main() {
  group('ProfileState', () {
    test('copyWith clearError', () {
      const state = ProfileState(
        status: ProfileStatus.error,
        errorMessage: 'e',
      );
      expect(state.copyWith(clearError: true).errorMessage, isNull);
    });
  });
}
