import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/painting.dart';

/// Аватар тренера из сети — тот же подход, что в [ProfileAvatar]
/// (`CachedNetworkImageProvider`), с запасным портретом если URL пустой.
ImageProvider<Object> coachAvatarImageProvider(String? url) {
  final u = url?.trim() ?? '';
  if (u.isEmpty) {
    return CachedNetworkImageProvider(_fallbackCoachAvatarUrl);
  }
  return CachedNetworkImageProvider(u);
}

/// Статичный портрет randomuser.me (без hotlink-ограничений вроде picsum).
const _fallbackCoachAvatarUrl =
    'https://randomuser.me/api/portraits/lego/1.jpg';
