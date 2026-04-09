import 'package:flutter_test/flutter_test.dart';
import 'package:yandex_dance/core/enums/dance_style.dart';
import 'package:yandex_dance/features/style_selection/presentation/state/style_selection_state.dart';

void main() {
  group('StyleSelectionState', () {
    test('isProcessing', () {
      expect(const StyleSelectionState().isProcessing, isFalse);
      expect(
        const StyleSelectionState(isSaving: true).isProcessing,
        isTrue,
      );
      expect(
        const StyleSelectionState(isUploadingAvatar: true).isProcessing,
        isTrue,
      );
    });

    test('copyWith clearAvatar и clearSuccess', () {
      const state = StyleSelectionState(
        selectedStyles: [DanceStyle.house],
        errorMessage: 'err',
        successMessage: 'ok',
      );
      final cleared = state.copyWith(
        clearAvatar: true,
        clearError: true,
        clearSuccess: true,
      );
      expect(cleared.avatarFile, isNull);
      expect(cleared.errorMessage, isNull);
      expect(cleared.successMessage, isNull);
      expect(cleared.selectedStyles, [DanceStyle.house]);
    });
  });
}
