import 'package:flutter/material.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shadcn;

import '../theme/app_dimensions.dart';

enum AppButtonVariant { filled, elevated, outlined, text, tonal, destructive }

/// Modernized design-system button built natively on top of [shadcn_flutter] button primitives.
class AppButton extends StatelessWidget {
  const AppButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.variant = AppButtonVariant.filled,
    this.icon,
    this.trailingIcon = false,
    this.isLoading = false,
    this.expand = false,
    this.isCompact = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final AppButtonVariant variant;
  final IconData? icon;
  final bool trailingIcon;
  final bool isLoading;
  final bool expand;
  final bool isCompact;

  @override
  Widget build(BuildContext context) {
    final enabled = onPressed != null && !isLoading;

    final leadingWidget = isLoading
        ? const SizedBox(
            width: 16,
            height: 16,
            child: shadcn.CircularProgressIndicator(strokeWidth: 2),
          )
        : (icon != null && !trailingIcon ? Icon(icon, size: 18) : null);

    final trailingWidget = !isLoading && icon != null && trailingIcon
        ? Icon(icon, size: 18)
        : null;

    final childWidget = FittedBox(
      fit: BoxFit.scaleDown,
      alignment: Alignment.center,
      child: Text(
        label,
        textAlign: TextAlign.center,
        maxLines: 1,
        softWrap: false,
        overflow: TextOverflow.ellipsis,
      ),
    );

    final VoidCallback? handler = enabled ? onPressed : null;
    final buttonDensity = isCompact
        ? shadcn.ButtonDensity.compact
        : shadcn.ButtonDensity.normal;

    final Widget button = switch (variant) {
      AppButtonVariant.filled => shadcn.PrimaryButton(
        onPressed: handler,
        density: buttonDensity,
        alignment: Alignment.center,
        leading: leadingWidget,
        trailing: trailingWidget,
        child: childWidget,
      ),
      AppButtonVariant.elevated ||
      AppButtonVariant.tonal => shadcn.SecondaryButton(
        onPressed: handler,
        density: buttonDensity,
        alignment: Alignment.center,
        leading: leadingWidget,
        trailing: trailingWidget,
        child: childWidget,
      ),
      AppButtonVariant.outlined => shadcn.OutlineButton(
        onPressed: handler,
        density: buttonDensity,
        alignment: Alignment.center,
        leading: leadingWidget,
        trailing: trailingWidget,
        child: childWidget,
      ),
      AppButtonVariant.text => shadcn.GhostButton(
        onPressed: handler,
        density: buttonDensity,
        alignment: Alignment.center,
        leading: leadingWidget,
        trailing: trailingWidget,
        child: childWidget,
      ),
      AppButtonVariant.destructive => shadcn.DestructiveButton(
        onPressed: handler,
        density: buttonDensity,
        alignment: Alignment.center,
        leading: leadingWidget,
        trailing: trailingWidget,
        child: childWidget,
      ),
    };

    final double height = isCompact
        ? AppDimensions.buttonHeightCompact
        : AppDimensions.buttonHeight;

    final constrainedButton = ConstrainedBox(
      constraints: BoxConstraints(minHeight: isCompact ? 36.0 : 44.0),
      child: height > 0 ? SizedBox(height: height, child: button) : button,
    );

    if (expand) {
      return SizedBox(width: double.infinity, child: constrainedButton);
    }

    return constrainedButton;
  }
}
