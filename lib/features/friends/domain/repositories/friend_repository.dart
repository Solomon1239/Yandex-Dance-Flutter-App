import 'package:yandex_dance/features/profile/domain/entities/user_profile.dart';

abstract interface class FriendRepository {
  Future<void> follow({required String uid, required String targetUid});

  Future<void> unfollow({required String uid, required String targetUid});

  Future<List<UserProfile>> getFollowing(String uid);

  Future<List<UserProfile>> getFollowers(String uid);

  Future<bool> isFollowing({required String uid, required String targetUid});
}
