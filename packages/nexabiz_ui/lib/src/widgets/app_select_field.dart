import 'package:flutter/widgets.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shadcn;

import '../localization/nexabiz_ui_localizations.dart';
import 'app_field_shell.dart';
import 'app_select_option.dart';
import 'app_selection_foundation.dart';

export 'app_select_option.dart';

/// Canonical single selection dropdown field for NexaBiz ERP.
///
/// Built natively on `shadcn_flutter` [shadcn.Select] and standardized [AppFieldShell].
/// Adheres strictly to design tokens, keyboard navigation, and directional accessibility.
class AppSelectField<T> extends StatelessWidget {
  const AppSelectField({
    super.key,
    required this.items,
    required this.onChanged,
    this.value,
    this.label,
    this.description,
    this.hint,
    this.placeholder,
    this.required = false,
    this.enabled = true,
    this.readOnly = false,
    this.errorText,
    this.helperText,
    this.prefixIcon,
    this.density = AppFieldDensity.standard,
    this.canUnselect = false,
    this.itemBuilder,
  });

  /// The collection of selectable options.
  final List<AppSelectOption<T>> items;

  /// Callback fired when the selection changes (or is cleared to null).
  final ValueChanged<T?>? onChanged;

  /// Currently selected value of type [T].
  final T? value;

  /// Primary label text displayed above the field.
  final String? label;

  /// Secondary descriptive text displayed below the label.
  final String? description;

  /// Default hint text when no item is selected.
  final String? hint;

  /// Custom placeholder widget shown when no item is selected.
  final Widget? placeholder;

  /// Whether the field is mandatory (displays red `*`).
  final bool required;

  /// Whether the field accepts user interaction.
  final bool enabled;

  /// Whether the field is in read-only presentation.
  final bool readOnly;

  /// Validation error message string.
  final String? errorText;

  /// Helper message string displayed below the field.
  final String? helperText;

  /// Optional prefix icon data or widget.
  final dynamic prefixIcon;

  /// Standardized ERP field density.
  final AppFieldDensity density;

  /// Whether the selected item can be deselected by tapping it again.
  final bool canUnselect;

  /// Optional custom builder for items.
  final Widget Function(BuildContext context, AppSelectOption<T> option)?
  itemBuilder;

  @override
  Widget build(BuildContext context) {
    final theme = shadcn.Theme.of(context);
    final isInteractive = enabled && !readOnly;
    final hasError = errorText != null && errorText!.isNotEmpty;

    final effectiveHint =
        hint ?? NexaBizUiLocalizations.of(context).selectOption;

    final prefixWidget = prefixIcon is IconData
        ? Icon(
            prefixIcon as IconData,
            size: 18,
            color: enabled
                ? theme.colorScheme.primary
                : theme.colorScheme.mutedForeground,
          )
        : prefixIcon as Widget?;

    final childSelect = shadcn.Select<T>(
      value: value,
      enabled: isInteractive,
      canUnselect: canUnselect,
      onChanged: isInteractive ? (val) => onChanged?.call(val) : null,
      placeholder:
          placeholder ??
          Text(
            effectiveHint,
            style: theme.typography.small.copyWith(
              color: theme.colorScheme.mutedForeground,
            ),
          ),
      itemBuilder: (context, itemValue) {
        for (final element in items) {
          if (element.value == itemValue) {
            if (itemBuilder != null) {
              return itemBuilder!(context, element);
            }
            return AppSelectOptionTile<T>(option: element, isSelected: true);
          }
        }
        return Text(itemValue.toString());
      },
      popup: shadcn.SelectPopup<T>.builder(
        builder: (context, searchQuery) {
          return shadcn.SelectItemList(
            children: items.map((item) {
              return shadcn.SelectItemButton<T>(
                value: item.value,
                enabled: item.enabled,
                child: itemBuilder != null
                    ? itemBuilder!(context, item)
                    : AppSelectOptionTile<T>(
                        option: item,
                        isSelected: item.value == value,
                        showCheckmark: true,
                      ),
              );
            }).toList(),
          );
        },
      ).asBuilder,
    );

    final styledChild = wrapSelectWithErrorTheme(
      context: context,
      hasError: hasError,
      child: childSelect,
    );

    return AppFieldShell(
      label: label,
      description: description,
      required: required,
      errorText: errorText,
      helperText: helperText,
      density: density,
      enabled: enabled,
      readOnly: readOnly,
      prefix: prefixWidget,
      borderless: true,
      child: styledChild,
    );
  }
}
