import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:yandex_dance/features/profile/data/models/user_profile_model.dart';

/// Тонкая обёртка над Firestore для коллекции `users`.
/// Знает только про чтение/запись документов — никакой бизнес-логики
/// и никакого Storage. Всё хранится по ключу `users/{uid}`, поэтому
/// и методы принимают uid напрямую.
class ProfileRemoteDataSource {
  ProfileRemoteDataSource({required FirebaseFirestore firestore})
    : _firestore = firestore;

  final FirebaseFirestore _firestore;

  DocumentReference<Map<String, dynamic>> _doc(String uid) =>
      _firestore.collection('users').doc(uid);

  bool _isFirestoreNetworkError(FirebaseException e) {
    switch (e.code) {
      case 'unavailable':
      case 'deadline-exceeded':
      case 'network-request-failed':
        return true;
      default:
        return false;
    }
  }

  /// Подписка на все профили из коллекции `users`.
  Stream<List<UserProfileModel>> watchAllProfiles() {
    return _firestore
        .collection('users')
        .snapshots()
        .map(
          (snapshot) => snapshot.docs.map(UserProfileModel.fromDoc).toList(),
        );
  }

  /// Подписка на документ пользователя. Возвращает `null`, если
  /// документа ещё нет или он пустой — например, сразу после регистрации.
  Stream<UserProfileModel?> watchProfile(String uid) {
    return _doc(uid).snapshots().map((snapshot) {
      if (!snapshot.exists || snapshot.data() == null) return null;
      return UserProfileModel.fromDoc(snapshot);
    });
  }

  /// Разовое чтение документа. `null` — если документ не найден.
  /// При сетевой ошибке пробует только локальный кеш Firestore.
  Future<UserProfileModel?> getProfile(String uid) async {
    DocumentSnapshot<Map<String, dynamic>> snapshot;
    try {
      snapshot = await _doc(uid).get();
    } on FirebaseException catch (e) {
      if (!_isFirestoreNetworkError(e)) {
        rethrow;
      }
      try {
        snapshot = await _doc(uid).get(const GetOptions(source: Source.cache));
      } catch (_) {
        return null;
      }
    }
    if (!snapshot.exists || snapshot.data() == null) return null;
    return UserProfileModel.fromDoc(snapshot);
  }

  /// Создаёт документ только если его ещё нет. Если документ уже есть —
  /// просто выходим, ничего не перезаписываем. Так что дёргать можно
  /// хоть при каждом запуске.
  Future<void> createProfileIfNeeded(UserProfileModel model) async {
    final snapshot = await _doc(model.uid).get();
    if (snapshot.exists) return;
    await _doc(model.uid).set(model.toMapForCreate());
  }

  /// Сохраняет весь документ через merge — поля, которых нет в модели,
  /// в Firestore останутся как были. Удобно для сохранения формы профиля.
  Future<void> updateProfile(UserProfileModel model) async {
    await _doc(model.uid).set(model.toMapForUpdate(), SetOptions(merge: true));
  }

  /// Обновляет только переданные поля + автоматически ставит `updatedAt`.
  /// Подходит, когда нужно поменять 1–2 поля без таскания всей модели.
  Future<void> updateFields({
    required String uid,
    required Map<String, dynamic> fields,
  }) async {
    await _doc(uid).set({
      ...fields,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<void> addFollowing({
    required String uid,
    required String targetUid,
  }) async {
    await _doc(uid).update({
      'followingIds': FieldValue.arrayUnion([targetUid]),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> removeFollowing({
    required String uid,
    required String targetUid,
  }) async {
    await _doc(uid).update({
      'followingIds': FieldValue.arrayRemove([targetUid]),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<List<UserProfileModel>> getFollowers(String uid) async {
    final snapshot =
        await _firestore
            .collection('users')
            .where('followingIds', arrayContains: uid)
            .get();
    return snapshot.docs.map(UserProfileModel.fromDoc).toList();
  }

  /// Число пользователей, у которых в `followingIds` есть [uid] (обновляется в реальном времени).
  Stream<int> watchFollowersCount(String uid) {
    return _firestore
        .collection('users')
        .where('followingIds', arrayContains: uid)
        .snapshots()
        .map((snapshot) => snapshot.docs.length);
  }

  Future<List<UserProfileModel>> searchUsers(String query) async {
    final lower = query.toLowerCase();
    final snapshot = await _firestore.collection('users').get();
    return snapshot.docs
        .map(UserProfileModel.fromDoc)
        .where(
          (m) =>
              (m.displayName?.toLowerCase().contains(lower) ?? false) ||
              (m.email?.toLowerCase().contains(lower) ?? false) ||
              (m.city?.toLowerCase().contains(lower) ?? false),
        )
        .toList();
  }

  Future<List<UserProfileModel>> getProfiles(List<String> uids) async {
    if (uids.isEmpty) return [];

    final results = <UserProfileModel>[];
    final batches = <List<String>>[];
    for (var i = 0; i < uids.length; i += 10) {
      batches.add(uids.sublist(i, i + 10 > uids.length ? uids.length : i + 10));
    }

    for (final batch in batches) {
      final snapshot =
          await _firestore
              .collection('users')
              .where('uid', whereIn: batch)
              .get();

      for (final doc in snapshot.docs) {
        results.add(UserProfileModel.fromDoc(doc));
      }
    }

    return results;
  }
}
