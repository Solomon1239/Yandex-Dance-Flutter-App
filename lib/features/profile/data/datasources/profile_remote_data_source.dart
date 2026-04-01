import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:yandex_dance/features/profile/data/models/user_profile_model.dart';

class ProfileRemoteDataSource {
  ProfileRemoteDataSource({required FirebaseFirestore firestore})
    : _firestore = firestore;

  final FirebaseFirestore _firestore;

  DocumentReference<Map<String, dynamic>> _doc(String uid) =>
      _firestore.collection('users').doc(uid);

  Stream<UserProfileModel?> watchProfile(String uid) {
    return _doc(uid).snapshots().map((snapshot) {
      if (!snapshot.exists || snapshot.data() == null) return null;
      return UserProfileModel.fromDoc(snapshot);
    });
  }

  Future<UserProfileModel?> getProfile(String uid) async {
    final snapshot = await _doc(uid).get();
    if (!snapshot.exists || snapshot.data() == null) return null;
    return UserProfileModel.fromDoc(snapshot);
  }

  Future<void> createProfileIfNeeded(UserProfileModel model) async {
    final snapshot = await _doc(model.uid).get();
    if (snapshot.exists) return;
    await _doc(model.uid).set(model.toMapForCreate());
  }

  Future<void> updateProfile(UserProfileModel model) async {
    await _doc(model.uid).set(model.toMapForUpdate(), SetOptions(merge: true));
  }

  Future<void> updateFields({
    required String uid,
    required Map<String, dynamic> fields,
  }) async {
    await _doc(uid).set({
      ...fields,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }
}
