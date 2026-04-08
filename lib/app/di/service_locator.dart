import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:yandex_dance/core/services/geo/address_search_service.dart';
import 'package:yandex_dance/core/services/geo/city_search_service.dart';
import 'package:yandex_dance/core/services/media/image_optimizer.dart';
import 'package:yandex_dance/core/services/media/media_picker_service.dart';
import 'package:yandex_dance/core/services/media/video_optimizer.dart';
import 'package:yandex_dance/core/services/storage/storage_service.dart';
import 'package:yandex_dance/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:yandex_dance/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:yandex_dance/features/auth/domain/repositories/auth_repository.dart';
import 'package:yandex_dance/features/auth/presentation/managers/auth_manager.dart';
import 'package:yandex_dance/features/events/data/datasources/event_remote_data_source.dart';
import 'package:yandex_dance/features/friends/data/datasources/friend_remote_data_source.dart';
import 'package:yandex_dance/features/friends/data/repositories/friend_repository_impl.dart';
import 'package:yandex_dance/features/friends/domain/repositories/friend_repository.dart';
import 'package:yandex_dance/features/friends/presentation/managers/friends_manager.dart';
import 'package:yandex_dance/features/events/data/repositories/event_repository_impl.dart';
import 'package:yandex_dance/features/events/domain/repositories/event_repository.dart';
import 'package:yandex_dance/features/friends/data/datasources/friends_data_source.dart';
import 'package:yandex_dance/features/friends/data/datasources/friends_mock_data_source.dart';
import 'package:yandex_dance/features/friends/data/datasources/friends_remote_data_source.dart';
import 'package:yandex_dance/features/friends/data/repositories/friends_repository_impl.dart';
import 'package:yandex_dance/features/friends/domain/repositories/friends_repository.dart';
import 'package:yandex_dance/features/profile/data/datasources/profile_remote_data_source.dart';
import 'package:yandex_dance/features/profile/data/repositories/profile_repository_impl.dart';
import 'package:yandex_dance/features/profile/domain/repositories/profile_repository.dart';
import 'package:yandex_dance/features/profile/presentation/managers/edit_profile_manager.dart';
import 'package:yandex_dance/features/profile/presentation/managers/profile_manager.dart';
import 'package:yandex_dance/features/session/presentation/managers/app_session_manager.dart';
import 'package:yandex_dance/features/style_selection/presentation/managers/style_selection_manager.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:google_sign_in/google_sign_in.dart';

final sl = GetIt.instance;

/// `false` — список тренеров из [FriendsMockDataSource]; `true` — Firestore `coaches`.
const bool kFriendsUseFirestore = false;

const _fallbackDadataToken = '0743c317d03c6061ed73fb541a8fd44375e40fd2';

String get _dadataToken {
  const envToken = String.fromEnvironment('DADATA_TOKEN');
  return envToken.isNotEmpty ? envToken : _fallbackDadataToken;
}

Future<void> configureDependencies() async {
  sl
    ..registerLazySingleton<FirebaseAuth>(() => FirebaseAuth.instance)
    ..registerLazySingleton<FirebaseFirestore>(() => FirebaseFirestore.instance)
    ..registerLazySingleton<FirebaseStorage>(() => FirebaseStorage.instance)
    ..registerLazySingleton<GoogleSignIn>(() => GoogleSignIn.instance);

  sl
    ..registerLazySingleton<MediaPickerService>(MediaPickerService.new)
    ..registerLazySingleton<ImageOptimizer>(ImageOptimizer.new)
    ..registerLazySingleton<VideoOptimizer>(VideoOptimizer.new)
    ..registerLazySingleton<AddressSearchService>(
      () => AddressSearchService(token: _dadataToken),
    )
    ..registerLazySingleton<CitySearchService>(
      () => CitySearchService(token: _dadataToken),
    )
    ..registerLazySingleton<StorageService>(
      () => StorageService(sl<FirebaseStorage>()),
    );

  sl
    ..registerLazySingleton<AuthRemoteDataSource>(
      () => AuthRemoteDataSource(
        auth: sl<FirebaseAuth>(),
        googleSignIn: sl<GoogleSignIn>(),
      ),
    )
    ..registerLazySingleton<ProfileRemoteDataSource>(
      () => ProfileRemoteDataSource(firestore: sl<FirebaseFirestore>()),
    )
    ..registerLazySingleton<EventRemoteDataSource>(
      () => EventRemoteDataSource(firestore: sl<FirebaseFirestore>()),
    )
    ..registerLazySingleton<FriendRemoteDataSource>(
      () => FriendRemoteDataSource(firestore: sl<FirebaseFirestore>()),
    );

  sl
    ..registerLazySingleton<ProfileRepository>(
      () => ProfileRepositoryImpl(
        remote: sl<ProfileRemoteDataSource>(),
        storageService: sl<StorageService>(),
        imageOptimizer: sl<ImageOptimizer>(),
        videoOptimizer: sl<VideoOptimizer>(),
      ),
    )
    ..registerLazySingleton<AuthRepository>(
      () => AuthRepositoryImpl(
        remote: sl<AuthRemoteDataSource>(),
        profileRepository: sl<ProfileRepository>(),
      ),
    )
    ..registerLazySingleton<EventRepository>(
      () => EventRepositoryImpl(
        remote: sl<EventRemoteDataSource>(),
        storageService: sl<StorageService>(),
        imageOptimizer: sl<ImageOptimizer>(),
        videoOptimizer: sl<VideoOptimizer>(),
      ),
    )
    ..registerLazySingleton<FriendRepository>(
      () => FriendRepositoryImpl(
        remote: sl<FriendRemoteDataSource>(),
        profileRepository: sl<ProfileRepository>(),
      ),
    );

  sl.registerLazySingleton<AppSessionManager>(
    () => AppSessionManager(
      authRepository: sl<AuthRepository>(),
      profileRepository: sl<ProfileRepository>(),
    ),
  );

  sl.registerFactory<AuthManager>(() => AuthManager(sl<AuthRepository>()));
  sl.registerFactory<StyleSelectionManager>(
    () => StyleSelectionManager(
      profileRepository: sl<ProfileRepository>(),
      authRepository: sl<AuthRepository>(),
      mediaPickerService: sl<MediaPickerService>(),
    ),
  );
  sl.registerLazySingleton<ProfileManager>(
    () => ProfileManager(
      profileRepository: sl<ProfileRepository>(),
      authRepository: sl<AuthRepository>(),
      eventRepository: sl<EventRepository>(),
      mediaPickerService: sl<MediaPickerService>(),
    ),
  );
  sl.registerFactory<EditProfileManager>(
    () => EditProfileManager(
      profileRepository: sl<ProfileRepository>(),
      authRepository: sl<AuthRepository>(),
      mediaPickerService: sl<MediaPickerService>(),
    ),
  );
  sl.registerFactory<FriendsManager>(
    () => FriendsManager(
      friendRepository: sl<FriendRepository>(),
      profileRepository: sl<ProfileRepository>(),
      authRepository: sl<AuthRepository>(),
    ),
  );
}
