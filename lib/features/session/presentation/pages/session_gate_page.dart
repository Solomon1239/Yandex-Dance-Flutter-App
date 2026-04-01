import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/di/service_locator.dart';
import '../managers/app_session_manager.dart';
import '../state/app_session_state.dart';

class SessionGatePage extends StatefulWidget {
  const SessionGatePage({super.key});

  @override
  State<SessionGatePage> createState() => _SessionGatePageState();
}

class _SessionGatePageState extends State<SessionGatePage> {
  late final AppSessionManager _manager;
  StreamSubscription<AppSessionState>? _sessionSubscription;

  @override
  void initState() {
    super.initState();
    _manager = sl<AppSessionManager>();

    _sessionSubscription = _manager.stream.listen(_handleState);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _handleState(_manager.state);
    });
  }

  void _handleState(AppSessionState state) {
    if (!mounted) return;

    switch (state.status) {
      case AppSessionStatus.checking:
        break;
      case AppSessionStatus.guest:
        context.go('/auth');
        break;
      case AppSessionStatus.needsStyleSelection:
        context.go('/styles');
        break;
      case AppSessionStatus.authorized:
        context.go('/profile');
        break;
    }
  }

  @override
  void dispose() {
    _sessionSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}
