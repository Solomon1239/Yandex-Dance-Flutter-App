import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:yandex_dance/features/friends/presentation/widgets/coach_avatar_image_provider.dart';

import '../helpers/test_binding.dart';

void main() {
  setUpAll(ensureTestWidgetsBinding);

  group('coachAvatarImageProvider', () {
    test('пустой и null URL → fallback CachedNetworkImageProvider', () {
      expect(
        coachAvatarImageProvider(null),
        isA<CachedNetworkImageProvider>(),
      );
      expect(
        coachAvatarImageProvider(''),
        isA<CachedNetworkImageProvider>(),
      );
    });

    test('непустой URL', () {
      final p = coachAvatarImageProvider('https://example.com/x.jpg');
      expect(p, isA<CachedNetworkImageProvider>());
    });
  });
}
