import 'package:yandex_dance/core/enums/dance_style.dart';
import 'package:yandex_dance/features/events/domain/entities/dance_event.dart';

/// Минимальные [DanceEvent] для unit/widget-тестов без Firebase.
abstract final class DanceEventFixtures {
  static DanceEvent minimal({
    String id = 'test-event-1',
    String title = 'Test event',
    String description = 'Description',
    DateTime? dateTime,
    double? latitude,
    double? longitude,
    int maxParticipants = 20,
    List<String> participantIds = const [],
    String ageRestriction = '16+',
    String? coverUrl,
    String? promoVideoUrl,
    String creatorId = 'creator-1',
    DanceStyle danceStyle = DanceStyle.hipHop,
  }) {
    return DanceEvent(
      id: id,
      title: title,
      description: description,
      coverUrl: coverUrl,
      danceStyle: danceStyle,
      dateTime: dateTime ?? DateTime.utc(2026, 4, 9, 18, 0),
      address: 'Test address',
      latitude: latitude,
      longitude: longitude,
      maxParticipants: maxParticipants,
      participantIds: participantIds,
      ageRestriction: ageRestriction,
      promoVideoUrl: promoVideoUrl,
      creatorId: creatorId,
    );
  }
}
