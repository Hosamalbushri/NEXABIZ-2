import 'dart:async';
import 'package:flutter/widgets.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shadcn;

import '../layout/app_breakpoints.dart';

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
    final effectiveConstraints = constraints ??
        const BoxConstraints(maxWidth: defaultMaxWidth);

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
          final isSelected = selectedValue != null && selectedValue == item.value;
          final theme = shadcn.Theme.of(ctx);

          return GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: item.enabled
                ? () => close<T>(ctx, item.value)
                : null,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
              decoration: BoxDecoration(
                color: isSelected
                    ? theme.colorScheme.primary.withValues(alpha: 0.1)
                    : const Color(0x00000000),
                borderRadius: BorderRadius.circular(8.0),
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
                            fontSize: 14,
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
                              fontSize: 12,
                              color: theme.colorScheme.mutedForeground,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  if (item.trailing != null) item.trailing!,
                  if (isSelected)
                    Icon(
                      shadcn.LucideIcons.check,
                      size: 18,
                      color: theme.colorScheme.primary,
                    ),
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
      icon: icon ?? (isDestructive ? shadcn.LucideIcons.triangleAlert : shadcn.LucideIcons.circleHelp),
      child: Text(
        message,
        style: shadcn.Theme.of(context).typography.normal.copyWith(
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
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final safeBottom = MediaQuery.of(context).padding.bottom;

    final bodyWidget = Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Standardized Header
        if (title != null || icon != null)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(color: theme.colorScheme.border),
              ),
            ),
            child: Row(
              children: [
                if (icon != null) ...[
                  Icon(icon, size: 20, color: theme.colorScheme.primary),
                  const SizedBox(width: 10),
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
                            fontSize: 16,
                            color: theme.colorScheme.foreground,
                          ),
                        ),
                      if (subtitle != null) ...[
                        const SizedBox(height: 2),
                        Text(
                          subtitle!,
                          style: theme.typography.small.copyWith(
                            fontSize: 12,
                            color: theme.colorScheme.mutedForeground,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                shadcn.IconButton.ghost(
                  icon: const Icon(shadcn.LucideIcons.x, size: 18),
                  onPressed: () {
                    if (onClose != null) {
                      onClose!();
                    } else {
                      close(context);
                    }
                  },
                ),
              ],
            ),
          ),

        // Optional Error Banner
        if (errorText != null && errorText!.isNotEmpty)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            color: theme.colorScheme.destructive.withValues(alpha: 0.1),
            child: Row(
              children: [
                Icon(shadcn.LucideIcons.circleAlert, size: 16, color: theme.colorScheme.destructive),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    errorText!,
                    style: theme.typography.small.copyWith(
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
                      padding: padding.add(EdgeInsets.only(bottom: bottomInset + safeBottom)),
                      child: child,
                    )
                  : Padding(
                      padding: padding.add(EdgeInsets.only(bottom: bottomInset + safeBottom)),
                      child: child,
                    )),
        ),

        // Footer Action Bar
        if (actions != null && actions!.isNotEmpty)
          Container(
            padding: EdgeInsets.fromLTRB(16.0, 12.0, 16.0, 12.0 + (bottomInset > 0 ? 0 : safeBottom)),
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(color: theme.colorScheme.border),
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
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16.0)),
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
