import 'package:flutter/widgets.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shadcn;

import '../layout/app_layout_tokens.dart';
import '../theme/tokens/tokens.dart';

/// Item descriptor for an [AppSidebar] navigation destination.
class AppSidebarItem {
  /// Unique key or route path representing this item.
  final Key? key;

  /// Display text label for the navigation item.
  final String label;

  /// Leading icon widget.
  final Widget icon;

  /// Callback when this navigation item is tapped.
  final VoidCallback? onTap;

  /// Whether this item is currently active/selected.
  final bool selected;

  /// Optional trailing badge text or widget.
  final Widget? badge;

  /// Optional trailing status or count widget.
  final Widget? trailing;

  /// Whether this item is enabled.
  final bool enabled;

  const AppSidebarItem({
    this.key,
    required this.label,
    required this.icon,
    this.onTap,
    this.selected = false,
    this.badge,
    this.trailing,
    this.enabled = true,
  });
}

/// Logical grouping of [AppSidebarItem] entries with an optional category header.
class AppSidebarGroup {
  /// Optional title for the group.
  final String? title;

  /// Children navigation items in this group.
  final List<AppSidebarItem> items;

  const AppSidebarGroup({
    this.title,
    required this.items,
  });
}

/// Canonical enterprise navigation sidebar for NexaBiz ERP.
///
/// Built on top of [shadcn.NavigationSidebar] and compliant with the
/// Enterprise Structured Frame architecture. Provides top-to-bottom
/// structured navigation with full RTL directionality, company switcher header,
/// grouped items, and user footer.
class AppSidebar extends StatelessWidget {
  /// Header widget (e.g. [AppCompanySwitcher] or brand logo).
  final Widget? header;

  /// Navigation groups displayed within the scrollable sidebar body.
  final List<AppSidebarGroup> groups;

  /// Footer widget (e.g. user profile tile or system status).
  final Widget? footer;

  /// Sidebar width when expanded. Defaults to [AppLayoutTokens.navSidebarWidth] (240.0).
  final double width;

  /// Whether the sidebar is collapsed into rail mode.
  final bool isCollapsed;

  /// Background color override. Resolves to [shadcn.ColorScheme.card] when null.
  final Color? backgroundColor;

  const AppSidebar({
    super.key,
    this.header,
    required this.groups,
    this.footer,
    this.width = AppLayoutTokens.navSidebarWidth,
    this.isCollapsed = false,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = shadcn.Theme.of(context);
    final colorScheme = theme.colorScheme;
    final effectiveBg = backgroundColor ?? colorScheme.card;

    final effectiveWidth =
        isCollapsed ? AppLayoutTokens.navCollapsedSidebarWidth : width;

    final isRtl = Directionality.of(context) == TextDirection.rtl;

    return Container(
      width: effectiveWidth,
      decoration: BoxDecoration(
        color: effectiveBg,
        border: Border(
          // In RTL, the sidebar sits on the right, so the inner divider is on the left
          left: isRtl
              ? BorderSide(color: colorScheme.border, width: AppBorders.thin)
              : BorderSide.none,
          // In LTR, the sidebar sits on the left, so the inner divider is on the right
          right: !isRtl
              ? BorderSide(color: colorScheme.border, width: AppBorders.thin)
              : BorderSide.none,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (header != null)
            Container(
              padding: const EdgeInsets.all(AppSpacing.sm),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: colorScheme.border,
                    width: AppBorders.thin,
                  ),
                ),
              ),
              child: header!,
            ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                vertical: AppSpacing.sm,
                horizontal: AppSpacing.xs,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  for (final (gIndex, group) in groups.indexed) ...[
                    if (group.title != null && !isCollapsed) ...[
                      Padding(
                        padding: const EdgeInsetsDirectional.only(
                          start: AppSpacing.sm,
                          top: AppSpacing.sm,
                          bottom: AppSpacing.xs,
                        ),
                        child: Text(
                          group.title!.toUpperCase(),
                          style: theme.typography.xSmall.copyWith(
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.8,
                            color: colorScheme.mutedForeground,
                          ),
                        ),
                      ),
                    ],
                    for (final item in group.items) ...[
                      _SidebarItemTile(
                        item: item,
                        isCollapsed: isCollapsed,
                      ),
                      const SizedBox(height: 2.0),
                    ],
                    if (gIndex < groups.length - 1)
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: AppSpacing.xs,
                          horizontal: AppSpacing.sm,
                        ),
                        child: Container(
                          height: 1.0,
                          color: colorScheme.border.withValues(alpha: 0.4),
                        ),
                      ),
                  ],
                ],
              ),
            ),
          ),
          if (footer != null)
            Container(
              padding: const EdgeInsets.all(AppSpacing.sm),
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(
                    color: colorScheme.border,
                    width: AppBorders.thin,
                  ),
                ),
              ),
              child: footer!,
            ),
        ],
      ),
    );
  }
}

class _SidebarItemTile extends StatelessWidget {
  final AppSidebarItem item;
  final bool isCollapsed;

  const _SidebarItemTile({
    required this.item,
    required this.isCollapsed,
  });

  @override
  Widget build(BuildContext context) {
    final theme = shadcn.Theme.of(context);
    final colorScheme = theme.colorScheme;

    final isSelected = item.selected;

    final content = shadcn.Button(
      style: isSelected
          ? const shadcn.ButtonStyle.secondary()
          : const shadcn.ButtonStyle.ghost(),
      alignment: isCollapsed ? Alignment.center : AlignmentDirectional.centerStart,
      onPressed: item.enabled ? item.onTap : null,
      child: isCollapsed
          ? item.icon
          : Row(
              children: [
                item.icon,
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    item.label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontWeight:
                          isSelected ? FontWeight.w600 : FontWeight.w500,
                      color: isSelected
                          ? colorScheme.primary
                          : colorScheme.foreground,
                    ),
                  ),
                ),
                if (item.badge != null) ...[
                  const SizedBox(width: AppSpacing.xs),
                  item.badge!,
                ],
                if (item.trailing != null) ...[
                  const SizedBox(width: AppSpacing.xs),
                  item.trailing!,
                ],
              ],
            ),
    );

    if (isCollapsed) {
      return shadcn.Tooltip(
        tooltip: (context) => Text(item.label),
        child: content,
      );
    }

    return content;
  }
}
