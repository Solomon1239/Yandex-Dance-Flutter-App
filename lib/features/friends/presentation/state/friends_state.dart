import 'package:equatable/equatable.dart';
import 'package:yandex_dance/features/friends/domain/entities/friend_request.dart';
import 'package:yandex_dance/features/profile/domain/entities/user_profile.dart';

enum FriendsStatus { loading, ready, error }

class FriendsState extends Equatable {
  const FriendsState({
    this.status = FriendsStatus.loading,
    this.friends = const [],
    this.incomingRequests = const [],
    this.outgoingRequests = const [],
    this.errorMessage,
  });

  final FriendsStatus status;
  final List<UserProfile> friends;
  final List<FriendRequest> incomingRequests;
  final List<FriendRequest> outgoingRequests;
  final String? errorMessage;

  FriendsState copyWith({
    FriendsStatus? status,
    List<UserProfile>? friends,
    List<FriendRequest>? incomingRequests,
    List<FriendRequest>? outgoingRequests,
    String? errorMessage,
    bool clearError = false,
  }) {
    return FriendsState(
      status: status ?? this.status,
      friends: friends ?? this.friends,
      incomingRequests: incomingRequests ?? this.incomingRequests,
      outgoingRequests: outgoingRequests ?? this.outgoingRequests,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  List<Object?> get props => [
        status,
        friends,
        incomingRequests,
        outgoingRequests,
        errorMessage,
      ];
}
