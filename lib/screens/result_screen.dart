import 'package:flutter/material.dart';

import '../app/brand.dart';
import '../app/theme.dart';
import '../data/progress_store.dart';
import '../logic/quiz_session.dart';
import '../logic/round_spec.dart';
import '../widgets/brand_mark.dart';
import 'quiz_screen.dart';
import 'review_screen.dart';

class ResultScreen extends StatelessWidget {
  final RoundSpec spec;
  final QuizSession session;
  final bool isPersonalBest;
  final ProgressStore progressStore;

  const ResultScreen({
    super.key,
    required this.spec,
    required this.session,
    required this.isPersonalBest,
    required this.progressStore,
  });

  String get _verdict {
    final percent = session.scorePercent;
    if (percent == 100) return 'Perfect round';
    if (percent >= 80) return 'Strong result';
    if (percent >= 50) return 'Solid effort';
    return 'Room to improve';
  }

  @override
  Widget build(BuildContext context) {
    final percent = session.scorePercent;

    return Scaffold(
      body: Container(
        decoration: AppTheme.pageBackground,
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(18, 24, 18, 24),
            children: [
              const Center(child: BrandMark(size: 56)),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 24,
                ),
                decoration: AppTheme.panel(accented: true),
                child: Column(
                  children: [
                    Text(
                      _verdict,
                      style: TextStyle(
                        fontFamily: kFontFamily,
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      session.categoryName,
                      style: TextStyle(
                        fontFamily: kFontFamily,
                        fontSize: 13,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 18),
                    Text(
                      '$percent%',
                      style: TextStyle(
                        fontFamily: kFontFamily,
                        fontSize: 52,
                        height: 1.0,
                        fontWeight: FontWeight.w800,
                        color: cAccent,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '${session.correctCount} of ${session.total} correct',
                      style: TextStyle(
                        fontFamily: kFontFamily,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    if (isPersonalBest) ...[
                      const SizedBox(height: 14),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(
                            AppTheme.chipRadius,
                          ),
                          color: cCorrect.withValues(alpha: 0.20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.emoji_events_rounded,
                              size: 16,
                              color: cCorrect,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'New personal best',
                              style: TextStyle(
                                fontFamily: kFontFamily,
                                fontSize: 12.5,
                                fontWeight: FontWeight.w700,
                                color: cCorrect,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 22),
              FilledButton.icon(
                onPressed: () => Navigator.of(context).pushReplacement(
                  MaterialPageRoute<void>(
                    builder: (_) => QuizScreen(
                      spec: spec,
                      progressStore: progressStore,
                    ),
                  ),
                ),
                icon: const Icon(Icons.refresh_rounded, size: 20),
                label: const Text('Play again'),
              ),
              const SizedBox(height: 10),
              OutlinedButton.icon(
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => ReviewScreen(session: session),
                  ),
                ),
                icon: const Icon(Icons.fact_check_outlined, size: 20),
                label: const Text('Review answers'),
              ),
              const SizedBox(height: 10),
              TextButton(
                onPressed: () =>
                    Navigator.of(context).popUntil((route) => route.isFirst),
                child: const Text('Back to categories'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
