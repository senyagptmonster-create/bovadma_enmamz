import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;

import '../models/quiz_content.dart';

/// Loads the offline question pack. Everything ships in the bundle — no network
/// call is involved in the product itself.
class QuizRepository {
  static const String assetPath = 'assets/json/content.json';

  QuizContent? _cached;

  Future<QuizContent> load() async {
    final cached = _cached;
    if (cached != null) return cached;

    QuizContent content;
    try {
      final raw = await rootBundle.loadString(assetPath);
      content = QuizContent.parse(jsonDecode(raw));
    } catch (_) {
      // Missing or corrupt asset must degrade to an empty state, not a crash.
      content = QuizContent.empty;
    }

    _cached = content;
    return content;
  }
}
