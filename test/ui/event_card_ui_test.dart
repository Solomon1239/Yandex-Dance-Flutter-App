import 'package:flutter_test/flutter_test.dart';
import 'package:yandex_dance/features/events/presentation/widgets/event_card.dart';

import '../helpers/test_binding.dart';
import 'ui_test_app.dart';

void main() {
  setUpAll(ensureTestWidgetsBinding);

  group('EventCard (UI)', () {
    testWidgets('compact: отображает заголовок и метки', (tester) async {
      await tester.pumpWidget(
        wrapWithAppTheme(
          const EventCard(
            compact: true,
            title: 'UI Jam',
            styleLabel: 'House',
            dateLabel: '10.04.2026, 20:00',
            locationLabel: 'Москва',
            participantsLabel: '5/20',
          ),
        ),
      );

      expect(find.text('UI Jam'), findsOneWidget);
      expect(find.text('House'), findsOneWidget);
      expect(find.textContaining('10.04.2026'), findsOneWidget);
    });

    testWidgets('onTap вызывается по нажатию', (tester) async {
      var tapped = false;
      await tester.pumpWidget(
        wrapWithAppTheme(
          EventCard(
            compact: true,
            title: 'Tappable',
            onTap: () => tapped = true,
          ),
        ),
      );

      await tester.tap(find.text('Tappable'));
      await tester.pumpAndSettle();
      expect(tapped, isTrue);
    });
  });
}
