import 'package:flutter_test/flutter_test.dart';
import 'package:yandex_dance/core/enums/dance_style.dart';
import 'package:yandex_dance/features/auth/domain/entities/auth_session.dart';
import 'package:yandex_dance/features/profile/domain/entities/user_profile.dart';
import 'package:yandex_dance/features/session/presentation/state/app_session_state.dart';

void main() {
  group('AppSessionState', () {
    test('copyWith сохраняет session при смене status', () {
      const session = AuthSession(uid: 'u1');
      const state = AppSessionState(
        status: AppSessionStatus.checking,
        session: session,
      );
      final next = state.copyWith(status: AppSessionStatus.authorized);
      expect(next.status, AppSessionStatus.authorized);
      expect(next.session, session);
    });

    test('copyWith(clearProfile: true) обнуляет profile', () {
      const session = AuthSession(uid: 'u1');
      final profile = UserProfile(
        uid: 'u1',
        danceStyles: const [DanceStyle.house],
        onboardingCompleted: true,
      );
      final state = AppSessionState(
        status: AppSessionStatus.authorized,
        session: session,
        profile: profile,
      );
      final cleared = state.copyWith(clearProfile: true);
      expect(cleared.profile, isNull);
      expect(cleared.session, session);
    });
  });
}
