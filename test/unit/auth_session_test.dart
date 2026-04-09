import 'package:flutter_test/flutter_test.dart';
import 'package:yandex_dance/features/auth/domain/entities/auth_session.dart';

void main() {
  group('AuthSession', () {
    test('равенство по полям', () {
      const a = AuthSession(uid: '1', email: 'a@b.c');
      const b = AuthSession(uid: '1', email: 'a@b.c');
      const c = AuthSession(uid: '2', email: 'a@b.c');
      expect(a, b);
      expect(a, isNot(c));
    });
  });
}
