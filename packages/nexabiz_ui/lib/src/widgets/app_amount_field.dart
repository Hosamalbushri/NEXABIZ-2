import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shadcn;

import '../theme/tokens/tokens.dart';
import 'app_field_shell.dart';

/// Specialized financial input widget primitive for NexaBiz ERP.
///
/// Designed specifically for monetary amounts, unit prices, quantities, percentages,
/// debit/credit entries, and currency values.
/// Preserves strict LTR digit formatting within RTL (Arabic) contexts and provides
/// appropriate numeric keyboard inputs without adding business logic.
class AppAmountField extends StatelessWidget {
  const AppAmountField({
    super.key,
    this.controller,
    this.focusNode,
    this.label,
    this.hint = '0.00',
    this.required = false,
    this.errorText,
    this.helperText,
    this.currencySymbol = 'SAR',
    this.showCurrency = true,
    this.isDebit,
    this.isCredit,
    this.enabled = true,
    this.readOnly = false,
    this.onChanged,
    this.onSubmitted,
    this.density = AppFieldDensity.standard,
  });

  final TextEditingController? controller;
  final FocusNode? focusNode;
  final String? label;
  final String? hint;
  final bool required;
  final String? errorText;
  final String? helperText;
  final String currencySymbol;
  final bool showCurrency;
  final bool? isDebit;
  final bool? isCredit;
  final bool enabled;
  final bool readOnly;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final AppFieldDensity density;

  @override
  Widget build(BuildContext context) {
    final theme = shadcn.Theme.of(context);
    final colorScheme = theme.colorScheme;

    final hintTextStyle = theme.typography.small.copyWith(
      color: colorScheme.mutedForeground,
      fontFamily: 'Roboto',
    );

    // Tone indicator for Debit / Credit when specified
    Widget? toneBadge;
    if (isDebit == true) {
      toneBadge = Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        decoration: BoxDecoration(
          color: colorScheme.primary.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(
          'DR',
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.bold,
            color: colorScheme.primary,
          ),
        ),
      );
    } else if (isCredit == true) {
      toneBadge = Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        decoration: BoxDecoration(
          color: colorScheme.destructive.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(
          'CR',
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.bold,
            color: colorScheme.destructive,
          ),
        ),
      );
    }

    final currencyWidget = showCurrency
        ? Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
            child: Text(
              currencySymbol,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: enabled
                    ? colorScheme.mutedForeground
                    : colorScheme.mutedForeground.withValues(alpha: 0.5),
              ),
            ),
          )
        : null;

    final suffixWidget = toneBadge != null
        ? Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              ?currencyWidget,
              const SizedBox(width: 4),
              toneBadge,
            ],
          )
        : currencyWidget;

    final childInput = Directionality(
      textDirection: TextDirection.ltr,
      child: shadcn.TextField(
        controller: controller,
        focusNode: focusNode,
        enabled: enabled,
        readOnly: readOnly,
        keyboardType: const TextInputType.numberWithOptions(
          decimal: true,
          signed: true,
        ),
        inputFormatters: [
          FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
        ],
        onChanged: onChanged != null
            ? (value) {
                final binding = WidgetsBinding.instance;
                if (binding.buildOwner?.debugBuilding ?? false) {
                  binding.addPostFrameCallback((_) => onChanged!(value));
                } else {
                  onChanged!(value);
                }
              }
            : null,
        onSubmitted: onSubmitted != null
            ? (value) {
                final binding = WidgetsBinding.instance;
                if (binding.buildOwner?.debugBuilding ?? false) {
                  binding.addPostFrameCallback((_) => onSubmitted!(value));
                } else {
                  onSubmitted!(value);
                }
              }
            : null,
        placeholder: hint != null ? Text(hint!, style: hintTextStyle) : null,
        padding: EdgeInsets.zero,
        border: const Border(),
        features: const [],
      ),
    );

    return AppFieldShell(
      label: label,
      required: required,
      errorText: errorText,
      helperText: helperText,
      density: density,
      enabled: enabled,
      readOnly: readOnly,
      suffix: suffixWidget,
      child: childInput,
    );
  }
}
