import 'package:flutter/material.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shadcn;

import '../theme/tokens/app_spacing.dart';
import 'app_custom_bottom_nav.dart';

/// Single item descriptor for quick actions grid.
class AppQuickActionItem {
  final String label;
  final String? description;
  final IconData icon;
  final Color? color;
  final VoidCallback onTap;

  const AppQuickActionItem({
    required this.label,
    this.description,
    required this.icon,
    this.color,
    required this.onTap,
  });
}

/// Canonical slide-over Quick Actions modal panel.
class AppQuickActionsPanel extends StatelessWidget {
  final String title;
  final String? subtitle;
  final List<AppQuickActionItem> items;
  final VoidCallback? onClose;

  const AppQuickActionsPanel({
    super.key,
    this.title = 'Quick Actions',
    this.subtitle = 'Create new documents or execute common business tasks',
    required this.items,
    this.onClose,
  });

  /// Displays the quick actions panel using [showModalBottomSheet].
  static Future<T?> show<T>(
    BuildContext context, {
    required List<AppQuickActionItem> items,
    String title = 'Quick Actions',
    String? subtitle,
  }) async {
    return showModalBottomSheet<T>(
      context: context,
      backgroundColor: const Color(0x00000000),
      isScrollControlled: true,
      useSafeArea: true,
      builder: (ctx) => AppQuickActionsPanel(
        title: title,
        subtitle: subtitle,
        items: items,
        onClose: () => Navigator.of(ctx).pop(),
      ),
    );
  }

  /// Closes the active quick actions bottom sheet panel.
  static void close(BuildContext context) {
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    } else {
      shadcn.closeSheet(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = shadcn.Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.topCenter,
      children: [
        Container(
          margin: const EdgeInsets.only(top: QuickActionsFab.size / 2),
          decoration: BoxDecoration(
            color: colorScheme.popover,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            border: Border.all(color: colorScheme.border),
            boxShadow: [
              BoxShadow(
                color: colorScheme.primary.withValues(alpha: 0.15),
                blurRadius: 24,
                offset: const Offset(0, -8),
              ),
            ],
          ),
          child: SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.md,
                AppSpacing.lg,
                AppSpacing.md,
                AppSpacing.md,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Drag Handle Indicator
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
                      decoration: BoxDecoration(
                        color: colorScheme.border,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),

              // Panel Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: colorScheme.foreground,
                          ),
                        ),
                        if (subtitle != null) ...[
                          const SizedBox(height: AppSpacing.xxs),
                          Text(
                            subtitle!,
                            style: TextStyle(
                              fontSize: 12,
                              color: colorScheme.mutedForeground,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  shadcn.IconButton.ghost(
                    icon: const Icon(shadcn.LucideIcons.x, size: 18),
                    onPressed: onClose ?? () => shadcn.closeSheet(context),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),

              // Action Items Grid
              Flexible(
                child: GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: AppSpacing.sm,
                    crossAxisSpacing: AppSpacing.sm,
                    childAspectRatio: 2.2,
                  ),
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    final item = items[index];
                    final itemColor = item.color ?? colorScheme.primary;

                    return GestureDetector(
                      onTap: () {
                        if (onClose != null) {
                          onClose!();
                        } else {
                          shadcn.closeDrawer(context);
                        }
                        item.onTap();
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.xs,
                          vertical: AppSpacing.xxs,
                        ),
                        decoration: BoxDecoration(
                          color: itemColor.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: itemColor.withValues(alpha: 0.18),
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(AppSpacing.xxs),
                              decoration: BoxDecoration(
                                color: itemColor.withValues(alpha: 0.16),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(item.icon, size: 20, color: itemColor),
                            ),
                            const SizedBox(width: AppSpacing.xs),
                            Expanded(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.label,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: colorScheme.foreground,
                                    ),
                                  ),
                                  if (item.description != null)
                                    Text(
                                      item.description!,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontSize: 10,
                                        color: colorScheme.mutedForeground,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    ),
    Positioned(
      top: 0,
      child: QuickActionsFab(
        tooltip: 'Close Quick Actions',
        isOpen: true,
        onPressed: onClose ?? () => close(context),
      ),
    ),
  ],
);
  }
}
