import 'package:flutter/material.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shadcn;

import '../layout/app_breakpoints.dart';
import '../theme/tokens/app_radii.dart';

/// Item definition for [AppBottomSheet.showSelection].
class AppBottomSheetSelectionItem<T> {
  const AppBottomSheetSelectionItem({
    required this.value,
    required this.label,
    this.subtitle,
    this.icon,
    this.trailing,
    this.enabled = true,
  });

  final T value;
  final String label;
  final String? subtitle;
  final IconData? icon;
  final Widget? trailing;
  final bool enabled;
}

/// Canonical NexaBiz ERP Bottom Sheet presentation infrastructure,
/// built natively on top of `shadcn_flutter` v0.0.53 (`openSheetOverlay`).
///
/// Provides a unified, accessible, RTL-compliant, theme-aware bottom sheet container
/// supporting form content, selection lists, action sheets, confirmation sheets,
/// keyboard insets, safe areas, and responsive layout constraints.
class AppBottomSheet extends StatelessWidget {
  const AppBottomSheet({
    super.key,
    required this.child,
    this.title,
    this.subtitle,
    this.icon,
    this.actions,
    this.onClose,
    this.padding = const EdgeInsets.all(16.0),
    this.scrollable = true,
    this.isLoading = false,
    this.errorText,
  });

  /// The main body widget content.
  final Widget child;

  /// Optional header title.
  final String? title;

  /// Optional header subtitle.
  final String? subtitle;

  /// Optional header leading icon.
  final IconData? icon;

  /// Optional action buttons displayed in the bottom footer bar.
  final List<Widget>? actions;

  /// Optional close callback override. If null, calls [AppBottomSheet.close].
  final VoidCallback? onClose;

  /// Internal padding for the body content.
  final EdgeInsetsGeometry padding;

  /// Whether the body content is wrapped in a SingleChildScrollView.
  final bool scrollable;

  /// Whether to display a loading indicator overlay inside the body.
  final bool isLoading;

  /// Optional error message banner displayed at top of content.
  final String? errorText;

  /// Standard maximum width for bottom sheets across mobile/tablet/desktop layouts.
  static const double defaultMaxWidth = AppBreakpoints.mobile;

  /// Opens a canonical [AppBottomSheet] as an overlay via `shadcn.openSheetOverlay`.
  static shadcn.DrawerOverlayCompleter<T?> show<T>({
    required BuildContext context,
    required Widget child,
    String? title,
    String? subtitle,
    IconData? icon,
    List<Widget>? actions,
    VoidCallback? onClose,
    EdgeInsetsGeometry padding = const EdgeInsets.all(16.0),
    bool scrollable = true,
    bool isLoading = false,
    String? errorText,
    bool barrierDismissible = true,
    bool draggable = true,
    BoxConstraints? constraints,
  }) {
    final effectiveConstraints =
        constraints ?? const BoxConstraints(maxWidth: defaultMaxWidth);

    return shadcn.openSheetOverlay<T>(
      context: context,
      position: shadcn.OverlayPosition.bottom,
      barrierDismissible: barrierDismissible,
      draggable: draggable,
      constraints: effectiveConstraints,
      builder: (context) {
        return AppBottomSheet(
          title: title,
          subtitle: subtitle,
          icon: icon,
          actions: actions,
          onClose: onClose,
          padding: padding,
          scrollable: scrollable,
          isLoading: isLoading,
          errorText: errorText,
          child: child,
        );
      },
    );
  }

  /// Closes the active bottom sheet or drawer overlay and passes an optional [result].
  static void close<T>(BuildContext context, [T? result]) {
    shadcn.closeDrawer<T>(context, result);
  }

  /// Opens a standardized selection list bottom sheet, returning the selected value [T?].
  static Future<T?> showSelection<T>({
    required BuildContext context,
    required String title,
    required List<AppBottomSheetSelectionItem<T>> items,
    T? selectedValue,
    String? subtitle,
    IconData? icon,
    bool barrierDismissible = true,
  }) async {
    final completer = show<T>(
      context: context,
      title: title,
      subtitle: subtitle,
      icon: icon,
      barrierDismissible: barrierDismissible,
      scrollable: false,
      child: ListView.separated(
        shrinkWrap: true,
        primary: false,
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        itemCount: items.length,
        separatorBuilder: (ctx, idx) => const SizedBox(height: 2),
        itemBuilder: (ctx, index) {
          final item = items[index];
          final isSelected =
              selectedValue != null && selectedValue == item.value;
          final theme = shadcn.Theme.of(ctx);

          return GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: item.enabled ? () => close<T>(ctx, item.value) : null,
            child: Container(
              margin: const EdgeInsets.symmetric(
                horizontal: 12.0,
                vertical: 2.0,
              ),
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 12.0,
              ),
              decoration: BoxDecoration(
                color: isSelected
                    ? theme.colorScheme.primary.withValues(alpha: 0.12)
                    : const Color(0x00000000),
                borderRadius: BorderRadius.circular(12.0),
                border: Border.all(
                  color: isSelected
                      ? theme.colorScheme.primary.withValues(alpha: 0.3)
                      : Colors.transparent,
                  width: 1.0,
                ),
              ),
              child: Row(
                children: [
                  if (item.icon != null) ...[
                    Icon(
                      item.icon,
                      size: 20,
                      color: isSelected
                          ? theme.colorScheme.primary
                          : theme.colorScheme.mutedForeground,
                    ),
                    const SizedBox(width: 12),
                  ],
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          item.label,
                          style: theme.typography.semiBold.copyWith(
                            fontSize: 14.5,
                            color: item.enabled
                                ? (isSelected
                                      ? theme.colorScheme.primary
                                      : theme.colorScheme.foreground)
                                : theme.colorScheme.mutedForeground,
                          ),
                        ),
                        if (item.subtitle != null) ...[
                          const SizedBox(height: 2),
                          Text(
                            item.subtitle!,
                            style: theme.typography.small.copyWith(
                              fontSize: 12.5,
                              color: theme.colorScheme.mutedForeground,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  if (item.trailing != null) item.trailing!,
                  if (isSelected) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        shadcn.LucideIcons.check,
                        size: 14,
                        color: theme.colorScheme.primaryForeground,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
    return completer.future;
  }

  /// Opens a standardized confirmation bottom sheet, returning `true` on confirm or `false`/`null` on cancel.
  static Future<bool?> showConfirmation({
    required BuildContext context,
    required String title,
    required String message,
    String confirmLabel = 'موافق',
    String cancelLabel = 'إلغاء',
    IconData? icon,
    bool isDestructive = false,
  }) async {
    final completer = show<bool>(
      context: context,
      title: title,
      icon:
          icon ??
          (isDestructive
              ? shadcn.LucideIcons.triangleAlert
              : shadcn.LucideIcons.circleHelp),
      child: Text(
        message,
        textAlign: TextAlign.center,
        style: shadcn.Theme.of(context).typography.normal.copyWith(
          fontSize: 14.5,
          height: 1.5,
          color: shadcn.Theme.of(context).colorScheme.mutedForeground,
        ),
      ),
      actions: [
        shadcn.Button.outline(
          onPressed: () => close<bool>(context, false),
          child: Text(cancelLabel),
        ),
        const SizedBox(width: 8),
        isDestructive
            ? shadcn.Button.destructive(
                onPressed: () => close<bool>(context, true),
                child: Text(confirmLabel),
              )
            : shadcn.Button.primary(
                onPressed: () => close<bool>(context, true),
                child: Text(confirmLabel),
              ),
      ],
    );
    return completer.future;
  }

  @override
  Widget build(BuildContext context) {
    final theme = shadcn.Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final safeBottom = MediaQuery.of(context).padding.bottom;

    final bodyWidget = Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Top Drag Handle Pill
        Center(
          child: Container(
            margin: const EdgeInsets.only(top: 10, bottom: 6),
            width: 38,
            height: 4.5,
            decoration: BoxDecoration(
              color: theme.colorScheme.muted.withValues(alpha: 0.6),
              borderRadius: BorderRadius.circular(3),
            ),
          ),
        ),

        // Standardized Header
        if (title != null || icon != null)
          Container(
            padding: const EdgeInsets.fromLTRB(20.0, 10.0, 16.0, 14.0),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: theme.colorScheme.border.withValues(alpha: 0.6),
                  width: 1.0,
                ),
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                if (icon != null) ...[
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(AppRadius.md),
                      border: Border.all(
                        color: theme.colorScheme.primary.withValues(
                          alpha: 0.24,
                        ),
                        width: 1.0,
                      ),
                    ),
                    child: Center(
                      child: Icon(
                        icon,
                        size: 18,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                ],
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (title != null)
                        Text(
                          title!,
                          style: theme.typography.semiBold.copyWith(
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                            letterSpacing: -0.3,
                            color: theme.colorScheme.foreground,
                          ),
                        ),
                      if (subtitle != null) ...[
                        const SizedBox(height: 2),
                        Text(
                          subtitle!,
                          style: theme.typography.small.copyWith(
                            fontSize: 13,
                            color: theme.colorScheme.mutedForeground,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    if (onClose != null) {
                      onClose!();
                    } else {
                      close<void>(context);
                    }
                  },
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: isDark
                          ? theme.colorScheme.muted.withValues(alpha: 0.6)
                          : theme.colorScheme.muted.withValues(alpha: 0.35),
                      borderRadius: BorderRadius.circular(AppRadius.md),
                      border: Border.all(
                        color: theme.colorScheme.border.withValues(alpha: 0.8),
                        width: 1.0,
                      ),
                    ),
                    child: Center(
                      child: Icon(
                        shadcn.LucideIcons.x,
                        size: 18,
                        color: theme.colorScheme.foreground,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

        // Optional Error Banner
        if (errorText != null && errorText!.isNotEmpty)
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 20.0,
              vertical: 10.0,
            ),
            color: theme.colorScheme.destructive.withValues(alpha: 0.1),
            child: Row(
              children: [
                Icon(
                  shadcn.LucideIcons.circleAlert,
                  size: 16,
                  color: theme.colorScheme.destructive,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    errorText!,
                    style: theme.typography.small.copyWith(
                      fontSize: 13,
                      color: theme.colorScheme.destructive,
                    ),
                  ),
                ),
              ],
            ),
          ),

        // Content Area with Keyboard Insets & Safe Areas
        Flexible(
          child: isLoading
              ? Container(
                  height: 120,
                  alignment: Alignment.center,
                  child: const shadcn.CircularProgressIndicator(),
                )
              : (scrollable
                    ? SingleChildScrollView(
                        padding: padding.add(
                          EdgeInsets.only(bottom: bottomInset + safeBottom),
                        ),
                        child: child,
                      )
                    : Padding(
                        padding: padding.add(
                          EdgeInsets.only(bottom: bottomInset + safeBottom),
                        ),
                        child: child,
                      )),
        ),

        // Footer Action Bar
        if (actions != null && actions!.isNotEmpty)
          Container(
            padding: EdgeInsets.fromLTRB(
              20.0,
              14.0,
              20.0,
              14.0 + (bottomInset > 0 ? 0 : safeBottom),
            ),
            decoration: BoxDecoration(
              color: theme.colorScheme.muted.withValues(alpha: 0.15),
              border: Border(
                top: BorderSide(
                  color: theme.colorScheme.border.withValues(alpha: 0.6),
                  width: 1.0,
                ),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: actions!,
            ),
          ),
      ],
    );

    return Align(
      alignment: Alignment.bottomCenter,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: defaultMaxWidth),
        child: Container(
          decoration: BoxDecoration(
            color: theme.colorScheme.popover,
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(22.0),
            ),
            border: Border.all(
              color: theme.colorScheme.border.withValues(alpha: 0.6),
              width: 1.0,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.4 : 0.15),
                blurRadius: 32,
                offset: const Offset(0, -8),
              ),
            ],
          ),
          child: SafeArea(
            top: false,
            left: true,
            right: true,
            bottom: false,
            child: bodyWidget,
          ),
        ),
      ),
    );
  }
}
