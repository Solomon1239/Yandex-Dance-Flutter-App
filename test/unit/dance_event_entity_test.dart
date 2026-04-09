import 'package:flutter_test/flutter_test.dart';

import '../fixtures/dance_event_fixtures.dart';

void main() {
  group('DanceEvent', () {
    test('currentParticipants и isParticipant', () {
      final event = DanceEventFixtures.minimal(
        participantIds: const ['a', 'b'],
      );
      expect(event.currentParticipants, 2);
      expect(event.isParticipant('a'), isTrue);
      expect(event.isParticipant('x'), isFalse);
    });

    test('isFull', () {
      final full = DanceEventFixtures.minimal(
        maxParticipants: 2,
        participantIds: const ['a', 'b'],
      );
      expect(full.isFull, isTrue);

      final notFull = DanceEventFixtures.minimal(
        maxParticipants: 10,
        participantIds: const ['a'],
      );
      expect(notFull.isFull, isFalse);
    });

    test('hasCover и hasPromoVideo', () {
      expect(DanceEventFixtures.minimal().hasCover, isFalse);
      expect(
        DanceEventFixtures.minimal(coverUrl: 'https://x/c.jpg').hasCover,
        isTrue,
      );
      expect(DanceEventFixtures.minimal().hasPromoVideo, isFalse);
      expect(
        DanceEventFixtures.minimal(promoVideoUrl: 'https://x/v.mp4').hasPromoVideo,
        isTrue,
      );
    });

    test('isCreator', () {
      final event = DanceEventFixtures.minimal(creatorId: 'uid-42');
      expect(event.isCreator('uid-42'), isTrue);
      expect(event.isCreator('other'), isFalse);
    });
  });
}
