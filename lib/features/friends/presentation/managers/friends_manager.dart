import 'package:yandex_dance/core/errors/app_exception.dart';
import 'package:yandex_dance/features/auth/domain/repositories/auth_repository.dart';
import 'package:yandex_dance/features/friends/domain/repositories/friend_repository.dart';
import 'package:yandex_dance/features/friends/presentation/state/friends_state.dart';
import 'package:yandex_dance/features/profile/domain/entities/user_profile.dart';
import 'package:yandex_dance/features/profile/domain/repositories/profile_repository.dart';
import 'package:yx_state/yx_state.dart';

class FriendsManager extends StateManager<FriendsState> {
  FriendsManager({
    required FriendRepository friendRepository,
    required AuthRepository authRepository,
    required ProfileRepository profileRepository,
  })  : _friendRepository = friendRepository,
        _authRepository = authRepository,
        _profileRepository = profileRepository,
        super(const FriendsState());

  final FriendRepository _friendRepository;
  final AuthRepository _authRepository;
  final ProfileRepository _profileRepository;

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

  /// Поиск пользователей по имени или email ([ProfileRepository.searchUsers]).
  Future<void> searchUsers(String query) async {
    return handle((emit) async {
      final q = query.trim();
      if (q.isEmpty) {
        emit(state.copyWith(searchResults: const [], searchLoading: false));
        return;
      }

      emit(state.copyWith(searchLoading: true, clearError: true));

      try {
        final results = await _profileRepository.searchUsers(q);
        final uid = _currentUid;
        final filtered =
            uid == null
                ? results
                : results.where((p) => p.uid != uid).toList();
        emit(state.copyWith(
          searchResults: filtered,
          searchLoading: false,
        ));
      } on AppException catch (e, stackTrace) {
        addError(e, stackTrace, 'friends.search');
        emit(state.copyWith(
          searchLoading: false,
          errorMessage: e.message,
        ));
      } catch (e, stackTrace) {
        addError(e, stackTrace, 'friends.search');
        emit(state.copyWith(
          searchLoading: false,
          errorMessage: 'Не удалось выполнить поиск',
        ));
      }
    }, identifier: 'friends.search');
  }

  Future<void> follow(String targetUid) {
    return handle((emit) async {
      final uid = _currentUid;
      if (uid == null) return;

      try {
        await _friendRepository.follow(uid: uid, targetUid: targetUid);
        final following = await _friendRepository.getFollowing(uid);
        final followers = await _friendRepository.getFollowers(uid);
        emit(state.copyWith(following: following, followers: followers));
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

      final previousFollowing = List<UserProfile>.from(state.following);
      emit(state.copyWith(
        following: state.following.where((u) => u.uid != targetUid).toList(),
        clearError: true,
      ));

      try {
        await _friendRepository.unfollow(uid: uid, targetUid: targetUid);
        var following = await _friendRepository.getFollowing(uid);
        following = following.where((u) => u.uid != targetUid).toList();
        final followers = await _friendRepository.getFollowers(uid);
        emit(state.copyWith(following: following, followers: followers));
      } on AppException catch (e, stackTrace) {
        addError(e, stackTrace, 'friends.unfollow');
        emit(state.copyWith(
          following: previousFollowing,
          errorMessage: e.message,
        ));
      } catch (e, stackTrace) {
        addError(e, stackTrace, 'friends.unfollow');
        emit(state.copyWith(following: previousFollowing));
      }
    }, identifier: 'friends.unfollow');
  }
}
