import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:yandex_dance/core/services/media/image_optimizer.dart';
import 'package:yandex_dance/core/services/media/media_picker_service.dart';
import 'package:yandex_dance/core/services/media/video_optimizer.dart';
import 'package:yandex_dance/core/services/storage/storage_service.dart';
import 'package:yandex_dance/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:yandex_dance/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:yandex_dance/features/auth/domain/repositories/auth_repository.dart';
import 'package:yandex_dance/features/auth/presentation/managers/auth_manager.dart';
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

Future<void> configureDependencies() async {
  sl
    ..registerLazySingleton<FirebaseAuth>(() => FirebaseAuth.instance)
    ..registerLazySingleton<FirebaseFirestore>(() => FirebaseFirestore.instance)
    ..registerLazySingleton<FirebaseStorage>(() => FirebaseStorage.instance)
    ..registerLazySingleton<GoogleSignIn>(() => GoogleSignIn.instance);

  sl
    ..registerLazySingleton(MediaPickerService.new)
    ..registerLazySingleton(ImageOptimizer.new)
    ..registerLazySingleton(VideoOptimizer.new)
    ..registerLazySingleton(() => StorageService(sl()));

  sl
    ..registerLazySingleton(
      () => AuthRemoteDataSource(auth: sl(), googleSignIn: sl()),
    )
    ..registerLazySingleton(() => ProfileRemoteDataSource(firestore: sl()));

  sl
    ..registerLazySingleton<ProfileRepository>(
      () => ProfileRepositoryImpl(
        remote: sl(),
        storageService: sl(),
        imageOptimizer: sl(),
        videoOptimizer: sl(),
      ),
    )
    ..registerLazySingleton<AuthRepository>(
      () => AuthRepositoryImpl(remote: sl(), profileRepository: sl()),
    );

  sl.registerLazySingleton(
    () => AppSessionManager(authRepository: sl(), profileRepository: sl()),
  );

  sl.registerFactory(() => AuthManager(sl()));
  sl.registerFactory(
    () => StyleSelectionManager(profileRepository: sl(), authRepository: sl()),
  );
  sl.registerFactory(
    () => ProfileManager(profileRepository: sl(), authRepository: sl()),
  );
  sl.registerFactory(
    () => EditProfileManager(
      profileRepository: sl(),
      authRepository: sl(),
      mediaPickerService: sl(),
    ),
  );
}
