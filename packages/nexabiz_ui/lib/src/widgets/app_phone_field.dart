import 'package:flutter/widgets.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shadcn;

import '../localization/nexabiz_ui_localizations.dart';
import 'app_field_shell.dart';

/// Canonical phone input field primitive for NexaBiz ERP.
///
/// Wraps `shadcn_flutter` [shadcn.PhoneInput] in a standardized [AppFieldShell]
/// layout (`label`, `required`, `description`, `errorText`, `helperText`).
class AppPhoneField extends StatelessWidget {
  const AppPhoneField({
    super.key,
    this.initialCountry,
    this.initialValue,
    this.value,
    this.onChanged,
    this.controller,
    this.countries,
    this.onlyNumber = true,
    this.label,
    this.description,
    this.searchPlaceholder,
    this.required = false,
    this.enabled = true,
    this.readOnly = false,
    this.errorText,
    this.helperText,
    this.density = AppFieldDensity.standard,
  });

  final shadcn.Country? initialCountry;
  final shadcn.PhoneNumber? initialValue;
  final shadcn.PhoneNumber? value;
  final ValueChanged<shadcn.PhoneNumber?>? onChanged;
  final TextEditingController? controller;
  final List<shadcn.Country>? countries;
  final bool onlyNumber;
  final String? label;
  final String? description;
  final String? searchPlaceholder;
  final bool required;
  final bool enabled;
  final bool readOnly;
  final String? errorText;
  final String? helperText;
  final AppFieldDensity density;

  @override
  Widget build(BuildContext context) {
    final loc = NexaBizUiLocalizations.of(context);
    final isInteractive = enabled && !readOnly;

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
      child: shadcn.PhoneInput(
        initialCountry: initialCountry,
        initialValue: value ?? initialValue,
        onChanged: isInteractive ? onChanged : null,
        controller: controller,
        countries: countries,
        onlyNumber: onlyNumber,
        searchPlaceholder: Text(searchPlaceholder ?? loc.searchCountry),
      ),
    );
  }
}
