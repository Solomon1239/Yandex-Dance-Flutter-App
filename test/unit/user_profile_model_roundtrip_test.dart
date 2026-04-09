import 'package:flutter_test/flutter_test.dart';
import 'package:yandex_dance/features/profile/data/models/user_profile_model.dart';

import '../fixtures/user_profile_fixtures.dart';

void main() {
  group('UserProfileModel', () {
    test('fromEntity → toEntity', () {
      final original = UserProfileFixtures.minimal(uid: 'u-42');
      final model = UserProfileModel.fromEntity(original);
      expect(model.toEntity(), original);
    });
  });
}
