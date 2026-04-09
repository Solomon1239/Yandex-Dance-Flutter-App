import 'package:flutter_test/flutter_test.dart';
import 'package:yandex_dance/features/events/data/models/dance_event_model.dart';

import '../fixtures/dance_event_fixtures.dart';

void main() {
  group('DanceEventModel', () {
    test('fromEntity → toEntity возвращает эквивалентное событие', () {
      final original = DanceEventFixtures.minimal(
        id: 'evt-99',
        title: 'Party',
        coverUrl: 'https://cdn/x.jpg',
        participantIds: const ['u1', 'u2'],
        ageRestriction: '',
      );
      final model = DanceEventModel.fromEntity(original);
      expect(model.toEntity(), original);
    });
  });
}
