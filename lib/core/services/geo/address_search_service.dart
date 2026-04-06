import 'dart:convert';

import 'package:http/http.dart' as http;

import 'address_suggestion.dart';

class AddressSearchService {
  AddressSearchService({http.Client? client, String? token})
    : _client = client ?? http.Client(),
      _token = token ?? _tokenFromEnv;

  final http.Client _client;
  final String _token;

  static const _tokenFromEnv = String.fromEnvironment('DADATA_TOKEN');
  static const _endpoint =
      'https://suggestions.dadata.ru/suggestions/api/4_1/rs/suggest/address';

  Future<List<AddressSuggestion>> search(String query) async {
    final trimmed = query.trim();
    if (trimmed.length < 3) return const [];
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
          'count': 8,
          'locations': [
            {'country': 'Россия'},
          ],
        }),
      );

      if (response.statusCode != 200) return const [];

      final decoded = json.decode(utf8.decode(response.bodyBytes));
      final suggestions = (decoded['suggestions'] as List?) ?? const [];

      final result = <AddressSuggestion>[];
      final seen = <String>{};

      for (final item in suggestions) {
        if (item is! Map<String, dynamic>) continue;
        final data = item['data'] as Map<String, dynamic>?;
        if (data == null) continue;

        final lat = _asDouble(data['geo_lat']);
        final lon = _asDouble(data['geo_lon']);
        if (lat == null || lon == null) continue;

        final label = (item['value'] as String?)?.trim();
        if (label == null || label.isEmpty) continue;
        if (!seen.add(label)) continue;

        result.add(
          AddressSuggestion(displayLabel: label, latitude: lat, longitude: lon),
        );
      }

      return result;
    } catch (_) {
      return const [];
    }
  }

  double? _asDouble(dynamic value) {
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }

  void dispose() {
    _client.close();
  }
}
