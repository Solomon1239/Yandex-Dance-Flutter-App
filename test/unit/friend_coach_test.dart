import 'package:flutter_test/flutter_test.dart';
import 'package:yandex_dance/features/friends/domain/entities/friend_coach.dart';

void main() {
  group('FriendCoach', () {
    test('stylesLabel склеивает стили', () {
      final c = FriendCoach(
        id: '1',
        name: 'A',
        styles: const ['House', 'Hip-Hop'],
        description: 'd',
        avatarUrl: 'u',
      );
      expect(c.stylesLabel, 'House · Hip-Hop');
    });

    test('пустой список стилей', () {
      final c = FriendCoach(
        id: '1',
        name: 'A',
        styles: const [],
        description: 'd',
        avatarUrl: 'u',
      );
      expect(c.stylesLabel, '');
    });

    test('равенство Equatable', () {
      final a = FriendCoach(
        id: '1',
        name: 'N',
        styles: const ['x'],
        description: 'd',
        avatarUrl: 'u',
      );
      final b = FriendCoach(
        id: '1',
        name: 'N',
        styles: const ['x'],
        description: 'd',
        avatarUrl: 'u',
      );
      expect(a, b);
    });
  });
}
