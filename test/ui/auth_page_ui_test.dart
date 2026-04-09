import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:yandex_dance/app/di/service_locator.dart';
import 'package:yandex_dance/core/theme/app_theme.dart';
import 'package:yandex_dance/features/auth/domain/repositories/auth_repository.dart';
import 'package:yandex_dance/features/auth/presentation/managers/auth_manager.dart';
import 'package:yandex_dance/features/auth/presentation/pages/auth_page.dart';

import '../fakes/fake_auth_repository.dart';
import '../helpers/test_binding.dart';

void main() {
  setUpAll(ensureTestWidgetsBinding);

  group('AuthPage (UI)', () {
    setUp(() async {
      await sl.reset();
      sl.registerLazySingleton<AuthRepository>(() => FakeAuthRepository());
      sl.registerFactory<AuthManager>(() => AuthManager(sl<AuthRepository>()));
    });

    tearDown(() async {
      await sl.reset();
    });

    testWidgets('показывает заголовок и переключатель вход/регистрация', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.dark(),
          home: const AuthPage(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.textContaining('Заходи'), findsOneWidget);
      expect(find.text('Войти'), findsWidgets);
      expect(find.text('Регистрация'), findsOneWidget);
    });

    testWidgets('переключение на регистрацию', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.dark(),
          home: const AuthPage(),
        ),
      );
      await tester.pump();

      await tester.tap(find.text('Регистрация'));
      await tester.pumpAndSettle();

      expect(find.text('Подтверждение пароля'), findsOneWidget);
      expect(find.text('Создать аккаунт'), findsOneWidget);
    });
  });
}
