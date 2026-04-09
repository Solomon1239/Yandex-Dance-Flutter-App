import 'package:flutter_test/flutter_test.dart';
import 'package:yandex_dance/features/profile/presentation/state/edit_profile_state.dart';

void main() {
  group('EditProfileState', () {
    test('copyWith clearError и clearSuccess', () {
      const state = EditProfileState(
        errorMessage: 'e',
        successMessage: 's',
      );
      final cleared = state.copyWith(clearError: true, clearSuccess: true);
      expect(cleared.errorMessage, isNull);
      expect(cleared.successMessage, isNull);
    });
  });
}
