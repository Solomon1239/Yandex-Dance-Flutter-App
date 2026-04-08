import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:yandex_dance/features/friends/data/models/friend_request_model.dart';

class FriendRemoteDataSource {
  FriendRemoteDataSource({required FirebaseFirestore firestore})
      : _firestore = firestore;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _requests =>
      _firestore.collection('friend_requests');

  DocumentReference<Map<String, dynamic>> _userDoc(String uid) =>
      _firestore.collection('users').doc(uid);

  Future<String> createRequest({
    required String fromUid,
    required String toUid,
  }) async {
    final doc = await _requests.add(
      FriendRequestModel(
        id: '',
        fromUid: fromUid,
        toUid: toUid,
        status: 'pending',
      ).toMap(),
    );
    return doc.id;
  }

  Future<void> updateRequestStatus({
    required String requestId,
    required String status,
  }) async {
    await _requests.doc(requestId).update({
      'status': status,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> deleteRequest(String requestId) async {
    await _requests.doc(requestId).delete();
  }

  Future<FriendRequestModel?> getRequest(String requestId) async {
    final doc = await _requests.doc(requestId).get();
    if (!doc.exists || doc.data() == null) return null;
    return FriendRequestModel.fromDoc(doc);
  }

  Stream<List<FriendRequestModel>> watchIncomingRequests(String uid) {
    return _requests
        .where('toUid', isEqualTo: uid)
        .where('status', isEqualTo: 'pending')
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map(FriendRequestModel.fromDoc).toList());
  }

  Stream<List<FriendRequestModel>> watchOutgoingRequests(String uid) {
    return _requests
        .where('fromUid', isEqualTo: uid)
        .where('status', isEqualTo: 'pending')
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map(FriendRequestModel.fromDoc).toList());
  }

  Future<FriendRequestModel?> findPendingRequest({
    required String fromUid,
    required String toUid,
  }) async {
    final snapshot = await _requests
        .where('fromUid', isEqualTo: fromUid)
        .where('toUid', isEqualTo: toUid)
        .where('status', isEqualTo: 'pending')
        .limit(1)
        .get();

    if (snapshot.docs.isEmpty) return null;
    return FriendRequestModel.fromDoc(snapshot.docs.first);
  }

  Future<void> addFriendBoth({
    required String uid1,
    required String uid2,
  }) async {
    final batch = _firestore.batch();
    batch.update(_userDoc(uid1), {
      'friendIds': FieldValue.arrayUnion([uid2]),
      'updatedAt': FieldValue.serverTimestamp(),
    });
    batch.update(_userDoc(uid2), {
      'friendIds': FieldValue.arrayUnion([uid1]),
      'updatedAt': FieldValue.serverTimestamp(),
    });
    await batch.commit();
  }

  Future<void> removeFriendBoth({
    required String uid1,
    required String uid2,
  }) async {
    final batch = _firestore.batch();
    batch.update(_userDoc(uid1), {
      'friendIds': FieldValue.arrayRemove([uid2]),
      'updatedAt': FieldValue.serverTimestamp(),
    });
    batch.update(_userDoc(uid2), {
      'friendIds': FieldValue.arrayRemove([uid1]),
      'updatedAt': FieldValue.serverTimestamp(),
    });
    await batch.commit();
  }
}
