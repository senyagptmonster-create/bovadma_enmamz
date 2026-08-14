import 'package:flutter/material.dart';

import '../brand.dart';
import '../theme.dart';

/// The brand letter on an accent tile. Deliberately the only visual element
/// shared across the whole series — everything else is per product.
class BrandMark extends StatelessWidget {
  final double size;

  const BrandMark({super.key, this.size = 56});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(size * 0.26),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [cAccent2, cAccent],
        ),
      ),
      child: Text(
        kBrandLetter,
        style: TextStyle(
          fontFamily: kDisplayFont,
          fontSize: size * 0.5,
          height: 1.0,
          fontWeight: FontWeight.w800,
          color: AppTheme.onAccent,
        ),
      ),
    );
  }
}
