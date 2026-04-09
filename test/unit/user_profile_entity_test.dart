import 'package:flutter_test/flutter_test.dart';

import '../fixtures/user_profile_fixtures.dart';

void main() {
  group('UserProfile', () {
    test('hasAvatar', () {
      expect(UserProfileFixtures.minimal().hasAvatar, isFalse);
      expect(
        UserProfileFixtures.minimal(avatarUrl: 'https://x/a.jpg').hasAvatar,
        isTrue,
      );
    });

    test('hasVideo', () {
      expect(UserProfileFixtures.minimal().hasVideo, isFalse);
      expect(
        UserProfileFixtures.minimal(introVideoUrl: 'https://x/v.mp4').hasVideo,
        isTrue,
      );
    });
  });
}
