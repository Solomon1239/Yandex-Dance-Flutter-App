import 'package:flutter/material.dart';
import 'package:yandex_dance/core/ui/colors/colors.dart';
import 'package:yandex_dance/core/ui/icons/app_icons.dart';
import 'package:yandex_dance/core/ui/widgets/buttons/app_button.dart';
import 'package:yandex_dance/core/ui/widgets/buttons/app_button_style.dart';

class ProfileHeader extends StatelessWidget {
  const ProfileHeader({super.key, required this.onSettingsTap});

  final VoidCallback onSettingsTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 12, 16, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          AppButton(
            onTap: onSettingsTap,
            icon: AppIcons.settings,
            style: const AppButtonStyle(
              width: 48,
              height: 48,
              padding: EdgeInsets.zero,
              backgroundColor: Colors.transparent,
              iconColor: AppColors.gray0,
              iconSize: 26,
            ),
          ),
        ],
      ),
    );
  }
}
