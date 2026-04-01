import 'package:yandex_dance/core/errors/app_exception.dart';
import 'package:yandex_dance/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:yandex_dance/features/auth/domain/entities/auth_session.dart';
import 'package:yandex_dance/features/auth/domain/repositories/auth_repository.dart';
import 'package:yandex_dance/features/profile/domain/repositories/profile_repository.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl({
    required AuthRemoteDataSource remote,
    required ProfileRepository profileRepository,
  }) : _remote = remote,
       _profileRepository = profileRepository;

  final AuthRemoteDataSource _remote;
  final ProfileRepository _profileRepository;

  @override
  Stream<AuthSession?> authStateChanges() {
    return _remote.authStateChanges().map((user) {
      if (user == null) return null;
      return _mapUser(user);
    });
  }

  @override
  String? get currentUserId => _remote.currentUserId;

  @override
  Future<void> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      await _remote.signInWithEmail(email: email, password: password);
    } on FirebaseAuthException catch (e) {
      throw AppException.auth(_mapFirebaseAuthMessage(e));
    } on AuthCancelledException {
      throw const AppException.cancelled('Вход отменен');
    } catch (_) {
      throw const AppException.unknown('Не удалось войти');
    }
  }

  @override
  Future<void> signUpWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _remote.signUpWithEmail(
        email: email,
        password: password,
      );

      final user = credential.user;
      if (user != null) {
        await _profileRepository.createProfileIfNeeded(
          uid: user.uid,
          email: user.email,
          displayName: user.displayName,
          photoUrl: user.photoURL,
        );
      }
    } on FirebaseAuthException catch (e) {
      throw AppException.auth(_mapFirebaseAuthMessage(e));
    } catch (_) {
      throw const AppException.unknown('Не удалось зарегистрироваться');
    }
  }

  @override
  Future<void> signInWithGoogle() async {
    try {
      final credential = await _remote.signInWithGoogle();
      final user = credential.user;

      if (user != null) {
        await _profileRepository.createProfileIfNeeded(
          uid: user.uid,
          email: user.email,
          displayName: user.displayName,
          photoUrl: user.photoURL,
        );
      }
    } on FirebaseAuthException catch (e) {
      throw AppException.auth(_mapFirebaseAuthMessage(e));
    } on AuthCancelledException {
      throw const AppException.cancelled('Google-вход отменен');
    } catch (_) {
      throw const AppException.unknown('Не удалось войти через Google');
    }
  }

  @override
  Future<void> signInWithApple() async {
    try {
      final credential = await _remote.signInWithApple();
      final user = credential.user;

      if (user != null) {
        await _profileRepository.createProfileIfNeeded(
          uid: user.uid,
          email: user.email,
          displayName: user.displayName,
          photoUrl: user.photoURL,
        );
      }
    } on FirebaseAuthException catch (e) {
      throw AppException.auth(_mapFirebaseAuthMessage(e));
    } on AuthCancelledException {
      throw const AppException.cancelled('Apple-вход отменен');
    } catch (_) {
      throw const AppException.unknown('Не удалось войти через Apple');
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await _remote.signOut();
    } catch (_) {
      throw const AppException.unknown('Не удалось выйти из аккаунта');
    }
  }

  AuthSession _mapUser(User user) {
    return AuthSession(
      uid: user.uid,
      email: user.email,
      displayName: user.displayName,
      photoUrl: user.photoURL,
    );
  }

  String _mapFirebaseAuthMessage(FirebaseAuthException e) {
    switch (e.code) {
      case 'invalid-email':
        return 'Некорректный email';
      case 'user-not-found':
      case 'wrong-password':
      case 'invalid-credential':
        return 'Неверный email или пароль';
      case 'email-already-in-use':
        return 'Этот email уже используется';
      case 'weak-password':
        return 'Слишком слабый пароль';
      case 'network-request-failed':
        return 'Нет сети';
      default:
        return e.message ?? 'Ошибка авторизации';
    }
  }
}
