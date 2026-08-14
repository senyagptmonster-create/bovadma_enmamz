import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;

class LocationService {
  static const _timeoutPerRequest = Duration(seconds: 4);

  static const _headers = {
    'Accept': 'application/json',
    'User-Agent': 'Mozilla/5.0 (compatible; Flutter/1.0)',
  };

  static const List<String> _endpoints = [
    'https://ipapi.co/json/',
    'http://ip-api.com/json/',
    'https://ipwho.is/',
    'https://get.geojs.io/v1/ip/geo.json',
    'https://api.ip2location.io/?format=json',
  ];

  Future<String?> getCountryCode() async {
    for (final endpoint in _endpoints) {
      try {
        final code = await _fetchCountryFrom(endpoint);
        if (code != null && code.isNotEmpty) return code;
      } on TimeoutException {
        // try next
      } on FormatException {
        // try next
      } catch (_) {
        // сеть/CORS/мусор в ответе — пробуем следующий эндпоинт
      }
    }
    return null;
  }

  Future<String?> _fetchCountryFrom(String endpoint) async {
    final uri = Uri.parse(endpoint);
    final resp = await http
        .get(uri, headers: _headers)
        .timeout(_timeoutPerRequest);

    if (resp.statusCode != 200) return null;

    final contentType = resp.headers['content-type']?.toLowerCase() ?? '';
    if (!contentType.contains('application/json')) return null;

    final body = resp.body;
    if (body.isEmpty || body.trimLeft().startsWith('<')) return null;

    final dynamic decoded = jsonDecode(body);
    if (decoded is! Map<String, dynamic>) return null;

    final code =
        (decoded['country_code'] ?? decoded['countryCode'] ?? decoded['country'])
            ?.toString()
            .trim()
            .toUpperCase();

    if (code == null || code.isEmpty) return null;
    if (code.length != 2) return null;

    return code;
  }
}