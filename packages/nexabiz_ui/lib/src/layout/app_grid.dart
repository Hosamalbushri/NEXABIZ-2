import 'dart:math' as math;
import 'package:flutter/widgets.dart';

import 'app_breakpoints.dart';
import 'app_layout_tokens.dart';
import 'app_responsive.dart';

/// Unified grid layout system supporting responsive column calculations and
/// fluid min-item-width adaptation.
class AppGrid extends StatelessWidget {
  const AppGrid({
    super.key,
    required this.children,
    this.compactColumns = 1,
    this.mediumColumns = 2,
    this.expandedColumns = 3,
    this.wideColumns = 4,
    this.minItemWidth,
    this.maxColumns,
    this.spacing = AppLayoutTokens.dashboardGridGap,
    this.runSpacing = AppLayoutTokens.dashboardGridGap,
  });

  /// The child widgets to display within the grid.
  final List<Widget> children;

  /// Number of columns when layout width is in the compact (< 600px) tier.
  final int compactColumns;

  /// Number of columns when layout width is in the medium (600px - 999px) tier.
  final int mediumColumns;

  /// Number of columns when layout width is in the expanded (1000px - 1439px) tier.
  final int expandedColumns;

  /// Number of columns when layout width is in the wide (>= 1440px) tier.
  final int wideColumns;

  /// Optional minimum width constraint per grid item.
  ///
  /// When provided and > 0, column count is computed dynamically based on
  /// available layout width: `((availableWidth + spacing) / (minItemWidth + spacing)).floor()`.
  /// Can be capped by [maxColumns].
  final double? minItemWidth;

  /// Optional maximum upper limit for the calculated column count.
  final int? maxColumns;

  /// Horizontal spacing between grid columns.
  final double spacing;

  /// Vertical spacing between grid rows.
  final double runSpacing;

  @override
  Widget build(BuildContext context) {
    if (children.isEmpty) {
      return const SizedBox.shrink();
    }

    return AppResponsive.builder(
      builder: (context, tier, constraints) {
        final parentScope = AppResponsiveScope.maybeOf(context);
        final availableWidth = constraints.hasBoundedWidth
            ? constraints.maxWidth
            : (parentScope?.availableWidth ?? MediaQuery.sizeOf(context).width);

        int columns;
        if (minItemWidth != null && minItemWidth! > 0) {
          if (availableWidth.isFinite && availableWidth > 0) {
            final computed =
                ((availableWidth + spacing) / (minItemWidth! + spacing))
                    .floor();
            columns = math.max(1, computed);
          } else {
            columns = 1;
          }
        } else {
          columns = switch (tier) {
            AppBreakpointTier.compact => compactColumns,
            AppBreakpointTier.medium => mediumColumns,
            AppBreakpointTier.expanded => expandedColumns,
            AppBreakpointTier.wide => wideColumns,
          };
        }

        if (maxColumns != null && maxColumns! > 0) {
          columns = math.min(columns, maxColumns!);
        }
        columns = math.max(1, columns);

        if (columns <= 1) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              for (var i = 0; i < children.length; i++) ...[
                if (i > 0) SizedBox(height: runSpacing),
                children[i],
              ],
            ],
          );
        }

        final double itemWidth;
        if (availableWidth.isFinite && availableWidth > 0) {
          itemWidth = math.max(
            0.0,
            (availableWidth - (spacing * (columns - 1))) / columns,
          );
        } else if (minItemWidth != null && minItemWidth! > 0) {
          itemWidth = minItemWidth!;
        } else {
          itemWidth = 300.0;
        }

        return Wrap(
          spacing: spacing,
          runSpacing: runSpacing,
          children: [
            for (final child in children)
              SizedBox(width: itemWidth, child: child),
          ],
        );
      },
    );
  }
}
