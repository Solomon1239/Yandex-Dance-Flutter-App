import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
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
              staggerIndex: 0,
            ),
            _NavTab(
              iconPath: AppIcons.list,
              label: 'Мероприятия',
              selected: currentIndex == 1,
              onTap: () => onTabSelected(1),
              staggerIndex: 1,
            ),
            _CreateNavButton(onTap: onCreatePressed),
            _NavTab(
              iconPath: AppIcons.friends,
              label: 'Друзья',
              selected: currentIndex == 2,
              onTap: () => onTabSelected(2),
              staggerIndex: 2,
            ),
            _NavTab(
              iconPath: AppIcons.user,
              label: 'Профиль',
              selected: currentIndex == 3,
              onTap: () => onTabSelected(3),
              staggerIndex: 3,
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
    required this.staggerIndex,
  });

  final String iconPath;
  final String label;
  final bool selected;
  final VoidCallback onTap;
  final int staggerIndex;

  @override
  Widget build(BuildContext context) {
    final color = selected ? AppColors.purple500 : AppColors.gray100;
    final delayMs = 45 * staggerIndex;

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
                        fontWeight:
                            selected ? FontWeight.w600 : FontWeight.w400,
                        color: color,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        )
        .animate()
        .fadeIn(
          delay: Duration(milliseconds: delayMs),
          duration: const Duration(milliseconds: 320),
          curve: Curves.easeOutCubic,
        )
        .slideY(
          begin: 10,
          end: 0,
          delay: Duration(milliseconds: delayMs),
          duration: const Duration(milliseconds: 380),
          curve: Curves.easeOutCubic,
        );
  }
}

class _CreateNavButton extends StatefulWidget {
  const _CreateNavButton({required this.onTap});

  final VoidCallback onTap;

  @override
  State<_CreateNavButton> createState() => _CreateNavButtonState();
}

class _CreateNavButtonState extends State<_CreateNavButton>
    with TickerProviderStateMixin {
  late final AnimationController _entranceController;
  late final Animation<double> _entranceScale;
  late final Animation<double> _entranceOpacity;
  late final Animation<double> _entranceSlideY;
  late final Animation<double> _entranceTurn;
  late final AnimationController _pulseController;
  late final Animation<double> _pulseScale;
  late final Animation<double> _glowStrength;
  late final AnimationController _gradientController;

  @override
  void initState() {
    super.initState();
    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 620),
    );
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    );
    _gradientController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    );

    final entranceCurve = CurvedAnimation(
      parent: _entranceController,
      curve: Curves.easeOutCubic,
    );

    _entranceScale = Tween<double>(begin: 0.72, end: 1).animate(
      CurvedAnimation(parent: _entranceController, curve: Curves.easeOutBack),
    );
    _entranceOpacity = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0, 0.5, curve: Curves.easeOut),
      ),
    );
    _entranceSlideY = Tween<double>(begin: 14, end: 0).animate(entranceCurve);
    _entranceTurn = Tween<double>(begin: 0.14, end: 0).animate(
      CurvedAnimation(parent: _entranceController, curve: Curves.easeOutBack),
    );
    _pulseScale = Tween<double>(begin: 1, end: 1.09).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    _glowStrength = Tween<double>(begin: 0.24, end: 0.4).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _entranceController.forward().then((_) {
      if (mounted) {
        _pulseController.repeat(reverse: true);
        _gradientController.repeat(reverse: true);
      }
    });
  }

  @override
  void dispose() {
    _entranceController.dispose();
    _pulseController.dispose();
    _gradientController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Center(
        child: AnimatedBuilder(
          animation: Listenable.merge([
            _entranceController,
            _pulseController,
            _gradientController,
          ]),
          builder: (context, child) {
            final entranceDone = _entranceController.isCompleted;
            final scale =
                entranceDone ? _pulseScale.value : _entranceScale.value;
            final gradientProgress = Curves.easeInOutSine.transform(
              _gradientController.value,
            );
            final primaryColor =
                Color.lerp(
                  AppColors.purple500,
                  AppColors.pink500,
                  gradientProgress * 0.55,
                )!;
            final secondaryColor =
                Color.lerp(
                  AppColors.pink500,
                  AppColors.purple500,
                  0.2 + gradientProgress * 0.45,
                )!;
            final highlightColor =
                Color.lerp(
                  AppColors.pink500,
                  Colors.white,
                  0.12 + gradientProgress * 0.1,
                )!;
            final buttonGradient = LinearGradient(
              begin: Alignment(-1 + gradientProgress * 0.9, -1),
              end: Alignment(1 - gradientProgress * 0.6, 1),
              colors: [primaryColor, highlightColor, secondaryColor],
              stops: const [0, 0.52, 1],
            );
            return Opacity(
              opacity: _entranceOpacity.value,
              child: Transform.translate(
                offset: Offset(0, entranceDone ? -4 : _entranceSlideY.value),
                child: Transform.rotate(
                  angle: entranceDone ? 0 : _entranceTurn.value,
                  child: Transform.scale(
                    scale: scale,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Container(
                          width: 72,
                          height: 72,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.pink500.withValues(
                                  alpha: _glowStrength.value,
                                ),
                                blurRadius: 30,
                                spreadRadius: 4,
                              ),
                              BoxShadow(
                                color: AppColors.purple500.withValues(
                                  alpha: 0.2,
                                ),
                                blurRadius: 18,
                                spreadRadius: 1,
                              ),
                            ],
                          ),
                        ),
                        Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.14),
                            ),
                          ),
                          child: ClipOval(
                            child: AppButton(
                              onTap: widget.onTap,
                              icon: AppIcons.create,
                              style: AppButtonStyle(
                                width: 60,
                                height: 60,
                                padding: EdgeInsets.zero,
                                iconSize: 28,
                                iconColor: AppColors.gray0,
                                gradient: buttonGradient,
                                border: const AppButtonBorder(borderRadius: 30),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
