import 'package:yandex_dance/features/auth/presentation/pages/auth_page.dart';
import 'package:yandex_dance/features/create_event/presentation/screen/create_event_screen.dart';
import 'package:yandex_dance/features/profile/presentation/pages/edit_profile_page.dart';
import 'package:yandex_dance/features/profile/presentation/pages/profile_page.dart';
import 'package:yandex_dance/features/session/presentation/pages/session_gate_page.dart';
import 'package:yandex_dance/features/style_selection/presentation/pages/style_selection_page.dart';
import 'package:go_router/go_router.dart';

final appRouter = GoRouter(
  initialLocation: const bool.fromEnvironment('DEV_INPUT') ? '/dev/input' : '/',
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
    GoRoute(path: '/profile', builder: (context, state) => const ProfilePage()),
    GoRoute(
      path: '/profile/edit',
      builder: (context, state) => const EditProfilePage(),
    ),
  ],
);
