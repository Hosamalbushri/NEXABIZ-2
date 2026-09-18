import 'package:flutter/widgets.dart';
import 'app_breakpoints.dart';

/// Builder callback for [AppResponsive.builder].
typedef AppResponsiveWidgetBuilder =
    Widget Function(
      BuildContext context,
      AppBreakpointTier tier,
      BoxConstraints constraints,
    );

/// Canonical responsive layout utilities and responsive builder primitives for NexaBiz UI.
class AppResponsive {
  const AppResponsive._();

  /// Evaluates and returns a value of type [T] matching the current viewport breakpoint tier.
  ///
  /// Falls back in hierarchy: `wide` -> `expanded` -> `medium` -> `compact`.
  static T value<T>(
    BuildContext context, {
    required T compact,
    T? medium,
    T? expanded,
    T? wide,
  }) {
    final width = MediaQuery.of(context).size.width;
    final tier = AppBreakpoints.getTier(width);

    switch (tier) {
      case AppBreakpointTier.wide:
        return wide ?? expanded ?? medium ?? compact;
      case AppBreakpointTier.expanded:
        return expanded ?? medium ?? compact;
      case AppBreakpointTier.medium:
        return medium ?? compact;
      case AppBreakpointTier.compact:
        return compact;
    }
  }

  /// Builds a widget tree using the current [AppBreakpointTier] and layout constraints.
  static Widget builder({
    Key? key,
    required AppResponsiveWidgetBuilder builder,
  }) {
    return LayoutBuilder(
      key: key,
      builder: (context, constraints) {
        final tier = AppBreakpoints.getTier(constraints.maxWidth);
        return builder(context, tier, constraints);
      },
    );
  }
}

/// Declarative widget switching between [compact], [medium], [expanded], and [wide] layouts.
class AppResponsiveLayout extends StatelessWidget {
  const AppResponsiveLayout({
    super.key,
    required this.compact,
    this.medium,
    this.expanded,
    this.wide,
  });

  /// Mobile layout widget (< 600px).
  final Widget compact;

  /// Tablet layout widget (600px - 999px).
  final Widget? medium;

  /// Desktop layout widget (1000px - 1439px).
  final Widget? expanded;

  /// Large desktop layout widget (>= 1440px).
  final Widget? wide;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final tier = AppBreakpoints.getTier(constraints.maxWidth);

        switch (tier) {
          case AppBreakpointTier.wide:
            return wide ?? expanded ?? medium ?? compact;
          case AppBreakpointTier.expanded:
            return expanded ?? medium ?? compact;
          case AppBreakpointTier.medium:
            return medium ?? compact;
          case AppBreakpointTier.compact:
            return compact;
        }
      },
    );
  }
}
