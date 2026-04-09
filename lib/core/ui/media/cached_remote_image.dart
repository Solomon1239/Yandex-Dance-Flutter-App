import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/painting.dart';

/// Дисковый кеш URL-картинок (через [CachedNetworkImageProvider] / flutter_cache_manager).
/// Использовать вместо [NetworkImage] для обложек и аватаров по HTTP(S).
ImageProvider<Object>? cachedNetworkImageProviderOrNull(String? url) {
  final value = url?.trim();
  if (value == null || value.isEmpty) {
    return null;
  }
  return CachedNetworkImageProvider(value);
}
