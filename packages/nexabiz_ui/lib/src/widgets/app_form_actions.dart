import 'package:flutter/material.dart';

import '../localization/nexabiz_ui_localizations.dart';
import '../theme/tokens/tokens.dart';
import 'app_bottom_actions.dart';
import 'app_button.dart';

/// Canonical form actions bar composite for NexaBiz ERP forms.
///
/// Features primary submit button, optional secondary cancel button,
/// loading state, and canonical sticky bottom bar layout.
class AppFormActions extends StatelessWidget {
  const AppFormActions({
    super.key,
    required this.onSubmit,
    this.submitLabel,
    this.onCancel,
    this.cancelLabel,
    this.isLoading = false,
    this.isSticky = true,
    this.submitIcon = Icons.check_rounded,
    this.cancelIcon = Icons.close_rounded,
    this.extraActions,
  });

  final VoidCallback? onSubmit;
  final String? submitLabel;
  final VoidCallback? onCancel;
  final String? cancelLabel;
  final bool isLoading;
  final bool isSticky;
  final IconData? submitIcon;
  final IconData? cancelIcon;
  final List<Widget>? extraActions;

  @override
  Widget build(BuildContext context) {
    final loc = NexaBizUiLocalizations.of(context);
    final effectiveSubmitLabel = submitLabel ?? loc.save;
    final effectiveCancelLabel = cancelLabel ?? loc.cancel;

    final primaryBtn = AppButton(
      label: effectiveSubmitLabel,
      onPressed: isLoading ? null : onSubmit,
      variant: AppButtonVariant.filled,
      icon: submitIcon,
      isLoading: isLoading,
      expand: true,
    );

    final secondaryBtn = onCancel != null
        ? AppButton(
            label: effectiveCancelLabel,
            onPressed: isLoading ? null : onCancel,
            variant: AppButtonVariant.outlined,
            icon: cancelIcon,
            expand: true,
          )
        : null;

    return AppBottomActions(
      primaryAction: primaryBtn,
      secondaryAction: secondaryBtn,
      extraActions: extraActions,
      padding: isSticky
          ? const EdgeInsetsDirectional.fromSTEB(
              AppSpacing.md,
              AppSpacing.sm,
              AppSpacing.md,
              AppSpacing.sm,
            )
          : EdgeInsets.zero,
      showBorder: isSticky,
    );
  }
}
