import 'package:equatable/equatable.dart';
import 'package:yandex_dance/features/events/domain/entities/dance_event.dart';
import 'package:yandex_dance/features/profile/domain/entities/user_profile.dart';

enum ProfileStatus { loading, ready, error }

class ProfileState extends Equatable {
  const ProfileState({
    this.status = ProfileStatus.loading,
    this.profile,
    this.events = const [],
    this.errorMessage,
  });

  final ProfileStatus status;
  final UserProfile? profile;
  final List<DanceEvent> events;
  final String? errorMessage;

  ProfileState copyWith({
    ProfileStatus? status,
    UserProfile? profile,
    List<DanceEvent>? events,
    String? errorMessage,
    bool clearError = false,
  }) {
    return ProfileState(
      status: status ?? this.status,
      profile: profile ?? this.profile,
      events: events ?? this.events,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  List<Object?> get props => [status, profile, events, errorMessage];
}
