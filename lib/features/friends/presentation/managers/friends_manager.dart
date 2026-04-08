import 'dart:async';

import 'package:yandex_dance/core/errors/app_exception.dart';
import 'package:yandex_dance/features/auth/domain/repositories/auth_repository.dart';
import 'package:yandex_dance/features/friends/domain/repositories/friend_repository.dart';
import 'package:yandex_dance/features/friends/presentation/state/friends_state.dart';
import 'package:yandex_dance/features/profile/domain/repositories/profile_repository.dart';
import 'package:yx_state/yx_state.dart';

class FriendsManager extends StateManager<FriendsState> {
  FriendsManager({
    required FriendRepository friendRepository,
    required ProfileRepository profileRepository,
    required AuthRepository authRepository,
  })  : _friendRepository = friendRepository,
       _profileRepository = profileRepository,
       _authRepository = authRepository,
       super(const FriendsState());

  final FriendRepository _friendRepository;
  final ProfileRepository _profileRepository;
  final AuthRepository _authRepository;

  StreamSubscription? _incomingSub;
  StreamSubscription? _outgoingSub;

  String? get _currentUid => _authRepository.currentUserId;

  Future<void> start() {
    return handle((emit) async {
      final uid = _currentUid;
      if (uid == null) return;

      emit(state.copyWith(status: FriendsStatus.loading, clearError: true));

      try {
        final friends = await _friendRepository.getFriends(uid);
        emit(state.copyWith(
          status: FriendsStatus.ready,
          friends: friends,
        ));

        _incomingSub?.cancel();
        _incomingSub = _friendRepository
            .watchIncomingRequests(uid)
            .listen((requests) {
          handle((emit) async {
            emit(state.copyWith(incomingRequests: requests));
          }, identifier: 'friends.incomingUpdate');
        });

        _outgoingSub?.cancel();
        _outgoingSub = _friendRepository
            .watchOutgoingRequests(uid)
            .listen((requests) {
          handle((emit) async {
            emit(state.copyWith(outgoingRequests: requests));
          }, identifier: 'friends.outgoingUpdate');
        });
      } on AppException catch (e, stackTrace) {
        addError(e, stackTrace, 'friends.start');
        emit(state.copyWith(
          status: FriendsStatus.error,
          errorMessage: e.message,
        ));
      }
    }, identifier: 'friends.start');
  }

  Future<void> sendRequest(String toUid) {
    return handle((emit) async {
      final uid = _currentUid;
      if (uid == null) return;

      try {
        await _friendRepository.sendRequest(fromUid: uid, toUid: toUid);
      } on AppException catch (e, stackTrace) {
        addError(e, stackTrace, 'friends.sendRequest');
        emit(state.copyWith(errorMessage: e.message));
      }
    }, identifier: 'friends.sendRequest');
  }

  Future<void> acceptRequest(String requestId) {
    return handle((emit) async {
      final uid = _currentUid;
      if (uid == null) return;

      try {
        await _friendRepository.acceptRequest(requestId);
        final friends = await _friendRepository.getFriends(uid);
        emit(state.copyWith(friends: friends));
      } on AppException catch (e, stackTrace) {
        addError(e, stackTrace, 'friends.acceptRequest');
        emit(state.copyWith(errorMessage: e.message));
      }
    }, identifier: 'friends.acceptRequest');
  }

  Future<void> rejectRequest(String requestId) {
    return handle((emit) async {
      try {
        await _friendRepository.rejectRequest(requestId);
      } on AppException catch (e, stackTrace) {
        addError(e, stackTrace, 'friends.rejectRequest');
        emit(state.copyWith(errorMessage: e.message));
      }
    }, identifier: 'friends.rejectRequest');
  }

  Future<void> removeFriend(String friendUid) {
    return handle((emit) async {
      final uid = _currentUid;
      if (uid == null) return;

      try {
        await _friendRepository.removeFriend(uid: uid, friendUid: friendUid);
        final friends = await _friendRepository.getFriends(uid);
        emit(state.copyWith(friends: friends));
      } on AppException catch (e, stackTrace) {
        addError(e, stackTrace, 'friends.removeFriend');
        emit(state.copyWith(errorMessage: e.message));
      }
    }, identifier: 'friends.removeFriend');
  }

  Future<void> rateUser({
    required String targetUid,
    required double value,
  }) {
    return handle((emit) async {
      final uid = _currentUid;
      if (uid == null) return;

      try {
        await _profileRepository.rateUser(
          targetUid: targetUid,
          raterUid: uid,
          value: value,
        );
        final friends = await _friendRepository.getFriends(uid);
        emit(state.copyWith(friends: friends));
      } on AppException catch (e, stackTrace) {
        addError(e, stackTrace, 'friends.rateUser');
        emit(state.copyWith(errorMessage: e.message));
      }
    }, identifier: 'friends.rateUser');
  }

  @override
  Future<void> close() async {
    _incomingSub?.cancel();
    _outgoingSub?.cancel();
    return super.close();
  }
}
