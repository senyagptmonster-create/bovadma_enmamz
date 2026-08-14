import 'package:flutter/material.dart';

import '../app/brand.dart';
import '../app/theme.dart';

/// Category entry point. [compact] is used by the grid layouts, the tall form
/// by the list layouts.
class CategoryCard extends StatelessWidget {
  final int position;
  final String name;
  final String blurb;
  final int questionCount;
  final int? bestPercent;
  final bool compact;
  final VoidCallback onTap;

  const CategoryCard({
    super.key,
    required this.position,
    required this.name,
    required this.blurb,
    required this.questionCount,
    required this.bestPercent,
    required this.onTap,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppTheme.cardRadius),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: AppTheme.panel(),
          child: compact ? _buildCompact() : _buildWide(),
        ),
      ),
    );
  }

  /// Only ever used inside the grid, where the cell height is fixed. The
  /// column fills that height and absorbs slack in the Flexible name and the
  /// Spacer, so it cannot overflow no matter how the fonts measure out.
  Widget _buildCompact() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.max,
      children: [
        _indexBadge(),
        const SizedBox(height: 10),
        Flexible(
          child: Text(
            name,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontFamily: kFontFamily,
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppTheme.textPrimary,
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '$questionCount questions',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontFamily: kFontFamily,
            fontSize: 12,
            color: AppTheme.textMuted,
          ),
        ),
        const Spacer(),
        _bestChip(),
      ],
    );
  }

  Widget _buildWide() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        _indexBadge(),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                name,
                style: TextStyle(
                  fontFamily: kFontFamily,
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textPrimary,
                ),
              ),
              if (blurb.isNotEmpty) ...[
                const SizedBox(height: 3),
                Text(
                  blurb,
                  style: TextStyle(
                    fontFamily: kFontFamily,
                    fontSize: 13,
                    height: 1.3,
                    color: AppTheme.textSecondary,
                  ),
                ),
              ],
              const SizedBox(height: 8),
              // Wrap, not Row: on a narrow phone the count and the chip must be
              // allowed to fall onto two lines rather than overflow.
              Wrap(
                spacing: 10,
                runSpacing: 6,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Text(
                    '$questionCount questions',
                    style: TextStyle(
                      fontFamily: kFontFamily,
                      fontSize: 12,
                      color: AppTheme.textMuted,
                    ),
                  ),
                  _bestChip(),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        const Icon(Icons.chevron_right, color: cAccent, size: 22),
      ],
    );
  }

  Widget _indexBadge() {
    return Container(
      width: 38,
      height: 38,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppTheme.chipRadius),
        color: kStyleVariant == StyleVariant.outline
            ? Colors.transparent
            : cAccent.withValues(alpha: 0.18),
        border: Border.all(color: cAccent.withValues(alpha: 0.6), width: 1.2),
      ),
      child: Text(
        '${position + 1}',
        style: TextStyle(
          fontFamily: kFontFamily,
          fontSize: 16,
          fontWeight: FontWeight.w800,
          color: cAccent,
        ),
      ),
    );
  }

  Widget _bestChip() {
    final best = bestPercent;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppTheme.chipRadius * 0.8),
        color: best == null
            ? AppTheme.surfaceBorder.withValues(alpha: 0.28)
            : cCorrect.withValues(alpha: 0.20),
      ),
      child: Text(
        best == null ? 'Not played' : 'Best $best%',
        style: TextStyle(
          fontFamily: kFontFamily,
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: best == null ? AppTheme.textMuted : cCorrect,
        ),
      ),
    );
  }
}
