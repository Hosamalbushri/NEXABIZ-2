import 'package:flutter/material.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shadcn;

/// Border stroke widths, sides, and outline tokens for NexaBiz.
class AppBorders {
  const AppBorders._();

  static const double thin = 1.0;
  static const double medium = 1.5;
  static const double thick = 2.0;

  /// Standard enterprise container border resolving directly from [shadcn.Theme].
  static BorderSide border(BuildContext context, {double width = thin}) {
    return BorderSide(
      color: shadcn.Theme.of(context).colorScheme.border,
      width: width,
    );
  }

  /// Subtle container outline border resolving directly from [shadcn.Theme].
  static BorderSide subtleBorder(BuildContext context, {double width = thin}) {
    return BorderSide(
      color: shadcn.Theme.of(context).colorScheme.border.withValues(alpha: 0.5),
      width: width,
    );
  }

  /// Focus ring border side resolving directly from [shadcn.Theme].
  static BorderSide ring(BuildContext context, {double width = medium}) {
    return BorderSide(
      color: shadcn.Theme.of(context).colorScheme.ring,
      width: width,
    );
  }

  /// Destructive/error border side resolving directly from [shadcn.Theme].
  static BorderSide destructive(BuildContext context, {double width = medium}) {
    return BorderSide(
      color: shadcn.Theme.of(context).colorScheme.destructive,
      width: width,
    );
  }

  /// Standard border side resolving outline color according to active brightness.
  static BorderSide outline(ColorScheme scheme, {double width = thin}) {
    return BorderSide(color: scheme.outline, width: width);
  }

  /// Subtle container outline border side.
  static BorderSide subtle(ColorScheme scheme, {double width = thin}) {
    return BorderSide(
      color: scheme.outlineVariant.withValues(alpha: 0.55),
      width: width,
    );
  }

  /// Focus state active ring border side.
  static BorderSide focus(ColorScheme scheme, {double width = medium}) {
    return BorderSide(color: scheme.primary, width: width);
  }

  /// Error state active ring border side.
  static BorderSide error(ColorScheme scheme, {double width = medium}) {
    return BorderSide(color: scheme.error, width: width);
  }
}
