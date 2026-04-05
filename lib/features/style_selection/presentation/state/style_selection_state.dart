import 'dart:io';

import 'package:yandex_dance/core/enums/dance_style.dart';
import 'package:equatable/equatable.dart';

class StyleSelectionState extends Equatable {
  const StyleSelectionState({
    this.selectedStyles = const [],
    this.avatarFile,
    this.isUploadingAvatar = false,
    this.isSaving = false,
    this.errorMessage,
    this.successMessage,
  });

  final List<DanceStyle> selectedStyles;
  final File? avatarFile;
  final bool isUploadingAvatar;
  final bool isSaving;
  final String? errorMessage;
  final String? successMessage;

  bool get isProcessing => isSaving || isUploadingAvatar;

  StyleSelectionState copyWith({
    List<DanceStyle>? selectedStyles,
    File? avatarFile,
    bool clearAvatar = false,
    bool? isUploadingAvatar,
    bool? isSaving,
    String? errorMessage,
    String? successMessage,
    bool clearError = false,
    bool clearSuccess = false,
  }) {
    return StyleSelectionState(
      selectedStyles: selectedStyles ?? this.selectedStyles,
      avatarFile: clearAvatar ? null : (avatarFile ?? this.avatarFile),
      isUploadingAvatar: isUploadingAvatar ?? this.isUploadingAvatar,
      isSaving: isSaving ?? this.isSaving,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      successMessage:
          clearSuccess ? null : (successMessage ?? this.successMessage),
    );
  }

  @override
  List<Object?> get props => [
    selectedStyles,
    avatarFile,
    isUploadingAvatar,
    isSaving,
    errorMessage,
    successMessage,
  ];
}
