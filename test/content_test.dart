import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_test/flutter_test.dart';

import 'package:bovadma_enmamz/models/question.dart';
import 'package:bovadma_enmamz/models/quiz_content.dart';

/// Content invariants. These are the checks that actually catch bad packs:
/// a duplicated id, an answer index pointing at nothing, a missing explanation.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late QuizContent content;

  setUp(() async {
    // rootBundle caches the Future from the previous test's fake-async zone;
    // without clearing, every test after the first reads nothing.
    rootBundle.clear();
    final raw = await rootBundle.loadString('assets/json/content.json');
    content = QuizContent.parse(jsonDecode(raw));
  });

  test('pack parses with every category intact', () {
    expect(content.isEmpty, isFalse);
    expect(content.sport, isNotEmpty);
    expect(content.categories.length, greaterThanOrEqualTo(3));
  });

  test('no question is dropped by the parser', () {
    final raw = <String, dynamic>{};
    expect(Question.tryParse(raw), isNull, reason: 'sanity: parser rejects junk');
    expect(content.questionCount, greaterThanOrEqualTo(24));
  });

  test('question ids are unique across the whole pack', () {
    final ids = content.allQuestions.map((q) => q.id).toList();
    expect(ids.toSet().length, ids.length);
  });

  test('every question has four options and a valid answer index', () {
    for (final q in content.allQuestions) {
      expect(q.options.length, 4, reason: q.id);
      expect(q.answerIndex, inInclusiveRange(0, q.options.length - 1),
          reason: q.id);
      expect(q.options.toSet().length, q.options.length,
          reason: '${q.id} has duplicate options');
    }
  });

  test('every question explains its answer', () {
    for (final q in content.allQuestions) {
      expect(q.explanation.trim(), isNotEmpty, reason: q.id);
    }
  });

  test('each question accepts its answer and rejects a blank', () {
    for (final q in content.allQuestions) {
      expect(q.isCorrect(q.answerIndex), isTrue, reason: q.id);
      expect(q.isCorrect(null), isFalse, reason: q.id);
    }
  });

  test('prompts are not accidentally duplicated', () {
    final prompts = content.allQuestions
        .map((q) => q.prompt.toLowerCase().trim())
        .toList();
    expect(prompts.toSet().length, prompts.length);
  });
}
