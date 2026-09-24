import 'package:flutter/widgets.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shadcn;

import '../localization/nexabiz_ui_localizations.dart';
import '../theme/tokens/tokens.dart';
import 'app_field_shell.dart';
import 'app_select_option.dart';
import 'app_selection_foundation.dart';

/// Generic searchable select dropdown field for NexaBiz ERP.
///
/// Wraps `shadcn_flutter` [shadcn.Select] with a searchable popup dialog,
/// standardized [AppSelectionSearchMatcher] client-side filtering,
/// and canonical [AppFieldShell] presentation layout.
class AppSearchableSelect<T> extends StatelessWidget {
  const AppSearchableSelect({
    super.key,
    required this.items,
    required this.itemBuilder,
    this.value,
    this.onChanged,
    this.searchValueBuilder,
    this.valueBuilder,
    this.label,
    this.description,
    this.hint,
    this.placeholder,
    this.searchPlaceholder,
    this.required = false,
    this.enabled = true,
    this.readOnly = false,
    this.errorText,
    this.helperText,
    this.emptyBuilder,
    this.density = AppFieldDensity.standard,
  });

  /// The list of items of type [T].
  final List<T> items;

  /// Builds each selectable item inside the popup menu.
  final Widget Function(BuildContext context, T item) itemBuilder;

  /// The currently selected item.
  final T? value;

  /// Callback fired when the selection changes.
  final ValueChanged<T?>? onChanged;

  /// String extractor for searching items. Defaults to `item.toString()`.
  final String Function(T item)? searchValueBuilder;

  /// Optional custom builder for the selected value trigger display.
  final Widget Function(BuildContext context, T item)? valueBuilder;

  /// Primary label text.
  final String? label;

  /// Secondary descriptive text.
  final String? description;

  /// Field hint string.
  final String? hint;

  /// Custom placeholder widget.
  final Widget? placeholder;

  /// Search input placeholder string.
  final String? searchPlaceholder;

  /// Whether the field is mandatory.
  final bool required;

  /// Whether user interaction is enabled.
  final bool enabled;

  /// Whether the field is read-only.
  final bool readOnly;

  /// Validation error message string.
  final String? errorText;

  /// Helper message string displayed below the field.
  final String? helperText;

  /// Custom empty search results builder.
  final Widget Function(BuildContext context)? emptyBuilder;

  /// Standardized ERP field density.
  final AppFieldDensity density;

  String _getSearchText(T item) {
    if (searchValueBuilder != null) {
      return searchValueBuilder!(item);
    }
    if (item is AppSelectOption) {
      return item.searchKey ?? item.label;
    }
    return item.toString();
  }

  @override
  Widget build(BuildContext context) {
    final theme = shadcn.Theme.of(context);
    final loc = NexaBizUiLocalizations.of(context);
    final isInteractive = enabled && !readOnly;
    final hasError = errorText != null && errorText!.isNotEmpty;

    final effectiveHint = hint ?? loc.select;
    final effectiveSearchPlaceholder =
        searchPlaceholder ?? loc.searchPlaceholder;

    final childSelect = shadcn.Select<T>(
      value: value,
      onChanged: isInteractive ? onChanged : null,
      enabled: isInteractive,
      placeholder:
          placeholder ??
          Text(
            effectiveHint,
            style: theme.typography.small.copyWith(
              color: theme.colorScheme.mutedForeground,
            ),
          ),
      itemBuilder: (context, itemValue) {
        if (valueBuilder != null) {
          return valueBuilder!(context, itemValue);
        }
        return itemBuilder(context, itemValue);
      },
      popup: shadcn.SelectPopup<T>.builder(
        enableSearch: true,
        searchPlaceholder: Text(effectiveSearchPlaceholder),
        emptyBuilder: emptyBuilder != null
            ? (context) => emptyBuilder!(context)
            : (context) => Center(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: Text(
                    loc.noResults,
                    style: theme.typography.small.copyWith(
                      color: theme.colorScheme.mutedForeground,
                    ),
                  ),
                ),
              ),
        builder: (context, searchQuery) {
          final query = searchQuery ?? '';
          final filteredItems = items.where((item) {
            if (query.isEmpty) return true;
            final searchText = _getSearchText(item);
            return AppSelectionSearchMatcher.matches(
              query: query,
              target: searchText,
            );
          }).toList();

          return shadcn.SelectItemList(
            children: filteredItems.map((item) {
              return shadcn.SelectItemButton<T>(
                value: item,
                child: itemBuilder(context, item),
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
