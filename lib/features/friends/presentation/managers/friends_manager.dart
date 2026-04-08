import 'package:yandex_dance/core/errors/app_exception.dart';
import 'package:yandex_dance/features/auth/domain/repositories/auth_repository.dart';
import 'package:yandex_dance/features/friends/domain/repositories/friend_repository.dart';
import 'package:yandex_dance/features/friends/presentation/state/friends_state.dart';
import 'package:yx_state/yx_state.dart';

class FriendsManager extends StateManager<FriendsState> {
  FriendsManager({
    required FriendRepository friendRepository,
    required AuthRepository authRepository,
  })  : _friendRepository = friendRepository,
       _authRepository = authRepository,
       super(const FriendsState());

  final FriendRepository _friendRepository;
  final AuthRepository _authRepository;

  String? get _currentUid => _authRepository.currentUserId;

  Future<void> start() {
    return handle((emit) async {
      final uid = _currentUid;
      if (uid == null) return;

      emit(state.copyWith(status: FriendsStatus.loading, clearError: true));

      try {
        final following = await _friendRepository.getFollowing(uid);
        final followers = await _friendRepository.getFollowers(uid);
        emit(state.copyWith(
          status: FriendsStatus.ready,
          following: following,
          followers: followers,
        ));
      } on AppException catch (e, stackTrace) {
        addError(e, stackTrace, 'friends.start');
        emit(state.copyWith(
          status: FriendsStatus.error,
          errorMessage: e.message,
        ));
      }
    }, identifier: 'friends.start');
  }

  Future<void> follow(String targetUid) {
    return handle((emit) async {
      final uid = _currentUid;
      if (uid == null) return;

      try {
        await _friendRepository.follow(uid: uid, targetUid: targetUid);
        final following = await _friendRepository.getFollowing(uid);
        emit(state.copyWith(following: following));
      } on AppException catch (e, stackTrace) {
        addError(e, stackTrace, 'friends.follow');
        emit(state.copyWith(errorMessage: e.message));
      }
    }, identifier: 'friends.follow');
  }

  Future<void> unfollow(String targetUid) {
    return handle((emit) async {
      final uid = _currentUid;
      if (uid == null) return;

      try {
        await _friendRepository.unfollow(uid: uid, targetUid: targetUid);
        final following = await _friendRepository.getFollowing(uid);
        emit(state.copyWith(following: following));
      } on AppException catch (e, stackTrace) {
        addError(e, stackTrace, 'friends.unfollow');
        emit(state.copyWith(errorMessage: e.message));
      }
    }, identifier: 'friends.unfollow');
  }
}
