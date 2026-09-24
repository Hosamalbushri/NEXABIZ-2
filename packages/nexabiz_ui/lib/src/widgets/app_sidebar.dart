import 'package:flutter/widgets.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shadcn;

import '../layout/app_layout_tokens.dart';
import '../theme/tokens/tokens.dart';
import 'app_navigation_item.dart';

/// Logical grouping of navigation entries with an optional category header.
class AppSidebarGroup {
  /// Optional title for the group.
  final String? title;

  /// Children navigation items in this group.
  final List<AppNavigationItem> items;

  const AppSidebarGroup({this.title, required this.items});
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

  /// Identifier of the selected destination.
  final String? selectedId;

  /// Reports selection to the application, which owns navigation policy.
  final ValueChanged<String>? onSelected;

  const AppSidebar({
    super.key,
    this.header,
    required this.groups,
    this.footer,
    this.width = AppLayoutTokens.navSidebarWidth,
    this.isCollapsed = false,
    this.backgroundColor,
    this.selectedId,
    this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final theme = shadcn.Theme.of(context);
    final colorScheme = theme.colorScheme;
    final effectiveBg = backgroundColor ?? colorScheme.card;

    final effectiveWidth = isCollapsed
        ? AppLayoutTokens.navCollapsedSidebarWidth
        : width;

    return Container(
      width: effectiveWidth,
      decoration: BoxDecoration(
        color: effectiveBg,
        border: BorderDirectional(
          end: BorderSide(color: colorScheme.border, width: AppBorders.thin),
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
                        key: ValueKey(item.id),
                        item: item,
                        isCollapsed: isCollapsed,
                        selected: item.id == selectedId,
                        onPressed: onSelected == null
                            ? null
                            : () => onSelected!(item.id),
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
  final AppNavigationItem item;
  final bool isCollapsed;
  final bool selected;
  final VoidCallback? onPressed;

  const _SidebarItemTile({
    super.key,
    required this.item,
    required this.isCollapsed,
    required this.selected,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final theme = shadcn.Theme.of(context);
    final colorScheme = theme.colorScheme;

    final isSelected = selected;

    final content = Semantics(
      button: true,
      selected: isSelected,
      enabled: item.enabled,
      label: item.label,
      child: shadcn.Button(
        style: isSelected
            ? const shadcn.ButtonStyle.secondary()
            : const shadcn.ButtonStyle.ghost(),
        alignment: isCollapsed
            ? Alignment.center
            : AlignmentDirectional.centerStart,
        onPressed: item.enabled ? onPressed : null,
        child: isCollapsed
            ? Icon(
                isSelected && item.selectedIcon != null
                    ? item.selectedIcon
                    : item.icon,
              )
            : Row(
                children: [
                  Icon(
                    isSelected && item.selectedIcon != null
                        ? item.selectedIcon
                        : item.icon,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(
                      item.label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontWeight: isSelected
                            ? FontWeight.w600
                            : FontWeight.w500,
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
