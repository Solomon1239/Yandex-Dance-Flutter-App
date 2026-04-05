import 'package:yandex_dance/core/enums/dance_style.dart';
import 'package:yandex_dance/core/errors/app_exception.dart';
import 'package:yandex_dance/core/services/media/media_picker_service.dart';
import 'package:yandex_dance/core/utils/optional.dart';
import 'package:yandex_dance/features/auth/domain/repositories/auth_repository.dart';
import 'package:yandex_dance/features/profile/domain/repositories/profile_repository.dart';
import 'package:yandex_dance/features/profile/presentation/state/edit_profile_state.dart';
import 'package:yx_state/yx_state.dart';

class EditProfileManager extends StateManager<EditProfileState> {
  EditProfileManager({
    required ProfileRepository profileRepository,
    required AuthRepository authRepository,
    required MediaPickerService mediaPickerService,
  }) : _profileRepository = profileRepository,
       _authRepository = authRepository,
       _mediaPickerService = mediaPickerService,
       super(const EditProfileState());

  final ProfileRepository _profileRepository;
  final AuthRepository _authRepository;
  final MediaPickerService _mediaPickerService;

  Future<void> load() {
    return handle((emit) async {
      final uid = _authRepository.currentUserId;
      if (uid == null) {
        emit(
          state.copyWith(
            isLoading: false,
            errorMessage: 'Пользователь не найден',
          ),
        );
        return;
      }

      final profile = await _profileRepository.getProfile(uid);

      if (profile == null) {
        emit(
          state.copyWith(isLoading: false, errorMessage: 'Профиль не найден'),
        );
        return;
      }

      emit(
        state.copyWith(isLoading: false, profile: profile, clearError: true),
      );
    }, identifier: 'editProfile.load');
  }

  Future<void> saveBasicInfo({
    required String displayName,
    required String bio,
    required String city,
    required DateTime? dateOfBirth,
    required List<DanceStyle> danceStyles,
  }) {
    return handle((emit) async {
      final current = state.profile;
      if (current == null) return;

      emit(
        state.copyWith(isSaving: true, clearError: true, clearSuccess: true),
      );

      try {
        final updated = current.copyWith(
          displayName: displayName.trim(),
          bio: bio.trim(),
          city: city.trim(),
          dateOfBirth: Optional(dateOfBirth),
          danceStyles: danceStyles,
        );

        await _profileRepository.saveProfile(updated);

        emit(
          state.copyWith(
            isSaving: false,
            profile: updated,
            successMessage: 'Профиль сохранён',
          ),
        );
      } on AppException catch (e, stackTrace) {
        addError(e, stackTrace, 'editProfile.saveBasicInfo');
        emit(state.copyWith(isSaving: false, errorMessage: e.message));
      } catch (e, stackTrace) {
        addError(e, stackTrace, 'editProfile.saveBasicInfo');
        emit(
          state.copyWith(
            isSaving: false,
            errorMessage: 'Не удалось сохранить профиль',
          ),
        );
      }
    }, identifier: 'editProfile.saveBasicInfo');
  }

  Future<void> pickAndUploadAvatar() {
    return handle((emit) async {
      final uid = _authRepository.currentUserId;
      final current = state.profile;
      if (uid == null || current == null) return;

      emit(
        state.copyWith(
          isUploadingAvatar: true,
          clearError: true,
          clearSuccess: true,
        ),
      );

      try {
        final file = await _mediaPickerService.pickImageFromGallery();
        if (file == null) {
          emit(state.copyWith(isUploadingAvatar: false));
          return;
        }

        final updated = await _profileRepository.uploadAvatar(
          uid: uid,
          currentProfile: current,
          sourcePath: file.path,
        );

        emit(
          state.copyWith(
            isUploadingAvatar: false,
            profile: updated,
            successMessage: 'Аватар обновлён',
          ),
        );
      } on AppException catch (e, stackTrace) {
        addError(e, stackTrace, 'editProfile.pickAndUploadAvatar');
        emit(state.copyWith(isUploadingAvatar: false, errorMessage: e.message));
      } catch (e, stackTrace) {
        addError(e, stackTrace, 'editProfile.pickAndUploadAvatar');
        emit(
          state.copyWith(
            isUploadingAvatar: false,
            errorMessage: 'Не удалось загрузить аватар',
          ),
        );
      }
    }, identifier: 'editProfile.pickAndUploadAvatar');
  }

  Future<void> pickAndUploadIntroVideo() {
    return handle((emit) async {
      final uid = _authRepository.currentUserId;
      final current = state.profile;
      if (uid == null || current == null) return;

      emit(
        state.copyWith(
          isUploadingVideo: true,
          clearError: true,
          clearSuccess: true,
        ),
      );

      try {
        final file = await _mediaPickerService.pickVideoFromGallery();
        if (file == null) {
          emit(state.copyWith(isUploadingVideo: false));
          return;
        }

        final updated = await _profileRepository.uploadIntroVideo(
          uid: uid,
          currentProfile: current,
          sourcePath: file.path,
        );

        emit(
          state.copyWith(
            isUploadingVideo: false,
            profile: updated,
            successMessage: 'Видео обновлено',
          ),
        );
      } on AppException catch (e, stackTrace) {
        addError(e, stackTrace, 'editProfile.pickAndUploadIntroVideo');
        emit(state.copyWith(isUploadingVideo: false, errorMessage: e.message));
      } catch (e, stackTrace) {
        addError(e, stackTrace, 'editProfile.pickAndUploadIntroVideo');
        emit(
          state.copyWith(
            isUploadingVideo: false,
            errorMessage: 'Не удалось загрузить видео',
          ),
        );
      }
    }, identifier: 'editProfile.pickAndUploadIntroVideo');
  }
}
