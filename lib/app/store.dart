import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

/// Local persistence for every app in the series. No account, no network, no
/// storage permission — SharedPreferences only.
///
/// Every method swallows platform failures and returns a neutral value: a
/// tracker that cannot save must still open.
class Store {
  Store._();

  static SharedPreferences? _prefs;

  static Future<void> init() async {
    try {
      _prefs = await SharedPreferences.getInstance();
    } catch (_) {
      _prefs = null;
    }
  }

  static Future<SharedPreferences?> _instance() async {
    final existing = _prefs;
    if (existing != null) return existing;
    await init();
    return _prefs;
  }

  static Future<int> getInt(String key, {int fallback = 0}) async {
    final p = await _instance();
    return p?.getInt(key) ?? fallback;
  }

  static Future<void> setInt(String key, int value) async {
    final p = await _instance();
    try {
      await p?.setInt(key, value);
    } catch (_) {}
  }

  static Future<double> getDouble(String key, {double fallback = 0}) async {
    final p = await _instance();
    return p?.getDouble(key) ?? fallback;
  }

  static Future<void> setDouble(String key, double value) async {
    final p = await _instance();
    try {
      await p?.setDouble(key, value);
    } catch (_) {}
  }

  static Future<bool> getBool(String key, {bool fallback = false}) async {
    final p = await _instance();
    return p?.getBool(key) ?? fallback;
  }

  static Future<void> setBool(String key, bool value) async {
    final p = await _instance();
    try {
      await p?.setBool(key, value);
    } catch (_) {}
  }

  static Future<Set<String>> getStringSet(String key) async {
    final p = await _instance();
    return (p?.getStringList(key) ?? const <String>[]).toSet();
  }

  static Future<void> setStringSet(String key, Set<String> value) async {
    final p = await _instance();
    try {
      await p?.setStringList(key, value.toList());
    } catch (_) {}
  }

  /// A list of JSON objects — the shape every log and history screen needs.
  /// A corrupt entry is dropped rather than thrown.
  static Future<List<Map<String, dynamic>>> getRecords(String key) async {
    final p = await _instance();
    final raw = p?.getStringList(key) ?? const <String>[];
    final out = <Map<String, dynamic>>[];
    for (final item in raw) {
      try {
        final decoded = jsonDecode(item);
        if (decoded is Map<String, dynamic>) out.add(decoded);
      } catch (_) {
        // skip the bad row, keep the rest
      }
    }
    return out;
  }

  static Future<void> setRecords(
    String key,
    List<Map<String, dynamic>> records,
  ) async {
    final p = await _instance();
    try {
      await p?.setStringList(key, [for (final r in records) jsonEncode(r)]);
    } catch (_) {}
  }

  static Future<void> addRecord(
    String key,
    Map<String, dynamic> record, {
    int limit = 500,
  }) async {
    final records = await getRecords(key);
    records.insert(0, record);
    if (records.length > limit) records.removeRange(limit, records.length);
    await setRecords(key, records);
  }

  static Future<void> remove(String key) async {
    final p = await _instance();
    try {
      await p?.remove(key);
    } catch (_) {}
  }
}
