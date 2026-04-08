import 'package:yandex_dance/features/friends/domain/entities/friend_request.dart';
import 'package:yandex_dance/features/profile/domain/entities/user_profile.dart';

abstract interface class FriendRepository {
  Future<void> sendRequest({
    required String fromUid,
    required String toUid,
  });

  Future<void> acceptRequest(String requestId);

  Future<void> rejectRequest(String requestId);

  Future<void> removeFriend({
    required String uid,
    required String friendUid,
  });

  Stream<List<FriendRequest>> watchIncomingRequests(String uid);

  Stream<List<FriendRequest>> watchOutgoingRequests(String uid);

  Future<List<UserProfile>> getFriends(String uid);

  Future<FriendRequest?> findExistingRequest({
    required String fromUid,
    required String toUid,
  });
}
