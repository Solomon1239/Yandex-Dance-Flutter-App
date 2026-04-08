import 'package:yandex_dance/features/friends/data/models/friend_coach_model.dart';

/// Источник списка тренеров (Firestore, моки и т.д.).
abstract interface class FriendsDataSource {
  Future<List<FriendCoachModel>> fetchCoaches();

  Future<FriendCoachModel?> getCoach(String id);
}
