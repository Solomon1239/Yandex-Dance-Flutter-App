import 'package:flutter_test/flutter_test.dart';
import 'package:yandex_dance/core/errors/app_exception.dart';

void main() {
  group('AppException', () {
    test('фабрики выставляют тип', () {
      expect(const AppException.auth('a').type, AppExceptionType.auth);
      expect(const AppException.cancelled('c').type, AppExceptionType.cancelled);
      expect(const AppException.unknown('u').type, AppExceptionType.unknown);
    });

    test('toString содержит тип и сообщение', () {
      const e = AppException(message: 'hello');
      expect(e.toString(), contains('hello'));
      expect(e.toString(), contains('unknown'));
    });
  });
}
