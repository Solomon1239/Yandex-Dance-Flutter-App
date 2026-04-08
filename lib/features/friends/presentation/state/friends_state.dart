import 'package:equatable/equatable.dart';
import 'package:yandex_dance/features/profile/domain/entities/user_profile.dart';

enum FriendsStatus { loading, ready, error }

class FriendsState extends Equatable {
  const FriendsState({
    this.status = FriendsStatus.loading,
    this.following = const [],
    this.followers = const [],
    this.errorMessage,
  });

  final FriendsStatus status;
  final List<UserProfile> following;
  final List<UserProfile> followers;
  final String? errorMessage;

  FriendsState copyWith({
    FriendsStatus? status,
    List<UserProfile>? following,
    List<UserProfile>? followers,
    String? errorMessage,
    bool clearError = false,
  }) {
    return FriendsState(
      status: status ?? this.status,
      following: following ?? this.following,
      followers: followers ?? this.followers,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  List<Object?> get props => [status, following, followers, errorMessage];
}
