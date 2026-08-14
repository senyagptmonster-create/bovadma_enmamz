import 'package:flutter/material.dart';

import '../app/brand.dart';
import '../app/theme.dart';

/// One tappable answer. After the round reveals, the correct row always turns
/// green and a wrong pick turns red — regardless of palette.
class AnswerOption extends StatelessWidget {
  final String label;
  final int position;
  final bool selected;
  final bool revealed;
  final bool isCorrect;
  final VoidCallback? onTap;

  const AnswerOption({
    super.key,
    required this.label,
    required this.position,
    required this.selected,
    required this.revealed,
    required this.isCorrect,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final showCorrect = revealed && isCorrect;
    final showWrong = revealed && selected && !isCorrect;

    Color borderColor = AppTheme.surfaceBorder;
    Color fill = Colors.transparent;
    Color badgeColor = cAccent;
    Color badgeText = cInk;

    if (showCorrect) {
      borderColor = cCorrect;
      fill = cCorrect.withValues(alpha: 0.16);
      badgeColor = cCorrect;
      badgeText = Colors.white;
    } else if (showWrong) {
      borderColor = cWrong;
      fill = cWrong.withValues(alpha: 0.16);
      badgeColor = cWrong;
      badgeText = Colors.white;
    } else if (selected) {
      borderColor = cAccent;
      fill = cAccent.withValues(alpha: 0.12);
    } else if (revealed) {
      borderColor = AppTheme.surfaceBorder.withValues(alpha: 0.4);
      badgeColor = AppTheme.surfaceBorder;
      badgeText = AppTheme.textSecondary;
    }

    final radius = BorderRadius.circular(AppTheme.buttonRadius);
    final dimmed = revealed && !showCorrect && !showWrong;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: radius,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            decoration: BoxDecoration(
              borderRadius: radius,
              color: fill,
              border: Border.all(
                color: borderColor,
                width: showCorrect || showWrong ? 1.8 : 1.3,
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: 30,
                  height: 30,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: badgeColor,
                    borderRadius: BorderRadius.circular(
                      AppTheme.chipRadius * 0.9,
                    ),
                  ),
                  child: Text(
                    String.fromCharCode(65 + position),
                    style: TextStyle(
                      fontFamily: kFontFamily,
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: badgeText,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // Expanded + soft wrap: long options must never overflow.
                Expanded(
                  child: Text(
                    label,
                    style: TextStyle(
                      fontFamily: kFontFamily,
                      fontSize: 15,
                      height: 1.3,
                      fontWeight: FontWeight.w500,
                      color: dimmed
                          ? AppTheme.textMuted
                          : AppTheme.textPrimary,
                    ),
                  ),
                ),
                if (showCorrect)
                  const Icon(Icons.check_circle, color: cCorrect, size: 20),
                if (showWrong)
                  const Icon(Icons.cancel, color: cWrong, size: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
