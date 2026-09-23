import 'package:flutter/material.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shadcn;

import '../theme/tokens/tokens.dart';

/// Canonical Mobile Bottom Actions Container for NexaBiz ERP.
///
/// Features priority action hierarchy (1 Primary action, Secondary actions, Ghost/Overflow),
/// full SafeArea awareness, gesture navigation bar insets, keyboard insets, and responsive
/// layout stacking (stacked vertical on 320–360px phone screens or long text).
class AppBottomActions extends StatelessWidget {
  const AppBottomActions({
    super.key,
    required this.primaryAction,
    this.secondaryAction,
    this.extraActions,
    this.padding = const EdgeInsets.fromLTRB(
      AppSpacing.md,
      AppSpacing.sm,
      AppSpacing.md,
      AppSpacing.sm,
    ),
    this.backgroundColor,
    this.showBorder = true,
  });

  /// Prominent primary action button (e.g. Save, Submit, Post, Confirm).
  final Widget primaryAction;

  /// Optional secondary action button (e.g. Cancel, Save Draft).
  final Widget? secondaryAction;

  /// Optional additional overflow or ghost action buttons (e.g. Delete, Close).
  final List<Widget>? extraActions;

  /// Internal padding for the actions container.
  final EdgeInsetsGeometry padding;

  /// Background color override.
  final Color? backgroundColor;

  /// Whether to render top divider border.
  final bool showBorder;

  @override
  Widget build(BuildContext context) {
    final theme = shadcn.Theme.of(context);
    final colorScheme = theme.colorScheme;
    final mediaQuery = MediaQuery.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final bg =
        backgroundColor ?? (isDark ? colorScheme.card : colorScheme.background);
    final border = showBorder
        ? Border(
            top: BorderSide(
              color: colorScheme.border.withValues(alpha: 0.6),
              width: 1.0,
            ),
          )
        : null;

    final keyboardInset = mediaQuery.viewInsets.bottom;
    final safeBottom = mediaQuery.padding.bottom;
    final effectiveBottomInset = keyboardInset > 0 ? 4.0 : safeBottom;

    return Container(
      padding: (padding as EdgeInsets).add(
        EdgeInsets.only(bottom: effectiveBottomInset),
      ),
      decoration: BoxDecoration(color: bg, border: border),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isNarrow =
              mediaQuery.size.width <= 360 || constraints.maxWidth < 280;

          if (isNarrow) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                primaryAction,
                if (secondaryAction != null) ...[
                  const SizedBox(height: AppSpacing.xs),
                  secondaryAction!,
                ],
                if (extraActions != null && extraActions!.isNotEmpty) ...[
                  const SizedBox(height: AppSpacing.xs),
                  ...extraActions!,
                ],
              ],
            );
          }

          return Row(
            children: [
              if (extraActions != null && extraActions!.isNotEmpty) ...[
                ...extraActions!,
                const Spacer(),
              ],
              if (secondaryAction != null) ...[
                Expanded(child: secondaryAction!),
                const SizedBox(width: AppSpacing.sm),
              ],
              Expanded(child: primaryAction),
            ],
          );
        },
      ),
    );
  }
}
