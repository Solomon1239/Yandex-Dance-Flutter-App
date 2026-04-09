import 'package:flutter_test/flutter_test.dart';
import 'package:yandex_dance/core/ui/widgets/person_card/friend_card.dart';

import '../helpers/test_binding.dart';
import 'ui_test_app.dart';

void main() {
  setUpAll(ensureTestWidgetsBinding);

  group('FriendCard (UI)', () {
    testWidgets('отображает имя и стиль', (tester) async {
      await tester.pumpWidget(
        wrapWithAppTheme(
          const FriendCard(
            name: 'Тест Танцор',
            styleName: 'Hip-Hop · House',
            description: 'Краткое описание для UI-теста.',
          ),
        ),
      );

      expect(find.text('Тест Танцор'), findsOneWidget);
      expect(find.textContaining('Hip-Hop'), findsOneWidget);
    });

    testWidgets('onTap срабатывает', (tester) async {
      var tapped = false;
      await tester.pumpWidget(
        wrapWithAppTheme(
          FriendCard(
            name: 'A',
            styleName: 'S',
            description: 'D',
            onTap: () => tapped = true,
          ),
        ),
      );

      await tester.tap(find.text('A'));
      await tester.pump();
      expect(tapped, isTrue);
    });
  });
}
