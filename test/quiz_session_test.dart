import 'dart:math';

import 'package:flutter_test/flutter_test.dart';

import 'package:bovadma_enmamz/logic/quiz_session.dart';
import 'package:bovadma_enmamz/models/question.dart';

Question _q(String id, int answer) => Question(
  id: id,
  prompt: 'Prompt $id',
  options: const ['A', 'B', 'C', 'D'],
  answerIndex: answer,
  explanation: 'Because $id',
);

QuizSession _session(List<Question> questions) => QuizSession(
  categoryId: 'test',
  categoryName: 'Test',
  questions: questions,
);

void main() {
  test('scores only the answers that were correct', () {
    final session = _session([_q('a', 0), _q('b', 1), _q('c', 2)]);

    session.answer(0);
    session.next();
    session.answer(3);
    session.next();
    session.answer(2);

    expect(session.correctCount, 2);
    expect(session.scorePercent, 67);
  });

  test('a second tap cannot overwrite the locked answer', () {
    final session = _session([_q('a', 0)]);

    session.answer(1);
    session.answer(0);

    expect(session.selected, 1);
    expect(session.correctCount, 0);
  });

  test('next is ignored until the current question is revealed', () {
    final session = _session([_q('a', 0), _q('b', 0)]);

    session.next();
    expect(session.index, 0);

    session.answer(0);
    session.next();
    expect(session.index, 1);
  });

  test('out of range answers are ignored', () {
    final session = _session([_q('a', 0)]);

    session.answer(99);
    session.answer(-1);

    expect(session.revealed, isFalse);
    expect(session.selected, isNull);
  });

  test('restart clears every answer', () {
    final session = _session([_q('a', 0), _q('b', 1)]);

    session.answer(0);
    session.next();
    session.answer(1);
    expect(session.correctCount, 2);

    session.restart();

    expect(session.index, 0);
    expect(session.revealed, isFalse);
    expect(session.correctCount, 0);
  });

  test('fromPool never asks for more questions than exist', () {
    final pool = [_q('a', 0), _q('b', 1), _q('c', 2)];
    final session = QuizSession.fromPool(
      categoryId: 'test',
      categoryName: 'Test',
      pool: pool,
      limit: 8,
      random: Random(1),
    );

    expect(session.total, 3);
    expect(session.questions.map((q) => q.id).toSet().length, 3);
  });

  test('an empty pool produces an empty, finished session', () {
    final session = QuizSession.fromPool(
      categoryId: 'test',
      categoryName: 'Test',
      pool: const [],
    );

    expect(session.isEmpty, isTrue);
    expect(session.isFinished, isTrue);
    expect(session.scorePercent, 0);
  });
}
