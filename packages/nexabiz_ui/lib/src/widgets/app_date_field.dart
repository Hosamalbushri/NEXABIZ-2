import 'package:flutter/widgets.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shadcn;
import '../localization/nexabiz_ui_localizations.dart';
import 'app_field_shell.dart';

/// Canonical date selection field primitive for NexaBiz ERP.
///
/// Backed natively by `shadcn_flutter` [shadcn.DatePicker], providing
/// dialog/popover presentation, date range state filtering (`firstDate`/`lastDate`),
/// full type safety, and [AppFieldShell] layout rules (`label`, `description`, `errorText`, `helperText`).
class AppDateField extends StatelessWidget {
  const AppDateField({
    super.key,
    required this.value,
    required this.onChanged,
    this.label,
    this.description,
    this.hint,
    this.placeholder,
    this.required = false,
    this.enabled = true,
    this.readOnly = false,
    this.firstDate,
    this.lastDate,
    this.dateFormat = 'yyyy-MM-dd',
    this.errorText,
    this.helperText,
    this.density = AppFieldDensity.standard,
    this.mode,
    this.dialogTitle,
    this.stateBuilder,
  });

  /// Currently selected [DateTime] value (`null` if empty).
  final DateTime? value;

  /// Callback fired when date is selected or cleared.
  final ValueChanged<DateTime?>? onChanged;

  /// Label string displayed above the field.
  final String? label;

  /// Secondary description displayed below the label.
  final String? description;

  /// Default hint text when no date is selected.
  final String? hint;

  /// Custom placeholder widget when no date is selected.
  final Widget? placeholder;

  /// Whether the field is mandatory (displays red `*`).
  final bool required;

  /// Whether the field accepts interaction.
  final bool enabled;

  /// Whether the field is read-only.
  final bool readOnly;

  /// Minimum allowable date.
  final DateTime? firstDate;

  /// Maximum allowable date.
  final DateTime? lastDate;

  /// Custom date format pattern (default `'yyyy-MM-dd'`).
  final String dateFormat;

  /// Validation error message string.
  final String? errorText;

  /// Helper text displayed below field.
  final String? helperText;

  /// Standardized ERP field density (compact, standard, large).
  final AppFieldDensity density;

  /// Presentation mode for the picker (`PromptMode.dialog` or `PromptMode.popover`).
  final shadcn.PromptMode? mode;

  /// Custom title for the modal dialog mode.
  final Widget? dialogTitle;

  /// Custom date state builder callback for fine-grained cell states.
  final shadcn.DateStateBuilder? stateBuilder;

  shadcn.DateStateBuilder? get _effectiveStateBuilder {
    if (stateBuilder != null) return stateBuilder;
    if (firstDate == null && lastDate == null) return null;

    return (date) {
      if (firstDate != null && date.isBefore(firstDate!)) {
        return shadcn.DateState.disabled;
      }
      if (lastDate != null && date.isAfter(lastDate!)) {
        return shadcn.DateState.disabled;
      }
      return shadcn.DateState.enabled;
    };
  }

  @override
  Widget build(BuildContext context) {
    final isInteractive = enabled && !readOnly;
    final effectiveHint = hint ?? NexaBizUiLocalizations.of(context).selectDate;

    return AppFieldShell(
      label: label,
      required: required,
      description: description,
      errorText: errorText,
      helperText: helperText,
      density: density,
      enabled: enabled,
      readOnly: readOnly,
      borderless: true,
      child: shadcn.DatePicker(
        value: value,
        onChanged: isInteractive ? onChanged : null,
        placeholder: placeholder ?? Text(effectiveHint),
        mode: mode,
        dialogTitle: dialogTitle ?? (label != null ? Text(label!) : null),
        stateBuilder: _effectiveStateBuilder,
        enabled: isInteractive,
      ),
    );
  }
}
