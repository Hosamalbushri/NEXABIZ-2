import 'package:flutter/widgets.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shadcn;

import '../localization/nexabiz_ui_localizations.dart';
import 'app_field_shell.dart';
import 'app_select_option.dart';
import 'app_selection_foundation.dart';

/// Canonical multi-select field primitive for NexaBiz ERP.
///
/// Wraps `shadcn_flutter` [shadcn.ControlledMultiSelect] in a type-safe generic (`T`)
/// field wrapper that adheres to [AppFieldShell] form field layout rules (`label`,
/// `required`, `description`, `errorText`, `helperText`, `density`).
class AppMultiSelectField<T> extends StatelessWidget {
  const AppMultiSelectField({
    super.key,
    required this.items,
    required this.itemLabelBuilder,
    this.value,
    this.onChanged,
    this.label,
    this.description,
    this.hint,
    this.placeholder,
    this.required = false,
    this.enabled = true,
    this.readOnly = false,
    this.errorText,
    this.helperText,
    this.density = AppFieldDensity.standard,
    this.itemBuilder,
  });

  /// The collection of selectable items of type [T].
  final List<T> items;

  /// Function mapping each item [T] to its display string label.
  final String Function(T item) itemLabelBuilder;

  /// Currently selected collection of items [T].
  final Iterable<T>? value;

  /// Callback fired when item selection is updated.
  final ValueChanged<Iterable<T>?>? onChanged;

  /// Field label text displayed above the component.
  final String? label;

  /// Secondary description displayed below the label.
  final String? description;

  /// Default hint text when no items are selected.
  final String? hint;

  /// Custom placeholder widget.
  final Widget? placeholder;

  /// Whether the field is mandatory (displays red `*`).
  final bool required;

  /// Whether the field accepts user interaction.
  final bool enabled;

  /// Whether the field is read-only.
  final bool readOnly;

  /// Validation error message string.
  final String? errorText;

  /// Helper message string displayed below the field.
  final String? helperText;

  /// Standardized ERP field density.
  final AppFieldDensity density;

  /// Optional custom builder for items inside the popup menu.
  final Widget Function(BuildContext context, T item, bool isSelected)?
  itemBuilder;

  @override
  Widget build(BuildContext context) {
    final isInteractive = enabled && !readOnly;
    final hasError = errorText != null && errorText!.isNotEmpty;
    final effectiveHint =
        hint ?? NexaBizUiLocalizations.of(context).selectItems;

    final childSelect = shadcn.ControlledMultiSelect<T>(
      initialValue: value,
      onChanged: isInteractive ? onChanged : null,
      enabled: isInteractive,
      placeholder: placeholder ?? Text(effectiveHint),
      popup: (context) {
        return shadcn.SelectGroup(
          children: items.map((item) {
            final displayLabel = itemLabelBuilder(item);
            return shadcn.SelectItemButton<T>(
              value: item,
              child: Builder(
                builder: (ctx) {
                  final popupHandle =
                      shadcn.Data.maybeOf<shadcn.SelectPopupHandle>(ctx);
                  final selected = popupHandle?.isSelected(item) ?? false;
                  if (itemBuilder != null) {
                    return itemBuilder!(ctx, item, selected);
                  }
                  return AppSelectOptionTile<T>(
                    option: item is AppSelectOption<T>
                        ? item
                        : AppSelectOption<T>(value: item, label: displayLabel),
                    isSelected: selected,
                    showCheckmark: true,
                  );
                },
              ),
            );
          }).toList(),
        );
      },
      itemBuilder: (context, itemValue) {
        return Text(itemLabelBuilder(itemValue));
      },
    );

    final styledChild = wrapSelectWithErrorTheme(
      context: context,
      hasError: hasError,
      child: childSelect,
    );

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
      child: styledChild,
    );
  }
}
