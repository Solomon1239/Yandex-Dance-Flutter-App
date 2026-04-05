import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:yandex_dance/features/events/data/models/dance_event_model.dart';

/// Тонкий слой поверх Firestore для коллекции `events`.
/// Отвечает только за CRUD-операции над документами — никакого Storage,
/// никакой загрузки файлов. Всё, что сложнее одного обращения к
/// Firestore, живёт в `EventRepositoryImpl`.
class EventRemoteDataSource {
  EventRemoteDataSource({required FirebaseFirestore firestore})
    : _firestore = firestore;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _collection =>
      _firestore.collection('events');

  DocumentReference<Map<String, dynamic>> _doc(String id) =>
      _collection.doc(id);

  /// Стрим всей коллекции, отсортированной по дате (от ранних к поздних).
  /// Обновляется автоматически при любых изменениях на сервере.
  Stream<List<DanceEventModel>> watchAllEvents() {
    return _collection
        .orderBy('dateTime', descending: false)
        .snapshots()
        .map((snapshot) => snapshot.docs.map(DanceEventModel.fromDoc).toList());
  }

  /// Стрим только тех мероприятий, где в `participantIds` есть uid.
  /// ВАЖНО: Firestore'у нужен составной индекс по полям
  /// (participantIds, dateTime) — если его нет, стрим упадёт
  /// с ошибкой и в логе будет ссылка на создание индекса.
  Stream<List<DanceEventModel>> watchUserEvents(String uid) {
    return _collection
        .where('participantIds', arrayContains: uid)
        .orderBy('dateTime', descending: false)
        .snapshots()
        .map((snapshot) => snapshot.docs.map(DanceEventModel.fromDoc).toList());
  }

  /// Разовое чтение мероприятия по id. `null` — если документа нет.
  Future<DanceEventModel?> getEvent(String eventId) async {
    final snapshot = await _doc(eventId).get();
    if (!snapshot.exists || snapshot.data() == null) return null;
    return DanceEventModel.fromDoc(snapshot);
  }

  /// Создаёт документ в коллекции — id генерит Firestore сам.
  /// Возвращает этот новый id, чтобы можно было подтянуть только что
  /// созданное мероприятие или привязать к нему файлы.
  Future<String> createEvent(DanceEventModel model) async {
    final docRef = await _collection.add(model.toMapForCreate());
    return docRef.id;
  }

  /// Сохраняет изменения через merge — поля, не указанные в модели,
  /// в Firestore останутся как были.
  Future<void> updateEvent(DanceEventModel model) async {
    await _doc(model.id).set(model.toMapForUpdate(), SetOptions(merge: true));
  }

  /// Просто удаляет документ. Файлы в Storage этот метод НЕ трогает —
  /// их чистит `EventRepositoryImpl.deleteEvent`.
  Future<void> deleteEvent(String eventId) async {
    await _doc(eventId).delete();
  }

  /// Добавляет uid в `participantIds` через `arrayUnion`,
  /// так что повторный вызов с тем же uid не задублит запись.
  /// Заодно обновляет `updatedAt`.
  Future<void> addParticipant({
    required String eventId,
    required String uid,
  }) async {
    await _doc(eventId).update({
      'participantIds': FieldValue.arrayUnion([uid]),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Убирает uid из `participantIds` через `arrayRemove`.
  /// Если uid там не было — ничего страшного не произойдёт.
  Future<void> removeParticipant({
    required String eventId,
    required String uid,
  }) async {
    await _doc(eventId).update({
      'participantIds': FieldValue.arrayRemove([uid]),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }
}
