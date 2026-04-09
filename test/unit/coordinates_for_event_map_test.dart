import 'package:flutter_test/flutter_test.dart';
import 'package:yandex_dance/features/events/presentation/utils/dance_event_to_event_preview.dart';

import '../fixtures/dance_event_fixtures.dart';

void main() {
  group('coordinatesForEventMap', () {
    test('возвращает координаты из события, если заданы', () {
      final event = DanceEventFixtures.minimal(latitude: 59.93, longitude: 30.33);
      final (lat, lng) = coordinatesForEventMap(event);
      expect(lat, 59.93);
      expect(lng, 30.33);
    });

    test('детерминированный fallback при отсутствии координат', () {
      final a = DanceEventFixtures.minimal(id: 'same');
      final b = DanceEventFixtures.minimal(id: 'same');
      expect(coordinatesForEventMap(a), coordinatesForEventMap(b));

      final c = DanceEventFixtures.minimal(id: 'other-id');
      expect(coordinatesForEventMap(a), isNot(coordinatesForEventMap(c)));
    });
  });
}
