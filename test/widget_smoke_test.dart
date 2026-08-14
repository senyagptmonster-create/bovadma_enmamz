import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:bovadma_enmamz/app/theme.dart';
import 'package:bovadma_enmamz/screens/home_screen.dart';
import 'package:bovadma_enmamz/widgets/answer_option.dart';

/// Clicks a whole round through the real widgets. Logic tests cannot catch a
/// RenderFlex overflow or a screen that never builds — this can, because the
/// test framework turns both into failures.
void main() {
  setUp(() {
    // rootBundle caches its Future from the previous test's fake-async zone.
    rootBundle.clear();
    SharedPreferences.setMockInitialValues(<String, Object>{});
  });

  Widget app() => MaterialApp(
    theme: AppTheme.build(),
    home: const HomeScreen(),
  );

  /// Repeated fixed pumps, never pumpAndSettle: the loading spinner animates
  /// forever and would time the settle out.
  Future<void> pumpUntil(WidgetTester tester, Finder finder) async {
    for (var i = 0; i < 40; i++) {
      await tester.pump(const Duration(milliseconds: 100));
      if (finder.evaluate().isNotEmpty) return;
    }
    fail('not found after pumping: $finder');
  }

  testWidgets('home screen builds and lists categories', (tester) async {
    await tester.pumpWidget(app());
    await pumpUntil(tester, find.text('Start mixed round'));

    expect(find.text('Categories'), findsOneWidget);
    expect(find.textContaining('questions'), findsWidgets);
  });

  testWidgets('a full round runs through to the result screen', (tester) async {
    await tester.pumpWidget(app());
    await pumpUntil(tester, find.text('Start mixed round'));

    await tester.tap(find.text('Start mixed round'));
    await pumpUntil(tester, find.byType(AnswerOption));

    for (var i = 0; i < 12; i++) {
      final firstOption = find.byType(AnswerOption).first;
      await tester.ensureVisible(firstOption);
      await tester.pump();
      await tester.tap(firstOption);
      await tester.pump(const Duration(milliseconds: 300));

      final finish = find.text('See results');
      if (finish.evaluate().isNotEmpty) {
        await tester.tap(finish);
        break;
      }
      await tester.tap(find.text('Next question'));
      await tester.pump(const Duration(milliseconds: 300));
    }

    await pumpUntil(tester, find.text('Play again'));
    expect(find.textContaining('correct'), findsWidgets);

    await tester.tap(find.text('Review answers'));
    await pumpUntil(tester, find.text('Review'));
    expect(find.textContaining('Correct answer'), findsWidgets);
  });

  testWidgets('layout survives a small phone screen', (tester) async {
    tester.view.physicalSize = const Size(320 * 3, 640 * 3);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(app());
    await pumpUntil(tester, find.text('Start mixed round'));

    await tester.tap(find.text('Start mixed round'));
    await pumpUntil(tester, find.byType(AnswerOption));

    // Reveal the explanation panel too — it is the tallest state of the screen.
    final firstOption = find.byType(AnswerOption).first;
    await tester.ensureVisible(firstOption);
    await tester.pump();
    await tester.tap(firstOption);
    await tester.pump(const Duration(milliseconds: 300));

    expect(tester.takeException(), isNull);
  });
}
