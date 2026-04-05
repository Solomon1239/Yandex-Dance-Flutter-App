import 'package:flutter/material.dart';
import 'package:yandex_dance/core/ui/colors/colors.dart';
import 'package:yandex_dance/core/ui/widgets/buttons/app_button.dart';
import 'package:yandex_dance/core/ui/widgets/buttons/app_button_style.dart';

enum ProfileSettingsAction { edit, signOut }

Future<ProfileSettingsAction?> showProfileSettingsSheet(
  BuildContext context,
) {
  return showModalBottomSheet<ProfileSettingsAction>(
    context: context,
    backgroundColor: AppColors.gray400,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (context) {
      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.gray300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              AppButton(
                onTap:
                    () => Navigator.of(
                      context,
                    ).pop(ProfileSettingsAction.edit),
                label: 'Редактировать профиль',
                iconWidget: const Icon(
                  Icons.edit_outlined,
                  color: AppColors.gray0,
                  size: 22,
                ),
                style: const AppButtonStyle(
                  height: 56,
                  backgroundColor: Colors.transparent,
                  textColor: AppColors.gray0,
                  iconColor: AppColors.gray0,
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  gap: 12,
                ),
              ),
              const SizedBox(height: 4),
              AppButton(
                onTap:
                    () => Navigator.of(
                      context,
                    ).pop(ProfileSettingsAction.signOut),
                label: 'Выйти',
                iconWidget: const Icon(
                  Icons.logout,
                  color: AppColors.pink500,
                  size: 22,
                ),
                style: const AppButtonStyle(
                  height: 56,
                  backgroundColor: Colors.transparent,
                  textColor: AppColors.pink500,
                  iconColor: AppColors.pink500,
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  gap: 12,
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}
