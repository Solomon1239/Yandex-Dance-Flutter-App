import 'package:yandex_dance/features/auth/domain/entities/auth_session.dart';

abstract interface class AuthRepository {
  Stream<AuthSession?> authStateChanges();

  String? get currentUserId;

  AuthSession? get currentSession;

  Future<void> signInWithEmail({
    required String email,
    required String password,
  });

  Future<void> signUpWithEmail({
    required String email,
    required String password,
  });

  Future<void> signInWithGoogle();

  Future<void> signInWithApple();

  Future<void> signOut();

  Future<void> deleteCurrentUser();
}
