import 'package:flutter/material.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shadcn;

import '../theme/tokens/tokens.dart';
import 'app_button.dart';
import 'app_icon_avatar.dart';

/// Predefined canonical width variants for NexaBiz dialogs with enhanced breathing room.
enum AppDialogSize {
  /// Small dialog (max-width: 460px). Ideal for simple alerts, confirmations, or small prompts.
  small(460),

  /// Medium dialog (max-width: 640px). Ideal for standard forms, quick detail cards, or selectors.
  medium(640),

  /// Large dialog (max-width: 880px). Ideal for multi-section forms, detailed tables, or trees.
  large(880),

  /// Fullscreen dialog (fills available viewport width & height).
  fullscreen(double.infinity);

  const AppDialogSize(this.maxWidth);
  final double maxWidth;
}

/// Semantic tones for confirmation and alert dialogs.
enum AppDialogTone { primary, info, warning, danger }

/// Canonical NexaBiz Central Dialog Component (`NexaBizDialog<T>`).
///
/// Built natively on `shadcn_flutter` overlays and theme tokens.
class AppDialog<T> extends StatelessWidget {
  const AppDialog({
    super.key,
    this.title,
    this.description,
    this.icon,
    this.leading,
    this.trailing,
    this.errorMessage,
    this.isLoading = false,
    this.size = AppDialogSize.medium,
    this.padding = const EdgeInsets.all(AppSpacing.xl),
    this.contentPadding = const EdgeInsets.symmetric(
      horizontal: 24,
      vertical: 18,
    ),
    required this.child,
    this.actions,
    this.confirmLabel = 'Confirm',
    this.cancelLabel = 'Cancel',
    this.onConfirm,
    this.onCancel,
    this.isDestructive = false,
    this.showCloseButton = true,
    this.showActions = true,
    this.showCancelButton = true,
    this.showConfirmButton = true,
    this.centerHeader = true,
    this.centerContent = true,
  });

  final String? title;
  final String? description;
  final IconData? icon;
  final Widget? leading;
  final Widget? trailing;
  final String? errorMessage;
  final bool isLoading;
  final AppDialogSize size;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry contentPadding;
  final Widget child;
  final List<Widget>? actions;
  final String confirmLabel;
  final String cancelLabel;
  final VoidCallback? onConfirm;
  final VoidCallback? onCancel;
  final bool isDestructive;
  final bool showCloseButton;
  final bool showActions;
  final bool showCancelButton;
  final bool showConfirmButton;
  final bool centerHeader;
  final bool centerContent;

  static Future<T?> show<T>({
    required BuildContext context,
    String? title,
    String? description,
    IconData? icon,
    Widget? leading,
    Widget? trailing,
    String? errorMessage,
    bool isLoading = false,
    AppDialogSize size = AppDialogSize.medium,
    EdgeInsetsGeometry padding = const EdgeInsets.all(AppSpacing.xl),
    EdgeInsetsGeometry contentPadding = const EdgeInsets.symmetric(
      horizontal: 24,
      vertical: 18,
    ),
    required Widget child,
    List<Widget>? actions,
    String confirmLabel = 'Confirm',
    String cancelLabel = 'Cancel',
    VoidCallback? onConfirm,
    VoidCallback? onCancel,
    bool isDestructive = false,
    bool showCloseButton = true,
    bool showActions = true,
    bool showCancelButton = true,
    bool showConfirmButton = true,
    bool centerHeader = true,
    bool centerContent = true,
    bool barrierDismissible = true,
    bool useRootNavigator = true,
  }) {
    final completer = shadcn.showOverlay<T>(
      context,
      shadcn.DialogConfiguration(
        builder: (overlayContext) {
          return AppDialog<T>(
            title: title,
            description: description,
            icon: icon,
            leading: leading,
            trailing: trailing,
            errorMessage: errorMessage,
            isLoading: isLoading,
            size: size,
            padding: padding,
            contentPadding: contentPadding,
            actions: actions,
            confirmLabel: confirmLabel,
            cancelLabel: cancelLabel,
            onConfirm: onConfirm,
            onCancel: onCancel,
            isDestructive: isDestructive,
            showCloseButton: showCloseButton,
            showActions: showActions,
            showCancelButton: showCancelButton,
            showConfirmButton: showConfirmButton,
            centerHeader: centerHeader,
            centerContent: centerContent,
            child: child,
          );
        },
      ),
    );
    return completer.future;
  }

  /// Canonical Information Dialog helper.
  static Future<void> info({
    required BuildContext context,
    required String title,
    required String message,
    String okLabel = 'OK',
    VoidCallback? onOk,
    bool barrierDismissible = true,
  }) {
    return show<void>(
      context: context,
      title: title,
      description: message,
      icon: shadcn.LucideIcons.info,
      size: AppDialogSize.small,
      showCancelButton: false,
      confirmLabel: okLabel,
      onConfirm: onOk,
      barrierDismissible: barrierDismissible,
      child: const SizedBox.shrink(),
    );
  }

  /// Canonical Confirmation Dialog helper.
  static Future<bool?> confirm({
    required BuildContext context,
    required String title,
    required String message,
    String confirmLabel = 'Confirm',
    String cancelLabel = 'Cancel',
    AppDialogTone tone = AppDialogTone.info,
    VoidCallback? onConfirm,
    VoidCallback? onCancel,
    bool barrierDismissible = true,
    Widget? customBody,
  }) {
    IconData? icon;
    if (tone == AppDialogTone.warning) {
      icon = shadcn.LucideIcons.triangleAlert;
    } else if (tone == AppDialogTone.danger) {
      icon = shadcn.LucideIcons.octagonAlert;
    }

    return show<bool>(
      context: context,
      title: title,
      description: message,
      icon: icon,
      size: AppDialogSize.small,
      isDestructive: tone == AppDialogTone.danger,
      confirmLabel: confirmLabel,
      cancelLabel: cancelLabel,
      onConfirm: onConfirm,
      onCancel: onCancel,
      barrierDismissible: barrierDismissible,
      child: customBody ?? const SizedBox.shrink(),
    );
  }

  /// Canonical Warning Dialog helper.
  static Future<bool?> warning({
    required BuildContext context,
    required String title,
    required String message,
    String confirmLabel = 'Proceed',
    String cancelLabel = 'Cancel',
    VoidCallback? onConfirm,
    VoidCallback? onCancel,
    bool barrierDismissible = true,
  }) {
    return confirm(
      context: context,
      title: title,
      message: message,
      confirmLabel: confirmLabel,
      cancelLabel: cancelLabel,
      tone: AppDialogTone.warning,
      onConfirm: onConfirm,
      onCancel: onCancel,
      barrierDismissible: barrierDismissible,
    );
  }

  /// Canonical Destructive Action Confirmation Dialog helper.
  static Future<bool?> destructive({
    required BuildContext context,
    required String title,
    required String message,
    String confirmLabel = 'Delete',
    String cancelLabel = 'Cancel',
    VoidCallback? onConfirm,
    VoidCallback? onCancel,
    bool barrierDismissible = true,
  }) {
    return confirm(
      context: context,
      title: title,
      message: message,
      confirmLabel: confirmLabel,
      cancelLabel: cancelLabel,
      tone: AppDialogTone.danger,
      onConfirm: onConfirm,
      onCancel: onCancel,
      barrierDismissible: barrierDismissible,
    );
  }

  /// Canonical Small Decision Dialog helper with multiple choice actions.
  static Future<T?> decision<T>({
    required BuildContext context,
    required String title,
    required String description,
    required Widget child,
    List<Widget>? actions,
    IconData? icon,
    bool barrierDismissible = true,
  }) {
    return show<T>(
      context: context,
      title: title,
      description: description,
      icon: icon ?? shadcn.LucideIcons.circleHelp,
      size: AppDialogSize.small,
      actions: actions,
      showConfirmButton: false,
      showCancelButton: false,
      barrierDismissible: barrierDismissible,
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = shadcn.Theme.of(context);
    final colorScheme = theme.colorScheme;
    final mediaQuery = MediaQuery.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final isFullscreen = size == AppDialogSize.fullscreen;
    final hasHeader =
        title != null ||
        description != null ||
        icon != null ||
        leading != null ||
        trailing != null ||
        showCloseButton;
    final renderActions =
        showActions && (actions == null || actions!.isNotEmpty);

    final dialogBgColor = colorScheme.popover;
    final borderColor = colorScheme.border.withValues(alpha: 0.6);
    final footerBgColor = colorScheme.muted.withValues(alpha: 0.15);

    // Build Icon Avatar
    final Widget? resolvedAvatar =
        leading ??
        (icon != null
            ? AppIconAvatar(
                icon: icon!,
                tone: isDestructive
                    ? AppIconAvatarTone.error
                    : (isDark
                          ? AppIconAvatarTone.primary
                          : AppIconAvatarTone.primary),
                size: AppIconAvatarSize.md,
              )
            : null);

    final Widget? closeButtonWidget = showCloseButton && trailing == null
        ? Material(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(AppRadius.md),
            child: InkWell(
              onTap: isLoading
                  ? null
                  : () {
                      onCancel?.call();
                      shadcn.closeOverlay(context, null);
                    },
              borderRadius: BorderRadius.circular(AppRadius.md),
              hoverColor: colorScheme.destructive.withValues(alpha: 0.15),
              highlightColor: colorScheme.destructive.withValues(alpha: 0.25),
              child: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: isDark
                      ? colorScheme.muted.withValues(alpha: 0.6)
                      : colorScheme.muted.withValues(alpha: 0.35),
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  border: Border.all(
                    color: colorScheme.border.withValues(alpha: 0.8),
                    width: 1.0,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(
                        alpha: isDark ? 0.2 : 0.05,
                      ),
                      blurRadius: 4,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
                child: Center(
                  child: Icon(
                    shadcn.LucideIcons.x,
                    size: 18,
                    color: colorScheme.foreground,
                  ),
                ),
              ),
            ),
          )
        : null;

    Widget headerWidget = const SizedBox.shrink();
    if (hasHeader) {
      headerWidget = Container(
        padding: const EdgeInsets.fromLTRB(16, 18, 16, 16),
        decoration: BoxDecoration(
          color: dialogBgColor,
          border: Border(bottom: BorderSide(color: borderColor, width: 1)),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            if (resolvedAvatar != null) ...[
              resolvedAvatar,
              const SizedBox(width: AppSpacing.sm),
            ] else if (closeButtonWidget != null || trailing != null) ...[
              // Spacer to balance the close button on the right for true centering
              const SizedBox(width: 32),
            ],
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  if (title != null)
                    Text(
                      title!,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.3,
                        height: 1.25,
                        color: colorScheme.foreground,
                      ),
                    ),
                ],
              ),
            ),
            if (trailing != null || closeButtonWidget != null) ...[
              const SizedBox(width: AppSpacing.sm),
              trailing ?? closeButtonWidget!,
            ] else if (resolvedAvatar != null) ...[
              const SizedBox(width: 32),
            ],
          ],
        ),
      );
    }

    Widget errorBannerWidget = const SizedBox.shrink();
    if (errorMessage case final String msg when msg.trim().isNotEmpty) {
      errorBannerWidget = Container(
        margin: const EdgeInsets.fromLTRB(20, 12, 20, 4),
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: colorScheme.destructive.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: colorScheme.destructive.withValues(alpha: 0.3),
          ),
        ),
        child: Row(
          children: [
            Icon(
              shadcn.LucideIcons.triangleAlert,
              color: colorScheme.destructive,
              size: 18,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                errorMessage!,
                style: TextStyle(
                  fontSize: 13,
                  color: colorScheme.destructive,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      );
    }

    Widget actionsWidget = const SizedBox.shrink();
    if (renderActions) {
      actionsWidget = Container(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
        decoration: BoxDecoration(
          color: footerBgColor,
          border: Border(top: BorderSide(color: borderColor, width: 1)),
          borderRadius: const BorderRadius.vertical(
            bottom: Radius.circular(20),
          ),
        ),
        child: Builder(
          builder: (context) {
            if (actions != null) {
              return Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: actions!,
              );
            }

            final confirmBtn = AppButton(
              label: confirmLabel,
              variant: isDestructive
                  ? AppButtonVariant.destructive
                  : AppButtonVariant.filled,
              isLoading: isLoading,
              expand: true,
              onPressed: isLoading
                  ? null
                  : () {
                      onConfirm?.call();
                      shadcn.closeOverlay(context, true);
                    },
            );

            final cancelBtn = showCancelButton && confirmLabel != cancelLabel
                ? AppButton(
                    label: cancelLabel,
                    variant: AppButtonVariant.outlined,
                    expand: true,
                    onPressed: isLoading
                        ? null
                        : () {
                            onCancel?.call();
                            shadcn.closeOverlay(context, false);
                          },
                  )
                : null;

            return Row(
              children: [
                if (cancelBtn != null) Expanded(child: cancelBtn),
                if (cancelBtn != null && showConfirmButton)
                  const SizedBox(width: 12),
                if (showConfirmButton) Expanded(child: confirmBtn),
              ],
            );
          },
        ),
      );
    }

    final maxDialogWidth = size.maxWidth;
    final viewportHeight = mediaQuery.size.height;
    final maxDialogHeight = isFullscreen
        ? viewportHeight
        : viewportHeight * 0.88;

    final isChildEmpty =
        child is SizedBox &&
        (child as SizedBox).width == 0 &&
        (child as SizedBox).height == 0;
    final hasDescription =
        description != null && description!.trim().isNotEmpty;

    final Widget bodyWidget = !isChildEmpty
        ? child
        : (hasDescription
              ? Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(24, 20, 24, 20),
                  child: Text(
                    description!,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14.5,
                      height: 1.55,
                      color: colorScheme.mutedForeground,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                )
              : const SizedBox.shrink());

    final bool renderBody = !isChildEmpty || hasDescription;

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Container(
          decoration: BoxDecoration(
            color: dialogBgColor,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: borderColor, width: 1),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.4 : 0.12),
                blurRadius: 32,
                offset: const Offset(0, 12),
                spreadRadius: -4,
              ),
            ],
          ),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: maxDialogWidth,
              maxHeight: maxDialogHeight,
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Column(
                mainAxisSize: isFullscreen
                    ? MainAxisSize.max
                    : MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  headerWidget,
                  errorBannerWidget,
                  if (renderBody)
                    Flexible(
                      child: SingleChildScrollView(
                        padding: !isChildEmpty
                            ? contentPadding
                            : EdgeInsets.zero,
                        child: centerContent
                            ? Center(
                                child: DefaultTextStyle.merge(
                                  textAlign: TextAlign.center,
                                  child: bodyWidget,
                                ),
                              )
                            : bodyWidget,
                      ),
                    ),
                  actionsWidget,
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
