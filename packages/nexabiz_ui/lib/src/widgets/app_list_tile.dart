import 'package:flutter/widgets.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shadcn;
import '../theme/tokens/app_spacing.dart';

/// Canonical list tile primitive for NexaBiz UI built on `shadcn_flutter`.
class AppListTile extends StatelessWidget {
  final Widget? leading;
  final Widget title;
  final Widget? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry padding;
  final bool enabled;

  const AppListTile({
    super.key,
    this.leading,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
    this.padding = const EdgeInsets.symmetric(
      horizontal: AppSpacing.md,
      vertical: AppSpacing.sm,
    ),
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = shadcn.Theme.of(context);
    final colorScheme = theme.colorScheme;

    final titleStyle = theme.typography.p.copyWith(
      fontWeight: FontWeight.w600,
      color: enabled
          ? colorScheme.foreground
          : colorScheme.mutedForeground.withValues(alpha: 0.5),
    );

    final subtitleStyle = theme.typography.small.copyWith(
      color: colorScheme.mutedForeground,
    );

    final tileContent = Padding(
      padding: padding,
      child: Row(
        children: [
          if (leading != null) ...[
            leading!,
            const SizedBox(width: AppSpacing.md),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                DefaultTextStyle(
                  style: titleStyle,
                  child: title,
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: AppSpacing.xxs),
                  DefaultTextStyle(
                    style: subtitleStyle,
                    child: subtitle!,
                  ),
                ],
              ],
            ),
          ),
          if (trailing != null) ...[
            const SizedBox(width: AppSpacing.sm),
            trailing!,
          ],
        ],
      ),
    );

    if (!enabled || onTap == null) {
      return tileContent;
    }

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: tileContent,
    );
  }
}

/// Canonical divider line for NexaBiz UI built on `shadcn_flutter`.
class AppDivider extends StatelessWidget {
  final double height;
  final double thickness;
  final Color? color;

  const AppDivider({
    super.key,
    this.height = 1.0,
    this.thickness = 1.0,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = shadcn.Theme.of(context);
    final effectiveColor = color ?? theme.colorScheme.border;
    return SizedBox(
      height: height,
      child: Center(
        child: Container(
          height: thickness,
          color: effectiveColor,
        ),
      ),
    );
  }
}
