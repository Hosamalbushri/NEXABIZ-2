import 'package:flutter/material.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shadcn;

import '../theme/tokens/app_dimensions.dart';

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

    final childWidget = Text(
      label,
      textAlign: TextAlign.center,
      softWrap: true,
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

    final double minHeight = isCompact
        ? AppDimensions.buttonHeightCompact
        : AppDimensions.desktopButtonHeight;

    final constrainedButton = ConstrainedBox(
      constraints: BoxConstraints(minHeight: minHeight),
      child: button,
    );

    final semanticButton = Semantics(
      button: true,
      label: label,
      child: constrainedButton,
    );

    if (expand) {
      return SizedBox(width: double.infinity, child: semanticButton);
    }

    return semanticButton;
  }
}
