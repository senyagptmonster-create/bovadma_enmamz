import 'package:shared_preferences/shared_preferences.dart';

/// Local-only progress. No account, no network, no permissions.
class ProgressStore {
  static const String _bestPrefix = 'best_pct_';
  static const String _roundsKey = 'rounds_played';
  static const String _answeredKey = 'answers_total';
  static const String _correctKey = 'answers_correct';

  SharedPreferences? _prefs;

  Future<SharedPreferences?> _instance() async {
    final existing = _prefs;
    if (existing != null) return existing;
    try {
      final prefs = await SharedPreferences.getInstance();
      _prefs = prefs;
      return prefs;
    } catch (_) {
      return null;
    }
  }

  Future<ProgressSnapshot> read() async {
    final prefs = await _instance();
    if (prefs == null) return ProgressSnapshot.empty;

    final best = <String, int>{};
    for (final key in prefs.getKeys()) {
      if (!key.startsWith(_bestPrefix)) continue;
      final value = prefs.getInt(key);
      if (value != null) best[key.substring(_bestPrefix.length)] = value;
    }

    return ProgressSnapshot(
      bestPercentByCategory: best,
      roundsPlayed: prefs.getInt(_roundsKey) ?? 0,
      answersTotal: prefs.getInt(_answeredKey) ?? 0,
      answersCorrect: prefs.getInt(_correctKey) ?? 0,
    );
  }

  /// Returns true when this round set a new personal best for [categoryId].
  Future<bool> recordRound({
    required String categoryId,
    required int correct,
    required int total,
  }) async {
    if (total <= 0) return false;

    final prefs = await _instance();
    if (prefs == null) return false;

    final percent = ((correct / total) * 100).round();
    final key = '$_bestPrefix$categoryId';
    final previous = prefs.getInt(key) ?? -1;
    final isBest = percent > previous;

    try {
      if (isBest) await prefs.setInt(key, percent);
      await prefs.setInt(_roundsKey, (prefs.getInt(_roundsKey) ?? 0) + 1);
      await prefs.setInt(
        _answeredKey,
        (prefs.getInt(_answeredKey) ?? 0) + total,
      );
      await prefs.setInt(
        _correctKey,
        (prefs.getInt(_correctKey) ?? 0) + correct,
      );
    } catch (_) {
      return false;
    }

    return isBest;
  }

  Future<void> reset() async {
    final prefs = await _instance();
    if (prefs == null) return;
    try {
      for (final key in prefs.getKeys().toList()) {
        if (key.startsWith(_bestPrefix) ||
            key == _roundsKey ||
            key == _answeredKey ||
            key == _correctKey) {
          await prefs.remove(key);
        }
      }
    } catch (_) {
      // Nothing actionable — the UI just keeps showing the old numbers.
    }
  }
}

class ProgressSnapshot {
  final Map<String, int> bestPercentByCategory;
  final int roundsPlayed;
  final int answersTotal;
  final int answersCorrect;

  const ProgressSnapshot({
    required this.bestPercentByCategory,
    required this.roundsPlayed,
    required this.answersTotal,
    required this.answersCorrect,
  });

  static const ProgressSnapshot empty = ProgressSnapshot(
    bestPercentByCategory: <String, int>{},
    roundsPlayed: 0,
    answersTotal: 0,
    answersCorrect: 0,
  );

  int? bestFor(String categoryId) => bestPercentByCategory[categoryId];

  int get accuracyPercent =>
      answersTotal == 0 ? 0 : ((answersCorrect / answersTotal) * 100).round();
}
