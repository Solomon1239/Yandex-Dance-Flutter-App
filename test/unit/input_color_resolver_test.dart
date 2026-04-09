import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:yandex_dance/core/ui/colors/colors.dart';
import 'package:yandex_dance/core/ui/colors/input_color.dart';

void main() {
  group('InputColorResolver', () {
    Future<InputColorResolver> resolver(
      WidgetTester tester,
      InputState state,
    ) async {
      late InputColorResolver r;
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              r = InputColorResolver(state: state, context: context);
              return const SizedBox.shrink();
            },
          ),
        ),
      );
      return r;
    }

    testWidgets('textColor для основных состояний', (tester) async {
      final initial = await resolver(tester, InputState.initial);
      expect(initial.textColor, AppColors.inputTextTertiary);

      final typing = await resolver(tester, InputState.typing);
      expect(typing.textColor, AppColors.inputTextPrimary);

      final error = await resolver(tester, InputState.error);
      expect(error.textColor, AppColors.inputTextNegative);
    });

    testWidgets('borderColor для success и disabled', (tester) async {
      final success = await resolver(tester, InputState.success);
      expect(success.borderColor, AppColors.inputTextPositive);

      final disabled = await resolver(tester, InputState.disabled);
      expect(disabled.borderColor, AppColors.inputBorderDisabled);
    });

    testWidgets('cursor и hint не зависят от state', (tester) async {
      final a = await resolver(tester, InputState.initial);
      final b = await resolver(tester, InputState.error);
      expect(a.cursorColor, b.cursorColor);
      expect(a.hintColor, b.hintColor);
    });
  });
}
