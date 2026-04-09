import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers/test_binding.dart';

/// Базовый widget/smoke-тест. Полноценный [DanceApp] с Firebase — в
/// `integration_test/` или с моками DI (см. `test/helpers/`).
void main() {
  setUpAll(ensureTestWidgetsBinding);

  testWidgets('MaterialApp с текстом отрисовывается', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Center(child: Text('yandex_dance test')),
        ),
      ),
    );

    expect(find.text('yandex_dance test'), findsOneWidget);
  });
}
