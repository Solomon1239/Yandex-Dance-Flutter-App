import 'package:yandex_dance/features/auth/domain/entities/auth_session.dart';
import 'package:yandex_dance/features/profile/domain/entities/user_profile.dart';
import 'package:equatable/equatable.dart';

enum AppSessionStatus { checking, guest, needsStyleSelection, authorized }

class AppSessionState extends Equatable {
  const AppSessionState({
    this.status = AppSessionStatus.checking,
    this.session,
    this.profile,
  });

  final AppSessionStatus status;
  final AuthSession? session;
  final UserProfile? profile;

  AppSessionState copyWith({
    AppSessionStatus? status,
    AuthSession? session,
    UserProfile? profile,
    bool clearProfile = false,
  }) {
    return AppSessionState(
      status: status ?? this.status,
      session: session ?? this.session,
      profile: clearProfile ? null : (profile ?? this.profile),
    );
  }

  @override
  List<Object?> get props => [status, session, profile];
}
