import 'package:yandex_dance/core/enums/dance_style.dart';
import 'package:equatable/equatable.dart';

class StyleSelectionState extends Equatable {
  const StyleSelectionState({
    this.selectedStyles = const [],
    this.isSaving = false,
    this.errorMessage,
  });

  final List<DanceStyle> selectedStyles;
  final bool isSaving;
  final String? errorMessage;

  StyleSelectionState copyWith({
    List<DanceStyle>? selectedStyles,
    bool? isSaving,
    String? errorMessage,
    bool clearError = false,
  }) {
    return StyleSelectionState(
      selectedStyles: selectedStyles ?? this.selectedStyles,
      isSaving: isSaving ?? this.isSaving,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  List<Object?> get props => [selectedStyles, isSaving, errorMessage];
}
