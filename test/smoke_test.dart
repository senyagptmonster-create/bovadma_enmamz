import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:bovadma_enmamz/app/theme.dart';
import 'package:bovadma_enmamz/product/product_app.dart';

/// Runs for every app in the series regardless of what the product does.
/// Builds the real product at two screen sizes and fails on any exception —
/// which is how a RenderFlex overflow or a bad decoration surfaces.
void main() {
  setUp(() {
    rootBundle.clear();
    SharedPreferences.setMockInitialValues(<String, Object>{});
  });

  Widget app() => MaterialApp(
    theme: AppTheme.build(),
    home: const ProductApp(),
  );

  /// Fixed pumps rather than pumpAndSettle: several products run a looping
  /// animation, which would make a settle time out.
  Future<void> pumpFrames(WidgetTester tester, {int frames = 25}) async {
    for (var i = 0; i < frames; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }
  }

  testWidgets('product builds on a normal screen', (tester) async {
    await tester.pumpWidget(app());
    await pumpFrames(tester);

    expect(tester.takeException(), isNull);
    expect(find.byType(ProductApp), findsOneWidget);
  });

  testWidgets('product builds on a small phone screen', (tester) async {
    tester.view.physicalSize = const Size(320 * 3, 640 * 3);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(app());
    await pumpFrames(tester);

    expect(tester.takeException(), isNull);
  });

  testWidgets('product builds on a short landscape screen', (tester) async {
    tester.view.physicalSize = const Size(740 * 2, 360 * 2);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(app());
    await pumpFrames(tester);

    expect(tester.takeException(), isNull);
  });
}
