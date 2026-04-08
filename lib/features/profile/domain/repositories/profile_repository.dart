import 'package:yandex_dance/core/enums/dance_style.dart';
import 'package:yandex_dance/features/profile/domain/entities/user_profile.dart';

/// Работает с профилем пользователя: читает, создаёт, обновляет,
/// загружает аватар и видео. Всё общение с Firebase спрятано за этим
/// интерфейсом — на экранах и в менеджерах работаем только с этими методами.
abstract interface class ProfileRepository {
  /// Подписка на все профили пользователей.
  /// Нужна для экранов, где показываются подборки танцоров или рейтинги.
  Stream<List<UserProfile>> watchAllProfiles();

  /// Подписка на профиль в реальном времени. Каждый раз, когда документ
  /// в Firestore меняется, в поток прилетает новое значение.
  /// Если профиля ещё нет — прилетит `null`.
  /// Используй, когда страница должна сама обновляться при изменениях.
  Stream<UserProfile?> watchProfile(String uid);

  /// Разовое чтение профиля. Вернёт `null`, если документа нет.
  /// Подходит для одноразовых проверок (например, «есть ли у этого uid
  /// профиль») — без подписки и без пересчётов при изменениях.
  Future<UserProfile?> getProfile(String uid);

  /// Создаёт документ профиля, если его ещё нет.
  /// Безопасно вызывать после каждого логина — существующий профиль
  /// не затирает. Обычно используется сразу после регистрации/входа,
  /// чтобы в Firestore точно был базовый документ для текущего uid.
  Future<void> createProfileIfNeeded({
    required String uid,
    String? email,
    String? displayName,
    String? photoUrl,
  });

  /// Обновляет только стили танца и флаг `onboardingCompleted`.
  /// Лёгкая операция — отдельный метод, чтобы не таскать весь профиль
  /// ради двух полей. Используется в экране выбора стилей (онбординге).
  Future<void> updateDanceStyles({
    required String uid,
    required List<DanceStyle> danceStyles,
  });

  /// Сохраняет профиль целиком (через merge — незаданные поля в Firestore
  /// не трогаются). Используй после редактирования формы профиля, когда
  /// меняется сразу несколько полей.
  Future<void> saveProfile(UserProfile profile);

  /// Загружает аватар в Storage:
  ///  1) оптимизирует картинку и делает thumbnail,
  ///  2) заливает оба файла в `user_avatars/{uid}/...`,
  ///  3) удаляет старые файлы из Storage (если были),
  ///  4) обновляет URL'ы в документе профиля.
  /// Возвращает уже обновлённый профиль — его можно сразу класть в state.
  /// Если что-то пошло не так — кидает `AppException` с понятным текстом.
  Future<UserProfile> uploadAvatar({
    required String uid,
    required UserProfile currentProfile,
    required String sourcePath,
  });

  /// То же самое, что и [uploadAvatar], только для intro-видео:
  /// оптимизирует, заливает видео и его обложку в `user_videos/{uid}/...`,
  /// удаляет предыдущие файлы и обновляет профиль. Возвращает новый профиль.
  Future<UserProfile> uploadIntroVideo({
    required String uid,
    required UserProfile currentProfile,
    required String sourcePath,
  });

  /// Удаляет intro-видео: сносит файлы из Storage и чистит поля
  /// `introVideoUrl`/`introVideoThumbUrl`/`introVideoStoragePath`/... в
  /// документе профиля. Возвращает профиль без видео.
  Future<UserProfile> deleteIntroVideo({required UserProfile currentProfile});
}
