import 'package:flutter/widgets.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shadcn;

import 'app_field_shell.dart';

/// Canonical multiline text field component for NexaBiz ERP.
///
/// Wraps `shadcn_flutter` [shadcn.TextArea] with [AppFieldShell] layout contracts:
/// `label`, `required` asterisk, `description`, resizable height handle (`expandableHeight`),
/// and error/helper footers.
class AppMultilineField extends StatelessWidget {
  const AppMultilineField({
    super.key,
    this.controller,
    this.initialValue,
    this.onChanged,
    this.label,
    this.description,
    this.hint,
    this.placeholder,
    this.required = false,
    this.enabled = true,
    this.readOnly = false,
    this.expandableHeight = true,
    this.initialHeight = 120.0,
    this.minHeight = 80.0,
    this.maxHeight = 400.0,
    this.maxLength,
    this.errorText,
    this.helperText,
  });

  final TextEditingController? controller;
  final String? initialValue;
  final ValueChanged<String>? onChanged;
  final String? label;
  final String? description;
  final String? hint;
  final Widget? placeholder;
  final bool required;
  final bool enabled;
  final bool readOnly;
  final bool expandableHeight;
  final double initialHeight;
  final double minHeight;
  final double maxHeight;
  final int? maxLength;
  final String? errorText;
  final String? helperText;

  @override
  Widget build(BuildContext context) {
    return AppFieldShell(
      label: label,
      required: required,
      description: description,
      errorText: errorText,
      helperText: helperText,
      enabled: enabled,
      readOnly: readOnly,
      borderless: true,
      child: shadcn.TextArea(
        controller: controller,
        initialValue: initialValue,
        onChanged: onChanged,
        enabled: enabled,
        readOnly: readOnly,
        expandableHeight: expandableHeight,
        initialHeight: initialHeight,
        minHeight: minHeight,
        maxHeight: maxHeight,
        maxLength: maxLength,
        placeholder: placeholder ?? (hint != null ? Text(hint!) : null),
      ),
    );
  }
}
