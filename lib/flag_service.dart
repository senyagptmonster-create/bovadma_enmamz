import 'dart:convert';
import 'package:flagsmith/flagsmith.dart';

class FlagService {
  static const String _apiKey = 'bhtEJievescgYYgXhfu7ge';

  FlagsmithClient? _flagsmithClient;
  bool showWebView = false;
  Map<String, String> webViewConfig = {};
  String? rawConfig;

  Future<void> init() async {
    try {
      _flagsmithClient = await FlagsmithClient.init(
        apiKey: _apiKey,
        config: const FlagsmithConfig(caches: false),
      );

      await _flagsmithClient!.getFeatureFlags(reload: true);

      final appConfigString = await _flagsmithClient!.getFeatureFlagValue(
        'appconfig',
      );

      rawConfig = appConfigString;

      if (appConfigString != null && appConfigString.isNotEmpty) {
        applyFromJson(appConfigString);
      } else {
        _reset();
      }
    } catch (_) {
      _reset();
    }
  }

  /// Применить конфиг из JSON-строки (используется при загрузке из кеша)
  void applyFromJson(String json) {
    try {
      final configJson = jsonDecode(json) as Map<String, dynamic>;
      showWebView = configJson['showWebView'] as bool? ?? false;
      final wvc = configJson['webViewConfig'] as Map<String, dynamic>? ?? {};
      webViewConfig = wvc.map((key, value) => MapEntry(key, value.toString()));
    } catch (_) {
      _reset();
    }
  }

  void _reset() {
    showWebView = false;
    webViewConfig = {};
  }

  void close() {
    _flagsmithClient?.close();
  }
}