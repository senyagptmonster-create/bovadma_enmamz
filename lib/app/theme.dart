import 'package:flutter/material.dart';

import 'brand.dart';

/// Answer feedback is deliberately not brand-derived. Correct and wrong must
/// stay unambiguous on all 25 palettes, light and dark alike.
const Color cCorrect = Color(0xFF2E9E68);
const Color cWrong = Color(0xFFD1483C);

/// Theme built from the five palette tokens in brand.dart. Handles light and
/// dark from the same tokens: `cBg` is always the scaffold, `cSurface` always
/// the raised colour, `cEdge` always the strongest of the three — which holds
/// whether the palette is a dark navy or a cream paper.
class AppTheme {
  const AppTheme._();

  static Color get textPrimary =>
      kIsLight ? const Color(0xFF10141A) : const Color(0xFFF4F5FA);

  static Color get textSecondary => textPrimary.withValues(alpha: 0.68);
  static Color get textMuted => textPrimary.withValues(alpha: 0.45);

  /// cEdge is generated per palette already contrasting with the page, so it
  /// is used as-is rather than blended — blending is what made dark borders
  /// vanish into the background.
  static Color get border => cEdge;

  /// Raised surface. On light palettes a card must sit *above* the page, on
  /// dark ones it sits below-then-lifted; both are handled by the token order.
  static Color get surface => cSurface;

  static Color get surfaceStrong => kIsLight
      ? Color.alphaBlend(cEdge.withValues(alpha: 0.45), cSurface)
      : Color.alphaBlend(cAccent.withValues(alpha: 0.10), cSurface);

  /// Readable text on top of a solid accent fill.
  static Color get onAccent {
    // Relative luminance decides black or white — a fixed choice breaks on
    // yellow accents in one direction and navy accents in the other.
    return cAccent.computeLuminance() > 0.5
        ? const Color(0xFF0B0B0B)
        : Colors.white;
  }

  static BorderRadius get radius => BorderRadius.circular(kRadius);
  static BorderRadius radiusOf(double factor) =>
      BorderRadius.circular(kRadius * factor);

  static BoxDecoration panel({
    bool accented = false,
    bool outlined = false,
    double radiusFactor = 1.0,
  }) {
    final fill = accented
        ? Color.alphaBlend(cAccent.withValues(alpha: kIsLight ? 0.12 : 0.16), surface)
        : surface;

    return BoxDecoration(
      color: fill,
      borderRadius: radiusOf(radiusFactor),
      border: outlined
          ? Border.all(color: accented ? cAccent : border, width: 1.2)
          : Border.all(color: border.withValues(alpha: kIsLight ? 0.9 : 0.6)),
      boxShadow: kIsLight
          ? [
              BoxShadow(
                color: const Color(0xFF1B2430).withValues(alpha: 0.06),
                blurRadius: 12,
                offset: const Offset(0, 3),
              ),
            ]
          : null,
    );
  }

  static TextStyle display(double size, {Color? color, double? height}) =>
      TextStyle(
        fontFamily: kDisplayFont,
        fontSize: size,
        height: height,
        fontWeight: FontWeight.w700,
        color: color ?? textPrimary,
      );

  static TextStyle text(
    double size, {
    Color? color,
    FontWeight weight = FontWeight.w500,
    double? height,
    double? spacing,
  }) => TextStyle(
    fontFamily: kBodyFont,
    fontSize: size,
    height: height,
    letterSpacing: spacing,
    fontWeight: weight,
    color: color ?? textPrimary,
  );

  static ThemeData build() {
    final brightness = kIsLight ? Brightness.light : Brightness.dark;
    final scheme = ColorScheme.fromSeed(
      seedColor: cAccent,
      brightness: brightness,
    ).copyWith(
      primary: cAccent,
      secondary: cAlt,
      surface: cSurface,
      onPrimary: onAccent,
      onSurface: textPrimary,
    );

    final base = ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: scheme,
      fontFamily: kBodyFont,
      scaffoldBackgroundColor: cBg,
      dividerColor: border,
    );

    return base.copyWith(
      textTheme: base.textTheme.apply(
        bodyColor: textPrimary,
        displayColor: textPrimary,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: cBg,
        surfaceTintColor: Colors.transparent,
        foregroundColor: textPrimary,
        elevation: 0,
        titleTextStyle: TextStyle(
          fontFamily: kDisplayFont,
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: textPrimary,
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: cAccent,
          foregroundColor: onAccent,
          minimumSize: const Size.fromHeight(52),
          shape: RoundedRectangleBorder(borderRadius: radiusOf(0.8)),
          textStyle: TextStyle(
            fontFamily: kDisplayFont,
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: textPrimary,
          minimumSize: const Size.fromHeight(48),
          side: BorderSide(color: border, width: 1.2),
          shape: RoundedRectangleBorder(borderRadius: radiusOf(0.8)),
          textStyle: TextStyle(
            fontFamily: kBodyFont,
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(foregroundColor: cAccent),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: surfaceStrong,
        contentTextStyle: TextStyle(
          fontFamily: kBodyFont,
          color: textPrimary,
        ),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
