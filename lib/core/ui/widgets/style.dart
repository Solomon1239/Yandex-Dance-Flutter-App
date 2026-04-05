import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class AppColors {
  static const Color white = Color(0xffFFFFFF);
  static const Color black = Color(0xff000000);
  static const Color gray = Color(0xff929191);

  static const Color backgroundSecondary = Color(0xffE6E6E6);

  static const Color blueLight = Color(0xffF0981A);
  static const Color blue = Color(0xffFD592F);

  static LinearGradient mainGradient = const LinearGradient(
    colors: [blueLight, blue],
    begin: Alignment.topRight,
    end: Alignment.bottomCenter,
  );
}

class AppFontFamily {
  static const String primary = 'Montserrat';
}

class AppDuration {
  static const Duration ms50 = Duration(milliseconds: 50);
  static const Duration ms150 = Duration(milliseconds: 150);
  static const Duration ms250 = Duration(milliseconds: 250);
  static const Duration ms400 = Duration(milliseconds: 400);
  static const Duration ms500 = Duration(milliseconds: 500);
  static const Duration ms750 = Duration(milliseconds: 750);
  static const Duration ms1500 = Duration(milliseconds: 1500);
  static const Duration ms2500 = Duration(milliseconds: 2500);
  static const Duration s1 = Duration(seconds: 1);
  static const Duration s3 = Duration(seconds: 3);
  static const Duration s5 = Duration(seconds: 5);
  static const Duration s15 = Duration(seconds: 15);
}

class AppSize {
  static double bottomSafeArea(BuildContext context) =>
      MediaQuery.of(context).padding.bottom == 0
          ? 16
          : MediaQuery.of(context).padding.bottom;
  static double topSafeArea(BuildContext context) =>
      MediaQuery.of(context).padding.top;
  static double screenWidth(BuildContext context) =>
      MediaQuery.of(context).size.width;
  static double screenHeight(BuildContext context) =>
      MediaQuery.of(context).size.height;
  static double keyboardPadding(BuildContext context) =>
      MediaQuery.of(context).viewInsets.bottom;
  static double horizontalPadding = 16;
}

class AppAnimationEffects {
  // Виджет появляется изза экрана и достигая своего места немного сжимается
  //и потом возвращается к своему нормальному размеру
  //(fromRight - регулирует с какой стороны появится виджет)
  static slideAndCompression(
    bool fromRight, {
    Duration duration = AppDuration.ms150,
    Duration delay = Duration.zero,
  }) => <Effect>[
    SlideEffect(
      begin: Offset(fromRight ? 1 : -1, 0),
      end: const Offset(0, 0),
      duration: duration,
      delay: delay,
    ),
    ScaleEffect(
      begin: Offset(1, 1),
      end: Offset(0.5, 1.3),
      duration: duration,
      delay: duration + delay,
    ),
    ScaleEffect(
      begin: Offset(1, 1),
      end: Offset(2, 0.77),
      duration: duration,
      delay: duration * 2 + delay,
    ),
  ];
  // Виджет появляется увеличивается и вращается
  static fadeAndRotate({
    Duration duration = AppDuration.ms500,
    Duration delay = Duration.zero,
  }) => <Effect>[
    ScaleEffect(duration: duration, delay: delay),
    ShakeEffect(rotation: 3),
  ];

  // Виджет появляется с увеличением и прозрачностью
  static fadeInAndScale({
    Duration duration = AppDuration.ms400,
    Duration delay = Duration.zero,
  }) => <Effect>[
    FadeEffect(begin: 0, end: 1, duration: duration, delay: delay),
    ScaleEffect(
      begin: Offset(0.5, 0.5),
      end: Offset(1, 1),
      duration: duration,
      delay: delay,
    ),
  ];

  // Виджет появляется с пульсацией и перемещением по оси Y
  static pulseAndSlideY({
    Duration duration = AppDuration.ms400,
    Duration delay = Duration.zero,
  }) => <Effect>[
    ScaleEffect(
      begin: Offset(0.6, 0.6),
      end: Offset(1.2, 1.2),
      duration: duration,
      delay: delay,
    ),
    ScaleEffect(
      begin: Offset(1, 1),
      end: Offset(0.85, 0.85),
      duration: duration,
      delay: duration * 0.5,
    ),
    SlideEffect(
      begin: const Offset(0, -2),
      end: const Offset(0, 0),
      duration: duration,
      delay: delay,
    ),
  ];

  // Виджет появляется с эффектом "прыжка" и затем размытия
  static bounceAndBlur({
    Duration duration = AppDuration.ms500,
    Duration delay = Duration.zero,
  }) => <Effect>[
    ScaleEffect(
      begin: Offset(0, 0),
      end: Offset(1.2, 1.2),
      duration: duration,
      delay: delay,
    ),
    ScaleEffect(
      begin: Offset(1, 1),
      end: Offset(0.85, 0.85),
      duration: duration,
      delay: duration,
    ),
    BlurEffect(
      begin: Offset(5, 5),
      end: Offset(0, 0),
      duration: duration,
      delay: duration,
    ),
  ];

  // Виджет плавно появляется с эффектом волн и последующим сжатием
  static waveAndCompress({
    Duration duration = AppDuration.ms500,
    Duration delay = Duration.zero,
  }) => <Effect>[
    FadeEffect(begin: 0, end: 1, duration: duration, delay: delay),
    SlideEffect(
      begin: const Offset(0, -2),
      end: const Offset(0, 0),
      duration: duration,
      delay: duration,
    ),
    ScaleEffect(
      begin: Offset(1, 1),
      end: Offset(1.1, 0.9),
      duration: duration * 0.8,
      delay: duration * 0.3,
    ),
    ScaleEffect(
      begin: Offset(1.1, 0.9),
      end: Offset(0.93, 1.04),
      duration: duration * 0.2,
      delay: duration * 0.8,
    ),
  ];

  // Виджет появляется с эффектом "сжатия и расширения" по оси X и Y с эффектом ротации
  static stretchAndRotate({
    Duration duration = AppDuration.ms750,
    Duration delay = Duration.zero,
  }) => <Effect>[
    ScaleEffect(
      begin: Offset(0, 0),
      end: Offset(1.2, 1.2),
      duration: duration,
      delay: delay,
    ),
    RotateEffect(begin: 0, end: 1, duration: duration, delay: duration * 0.5),
    ScaleEffect(
      begin: Offset(1.2, 1.2),
      end: Offset(0.85, 0.85),
      duration: duration * 0.5,
      delay: duration * 0.7,
    ),
  ];
}
