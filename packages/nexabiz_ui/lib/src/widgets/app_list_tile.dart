import 'package:flutter/widgets.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shadcn;
import '../theme/tokens/app_spacing.dart';

export 'app_separator.dart' show AppDivider, AppSeparator;

/// Canonical list tile primitive for NexaBiz UI built on `shadcn_flutter`.
class AppListTile extends StatelessWidget {
  final Widget? leading;
  final Widget title;
  final Widget? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry padding;
  final bool enabled;
  final bool? wrapTrailing;

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
    this.wrapTrailing,
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

    final tileContent = LayoutBuilder(
      builder: (context, constraints) {
        final availableWidth = constraints.maxWidth;
        // Adapt layout when available component width is restricted (< 320px)
        final isCompactTile =
            wrapTrailing ?? (availableWidth.isFinite && availableWidth < 320.0);

        final titleTextGroup = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            DefaultTextStyle(style: titleStyle, child: title),
            if (subtitle != null) ...[
              const SizedBox(height: AppSpacing.xxs),
              DefaultTextStyle(style: subtitleStyle, child: subtitle!),
            ],
          ],
        );

        if (isCompactTile && trailing != null) {
          return Padding(
            padding: padding,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (leading != null) ...[
                      leading!,
                      const SizedBox(width: AppSpacing.sm),
                    ],
                    Expanded(child: titleTextGroup),
                  ],
                ),
                const SizedBox(height: AppSpacing.xs),
                Padding(
                  padding: EdgeInsetsDirectional.only(
                    start: leading != null ? (AppSpacing.md + 18.0) : 0.0,
                  ),
                  child: DefaultTextStyle(
                    style: subtitleStyle,
                    child: trailing!,
                  ),
                ),
              ],
            ),
          );
        }

        return Padding(
          padding: padding,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              if (leading != null) ...[
                leading!,
                const SizedBox(width: AppSpacing.md),
              ],
              Expanded(child: titleTextGroup),
              if (trailing != null) ...[
                const SizedBox(width: AppSpacing.sm),
                trailing!,
              ],
            ],
          ),
        );
      },
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
