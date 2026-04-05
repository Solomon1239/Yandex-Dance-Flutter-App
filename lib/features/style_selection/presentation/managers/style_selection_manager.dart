import 'dart:io';

import 'package:yandex_dance/core/enums/dance_style.dart';
import 'package:yandex_dance/core/errors/app_exception.dart';
import 'package:yandex_dance/core/services/media/media_picker_service.dart';
import 'package:yandex_dance/core/utils/optional.dart';
import 'package:yandex_dance/features/auth/domain/repositories/auth_repository.dart';
import 'package:yandex_dance/features/profile/domain/repositories/profile_repository.dart';
import 'package:yandex_dance/features/style_selection/presentation/state/style_selection_state.dart';
import 'package:yx_state/yx_state.dart';

class StyleSelectionManager extends StateManager<StyleSelectionState> {
  StyleSelectionManager({
    required ProfileRepository profileRepository,
    required AuthRepository authRepository,
    required MediaPickerService mediaPickerService,
  }) : _profileRepository = profileRepository,
       _authRepository = authRepository,
       _mediaPickerService = mediaPickerService,
       super(const StyleSelectionState());

  final ProfileRepository _profileRepository;
  final AuthRepository _authRepository;
  final MediaPickerService _mediaPickerService;

  Future<void> toggleStyle(DanceStyle style) {
    return handle((emit) async {
      final current = [...state.selectedStyles];

      if (current.contains(style)) {
        current.remove(style);
      } else {
        current.add(style);
      }

      emit(state.copyWith(selectedStyles: current, clearError: true));
    }, identifier: 'styleSelection.toggleStyle');
  }

  Future<void> pickAvatar() {
    return handle((emit) async {
      final file = await _mediaPickerService.pickImageFromGallery();
      if (file == null) return;

      emit(state.copyWith(avatarFile: File(file.path)));
    }, identifier: 'styleSelection.pickAvatar');
  }

  Future<void> submit({
    required String displayName,
    required String city,
    required DateTime? dateOfBirth,
    String? bio,
  }) {
    return handle((emit) async {
      if (displayName.trim().isEmpty) {
        emit(state.copyWith(errorMessage: 'Введите имя'));
        return;
      }

      if (city.trim().isEmpty) {
        emit(state.copyWith(errorMessage: 'Введите город'));
        return;
      }

      if (dateOfBirth == null) {
        emit(state.copyWith(errorMessage: 'Выберите дату рождения'));
        return;
      }

      if (state.selectedStyles.isEmpty) {
        emit(state.copyWith(errorMessage: 'Выберите хотя бы один стиль'));
        return;
      }

      emit(state.copyWith(isSaving: true, clearError: true));

      try {
        final session = _authRepository.currentSession;
        if (session == null) {
          emit(
            state.copyWith(
              isSaving: false,
              errorMessage: 'Пользователь не найден',
            ),
          );
          return;
        }

        await _profileRepository.createProfileIfNeeded(
          uid: session.uid,
          email: session.email,
          displayName: session.displayName ?? displayName.trim(),
          photoUrl: session.photoUrl,
        );

        var profile = await _profileRepository.getProfile(session.uid);
        if (profile == null) {
          emit(
            state.copyWith(
              isSaving: false,
              errorMessage: 'Профиль не найден',
            ),
          );
          return;
        }

        if (state.avatarFile != null) {
          profile = await _profileRepository.uploadAvatar(
            uid: session.uid,
            currentProfile: profile,
            sourcePath: state.avatarFile!.path,
          );
        }

        final updated = profile.copyWith(
          displayName: displayName.trim(),
          bio: bio?.trim(),
          city: city.trim(),
          dateOfBirth: Optional(dateOfBirth),
          danceStyles: state.selectedStyles,
          onboardingCompleted: true,
        );

        await _profileRepository.saveProfile(updated);
      } on AppException catch (e, stackTrace) {
        addError(e, stackTrace, 'styleSelection.submit');
        emit(state.copyWith(isSaving: false, errorMessage: e.message));
      } catch (e, stackTrace) {
        addError(e, stackTrace, 'styleSelection.submit');
        emit(
          state.copyWith(
            isSaving: false,
            errorMessage: 'Не удалось сохранить профиль',
          ),
        );
      }
    }, identifier: 'styleSelection.submit');
  }
}
