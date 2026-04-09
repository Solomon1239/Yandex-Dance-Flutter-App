import 'package:yandex_dance/core/enums/dance_style.dart';
import 'package:yandex_dance/features/profile/domain/entities/user_profile.dart';

abstract final class UserProfileFixtures {
  static UserProfile minimal({
    String uid = 'test-uid',
    List<DanceStyle> danceStyles = const [DanceStyle.hipHop],
    bool onboardingCompleted = true,
    String? avatarUrl,
    String? introVideoUrl,
  }) {
    return UserProfile(
      uid: uid,
      danceStyles: danceStyles,
      onboardingCompleted: onboardingCompleted,
      avatarUrl: avatarUrl,
      introVideoUrl: introVideoUrl,
    );
  }
}
