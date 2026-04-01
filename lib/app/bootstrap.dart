import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import '../features/session/presentation/managers/app_session_manager.dart';
import '../firebase_options.dart';
import 'app.dart';
import 'di/service_locator.dart';
import 'observer/app_state_observer.dart';
import 'package:google_sign_in/google_sign_in.dart';

Future<void> bootstrap() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  await configureDependencies();
  await sl<GoogleSignIn>().initialize();
  setupStateObserver();

  sl<AppSessionManager>().start();

  runApp(const DanceApp());
}
