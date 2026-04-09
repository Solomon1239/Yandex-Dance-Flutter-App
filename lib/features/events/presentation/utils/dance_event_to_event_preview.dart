import 'package:flutter/painting.dart';
import 'package:intl/intl.dart';
import 'package:yandex_dance/core/enums/dance_style.dart';
import 'package:yandex_dance/core/ui/media/cached_remote_image.dart';
import 'package:yandex_dance/features/events/domain/entities/dance_event.dart';
import 'package:yandex_dance/features/events/presentation/models/event_preview.dart';

const _fallbackMapCenterLat = 55.751244;
const _fallbackMapCenterLng = 37.618423;

/// Координаты для карты: из события или детерминированный сдвиг от центра Москвы
/// (как на экране мероприятий).
(double, double) coordinatesForEventMap(DanceEvent event) {
  if (event.latitude != null && event.longitude != null) {
    return (event.latitude!, event.longitude!);
  }

  final seed = event.id.codeUnits.fold<int>(
    0,
    (acc, code) => acc * 31 + code,
  );
  final positiveSeed = seed.abs();
  final latOffset = ((positiveSeed % 2001) - 1000) / 100000.0;
  final lngOffset = (((positiveSeed ~/ 2001) % 2001) - 1000) / 100000.0;
  return (
    _fallbackMapCenterLat + latOffset,
    _fallbackMapCenterLng + lngOffset,
  );
}

/// См. [cachedNetworkImageProviderOrNull] — дисковый кеш для URL.
ImageProvider<Object>? networkImageOrNull(String? url) {
  return cachedNetworkImageProviderOrNull(url);
}

/// Для открытия [EventDetailsPage] из любого места, где есть [DanceEvent].
EventPreview eventPreviewFromDanceEvent(
  DanceEvent event, {
  required String authorLabel,
  ImageProvider<Object>? authorAvatarImage,
}) {
  final dateFormat = DateFormat('dd.MM.yyyy, HH:mm');
  final coords = coordinatesForEventMap(event);
  return EventPreview(
    id: event.id,
    title: event.title,
    styleLabel: event.danceStyle.title,
    ageRestrictionLabel:
        event.ageRestriction.trim().isEmpty
            ? 'Для всех'
            : event.ageRestriction,
    dateTime: event.dateTime,
    dateLabel: dateFormat.format(event.dateTime),
    locationLabel: event.address,
    authorLabel: authorLabel,
    authorAvatarImage: authorAvatarImage,
    currentParticipants: event.currentParticipants,
    maxParticipants: event.maxParticipants,
    participantsLabel:
        '${event.currentParticipants}/${event.maxParticipants}',
    description: event.description,
    latitude: coords.$1,
    longitude: coords.$2,
    coverImage: networkImageOrNull(event.coverThumbUrl ?? event.coverUrl),
  );
}
