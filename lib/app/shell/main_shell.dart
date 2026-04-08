import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:yandex_dance/core/ui/colors/colors.dart';
import 'package:yandex_dance/core/ui/icons/app_icons.dart';
import 'package:yandex_dance/core/ui/icons/svg_icon.dart';
import 'package:yandex_dance/core/ui/widgets/buttons/app_button.dart';
import 'package:yandex_dance/core/ui/widgets/buttons/app_button_style.dart';
import 'package:yandex_dance/core/ui/widgets/custom_bounce_effect.dart';

const double _kNavBarHeight = 64;

class MainShell extends StatelessWidget {
  const MainShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  void _onTabSelected(int index) {
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.gray500,
      body: navigationShell,
      bottomNavigationBar: _BottomNavBar(
        currentIndex: navigationShell.currentIndex,
        onTabSelected: _onTabSelected,
        onCreatePressed: () => context.push('/create'),
      ),
    );
  }
}

class _BottomNavBar extends StatelessWidget {
  const _BottomNavBar({
    required this.currentIndex,
    required this.onTabSelected,
    required this.onCreatePressed,
  });

  final int currentIndex;
  final ValueChanged<int> onTabSelected;
  final VoidCallback onCreatePressed;

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.gray400,
        border: Border(
          top: BorderSide(
            color: AppColors.gray300.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
      ),
      padding: EdgeInsets.only(bottom: bottomPadding),
      child: SizedBox(
        height: _kNavBarHeight,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _NavTab(
              iconPath: AppIcons.home,
              label: 'Главная',
              selected: currentIndex == 0,
              onTap: () => onTabSelected(0),
            ),
            _NavTab(
              iconPath: AppIcons.list,
              label: 'Мероприятия',
              selected: currentIndex == 1,
              onTap: () => onTabSelected(1),
            ),
            _CreateNavButton(onTap: onCreatePressed),
            _NavTab(
              iconPath: AppIcons.friends,
              label: 'Друзья',
              selected: currentIndex == 2,
              onTap: () => onTabSelected(2),
            ),
            _NavTab(
              iconPath: AppIcons.user,
              label: 'Профиль',
              selected: currentIndex == 3,
              onTap: () => onTabSelected(3),
            ),
          ],
        ),
      ),
    );
  }
}

class _NavTab extends StatelessWidget {
  const _NavTab({
    required this.iconPath,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String iconPath;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = selected ? AppColors.purple500 : AppColors.gray100;

    return Expanded(
      child: CustomBounceEffect(
        onTap: onTap,
        child: ColoredBox(
          color: Colors.transparent,
          child: SizedBox.expand(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SvgIcon(iconPath, size: 24, color: color),
                const SizedBox(height: 4),
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: 'Outfit',
                    fontSize: 11,
                    fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                    color: color,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _CreateNavButton extends StatelessWidget {
  const _CreateNavButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Center(
        child: AppButton(
          onTap: onTap,
          icon: AppIcons.create,
          style: AppButtonStyle(
            width: 48,
            height: 48,
            padding: EdgeInsets.zero,
            iconSize: 24,
            iconColor: AppColors.gray0,
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [AppColors.purple500, AppColors.pink500],
            ),
            border: const AppButtonBorder(borderRadius: 24),
          ),
        ),
      ),
    );
  }
}
