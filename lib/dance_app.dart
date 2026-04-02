import 'package:flutter/material.dart';
import 'package:yandex_dance/features/test_app.dart';

class DanceApp extends StatelessWidget {
  const DanceApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(home: TestApp());
  }
}
