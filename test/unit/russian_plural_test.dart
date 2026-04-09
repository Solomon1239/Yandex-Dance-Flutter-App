import 'package:flutter_test/flutter_test.dart';
import 'package:yandex_dance/core/utils/russian_plural.dart';

void main() {
  group('russianPlural', () {
    test('1, 21, 101 → one', () {
      expect(
        russianPlural(n: 1, one: 'год', few: 'года', many: 'лет'),
        'год',
      );
      expect(
        russianPlural(n: 21, one: 'год', few: 'года', many: 'лет'),
        'год',
      );
    });

    test('2–4, 22–24 → few (кроме 12–14)', () {
      expect(
        russianPlural(n: 3, one: 'x', few: 'y', many: 'z'),
        'y',
      );
      expect(
        russianPlural(n: 22, one: 'x', few: 'y', many: 'z'),
        'y',
      );
    });

    test('5–20, 11–14, 25+ → many', () {
      expect(
        russianPlural(n: 5, one: 'x', few: 'y', many: 'z'),
        'z',
      );
      expect(
        russianPlural(n: 11, one: 'x', few: 'y', many: 'z'),
        'z',
      );
      expect(
        russianPlural(n: 12, one: 'x', few: 'y', many: 'z'),
        'z',
      );
      expect(
        russianPlural(n: 14, one: 'x', few: 'y', many: 'z'),
        'z',
      );
    });
  });
}
