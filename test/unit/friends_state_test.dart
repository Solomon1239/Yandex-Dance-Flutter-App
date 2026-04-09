import 'package:flutter_test/flutter_test.dart';
import 'package:yandex_dance/features/friends/presentation/state/friends_state.dart';

void main() {
  group('FriendsState', () {
    test('copyWith clearError сбрасывает сообщение', () {
      const state = FriendsState(
        status: FriendsStatus.error,
        errorMessage: 'oops',
      );
      final next = state.copyWith(clearError: true);
      expect(next.errorMessage, isNull);
    });

    test('copyWith сохраняет списки по умолчанию', () {
      const state = FriendsState(status: FriendsStatus.ready);
      final next = state.copyWith(searchLoading: true);
      expect(next.following, isEmpty);
      expect(next.searchLoading, isTrue);
    });
  });
}
