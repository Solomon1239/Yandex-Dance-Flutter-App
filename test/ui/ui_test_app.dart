import 'package:flutter/material.dart';
import 'package:yandex_dance/core/theme/app_theme.dart';

Widget wrapWithAppTheme(Widget child) {
  return MaterialApp(
    theme: AppTheme.dark(),
    home: Scaffold(body: child),
  );
}
