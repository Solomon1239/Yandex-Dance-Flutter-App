import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:yandex_dance/core/services/geo/city.dart';

class CitySearchService {
  CitySearchService({http.Client? client, String? token})
    : _client = client ?? http.Client(),
      _token = token ?? _tokenFromEnv;

  final http.Client _client;
  final String _token;

  static const _tokenFromEnv = String.fromEnvironment('DADATA_TOKEN');
  static const _endpoint =
      'https://suggestions.dadata.ru/suggestions/api/4_1/rs/suggest/address';

  Future<List<City>> search(String query) async {
    final trimmed = query.trim();
    if (trimmed.length < 2) return const [];
    if (_token.isEmpty) return const [];

    try {
      final response = await _client.post(
        Uri.parse(_endpoint),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Token $_token',
        },
        body: json.encode({
          'query': trimmed,
          'count': 10,
          'from_bound': {'value': 'city'},
          'to_bound': {'value': 'settlement'},
        }),
      );

      if (response.statusCode != 200) return const [];

      final decoded = json.decode(utf8.decode(response.bodyBytes));
      final suggestions = (decoded['suggestions'] as List?) ?? const [];

      final cities = <City>[];
      final seenFias = <String>{};

      for (final item in suggestions) {
        if (item is! Map<String, dynamic>) continue;
        final data = item['data'] as Map<String, dynamic>?;
        if (data == null) continue;

        final cityName = (data['city'] as String?)?.trim();
        final settlementName = (data['settlement'] as String?)?.trim();
        final name = (cityName?.isNotEmpty == true)
            ? cityName!
            : (settlementName?.isNotEmpty == true ? settlementName! : null);
        if (name == null) continue;

        final fiasId =
            (data['city_fias_id'] as String?) ??
            (data['settlement_fias_id'] as String?) ??
            (data['fias_id'] as String?);
        if (fiasId == null || fiasId.isEmpty) continue;
        if (!seenFias.add(fiasId)) continue;

        final region = (data['region_with_type'] as String?)?.trim();
        final showRegion =
            region != null &&
            region.isNotEmpty &&
            !region.toLowerCase().contains(name.toLowerCase());

        cities.add(
          City(name: name, fiasId: fiasId, region: showRegion ? region : null),
        );
      }

      return cities;
    } catch (_) {
      return const [];
    }
  }

  void dispose() {
    _client.close();
  }
}
