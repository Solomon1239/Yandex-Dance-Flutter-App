import 'package:flutter_test/flutter_test.dart';
import 'package:yandex_dance/core/services/geo/address_suggestion.dart';

void main() {
  group('AddressSuggestion', () {
    test('равенство по полям', () {
      const a = AddressSuggestion(
        displayLabel: 'Москва',
        latitude: 55.75,
        longitude: 37.62,
      );
      const b = AddressSuggestion(
        displayLabel: 'Москва',
        latitude: 55.75,
        longitude: 37.62,
      );
      expect(a, b);
    });
  });
}
