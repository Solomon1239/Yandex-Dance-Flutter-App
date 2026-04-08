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

  /// Подписка на документ пользователя. Возвращает `null`, если
  /// документа ещё нет или он пустой — например, сразу после регистрации.
  Stream<UserProfileModel?> watchProfile(String uid) {
    return _doc(uid).snapshots().map((snapshot) {
      if (!snapshot.exists || snapshot.data() == null) return null;
      return UserProfileModel.fromDoc(snapshot);
    });
  }

  /// Разовое чтение документа. `null` — если документ не найден.
  Future<UserProfileModel?> getProfile(String uid) async {
    final snapshot = await _doc(uid).get();
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

  Future<void> addFriend({
    required String uid,
    required String friendUid,
  }) async {
    await _doc(uid).update({
      'friendIds': FieldValue.arrayUnion([friendUid]),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> removeFriend({
    required String uid,
    required String friendUid,
  }) async {
    await _doc(uid).update({
      'friendIds': FieldValue.arrayRemove([friendUid]),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> setRating({
    required String targetUid,
    required String raterUid,
    required double value,
  }) async {
    await _doc(targetUid)
        .collection('ratings')
        .doc(raterUid)
        .set({
      'value': value,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<double?> getRatingByRater({
    required String targetUid,
    required String raterUid,
  }) async {
    final doc = await _doc(targetUid)
        .collection('ratings')
        .doc(raterUid)
        .get();
    if (!doc.exists || doc.data() == null) return null;
    return (doc.data()!['value'] as num?)?.toDouble();
  }

  Future<({double average, int count})> recalculateRating(
    String targetUid,
  ) async {
    final snapshot = await _doc(targetUid).collection('ratings').get();
    if (snapshot.docs.isEmpty) return (average: 0.0, count: 0);

    double sum = 0;
    for (final doc in snapshot.docs) {
      sum += (doc.data()['value'] as num).toDouble();
    }
    final count = snapshot.docs.length;
    final average = sum / count;

    await updateFields(
      uid: targetUid,
      fields: {'rating': average, 'ratingCount': count},
    );

    return (average: average, count: count);
  }

  Future<List<UserProfileModel>> getProfiles(List<String> uids) async {
    if (uids.isEmpty) return [];

    final results = <UserProfileModel>[];
    final batches = <List<String>>[];
    for (var i = 0; i < uids.length; i += 10) {
      batches.add(uids.sublist(i, i + 10 > uids.length ? uids.length : i + 10));
    }

    for (final batch in batches) {
      final snapshot = await _firestore
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
