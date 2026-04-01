import 'package:yandex_dance/core/enums/dance_style.dart';
import 'package:yandex_dance/core/errors/app_exception.dart';
import 'package:yandex_dance/features/auth/domain/repositories/auth_repository.dart';
import 'package:yandex_dance/features/profile/domain/repositories/profile_repository.dart';
import 'package:yandex_dance/features/style_selection/presentation/state/style_selection_state.dart';
import 'package:yx_state/yx_state.dart';

class StyleSelectionManager extends StateManager<StyleSelectionState> {
  StyleSelectionManager({
    required ProfileRepository profileRepository,
    required AuthRepository authRepository,
  }) : _profileRepository = profileRepository,
       _authRepository = authRepository,
       super(const StyleSelectionState());

  final ProfileRepository _profileRepository;
  final AuthRepository _authRepository;

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

  Future<void> submit() {
    return handle((emit) async {
      if (state.selectedStyles.isEmpty) {
        emit(state.copyWith(errorMessage: 'Выбери хотя бы один стиль'));
        return;
      }

      final uid = _authRepository.currentUserId;
      if (uid == null) {
        emit(state.copyWith(errorMessage: 'Пользователь не найден'));
        return;
      }

      emit(state.copyWith(isSaving: true, clearError: true));

      try {
        await _profileRepository.updateDanceStyles(
          uid: uid,
          danceStyles: state.selectedStyles,
        );

        emit(state.copyWith(isSaving: false));
      } on AppException catch (e, stackTrace) {
        addError(e, stackTrace, 'styleSelection.submit');
        emit(state.copyWith(isSaving: false, errorMessage: e.message));
      } catch (e, stackTrace) {
        addError(e, stackTrace, 'styleSelection.submit');
        emit(
          state.copyWith(
            isSaving: false,
            errorMessage: 'Не удалось сохранить стили',
          ),
        );
      }
    }, identifier: 'styleSelection.submit');
  }
}
