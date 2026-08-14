import 'package:flutter/material.dart';

import '../app/brand.dart';
import '../app/theme.dart';
import '../logic/quiz_session.dart';

class ReviewScreen extends StatelessWidget {
  final QuizSession session;

  const ReviewScreen({super.key, required this.session});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Review')),
      body: Container(
        decoration: AppTheme.pageBackground,
        child: SafeArea(
          top: false,
          child: ListView.separated(
            padding: const EdgeInsets.fromLTRB(18, 12, 18, 28),
            itemCount: session.questions.length,
            separatorBuilder: (_, _) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final question = session.questions[index];
              final selected = session.answerAt(index);
              final correct = question.isCorrect(selected);
              final tone = correct ? cCorrect : cWrong;

              return Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(AppTheme.cardRadius),
                  color: AppTheme.surface,
                  border: Border.all(color: tone.withValues(alpha: 0.5)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          correct
                              ? Icons.check_circle
                              : Icons.cancel_outlined,
                          size: 18,
                          color: tone,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            question.prompt,
                            style: TextStyle(
                              fontFamily: kFontFamily,
                              fontSize: 15.5,
                              height: 1.3,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.textPrimary,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    if (!correct)
                      _row(
                        'Your answer',
                        selected == null
                            ? 'Not answered'
                            : question.options[selected],
                        cWrong,
                      ),
                    _row('Correct answer', question.correctAnswer, cCorrect),
                    if (question.explanation.isNotEmpty) ...[
                      const SizedBox(height: 10),
                      Text(
                        question.explanation,
                        style: TextStyle(
                          fontFamily: kFontFamily,
                          fontSize: 13,
                          height: 1.4,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ],
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _row(String label, String value, Color tone) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 108,
            child: Text(
              label,
              style: TextStyle(
                fontFamily: kFontFamily,
                fontSize: 12.5,
                color: AppTheme.textMuted,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontFamily: kFontFamily,
                fontSize: 13.5,
                fontWeight: FontWeight.w600,
                color: tone,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
