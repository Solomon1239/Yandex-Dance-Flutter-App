import 'package:flutter_test/flutter_test.dart';
import 'package:yandex_dance/features/friends/data/models/friend_coach_model.dart';

void main() {
  group('FriendCoachModel', () {
    test('toEntity сохраняет поля и stylesLabel', () {
      const model = FriendCoachModel(
        id: 'c1',
        name: 'Coach',
        styles: ['A', 'B'],
        description: 'Bio',
        avatarUrl: 'https://a/1.jpg',
      );
      final entity = model.toEntity();
      expect(entity.id, 'c1');
      expect(entity.name, 'Coach');
      expect(entity.stylesLabel, 'A · B');
      expect(entity.description, 'Bio');
      expect(entity.avatarUrl, 'https://a/1.jpg');
    });
  });
}
