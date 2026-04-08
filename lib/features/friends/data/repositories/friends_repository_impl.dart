import 'package:yandex_dance/features/friends/data/datasources/friends_data_source.dart';
import 'package:yandex_dance/features/friends/domain/entities/friend_coach.dart';
import 'package:yandex_dance/features/friends/domain/repositories/friends_repository.dart';

class FriendsRepositoryImpl implements FriendsRepository {
  FriendsRepositoryImpl(this._dataSource);

  final FriendsDataSource _dataSource;

  @override
  Future<List<FriendCoach>> getCoaches() async {
    final models = await _dataSource.fetchCoaches();
    return models.map((m) => m.toEntity()).toList(growable: false);
  }

  @override
  Future<FriendCoach?> getCoachById(String id) async {
    final model = await _dataSource.getCoach(id);
    return model?.toEntity();
  }
}
