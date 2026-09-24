import 'package:flutter/widgets.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shadcn;

/// Canonical separator primitive for NexaBiz UI built on `shadcn_flutter`.
///
/// Supports horizontal and vertical orientations and automatically resolves
/// default border colors from the active shadcn theme.
class AppSeparator extends StatelessWidget {
  /// Orientation of the separator line (horizontal or vertical).
  final Axis orientation;

  /// Thickness of the line in logical pixels. Defaults to 1.0.
  final double thickness;

  /// Optional length of the line along its main axis.
  /// If null in horizontal orientation, fills available width (`double.infinity`).
  final double? length;

  /// Custom line color. Defaults to `shadcn.Theme.of(context).colorScheme.border`.
  final Color? color;

  /// Optional padding/margin around the separator.
  final EdgeInsetsGeometry? margin;

  const AppSeparator({
    super.key,
    this.orientation = Axis.horizontal,
    this.thickness = 1.0,
    this.length,
    this.color,
    this.margin,
  });

  /// Creates a vertical separator line.
  const AppSeparator.vertical({
    super.key,
    this.thickness = 1.0,
    this.length,
    this.color,
    this.margin,
  }) : orientation = Axis.vertical;

  @override
  Widget build(BuildContext context) {
    final theme = shadcn.Theme.of(context);
    final effectiveColor = color ?? theme.colorScheme.border;

    Widget separator;
    if (orientation == Axis.horizontal) {
      separator = LayoutBuilder(
        builder: (context, constraints) {
          // A fill separator has no meaningful natural length on an unbounded
          // horizontal axis. Collapse safely unless the caller supplies one.
          final resolvedLength =
              length ??
              (constraints.hasBoundedWidth ? constraints.maxWidth : 0);
          return SizedBox(
            width: resolvedLength,
            height: thickness,
            child: ColoredBox(color: effectiveColor),
          );
        },
      );
    } else {
      separator = LayoutBuilder(
        builder: (context, constraints) {
          final resolvedLength =
              length ??
              (constraints.hasBoundedHeight ? constraints.maxHeight : 0);
          return SizedBox(
            width: thickness,
            height: resolvedLength,
            child: ColoredBox(color: effectiveColor),
          );
        },
      );
    }

    if (margin != null) {
      separator = Padding(padding: margin!, child: separator);
    }

    return separator;
  }
}

/// Canonical horizontal divider line for NexaBiz UI built on `shadcn_flutter`.
///
/// Preserves exact backward-compatible signature and behavior.
class AppDivider extends StatelessWidget {
  /// Overall container height for the divider row.
  final double height;

  /// Thickness of the divider line.
  final double thickness;

  /// Custom divider color. Defaults to `shadcn.Theme.of(context).colorScheme.border`.
  final Color? color;

  const AppDivider({
    super.key,
    this.height = 1.0,
    this.thickness = 1.0,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: Center(
        child: AppSeparator(thickness: thickness, color: color),
      ),
    );
  }
}
