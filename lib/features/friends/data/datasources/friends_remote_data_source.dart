import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:yandex_dance/features/friends/data/datasources/friends_data_source.dart';
import 'package:yandex_dance/features/friends/data/models/friend_coach_model.dart';

/// Чтение коллекции `coaches` в Firestore.
class FriendsRemoteDataSource implements FriendsDataSource {
  FriendsRemoteDataSource({required FirebaseFirestore firestore})
    : _firestore = firestore;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _collection =>
      _firestore.collection('coaches');

  DocumentReference<Map<String, dynamic>> _doc(String id) =>
      _collection.doc(id);

  /// Все документы коллекции (без фильтров на стороне сервера).
  @override
  Future<List<FriendCoachModel>> fetchCoaches() async {
    final snapshot = await _collection.get();
    final list = <FriendCoachModel>[];
    for (final doc in snapshot.docs) {
      try {
        list.add(FriendCoachModel.fromDoc(doc));
      } catch (_) {
        // Пропускаем повреждённые документы, чтобы не падал весь список.
      }
    }
    list.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
    return list;
  }

  /// Один тренер по id документа.
  @override
  Future<FriendCoachModel?> getCoach(String id) async {
    final snapshot = await _doc(id).get();
    if (!snapshot.exists || snapshot.data() == null) return null;
    return FriendCoachModel.fromDoc(snapshot);
  }
}
