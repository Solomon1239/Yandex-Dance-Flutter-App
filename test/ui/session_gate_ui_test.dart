import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:yandex_dance/features/session/presentation/pages/session_gate_page.dart';

import '../helpers/test_binding.dart';
import 'ui_test_app.dart';

void main() {
  setUpAll(ensureTestWidgetsBinding);

  group('SessionGatePage (UI)', () {
    testWidgets('показывает индикатор загрузки', (tester) async {
      await tester.pumpWidget(
        wrapWithAppTheme(const SessionGatePage()),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });
  });
}
