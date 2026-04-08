import 'package:yandex_dance/features/friends/domain/entities/friend_coach.dart';

/// Список тренеров и карточка по id. Реализация может быть моком или API/Firestore.
abstract interface class FriendsRepository {
  Future<List<FriendCoach>> getCoaches();

  Future<FriendCoach?> getCoachById(String id);
}
