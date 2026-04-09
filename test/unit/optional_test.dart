import 'package:flutter_test/flutter_test.dart';
import 'package:yandex_dance/core/utils/optional.dart';

void main() {
  group('Optional', () {
    test('absent даёт null value', () {
      const o = Optional<int>.absent();
      expect(o.value, isNull);
    });

    test('хранит значение', () {
      const o = Optional(42);
      expect(o.value, 42);
    });
  });
}
