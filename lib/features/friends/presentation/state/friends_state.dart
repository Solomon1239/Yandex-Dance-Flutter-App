import 'package:equatable/equatable.dart';
import 'package:yandex_dance/features/profile/domain/entities/user_profile.dart';

enum FriendsStatus { loading, ready, error }

class FriendsState extends Equatable {
  const FriendsState({
    this.status = FriendsStatus.loading,
    this.following = const [],
    this.followers = const [],
    this.searchResults = const [],
    this.searchLoading = false,
    this.errorMessage,
  });

  final FriendsStatus status;
  final List<UserProfile> following;
  final List<UserProfile> followers;
  final List<UserProfile> searchResults;
  final bool searchLoading;
  final String? errorMessage;

  FriendsState copyWith({
    FriendsStatus? status,
    List<UserProfile>? following,
    List<UserProfile>? followers,
    List<UserProfile>? searchResults,
    bool? searchLoading,
    String? errorMessage,
    bool clearError = false,
  }) {
    return FriendsState(
      status: status ?? this.status,
      following: following ?? this.following,
      followers: followers ?? this.followers,
      searchResults: searchResults ?? this.searchResults,
      searchLoading: searchLoading ?? this.searchLoading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  List<Object?> get props => [
    status,
    following,
    followers,
    searchResults,
    searchLoading,
    errorMessage,
  ];
}
