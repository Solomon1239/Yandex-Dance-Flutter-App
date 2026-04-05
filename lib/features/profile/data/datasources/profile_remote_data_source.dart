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
}
