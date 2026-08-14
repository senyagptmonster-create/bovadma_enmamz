import 'package:flutter/material.dart';

import 'brand.dart';

/// Style variants. One per app inside a brand, so five apps that share a
/// palette still read as five different products.
class StyleVariant {
  const StyleVariant._();

  static const int gradient = 0;
  static const int glow = 1;
  static const int invert = 2;
  static const int band = 3;
  static const int outline = 4;
}

/// Answer feedback colours are deliberately not brand-derived: red/green must
/// stay unambiguous on every palette.
const Color cCorrect = Color(0xFF35C177);
const Color cWrong = Color(0xFFE2564B);

class AppTheme {
  const AppTheme._();

  static const Color textPrimary = Color(0xFFF4F5FA);
  static const Color textSecondary = Color(0xB3F4F5FA);
  static const Color textMuted = Color(0x80F4F5FA);

  /// The scaffold stays dark for every variant. Variants change surfaces and
  /// accents only — flipping the background too is how contrast bugs creep in.
  static Color get background => cBgMid;

  static double get cardRadius => kRadius;
  static double get chipRadius => kRadius * 0.55;
  static double get buttonRadius {
    // Outline and glow read as softer, invert as sharper.
    switch (kStyleVariant) {
      case StyleVariant.invert:
        return kRadius * 0.5;
      case StyleVariant.glow:
      case StyleVariant.outline:
        return kRadius * 1.4;
      default:
        return kRadius * 0.9;
    }
  }

  static Color get surface {
    switch (kStyleVariant) {
      case StyleVariant.invert:
        return Color.alphaBlend(cAccent.withValues(alpha: 0.14), cBgDark);
      case StyleVariant.outline:
        return cBgMid;
      default:
        return Color.alphaBlend(cBgLight.withValues(alpha: 0.34), cBgDark);
    }
  }

  static Color get surfaceBorder {
    switch (kStyleVariant) {
      case StyleVariant.outline:
        return cAccent.withValues(alpha: 0.55);
      case StyleVariant.invert:
        return cAccent.withValues(alpha: 0.42);
      default:
        return cBgLight.withValues(alpha: 0.55);
    }
  }

  /// Decoration shared by cards, answer buttons and panels. [accented] lifts a
  /// surface towards the brand accent; [border] forces an outline on variants
  /// that normally have none.
  static BoxDecoration panel({
    bool accented = false,
    bool border = false,
    double? radius,
  }) {
    final r = BorderRadius.circular(radius ?? cardRadius);
    final base = accented
        ? Color.alphaBlend(cAccent.withValues(alpha: 0.18), surface)
        : surface;

    switch (kStyleVariant) {
      case StyleVariant.gradient:
        return BoxDecoration(
          borderRadius: r,
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color.alphaBlend(cBgLight.withValues(alpha: 0.45), base),
              base,
            ],
          ),
          border: border ? Border.all(color: surfaceBorder, width: 1) : null,
        );

      case StyleVariant.glow:
        return BoxDecoration(
          borderRadius: r,
          color: base,
          boxShadow: [
            BoxShadow(
              color: cAccent.withValues(alpha: accented ? 0.30 : 0.14),
              blurRadius: 22,
              spreadRadius: -4,
            ),
          ],
          border: border ? Border.all(color: surfaceBorder, width: 1) : null,
        );

      case StyleVariant.invert:
        return BoxDecoration(
          borderRadius: r,
          color: base,
          border: Border.all(color: surfaceBorder, width: 1.4),
        );

      case StyleVariant.band:
        // Flutter forbids a non-uniform Border together with a borderRadius —
        // it asserts at paint time. The accent band is therefore a hard-stop
        // gradient rather than a left BorderSide.
        return BoxDecoration(
          borderRadius: r,
          gradient: LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: [cAccent, cAccent, base, base],
            stops: const [0.0, 0.022, 0.022, 1.0],
          ),
          border: border
              ? Border.all(color: surfaceBorder, width: 1)
              : null,
        );

      case StyleVariant.outline:
      default:
        return BoxDecoration(
          borderRadius: r,
          color: accented ? base : Colors.transparent,
          border: Border.all(color: surfaceBorder, width: 1.4),
        );
    }
  }

  /// Page background. Only `gradient` and `glow` paint one — the rest stay flat
  /// so their surfaces carry the character instead.
  static BoxDecoration get pageBackground {
    switch (kStyleVariant) {
      case StyleVariant.gradient:
        return const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [cBgMid, cBgDark],
          ),
        );
      case StyleVariant.glow:
        return const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment(0, -0.6),
            radius: 1.2,
            colors: [cBgLight, cBgDark],
          ),
        );
      default:
        return BoxDecoration(color: background);
    }
  }

  static ThemeData build() {
    final scheme =
        ColorScheme.fromSeed(
          seedColor: cAccent,
          brightness: Brightness.dark,
        ).copyWith(
          primary: cAccent,
          secondary: cAlt,
          surface: cBgMid,
          onPrimary: cInk,
          onSurface: textPrimary,
        );

    final base = ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: scheme,
      fontFamily: kFontFamily,
      scaffoldBackgroundColor: background,
      splashFactory: InkRipple.splashFactory,
    );

    return base.copyWith(
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: kBrandLayout == 3,
        foregroundColor: textPrimary,
        titleTextStyle: base.textTheme.titleLarge?.copyWith(
          color: textPrimary,
          fontWeight: FontWeight.w700,
          fontFamily: kFontFamily,
        ),
      ),
      textTheme: base.textTheme.apply(
        bodyColor: textPrimary,
        displayColor: textPrimary,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: cAccent,
          foregroundColor: cInk,
          minimumSize: const Size.fromHeight(52),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            fontFamily: kFontFamily,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(buttonRadius),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: textPrimary,
          minimumSize: const Size.fromHeight(52),
          side: BorderSide(color: surfaceBorder, width: 1.4),
          textStyle: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            fontFamily: kFontFamily,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(buttonRadius),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(foregroundColor: cAccent),
      ),
    );
  }
}
