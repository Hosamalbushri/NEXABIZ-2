import 'package:flutter/widgets.dart';
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

  static Future<bool?> confirm({
    required BuildContext context,
    required String title,
    required String message,
    String confirmLabel = 'Confirm',
    String cancelLabel = 'Cancel',
    AppDialogTone tone = AppDialogTone.warning,
    VoidCallback? onConfirm,
    VoidCallback? onCancel,
    Widget? customBody,
    bool barrierDismissible = true,
  }) {
    final avatarTone = switch (tone) {
      AppDialogTone.primary => AppIconAvatarTone.primary,
      AppDialogTone.info => AppIconAvatarTone.info,
      AppDialogTone.warning => AppIconAvatarTone.warning,
      AppDialogTone.danger => AppIconAvatarTone.error,
    };

    final iconData = switch (tone) {
      AppDialogTone.primary => shadcn.LucideIcons.circleHelp,
      AppDialogTone.info => shadcn.LucideIcons.info,
      AppDialogTone.warning => shadcn.LucideIcons.triangleAlert,
      AppDialogTone.danger => shadcn.LucideIcons.circleAlert,
    };

    return show<bool>(
      context: context,
      title: title,
      size: AppDialogSize.small,
      isDestructive: tone == AppDialogTone.danger,
      confirmLabel: confirmLabel,
      cancelLabel: cancelLabel,
      onConfirm: onConfirm,
      onCancel: onCancel,
      barrierDismissible: barrierDismissible,
      centerHeader: true,
      centerContent: true,
      leading: AppIconAvatar(
        icon: iconData,
        tone: avatarTone,
        size: AppIconAvatarSize.md,
      ),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                height: 1.5,
                fontWeight: FontWeight.w500,
              ),
            ),
            if (customBody != null) ...[const SizedBox(height: 14), customBody],
          ],
        ),
      ),
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
    final borderColor = colorScheme.border;
    final footerBgColor = colorScheme.muted.withValues(alpha: 0.3);

    final rawAvatar =
        leading ??
        (icon != null
            ? AppIconAvatar(
                icon: icon!,
                tone: isDestructive
                    ? AppIconAvatarTone.error
                    : AppIconAvatarTone.primary,
                size: AppIconAvatarSize.sm,
              )
            : null);

    final resolvedLeading = rawAvatar != null
        ? Container(
            padding: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color:
                    (isDestructive
                            ? colorScheme.destructive
                            : colorScheme.primary)
                        .withValues(alpha: isDark ? 0.3 : 0.2),
                width: 1,
              ),
            ),
            child: rawAvatar,
          )
        : null;

    final closeButtonWidget = showCloseButton && trailing == null
        ? shadcn.GhostButton(
            onPressed: isLoading
                ? null
                : () {
                    onCancel?.call();
                    shadcn.closeOverlay(context, null);
                  },
            child: Icon(
              shadcn.LucideIcons.x,
              size: 16,
              color: colorScheme.mutedForeground,
            ),
          )
        : null;

    Widget headerWidget = const SizedBox.shrink();
    if (hasHeader) {
      final Widget leftSlotWidget =
          resolvedLeading ??
          (showCloseButton && trailing == null
              ? const SizedBox(width: 28)
              : const SizedBox.shrink());
      final Widget rightSlotWidget =
          trailing ??
          (closeButtonWidget ??
              (resolvedLeading != null
                  ? const SizedBox(width: 28)
                  : const SizedBox.shrink()));

      headerWidget = Container(
        padding: const EdgeInsets.fromLTRB(24, 20, 20, 16),
        decoration: BoxDecoration(
          color: dialogBgColor,
          border: Border(bottom: BorderSide(color: borderColor, width: 1)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            leftSlotWidget,
            if (resolvedLeading != null) const SizedBox(width: 14),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: centerHeader
                    ? CrossAxisAlignment.center
                    : CrossAxisAlignment.start,
                children: [
                  if (title != null)
                    Text(
                      title!,
                      textAlign: centerHeader
                          ? TextAlign.center
                          : TextAlign.start,
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.3,
                        color: colorScheme.foreground,
                      ),
                    ),
                  if (description != null) ...[
                    const SizedBox(height: 3),
                    Text(
                      description!,
                      textAlign: centerHeader
                          ? TextAlign.center
                          : TextAlign.start,
                      style: TextStyle(
                        fontSize: 13,
                        height: 1.45,
                        color: colorScheme.mutedForeground,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (rightSlotWidget is! SizedBox || rightSlotWidget.width != 0)
              const SizedBox(width: 12),
            rightSlotWidget,
          ],
        ),
      );
    }

    Widget errorBannerWidget = const SizedBox.shrink();
    if (errorMessage case final String msg when msg.trim().isNotEmpty) {
      errorBannerWidget = Container(
        margin: const EdgeInsets.fromLTRB(24, 12, 24, 4),
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
                textAlign: centerHeader ? TextAlign.center : TextAlign.start,
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
      List<Widget> defaultActionButtons;
      if (actions != null) {
        defaultActionButtons = actions!;
      } else {
        final buttons = <Widget>[];

        if (showCancelButton && confirmLabel != cancelLabel) {
          buttons.add(
            Expanded(
              child: AppButton(
                label: cancelLabel,
                variant: AppButtonVariant.outlined,
                expand: true,
                onPressed: isLoading
                    ? null
                    : () {
                        onCancel?.call();
                        shadcn.closeOverlay(context, false);
                      },
              ),
            ),
          );
        }

        if (showConfirmButton) {
          if (buttons.isNotEmpty) {
            buttons.add(const SizedBox(width: 12));
          }

          buttons.add(
            Expanded(
              child: AppButton(
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
              ),
            ),
          );
        }

        defaultActionButtons = buttons;
      }

      actionsWidget = Container(
        padding: const EdgeInsets.fromLTRB(24, 14, 24, 18),
        decoration: BoxDecoration(
          color: footerBgColor,
          border: Border(top: BorderSide(color: borderColor, width: 1)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: defaultActionButtons,
        ),
      );
    }

    final maxDialogWidth = size.maxWidth;
    final viewportHeight = mediaQuery.size.height;
    final maxDialogHeight = isFullscreen
        ? viewportHeight
        : viewportHeight * 0.88;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: shadcn.SurfaceCard(
          padding: EdgeInsets.zero,
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: maxDialogWidth,
              maxHeight: maxDialogHeight,
            ),
            child: Column(
              mainAxisSize: isFullscreen ? MainAxisSize.max : MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                headerWidget,
                errorBannerWidget,
                Flexible(
                  child: SingleChildScrollView(
                    padding: contentPadding,
                    child: centerContent
                        ? Center(
                            child: DefaultTextStyle.merge(
                              textAlign: TextAlign.center,
                              child: child,
                            ),
                          )
                        : child,
                  ),
                ),
                actionsWidget,
              ],
            ),
          ),
        ),
      ),
    );
  }
}
