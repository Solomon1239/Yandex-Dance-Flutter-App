import 'package:flutter_test/flutter_test.dart';
import 'package:yandex_dance/features/events/presentation/models/event_preview.dart';

void main() {
  group('EventPreview', () {
    test('hasFreeSpots', () {
      final t = DateTime.utc(2026, 1, 1, 12);
      final preview = EventPreview(
        id: '1',
        title: 'T',
        styleLabel: 'S',
        ageRestrictionLabel: '18+',
        dateTime: t,
        dateLabel: '',
        locationLabel: '',
        authorLabel: '',
        currentParticipants: 3,
        maxParticipants: 10,
        participantsLabel: '3/10',
        latitude: 0,
        longitude: 0,
      );
      expect(preview.hasFreeSpots, isTrue);

      final full = EventPreview(
        id: '1',
        title: 'T',
        styleLabel: 'S',
        ageRestrictionLabel: '18+',
        dateTime: t,
        dateLabel: '',
        locationLabel: '',
        authorLabel: '',
        currentParticipants: 10,
        maxParticipants: 10,
        participantsLabel: '10/10',
        latitude: 0,
        longitude: 0,
      );
      expect(full.hasFreeSpots, isFalse);
    });
  });
}
