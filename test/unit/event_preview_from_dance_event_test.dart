import 'package:flutter_test/flutter_test.dart';
import 'package:yandex_dance/features/events/presentation/utils/dance_event_to_event_preview.dart';

import '../fixtures/dance_event_fixtures.dart';
import '../helpers/test_binding.dart';

void main() {
  setUpAll(ensureTestWidgetsBinding);

  group('eventPreviewFromDanceEvent', () {
    test('пустой ageRestriction → «Для всех»', () {
      final event = DanceEventFixtures.minimal(ageRestriction: '   ');
      final preview = eventPreviewFromDanceEvent(
        event,
        authorLabel: 'Орг',
      );
      expect(preview.ageRestrictionLabel, 'Для всех');
    });

    test('participantsLabel и заголовок', () {
      final event = DanceEventFixtures.minimal(
        title: 'Jam',
        participantIds: const ['a', 'b'],
        maxParticipants: 5,
      );
      final preview = eventPreviewFromDanceEvent(
        event,
        authorLabel: 'Вы',
      );
      expect(preview.title, 'Jam');
      expect(preview.participantsLabel, '2/5');
      expect(preview.authorLabel, 'Вы');
    });
  });
}
