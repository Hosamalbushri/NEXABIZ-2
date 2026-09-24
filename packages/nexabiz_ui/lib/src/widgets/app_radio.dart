import 'package:flutter/widgets.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shadcn;

import '../theme/tokens/app_dimensions.dart';
import '../theme/tokens/app_spacing.dart';

/// Canonical radio button primitive for NexaBiz UI built on `shadcn_flutter`.
///
/// Designed to be used as an item within [AppRadioGroup] or [shadcn.ControlledRadioGroup].
class AppRadio<T> extends StatelessWidget {
  /// Value represented by this radio option.
  final T value;

  /// Optional text label displayed next to the radio circle.
  final String? label;

  /// Optional trailing widget. If [label] is also provided, [trailing] takes precedence.
  final Widget? trailing;

  /// Optional leading widget placed before the radio circle.
  final Widget? leading;

  /// Whether this specific item is enabled. Defaults to true.
  final bool enabled;

  const AppRadio({
    super.key,
    required this.value,
    this.label,
    this.trailing,
    this.leading,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveTrailing = trailing ?? (label != null ? Text(label!) : null);

    return Semantics(
      inMutuallyExclusiveGroup: true,
      label: label,
      enabled: enabled,
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          minHeight: AppDimensions.minTouchTarget,
        ),
        child: shadcn.RadioItem<T>(
          value: value,
          leading: leading,
          trailing: effectiveTrailing,
          enabled: enabled,
        ),
      ),
    );
  }
}

/// Canonical radio group container for NexaBiz UI built on `shadcn_flutter`.
///
/// Manages mutual exclusion and provides accessible keyboard and touch navigation.
class AppRadioGroup<T> extends StatelessWidget {
  /// The currently selected value.
  final T? value;

  /// Callback invoked when selection changes.
  final ValueChanged<T?>? onChanged;

  /// Orientation of radio items when [children] are provided.
  final Axis orientation;

  /// Custom child containing radio options.
  final Widget? child;

  /// List of radio items (typically [AppRadio]).
  final List<Widget>? children;

  /// Spacing between radio options. Defaults to [AppSpacing.sm].
  final double gap;

  /// Whether the radio group is interactive.
  final bool enabled;

  const AppRadioGroup({
    super.key,
    required this.value,
    required this.onChanged,
    this.orientation = Axis.vertical,
    this.enabled = true,
    this.gap = AppSpacing.sm,
    this.child,
    this.children,
  }) : assert(
         child != null || children != null,
         'Either child or children must be provided to AppRadioGroup',
       );

  @override
  Widget build(BuildContext context) {
    Widget content;
    if (child != null) {
      content = child!;
    } else {
      if (orientation == Axis.vertical) {
        content = Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: _buildSeparated(children!, SizedBox(height: gap)),
        );
      } else {
        content = Wrap(spacing: gap, runSpacing: gap, children: children!);
      }
    }

    return shadcn.ControlledRadioGroup<T>(
      initialValue: value,
      onChanged: enabled ? onChanged : null,
      enabled: enabled,
      child: content,
    );
  }

  List<Widget> _buildSeparated(List<Widget> list, Widget separator) {
    if (list.isEmpty) return const [];
    final result = <Widget>[];
    for (int i = 0; i < list.length; i++) {
      result.add(list[i]);
      if (i != list.length - 1) {
        result.add(separator);
      }
    }
    return result;
  }
}
