import 'package:yandex_dance/features/friends/domain/repositories/friend_repository.dart';
import 'package:yandex_dance/features/profile/domain/entities/user_profile.dart';
import 'package:yandex_dance/features/profile/domain/repositories/profile_repository.dart';

class FriendRepositoryImpl implements FriendRepository {
  FriendRepositoryImpl({required ProfileRepository profileRepository})
      : _profileRepository = profileRepository;

  final ProfileRepository _profileRepository;

  @override
  Future<void> follow({required String uid, required String targetUid}) async {
    await _profileRepository.follow(uid: uid, targetUid: targetUid);
  }

  @override
  Future<void> unfollow({
    required String uid,
    required String targetUid,
  }) async {
    await _profileRepository.unfollow(uid: uid, targetUid: targetUid);
  }

  @override
  Future<List<UserProfile>> getFollowing(String uid) async {
    return _profileRepository.getFollowing(uid);
  }

  @override
  Future<List<UserProfile>> getFollowers(String uid) async {
    return _profileRepository.getFollowers(uid);
  }

  @override
  Future<bool> isFollowing({
    required String uid,
    required String targetUid,
  }) async {
    final profile = await _profileRepository.getProfile(uid);
    return profile?.followingIds.contains(targetUid) ?? false;
  }
}
