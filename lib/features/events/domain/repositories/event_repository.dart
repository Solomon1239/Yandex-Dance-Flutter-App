import 'package:yandex_dance/core/enums/dance_style.dart';
import 'package:yandex_dance/features/events/domain/entities/dance_event.dart';

/// Всё, что касается мероприятий: создание, обновление, удаление,
/// участие, загрузка обложки и промо-видео. Под капотом Firestore +
/// Firebase Storage, но наружу этот слой отдаёт только чистые
/// `DanceEvent` и стримы.
abstract interface class EventRepository {
  /// Стрим всех мероприятий (отсортированных по дате, от ближайших
  /// к будущим). Обновляется автоматически при любых изменениях в
  /// коллекции. Подходит для общего списка мероприятий.
  Stream<List<DanceEvent>> watchAllEvents();

  /// Стрим мероприятий, в которых пользователь участвует
  /// (включая те, что он создал — создатель автоматически
  /// попадает в participantIds). Используется, например, в профиле
  /// для блока «Мои мероприятия».
  Stream<List<DanceEvent>> watchUserEvents(String uid);

  /// Разовое чтение одного мероприятия по id. Вернёт `null`, если
  /// документ удалён или не существует.
  Future<DanceEvent?> getEvent(String eventId);

  /// Создаёт новое мероприятие. Если переданы пути к обложке и/или
  /// промо-видео — сначала загружает их в Storage, потом создаёт
  /// документ в Firestore с готовыми URL'ами. Создатель сразу
  /// добавляется в participantIds. Возвращает уже созданное
  /// мероприятие (с присвоенным Firestore'ом id).
  ///
  /// Поля [coverSourcePath] и [promoVideoSourcePath] — это локальные
  /// пути к файлам (то, что отдаёт image_picker/file_picker).
  Future<DanceEvent> createEvent({
    required String title,
    required String description,
    required DanceStyle danceStyle,
    required DateTime dateTime,
    required String address,
    required int maxParticipants,
    required String ageRestriction,
    required String creatorId,
    String? coverSourcePath,
    String? promoVideoSourcePath,
  });

  /// Сохраняет изменения в существующем мероприятии (через merge).
  /// Предполагается, что ты передаёшь уже изменённую сущность.
  Future<void> updateEvent(DanceEvent event);

  /// Удаляет мероприятие полностью: сначала чистит файлы (обложку,
  /// промо-видео и их thumbnail'ы) из Storage, потом удаляет документ
  /// из Firestore. Безопасно вызывать — если файлов нет, шагаем дальше.
  Future<void> deleteEvent(String eventId);

  /// Добавляет пользователя в участники мероприятия
  /// (через `arrayUnion`, так что двойного добавления не будет).
  /// Возвращает свежую версию мероприятия после обновления.
  Future<DanceEvent> joinEvent({
    required String eventId,
    required String uid,
  });

  /// Убирает пользователя из participantIds (через `arrayRemove`).
  /// Возвращает свежую версию мероприятия.
  Future<DanceEvent> leaveEvent({
    required String eventId,
    required String uid,
  });

  /// Обновляет обложку у существующего мероприятия: оптимизирует
  /// картинку, делает thumbnail, заливает в `event_covers/{eventId}/...`,
  /// удаляет предыдущую обложку и сохраняет новые URL'ы в документе.
  /// Возвращает обновлённое мероприятие.
  Future<DanceEvent> uploadCover({
    required String eventId,
    required DanceEvent currentEvent,
    required String sourcePath,
  });

  /// То же, что и [uploadCover], только для промо-видео:
  /// заливает в `event_videos/{eventId}/...` и обновляет URL'ы.
  Future<DanceEvent> uploadPromoVideo({
    required String eventId,
    required DanceEvent currentEvent,
    required String sourcePath,
  });
}
