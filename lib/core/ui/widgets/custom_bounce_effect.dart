import 'package:flutter/material.dart';

class CustomBounceEffect extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final Duration? duration;
  const CustomBounceEffect({
    super.key,
    required this.child,
    required this.onTap,
    this.duration,
    this.onLongPress,
  });

  @override
  State<CustomBounceEffect> createState() => _CustomBounceEffectState();
}

class _CustomBounceEffectState extends State<CustomBounceEffect> with SingleTickerProviderStateMixin {
  double _scale = 1;
  late AnimationController _animationController;

  @override
  void initState() {
    _animationController = AnimationController(
      vsync: this,
      duration: widget.duration ?? const Duration(milliseconds: 80),
      lowerBound: 0.0,
      upperBound: 0.1,
    )..addListener(() {
        setState(() {
          _scale = 1 - _animationController.value;
        });
      });

    super.initState();
  }

  @override
  void dispose() {
    _animationController.reverse();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () async {
        await _tapDown();
        if (widget.onTap != null) {
          widget.onTap!();
        }
        _tapUp();
      },
      onLongPress: () async {
        await _tapDown();
        if (widget.onLongPress != null) {
          widget.onLongPress!();
        }
      },
      onTapDown: (details) => _tapDown(),
      onLongPressDown: (details) => _tapDown(),
      onTapUp: (details) => _tapUp(),
      onLongPressUp: () => _tapUp(),
      onTapCancel: () => _tapUp(),
      onLongPressCancel: () => _tapUp(),
      child: Transform.scale(
        scale: _scale,
        child: widget.child,
      ),
    );
  }

  Future<void> _tapDown() async {
    await _animationController.forward();
  }

  void _tapUp() async {
    await _animationController.reverse();
  }
}
