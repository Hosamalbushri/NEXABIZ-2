import 'package:flutter/widgets.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shadcn;

import '../theme/tokens/tokens.dart';
import 'app_field_shell.dart';

/// Canonical slider form field component for NexaBiz ERP.
///
/// Wraps `shadcn_flutter` [shadcn.Slider] with [AppFieldShell] presentation layout (`label`, `required`,
/// `description`, formatted value badge, range labels, and error/helper footers).
class AppSliderField extends StatelessWidget {
  const AppSliderField({
    super.key,
    required this.value,
    this.onChanged,
    this.onChangeStart,
    this.onChangeEnd,
    this.min = 0.0,
    this.max = 100.0,
    this.divisions,
    this.label,
    this.description,
    this.valueFormatter,
    this.required = false,
    this.enabled = true,
    this.showMinMaxLabels = true,
    this.errorText,
    this.helperText,
  });

  final shadcn.SliderValue value;
  final ValueChanged<shadcn.SliderValue>? onChanged;
  final ValueChanged<shadcn.SliderValue>? onChangeStart;
  final ValueChanged<shadcn.SliderValue>? onChangeEnd;
  final double min;
  final double max;
  final int? divisions;
  final String? label;
  final String? description;
  final String Function(shadcn.SliderValue value)? valueFormatter;
  final bool required;
  final bool enabled;
  final bool showMinMaxLabels;
  final String? errorText;
  final String? helperText;

  String _defaultFormat(shadcn.SliderValue val) {
    if (val.isRanged) {
      return '${val.start.toStringAsFixed(0)} - ${val.end.toStringAsFixed(0)}';
    }
    return val.value.toStringAsFixed(0);
  }

  @override
  Widget build(BuildContext context) {
    final theme = shadcn.Theme.of(context);
    final isInteractive = enabled && onChanged != null;
    final formattedValue = valueFormatter != null
        ? valueFormatter!(value)
        : _defaultFormat(value);

    return AppFieldShell(
      label: label,
      required: required,
      description: description,
      errorText: errorText,
      helperText: helperText,
      enabled: enabled,
      borderless: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.xs,
                  vertical: 2,
                ),
                decoration: BoxDecoration(
                  color: theme.colorScheme.secondary,
                  borderRadius: BorderRadius.circular(AppRadii.smOf(context)),
                ),
                child: Text(
                  formattedValue,
                  style: theme.typography.small.copyWith(
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.secondaryForeground,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xxs),
          shadcn.Slider(
            value: value,
            onChanged: isInteractive ? onChanged : null,
            onChangeStart: onChangeStart,
            onChangeEnd: onChangeEnd,
            min: min,
            max: max,
            divisions: divisions,
            enabled: isInteractive,
          ),
          if (showMinMaxLabels) ...[
            const SizedBox(height: AppSpacing.xxs),
            Directionality(
              textDirection: TextDirection.ltr,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    min.toStringAsFixed(0),
                    style: theme.typography.small.copyWith(
                      color: theme.colorScheme.mutedForeground,
                      fontSize: 11,
                    ),
                  ),
                  Text(
                    max.toStringAsFixed(0),
                    style: theme.typography.small.copyWith(
                      color: theme.colorScheme.mutedForeground,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
