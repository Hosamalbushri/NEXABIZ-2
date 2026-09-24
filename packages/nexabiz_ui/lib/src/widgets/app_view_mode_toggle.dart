import 'package:flutter/widgets.dart';

import 'app_exclusive_toggle_group.dart';

/// Descriptor for an option in an [AppViewModeToggle].
class AppViewModeOption<T> {
  const AppViewModeOption({
    required this.value,
    required this.icon,
    required this.tooltip,
  });

  final T value;
  final IconData icon;
  final String tooltip;
}

/// Generic segmented view mode toggle widget built natively on `shadcn_flutter`.
///
/// Allows switching between collection view modes (e.g. List, Grid) using
/// canonical design-system toggles via [AppExclusiveToggleGroup].
class AppViewModeToggle<T> extends StatelessWidget {
  const AppViewModeToggle({
    super.key,
    required this.options,
    required this.selected,
    required this.onChanged,
  });

  final List<AppViewModeOption<T>> options;
  final T selected;
  final ValueChanged<T> onChanged;

  @override
  Widget build(BuildContext context) {
    return AppExclusiveToggleGroup<T>(
      value: selected,
      onChanged: (val) {
        if (val != null) {
          onChanged(val);
        }
      },
      options: options.map((option) {
        return ToggleOption<T>(
          value: option.value,
          tooltip: option.tooltip,
          child: Icon(option.icon, size: 18),
        );
      }).toList(),
    );
  }
}
