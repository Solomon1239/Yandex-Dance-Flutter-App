import 'package:flutter_test/flutter_test.dart';
import 'package:yandex_dance/core/enums/dance_style.dart';

import '../fixtures/dance_event_fixtures.dart';

void main() {
  group('DanceEvent.copyWith', () {
    test('меняет title, сохраняет id', () {
      final base = DanceEventFixtures.minimal(id: 'e1', title: 'Old');
      final next = base.copyWith(title: 'New');
      expect(next.id, 'e1');
      expect(next.title, 'New');
      expect(next.danceStyle, DanceStyle.hipHop);
    });
  });
}
