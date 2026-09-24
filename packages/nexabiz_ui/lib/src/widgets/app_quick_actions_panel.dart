import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shadcn;

import '../localization/nexabiz_ui_localizations.dart';
import '../theme/tokens/app_spacing.dart';
import 'app_bottom_sheet.dart';
import 'app_icon_button.dart';

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

  // Keep close(context) usable from the shell's original Navigator context.
  // Each invocation remains independent, as with the previous modal API.
  static final _activePanels = <NavigatorState, List<VoidCallback>>{};

  /// Displays the quick actions panel through the canonical sheet overlay.
  static Future<T?> show<T>(
    BuildContext context, {
    required List<AppQuickActionItem> items,
    String title = 'Quick Actions',
    String? subtitle,
  }) async {
    final owner = Navigator.of(context);
    final previousFocus = FocusManager.instance.primaryFocus;
    final direction = Directionality.of(context);
    BuildContext? sheetContext;
    late shadcn.DrawerOverlayCompleter<T?> overlay;
    var closing = false;
    void closePanel() {
      if (closing) return;
      closing = true;
      final mountedContext = sheetContext;
      if (mountedContext != null && mountedContext.mounted) {
        AppBottomSheet.close<T>(mountedContext);
      } else {
        overlay.remove();
      }
    }

    overlay = shadcn.openSheetOverlay<T>(
      context: context,
      position: shadcn.OverlayPosition.bottom,
      barrierDismissible: true,
      draggable: true,
      constraints: const BoxConstraints(
        maxWidth: AppBottomSheet.defaultMaxWidth,
      ),
      builder: (ctx) {
        sheetContext = ctx;
        // SheetWrapper already applies the bottom/side safe-area padding.
        return PopScope(
          canPop: false,
          onPopInvokedWithResult: (didPop, result) {
            if (didPop) return;
            closePanel();
          },
          child: MediaQuery.removePadding(
            context: ctx,
            removeLeft: true,
            removeRight: true,
            removeBottom: true,
            child: Directionality(
              textDirection: direction,
              child: Padding(
                padding: EdgeInsets.only(
                  bottom: MediaQuery.viewInsetsOf(ctx).bottom,
                ),
                child: SingleChildScrollView(
                  child: AppQuickActionsPanel(
                    title: title,
                    subtitle: subtitle,
                    items: items,
                    onClose: closePanel,
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
    final panels = _activePanels.putIfAbsent(owner, () => []);
    panels.add(closePanel);
    try {
      return await overlay.future;
    } finally {
      panels.remove(closePanel);
      if (panels.isEmpty) _activePanels.remove(owner);
      if (previousFocus?.context?.mounted == true &&
          previousFocus!.canRequestFocus) {
        previousFocus.requestFocus();
      }
    }
  }

  /// Closes the latest quick-actions panel belonging to the caller's Navigator if open.
  /// Returns true if an active panel was found and closed.
  static bool closeActivePanel(BuildContext context) {
    final nav = Navigator.maybeOf(context);
    final panels = _activePanels[nav];
    if (panels != null && panels.isNotEmpty) {
      panels.last();
      return true;
    }
    return false;
  }

  /// Closes the latest quick-actions panel belonging to the caller's Navigator.
  static void close(BuildContext context) {
    if (context.findAncestorWidgetOfExactType<shadcn.SheetWrapper>() != null) {
      AppBottomSheet.close<void>(context);
      return;
    }
    final panels = _activePanels[Navigator.maybeOf(context)];
    if (panels != null && panels.isNotEmpty) panels.last();
  }

  @override
  Widget build(BuildContext context) {
    final theme = shadcn.Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.topCenter,
      children: [
        SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Panel Header (Title, Subtitle & Close Button)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
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
                    AppIconButton(
                      variant: AppIconButtonVariant.ghost,
                      icon: shadcn.LucideIcons.x,
                      iconSize: 18,
                      tooltip: NexaBizUiLocalizations.of(context).close,
                      onPressed: onClose ?? () => close(context),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),

                // Action Items Grid
                Flexible(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      double lineHeight(double fontSize) {
                        final painter = TextPainter(
                          text: TextSpan(
                            text: 'Ag',
                            style: DefaultTextStyle.of(
                              context,
                            ).style.copyWith(fontSize: fontSize),
                          ),
                          textDirection: Directionality.of(context),
                          textScaler: MediaQuery.textScalerOf(context),
                        )..layout();
                        final height = painter.height;
                        painter.dispose();
                        return height;
                      }

                      final labelHeight = lineHeight(13);
                      final descriptionHeight = lineHeight(10);
                      final contentHeight =
                          items.any((item) => item.description != null)
                          ? labelHeight + descriptionHeight
                          : labelHeight;
                      final tileWidth =
                          (constraints.maxWidth - AppSpacing.sm) / 2;
                      // Preserve the normal aspect ratio, but let scaled text
                      // determine a larger minimum extent when necessary.
                      final tileHeight = math.max(
                        tileWidth / 2.2,
                        math.max(20 + AppSpacing.xxs * 2, contentHeight) +
                            AppSpacing.xxs * 2 +
                            Border.all().dimensions.vertical,
                      );
                      return GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          mainAxisSpacing: AppSpacing.sm,
                          crossAxisSpacing: AppSpacing.sm,
                          mainAxisExtent: tileHeight,
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
                                shadcn.closeDrawer<void>(context);
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
                                    padding: const EdgeInsets.all(
                                      AppSpacing.xxs,
                                    ),
                                    decoration: BoxDecoration(
                                      color: itemColor.withValues(alpha: 0.16),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Icon(
                                      item.icon,
                                      size: 20,
                                      color: itemColor,
                                    ),
                                  ),
                                  const SizedBox(width: AppSpacing.xs),
                                  Expanded(
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
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
                                              color:
                                                  colorScheme.mutedForeground,
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
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
