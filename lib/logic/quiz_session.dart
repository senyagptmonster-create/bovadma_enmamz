import 'dart:math';

import 'package:flutter/foundation.dart';

import '../models/question.dart';

/// One round. Plain [ChangeNotifier] with no widget imports, so the whole
/// round can be exercised without building any UI.
class QuizSession extends ChangeNotifier {
  final String categoryId;
  final String categoryName;
  final List<Question> questions;

  final List<int?> _answers;
  int _index = 0;
  bool _revealed = false;

  QuizSession({
    required this.categoryId,
    required this.categoryName,
    required this.questions,
  }) : _answers = List<int?>.filled(questions.length, null);

  /// Builds a round from [pool]: shuffles, then takes at most [limit].
  factory QuizSession.fromPool({
    required String categoryId,
    required String categoryName,
    required List<Question> pool,
    int limit = 8,
    Random? random,
  }) {
    final shuffled = List<Question>.of(pool)..shuffle(random ?? Random());
    final take = limit <= 0 ? shuffled.length : min(limit, shuffled.length);
    return QuizSession(
      categoryId: categoryId,
      categoryName: categoryName,
      questions: shuffled.sublist(0, take),
    );
  }

  int get index => _index;
  int get total => questions.length;
  bool get revealed => _revealed;
  bool get isEmpty => questions.isEmpty;

  Question get current => questions[_index];
  int? get selected => _answers[_index];

  bool get isLastQuestion => _index >= total - 1;
  bool get isFinished => _index >= total;

  int get correctCount {
    var count = 0;
    for (var i = 0; i < questions.length; i++) {
      if (questions[i].isCorrect(_answers[i])) count++;
    }
    return count;
  }

  int get scorePercent =>
      total == 0 ? 0 : ((correctCount / total) * 100).round();

  double get progress => total == 0 ? 0 : (_index + (_revealed ? 1 : 0)) / total;

  int? answerAt(int i) =>
      (i >= 0 && i < _answers.length) ? _answers[i] : null;

  /// Locks in an answer for the current question. Ignored once revealed, so a
  /// double tap cannot overwrite the first choice.
  void answer(int optionIndex) {
    if (_revealed || isFinished) return;
    if (optionIndex < 0 || optionIndex >= current.options.length) return;

    _answers[_index] = optionIndex;
    _revealed = true;
    notifyListeners();
  }

  void next() {
    if (!_revealed || isFinished) return;
    _index++;
    _revealed = false;
    notifyListeners();
  }

  void restart() {
    for (var i = 0; i < _answers.length; i++) {
      _answers[i] = null;
    }
    _index = 0;
    _revealed = false;
    notifyListeners();
  }
}
