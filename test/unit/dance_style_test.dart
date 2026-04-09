import 'package:flutter_test/flutter_test.dart';
import 'package:yandex_dance/core/enums/dance_style.dart';

void main() {
  group('DanceStyleX', () {
    test('code и fromCode согласованы для всех стилей', () {
      for (final style in DanceStyle.values) {
        expect(DanceStyleX.fromCode(style.code), style);
      }
    });

    test('неизвестный код даёт hipHop по умолчанию', () {
      expect(DanceStyleX.fromCode('unknown_style'), DanceStyle.hipHop);
    });

    test('title не пустой для каждого стиля', () {
      for (final style in DanceStyle.values) {
        expect(style.title.isNotEmpty, isTrue);
      }
    });
  });
}
