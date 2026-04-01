import 'package:yandex_dance/core/enums/dance_style.dart';
import 'package:yandex_dance/features/profile/domain/entities/user_profile.dart';

abstract interface class ProfileRepository {
  Stream<UserProfile?> watchProfile(String uid);

  Future<UserProfile?> getProfile(String uid);

  Future<void> createProfileIfNeeded({
    required String uid,
    String? email,
    String? displayName,
    String? photoUrl,
  });

  Future<void> updateDanceStyles({
    required String uid,
    required List<DanceStyle> danceStyles,
  });

  Future<void> saveProfile(UserProfile profile);

  Future<UserProfile> uploadAvatar({
    required String uid,
    required UserProfile currentProfile,
    required String sourcePath,
  });

  Future<UserProfile> uploadIntroVideo({
    required String uid,
    required UserProfile currentProfile,
    required String sourcePath,
  });
}
