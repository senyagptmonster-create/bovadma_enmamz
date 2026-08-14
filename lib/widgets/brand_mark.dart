import 'package:flutter/material.dart';

import '../app/brand.dart';
import '../app/theme.dart';

/// The brand letter, rendered the same way the launcher icon is: one mark, five
/// treatments.
class BrandMark extends StatelessWidget {
  final double size;

  const BrandMark({super.key, this.size = 56});

  @override
  Widget build(BuildContext context) {
    final radius = size * 0.28;
    final letter = Text(
      kBrandLetter,
      style: TextStyle(
        fontFamily: kFontFamily,
        fontSize: size * 0.54,
        height: 1.0,
        fontWeight: FontWeight.w800,
        color: kStyleVariant == StyleVariant.invert
            ? cInk
            : (kStyleVariant == StyleVariant.band ? cPaper : cAccent),
      ),
    );

    late final BoxDecoration decoration;
    switch (kStyleVariant) {
      case StyleVariant.gradient:
        decoration = BoxDecoration(
          borderRadius: BorderRadius.circular(radius),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [cBgLight, cBgDark],
          ),
        );
        break;
      case StyleVariant.glow:
        decoration = BoxDecoration(
          borderRadius: BorderRadius.circular(radius),
          color: cBgDark,
          boxShadow: [
            BoxShadow(
              color: cAccent.withValues(alpha: 0.45),
              blurRadius: size * 0.32,
              spreadRadius: -size * 0.06,
            ),
          ],
        );
        break;
      case StyleVariant.invert:
        decoration = BoxDecoration(
          borderRadius: BorderRadius.circular(radius),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [cAccent2, cAccent],
          ),
        );
        break;
      case StyleVariant.band:
        decoration = BoxDecoration(
          borderRadius: BorderRadius.circular(radius),
          color: cBgDark,
          border: Border(left: BorderSide(color: cAccent, width: size * 0.11)),
        );
        break;
      case StyleVariant.outline:
      default:
        decoration = BoxDecoration(
          borderRadius: BorderRadius.circular(radius),
          color: cBgDark,
          border: Border.all(color: cAccent, width: size * 0.055),
        );
        break;
    }

    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: decoration,
      child: letter,
    );
  }
}
