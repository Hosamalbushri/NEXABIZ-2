import 'package:flutter/widgets.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shadcn;

import '../theme/tokens/tokens.dart';

/// Canonical enterprise top header bar for NexaBiz ERP.
///
/// Compliant with the Enterprise Structured Frame architecture. Provides
/// a compact, non-intrusive command header for global search, company indicator,
/// notifications, localization toggle, and user profile actions.
class AppTopHeader extends StatelessWidget implements PreferredSizeWidget {
  /// Header bar height. Defaults to [AppDimensions.topHeaderHeight] (48.0).
  final double height;

  /// Optional leading widget (e.g. sidebar collapse toggle button or title).
  final Widget? leading;

  /// Optional center widget (e.g. global search input or breadcrumbs).
  final Widget? center;

  /// List of trailing action widgets (notifications, user profile, language switch).
  final List<Widget> actions;

  /// Background color override. Defaults to [shadcn.ColorScheme.card].
  final Color? backgroundColor;

  /// Bottom border color override. Defaults to [shadcn.ColorScheme.border].
  final Color? borderColor;

  /// Internal horizontal padding. Defaults to [AppSpacing.md].
  final double horizontalPadding;

  const AppTopHeader({
    super.key,
    this.height = AppDimensions.topHeaderHeight,
    this.leading,
    this.center,
    this.actions = const [],
    this.backgroundColor,
    this.borderColor,
    this.horizontalPadding = AppSpacing.md,
  });

  @override
  Size get preferredSize => Size.fromHeight(height);

  @override
  Widget build(BuildContext context) {
    final theme = shadcn.Theme.of(context);
    final colorScheme = theme.colorScheme;

    final effectiveBg = backgroundColor ?? colorScheme.card;
    final effectiveBorder = borderColor ?? colorScheme.border;

    return Container(
      height: height,
      padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
      decoration: BoxDecoration(
        color: effectiveBg,
        border: Border(
          bottom: BorderSide(
            color: effectiveBorder,
            width: AppBorders.thin,
          ),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (leading != null) ...[
            leading!,
            const SizedBox(width: AppSpacing.sm),
          ],
          if (center != null)
            Expanded(
              child: Center(
                child: center!,
              ),
            )
          else
            const Spacer(),
          if (actions.isNotEmpty) ...[
            const SizedBox(width: AppSpacing.sm),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (var i = 0; i < actions.length; i++) ...[
                  if (i > 0) const SizedBox(width: AppSpacing.xs),
                  actions[i],
                ],
              ],
            ),
          ],
        ],
      ),
    );
  }
}

