import 'dart:io';

import 'package:yandex_dance/features/profile/domain/entities/user_profile.dart';
import 'package:equatable/equatable.dart';

class EditProfileState extends Equatable {
  const EditProfileState({
    this.isLoading = true,
    this.isSaving = false,
    this.isUploadingAvatar = false,
    this.isUploadingVideo = false,
    this.localAvatarFile,
    this.profile,
    this.errorMessage,
    this.successMessage,
  });

  final bool isLoading;
  final bool isSaving;
  final bool isUploadingAvatar;
  final bool isUploadingVideo;
  final File? localAvatarFile;
  final UserProfile? profile;
  final String? errorMessage;
  final String? successMessage;

  EditProfileState copyWith({
    bool? isLoading,
    bool? isSaving,
    bool? isUploadingAvatar,
    bool? isUploadingVideo,
    File? localAvatarFile,
    bool clearLocalAvatarFile = false,
    UserProfile? profile,
    String? errorMessage,
    String? successMessage,
    bool clearError = false,
    bool clearSuccess = false,
  }) {
    return EditProfileState(
      isLoading: isLoading ?? this.isLoading,
      isSaving: isSaving ?? this.isSaving,
      isUploadingAvatar: isUploadingAvatar ?? this.isUploadingAvatar,
      isUploadingVideo: isUploadingVideo ?? this.isUploadingVideo,
      localAvatarFile:
          clearLocalAvatarFile
              ? null
              : (localAvatarFile ?? this.localAvatarFile),
      profile: profile ?? this.profile,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      successMessage:
          clearSuccess ? null : (successMessage ?? this.successMessage),
    );
  }

  @override
  List<Object?> get props => [
    isLoading,
    isSaving,
    isUploadingAvatar,
    isUploadingVideo,
    localAvatarFile,
    profile,
    errorMessage,
    successMessage,
  ];
}
