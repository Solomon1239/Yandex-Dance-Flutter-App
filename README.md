![photo_2026-04-09 10 23 58](https://github.com/user-attachments/assets/410fd928-7690-4d64-92cb-9df7810e76b5)

# Yandex Dance (Flutter)

Мобильное приложение **dance community**: мероприятия, профили танцоров, друзья и создание событий. Клиент на **Flutter** с бэкендом на **Firebase** (Auth, Cloud Firestore, Storage).

## Возможности

| Область | Что есть в приложении |
|--------|-------------------------|
| **Аккаунт** | Вход и регистрация по email/паролю, **Google Sign-In**, **Sign in with Apple** |
| **Онбординг** | Выбор танцевальных стилей после первого входа |
| **Главная** | Подборки «Популярные мероприятия» и «Популярные танцоры» |
| **Мероприятия** | Список с поиском и фильтрами (жанр, дата, возраст), переключение **список / карта** (MapLibre), карточка события, детальная страница, участие / отписка |
| **Создание события** | Обложка, описание, стиль, дата/время, адрес (подсказки DaData), возрастные ограничения, лимит участников |
| **Друзья** | Поиск пользователей, подписки (подписчики / подписки), профиль другого пользователя |
| **Профиль** | Аватар, видео-интро, стили, город, события пользователя, настройки, выход из аккаунта |

## Стек

- **Flutter** (Dart 3.7+), `go_router`, `get_it`
- **Firebase**: `firebase_core`, `firebase_auth`, `cloud_firestore`, `firebase_storage`
- **Медиа**: `image_picker`, `cached_network_image`, сжатие изображений/видео
- **Карты**: `maplibre_gl`
- **Состояние**: `yx_state` / `yx_state_flutter`
- **Прочее**: `intl`, `http`, `flutter_svg`, `google_fonts`, и др. (см. `pubspec.yaml`)

## Требования

- **Flutter** SDK (stable), совместимый с `environment.sdk` в `pubspec.yaml`
- Для iOS: Xcode и CocoaPods; для Android: Android SDK
- Файлы **`GoogleService-Info.plist`** (iOS) и **`google-services.json`** (Android) из консоли Firebase — в проекте уже предполагаются для сборки

### Переменные окружения (опционально)

- `DADATA_TOKEN` — токен DaData для подсказок адресов и городов (есть fallback в коде для разработки)
- `DEV_INPUT` — при `true` стартовый маршрут может открывать экран создания события (см. `app_router.dart`)

## Запуск

```bash
cd Yandex-Dance-Flutter-App
flutter pub get
flutter run
```

## Тесты и анализ

```bash
dart analyze
flutter test
```

В **GitHub Actions** (`.github/workflows/ci.yml`) на push/PR выполняются `dart analyze` и `flutter test`.

## Структура `lib/` (кратко)

- `app/` — bootstrap, DI (`service_locator.dart`), роутер, shell с нижней навигацией
- `core/` — тема, цвета, общие виджеты, утилиты, сервисы (гео, медиа, storage)
- `features/` — фичи по доменам: `auth`, `session`, `style_selection`, `events`, `create_event`, `friends`, `profile`

---

Проект изначально создавался как шаблон Flutter; текущая версия — полноценное клиентское приложение под описанный сценарий.
