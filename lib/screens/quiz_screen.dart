import 'package:flutter/material.dart';

import '../app/brand.dart';
import '../app/theme.dart';
import '../data/progress_store.dart';
import '../logic/quiz_session.dart';
import '../logic/round_spec.dart';
import '../widgets/answer_option.dart';
import 'result_screen.dart';

class QuizScreen extends StatefulWidget {
  final RoundSpec spec;
  final ProgressStore progressStore;

  const QuizScreen({
    super.key,
    required this.spec,
    required this.progressStore,
  });

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  late final QuizSession _session;
  bool _finishing = false;

  @override
  void initState() {
    super.initState();
    _session = QuizSession.fromPool(
      categoryId: widget.spec.categoryId,
      categoryName: widget.spec.categoryName,
      pool: widget.spec.pool,
      limit: widget.spec.limit,
    );
  }

  @override
  void dispose() {
    _session.dispose();
    super.dispose();
  }

  Future<void> _onNext() async {
    if (!_session.isLastQuestion) {
      _session.next();
      return;
    }
    if (_finishing) return;
    _finishing = true;

    final isBest = await widget.progressStore.recordRound(
      categoryId: _session.categoryId,
      correct: _session.correctCount,
      total: _session.total,
    );
    if (!mounted) return;

    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(
        builder: (_) => ResultScreen(
          spec: widget.spec,
          session: _session,
          isPersonalBest: isBest,
          progressStore: widget.progressStore,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: AppTheme.pageBackground,
        child: SafeArea(
          child: AnimatedBuilder(
            animation: _session,
            builder: (context, _) {
              if (_session.isEmpty) {
                return Center(
                  child: Text(
                    'No questions in this category.',
                    style: TextStyle(
                      fontFamily: kFontFamily,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                );
              }
              return _buildRound();
            },
          ),
        ),
      ),
    );
  }

  Widget _buildRound() {
    final question = _session.current;
    final revealed = _session.revealed;
    final selected = _session.selected;

    return Column(
      children: [
        _buildTopBar(),
        Expanded(
          // Scrollable: long questions on small screens must never overflow.
          child: ListView(
            padding: const EdgeInsets.fromLTRB(18, 6, 18, 12),
            children: [
              Text(
                _session.categoryName.toUpperCase(),
                style: TextStyle(
                  fontFamily: kFontFamily,
                  fontSize: 11.5,
                  letterSpacing: 1.2,
                  fontWeight: FontWeight.w700,
                  color: cAccent,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                question.prompt,
                style: TextStyle(
                  fontFamily: kFontFamily,
                  fontSize: 20,
                  height: 1.3,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 20),
              for (var i = 0; i < question.options.length; i++)
                AnswerOption(
                  label: question.options[i],
                  position: i,
                  selected: selected == i,
                  revealed: revealed,
                  isCorrect: i == question.answerIndex,
                  onTap: revealed ? null : () => _session.answer(i),
                ),
              if (revealed) ...[
                const SizedBox(height: 6),
                _buildExplanation(),
              ],
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(18, 4, 18, 14),
          child: FilledButton(
            onPressed: revealed ? _onNext : null,
            child: Text(
              _session.isLastQuestion ? 'See results' : 'Next question',
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(10, 6, 18, 10),
      child: Column(
        children: [
          Row(
            children: [
              IconButton(
                onPressed: () => Navigator.of(context).maybePop(),
                icon: const Icon(Icons.close_rounded),
                color: AppTheme.textSecondary,
                tooltip: 'Leave round',
              ),
              Expanded(
                child: Text(
                  'Question ${_session.index + 1} of ${_session.total}',
                  style: TextStyle(
                    fontFamily: kFontFamily,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textSecondary,
                  ),
                ),
              ),
              Text(
                '${_session.correctCount} correct',
                style: TextStyle(
                  fontFamily: kFontFamily,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: cCorrect,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: _buildProgress(),
          ),
        ],
      ),
    );
  }

  /// Segmented for the sharper variants, a continuous bar for the softer ones.
  Widget _buildProgress() {
    final segmented =
        kStyleVariant == StyleVariant.invert ||
        kStyleVariant == StyleVariant.outline;

    if (!segmented) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(6),
        child: LinearProgressIndicator(
          value: _session.progress,
          minHeight: 6,
          backgroundColor: AppTheme.surfaceBorder.withValues(alpha: 0.4),
          valueColor: const AlwaysStoppedAnimation<Color>(cAccent),
        ),
      );
    }

    return Row(
      children: [
        for (var i = 0; i < _session.total; i++)
          Expanded(
            child: Container(
              height: 6,
              margin: EdgeInsets.only(right: i == _session.total - 1 ? 0 : 4),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(2),
                color: i < _session.index || (i == _session.index && _session.revealed)
                    ? cAccent
                    : AppTheme.surfaceBorder.withValues(alpha: 0.4),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildExplanation() {
    final question = _session.current;
    final wasCorrect = question.isCorrect(_session.selected);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppTheme.cardRadius),
        color: (wasCorrect ? cCorrect : cWrong).withValues(alpha: 0.10),
        border: Border.all(
          color: (wasCorrect ? cCorrect : cWrong).withValues(alpha: 0.45),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                wasCorrect ? Icons.check_circle : Icons.info_rounded,
                size: 18,
                color: wasCorrect ? cCorrect : cWrong,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  wasCorrect
                      ? 'Correct'
                      : 'Answer: ${question.correctAnswer}',
                  style: TextStyle(
                    fontFamily: kFontFamily,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: wasCorrect ? cCorrect : cWrong,
                  ),
                ),
              ),
            ],
          ),
          if (question.explanation.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              question.explanation,
              style: TextStyle(
                fontFamily: kFontFamily,
                fontSize: 13.5,
                height: 1.4,
                color: AppTheme.textSecondary,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
