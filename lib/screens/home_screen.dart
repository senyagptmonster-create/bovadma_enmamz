import 'package:flutter/material.dart';

import '../app/brand.dart';
import '../app/theme.dart';
import '../data/progress_store.dart';
import '../data/quiz_repository.dart';
import '../logic/round_spec.dart';
import '../models/quiz_content.dart';
import '../widgets/brand_mark.dart';
import '../widgets/category_card.dart';
import 'quiz_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeData {
  final QuizContent content;
  final ProgressSnapshot progress;
  const _HomeData(this.content, this.progress);
}

class _HomeScreenState extends State<HomeScreen> {
  final QuizRepository _repository = QuizRepository();
  final ProgressStore _progressStore = ProgressStore();

  late Future<_HomeData> _future;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<_HomeData> _load() async {
    final content = await _repository.load();
    final progress = await _progressStore.read();
    return _HomeData(content, progress);
  }

  void _reload() {
    if (!mounted) return;
    // Block body, not an arrow: an arrow returns the assigned Future and
    // setState asserts that its callback returned one.
    setState(() {
      _future = _load();
    });
  }

  Future<void> _start(RoundSpec spec) async {
    if (spec.pool.isEmpty) return;
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) =>
            QuizScreen(spec: spec, progressStore: _progressStore),
      ),
    );
    _reload();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: AppTheme.pageBackground,
        child: SafeArea(
          child: FutureBuilder<_HomeData>(
            future: _future,
            builder: (context, snapshot) {
              if (snapshot.connectionState != ConnectionState.done) {
                return const Center(
                  child: CircularProgressIndicator(color: cAccent),
                );
              }
              final data = snapshot.data;
              if (data == null || data.content.isEmpty) {
                return _buildEmpty();
              }
              return _buildContent(data);
            },
          ),
        ),
      ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const BrandMark(size: 64),
            const SizedBox(height: 18),
            Text(
              'Question pack unavailable',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: kFontFamily,
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Reinstalling the app restores the bundled questions.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: kFontFamily,
                fontSize: 14,
                height: 1.4,
                color: AppTheme.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(_HomeData data) {
    final content = data.content;
    final categories = content.categories;
    final grid = kBrandLayout == 1 || kBrandLayout == 4;

    return ListView(
      padding: const EdgeInsets.fromLTRB(18, 12, 18, 32),
      children: [
        _buildHeader(data),
        const SizedBox(height: 18),
        _buildMixedButton(content),
        const SizedBox(height: 22),
        Row(
          children: [
            Flexible(
              child: Text(
                'Categories',
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontFamily: kFontFamily,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.4,
                  color: AppTheme.textSecondary,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Text(
              '${content.questionCount} questions',
              style: TextStyle(
                fontFamily: kFontFamily,
                fontSize: 12,
                color: AppTheme.textMuted,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (grid)
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: categories.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              // A fixed height, not an aspect ratio: on a narrow screen a
              // ratio-derived cell gets too short and the card overflows.
              mainAxisExtent: 186,
            ),
            itemBuilder: (context, i) => _categoryCard(data, i, compact: true),
          )
        else
          for (var i = 0; i < categories.length; i++) ...[
            _categoryCard(data, i),
            const SizedBox(height: 12),
          ],
        const SizedBox(height: 10),
        _buildFooterStats(data),
      ],
    );
  }

  Widget _categoryCard(_HomeData data, int index, {bool compact = false}) {
    final category = data.content.categories[index];
    return CategoryCard(
      position: index,
      name: category.name,
      blurb: category.blurb,
      questionCount: category.questions.length,
      bestPercent: data.progress.bestFor(category.id),
      compact: compact,
      onTap: () => _start(
        RoundSpec(
          categoryId: category.id,
          categoryName: category.name,
          pool: category.questions,
        ),
      ),
    );
  }

  Widget _buildMixedButton(QuizContent content) {
    return FilledButton.icon(
      onPressed: () => _start(
        RoundSpec(
          categoryId: 'mixed',
          categoryName: 'Mixed round',
          pool: content.allQuestions,
        ),
      ),
      icon: const Icon(Icons.play_arrow_rounded, size: 22),
      label: const Text('Start mixed round'),
    );
  }

  /// One header per brand, so five brands never share a first impression.
  Widget _buildHeader(_HomeData data) {
    switch (kBrandLayout) {
      case 0:
        return _headerHero(data);
      case 1:
        return _headerStats(data);
      case 2:
        return _headerSideMark(data);
      case 3:
        return _headerCentered(data);
      case 4:
      default:
        return _headerBar(data);
    }
  }

  Widget _headerHero(_HomeData data) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: AppTheme.panel(accented: true),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const BrandMark(size: 58),
          const SizedBox(height: 16),
          Text(
            kSportTitle,
            style: TextStyle(
              fontFamily: kFontFamily,
              fontSize: 28,
              height: 1.1,
              fontWeight: FontWeight.w800,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            kSportTagline,
            style: TextStyle(
              fontFamily: kFontFamily,
              fontSize: 14,
              height: 1.35,
              color: AppTheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _headerStats(_HomeData data) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const BrandMark(size: 44),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    kSportTitle,
                    style: TextStyle(
                      fontFamily: kFontFamily,
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  Text(
                    kSportTagline,
                    style: TextStyle(
                      fontFamily: kFontFamily,
                      fontSize: 12.5,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _statTile('Rounds', '${data.progress.roundsPlayed}'),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _statTile(
                'Accuracy',
                '${data.progress.accuracyPercent}%',
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _headerSideMark(_HomeData data) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const BrandMark(size: 66),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                kSportTitle.toUpperCase(),
                style: TextStyle(
                  fontFamily: kFontFamily,
                  fontSize: 21,
                  letterSpacing: 1.1,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              Container(width: 40, height: 3, color: cAccent),
              const SizedBox(height: 8),
              Text(
                kSportTagline,
                style: TextStyle(
                  fontFamily: kFontFamily,
                  fontSize: 13,
                  height: 1.35,
                  color: AppTheme.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _headerCentered(_HomeData data) {
    return Column(
      children: [
        const SizedBox(height: 6),
        const BrandMark(size: 62),
        const SizedBox(height: 14),
        Text(
          kSportTitle,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: kFontFamily,
            fontSize: 26,
            fontWeight: FontWeight.w800,
            color: AppTheme.textPrimary,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          kSportTagline,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: kFontFamily,
            fontSize: 14,
            height: 1.35,
            color: AppTheme.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _headerBar(_HomeData data) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      decoration: AppTheme.panel(border: true),
      child: Row(
        children: [
          const BrandMark(size: 40),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              kSportTitle,
              style: TextStyle(
                fontFamily: kFontFamily,
                fontSize: 19,
                fontWeight: FontWeight.w800,
                color: AppTheme.textPrimary,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppTheme.chipRadius),
              color: cAccent.withValues(alpha: 0.18),
            ),
            child: Text(
              '${data.progress.roundsPlayed} rounds',
              style: TextStyle(
                fontFamily: kFontFamily,
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: cAccent,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _statTile(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: AppTheme.panel(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            value,
            style: TextStyle(
              fontFamily: kFontFamily,
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: cAccent,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontFamily: kFontFamily,
              fontSize: 12,
              color: AppTheme.textMuted,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooterStats(_HomeData data) {
    // Layout 1 already shows these at the top.
    if (kBrandLayout == 1) return const SizedBox.shrink();

    final progress = data.progress;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: AppTheme.panel(),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _footerStat('${progress.roundsPlayed}', 'Rounds'),
          _footerDivider(),
          _footerStat('${progress.answersCorrect}', 'Correct'),
          _footerDivider(),
          _footerStat('${progress.accuracyPercent}%', 'Accuracy'),
        ],
      ),
    );
  }

  Widget _footerStat(String value, String label) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          value,
          style: TextStyle(
            fontFamily: kFontFamily,
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: AppTheme.textPrimary,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            fontFamily: kFontFamily,
            fontSize: 11,
            color: AppTheme.textMuted,
          ),
        ),
      ],
    );
  }

  Widget _footerDivider() {
    return Container(
      width: 1,
      height: 26,
      color: AppTheme.surfaceBorder.withValues(alpha: 0.5),
    );
  }
}
