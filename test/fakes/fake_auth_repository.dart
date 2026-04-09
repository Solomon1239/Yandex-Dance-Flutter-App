import 'package:yandex_dance/features/auth/domain/entities/auth_session.dart';
import 'package:yandex_dance/features/auth/domain/repositories/auth_repository.dart';

/// Минимальная заглушка для UI-тестов [AuthPage] без Firebase.
class FakeAuthRepository implements AuthRepository {
  @override
  Stream<AuthSession?> authStateChanges() => const Stream.empty();

  @override
  String? get currentUserId => null;

  @override
  AuthSession? get currentSession => null;

  @override
  Future<void> deleteCurrentUser() async {}

  @override
  Future<void> signInWithApple() async {}

  @override
  Future<void> signInWithEmail({
    required String email,
    required String password,
  }) async {}

  @override
  Future<void> signInWithGoogle() async {}

  @override
  Future<void> signOut() async {}

  @override
  Future<void> signUpWithEmail({
    required String email,
    required String password,
  }) async {}
}
