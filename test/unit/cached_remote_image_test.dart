import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:yandex_dance/core/ui/media/cached_remote_image.dart';

import '../helpers/test_binding.dart';

void main() {
  setUpAll(ensureTestWidgetsBinding);

  group('cachedNetworkImageProviderOrNull', () {
    test('null, пустая строка и пробелы → null', () {
      expect(cachedNetworkImageProviderOrNull(null), isNull);
      expect(cachedNetworkImageProviderOrNull(''), isNull);
      expect(cachedNetworkImageProviderOrNull('   '), isNull);
    });

    test('валидный URL → CachedNetworkImageProvider', () {
      final p = cachedNetworkImageProviderOrNull('https://example.com/a.png');
      expect(p, isA<CachedNetworkImageProvider>());
    });
  });
}
