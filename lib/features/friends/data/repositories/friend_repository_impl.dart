import 'package:yandex_dance/features/friends/data/datasources/friend_remote_data_source.dart';
import 'package:yandex_dance/features/friends/domain/entities/friend_request.dart';
import 'package:yandex_dance/features/friends/domain/repositories/friend_repository.dart';
import 'package:yandex_dance/features/profile/domain/entities/user_profile.dart';
import 'package:yandex_dance/features/profile/domain/repositories/profile_repository.dart';

class FriendRepositoryImpl implements FriendRepository {
  FriendRepositoryImpl({
    required FriendRemoteDataSource remote,
    required ProfileRepository profileRepository,
  })  : _remote = remote,
       _profileRepository = profileRepository;

  final FriendRemoteDataSource _remote;
  final ProfileRepository _profileRepository;

  @override
  Future<void> sendRequest({
    required String fromUid,
    required String toUid,
  }) async {
    final existing = await _remote.findPendingRequest(
      fromUid: fromUid,
      toUid: toUid,
    );
    if (existing != null) return;

    final reverse = await _remote.findPendingRequest(
      fromUid: toUid,
      toUid: fromUid,
    );
    if (reverse != null) {
      await acceptRequest(reverse.id);
      return;
    }

    await _remote.createRequest(fromUid: fromUid, toUid: toUid);
  }

  @override
  Future<void> acceptRequest(String requestId) async {
    final request = await _remote.getRequest(requestId);
    if (request == null) return;

    await _remote.updateRequestStatus(
      requestId: requestId,
      status: 'accepted',
    );

    await _remote.addFriendBoth(
      uid1: request.fromUid,
      uid2: request.toUid,
    );
  }

  @override
  Future<void> rejectRequest(String requestId) async {
    await _remote.updateRequestStatus(
      requestId: requestId,
      status: 'rejected',
    );
  }

  @override
  Future<void> removeFriend({
    required String uid,
    required String friendUid,
  }) async {
    await _remote.removeFriendBoth(uid1: uid, uid2: friendUid);
  }

  @override
  Stream<List<FriendRequest>> watchIncomingRequests(String uid) {
    return _remote
        .watchIncomingRequests(uid)
        .map((models) => models.map((m) => m.toEntity()).toList());
  }

  @override
  Stream<List<FriendRequest>> watchOutgoingRequests(String uid) {
    return _remote
        .watchOutgoingRequests(uid)
        .map((models) => models.map((m) => m.toEntity()).toList());
  }

  @override
  Future<List<UserProfile>> getFriends(String uid) async {
    return _profileRepository.getFriends(uid);
  }

  @override
  Future<FriendRequest?> findExistingRequest({
    required String fromUid,
    required String toUid,
  }) async {
    final model = await _remote.findPendingRequest(
      fromUid: fromUid,
      toUid: toUid,
    );
    return model?.toEntity();
  }
}
