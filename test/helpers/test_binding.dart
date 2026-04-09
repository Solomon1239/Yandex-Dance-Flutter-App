import 'package:flutter_test/flutter_test.dart';

/// Вызывать в [setUpAll], если тест трогает виджеты, [ImageProvider], плагины или
/// `WidgetsBinding.instance`.
void ensureTestWidgetsBinding() {
  TestWidgetsFlutterBinding.ensureInitialized();
}
