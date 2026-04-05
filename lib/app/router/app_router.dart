import 'package:go_router/go_router.dart';
import 'package:yandex_dance/app/di/service_locator.dart';
import 'package:yandex_dance/app/router/go_router_refresh_stream.dart';
import 'package:yandex_dance/app/shell/main_shell.dart';
import 'package:yandex_dance/features/auth/presentation/pages/auth_page.dart';
import 'package:yandex_dance/features/create_event/presentation/screen/create_event_screen.dart';
import 'package:yandex_dance/features/events/presentation/pages/events_page.dart';
import 'package:yandex_dance/features/events/presentation/pages/upcoming_events_page.dart';
import 'package:yandex_dance/features/friends/presentation/pages/friends_page.dart';
import 'package:yandex_dance/features/profile/presentation/pages/edit_profile_page.dart';
import 'package:yandex_dance/features/profile/presentation/pages/profile_page.dart';
import 'package:yandex_dance/features/session/presentation/managers/app_session_manager.dart';
import 'package:yandex_dance/features/session/presentation/pages/session_gate_page.dart';
import 'package:yandex_dance/features/session/presentation/state/app_session_state.dart';
import 'package:yandex_dance/features/style_selection/presentation/pages/style_selection_page.dart';

const _guestRoutes = {'/auth', '/styles'};

const _authorizedOnlyRoutes = {
  '/upcoming',
  '/events',
  '/friends',
  '/profile',
  '/profile/edit',
  '/create',
};

final appRouter = GoRouter(
  initialLocation: const bool.fromEnvironment('DEV_INPUT') ? '/dev/input' : '/',
  refreshListenable: GoRouterRefreshStream(sl<AppSessionManager>().stream),
  redirect: _redirect,
  routes: [
    GoRoute(path: '/', builder: (context, state) => const SessionGatePage()),
    GoRoute(path: '/auth', builder: (context, state) => const AuthPage()),
    GoRoute(
      path: '/dev/input',
      builder: (context, state) => const CreateEventScreen(),
    ),
    GoRoute(
      path: '/styles',
      builder: (context, state) => const StyleSelectionPage(),
    ),
    GoRoute(
      path: '/profile/edit',
      builder: (context, state) => const EditProfilePage(),
    ),
    GoRoute(
      path: '/create',
      builder: (context, state) => const CreateEventScreen(),
    ),
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        return MainShell(navigationShell: navigationShell);
      },
      branches: [
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/upcoming',
              builder: (context, state) => const UpcomingEventsPage(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/events',
              builder: (context, state) => const EventsPage(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/friends',
              builder: (context, state) => const FriendsPage(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/profile',
              builder: (context, state) => const ProfilePage(),
            ),
          ],
        ),
      ],
    ),
  ],
);

String? _redirect(_, GoRouterState state) {
  final location = state.matchedLocation;
  if (location.startsWith('/dev')) return null;

  final status = sl<AppSessionManager>().state.status;

  switch (status) {
    case AppSessionStatus.checking:
      return null;

    case AppSessionStatus.guest:
      if (_guestRoutes.contains(location)) return null;
      return '/auth';

    case AppSessionStatus.needsStyleSelection:
      return location == '/styles' ? null : '/styles';

    case AppSessionStatus.authorized:
      if (_authorizedOnlyRoutes.contains(location)) return null;
      return '/upcoming';
  }
}
