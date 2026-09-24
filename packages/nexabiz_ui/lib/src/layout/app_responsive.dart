import 'package:flutter/widgets.dart';
import 'app_breakpoints.dart';

/// Builder callback for [AppResponsive.builder].
typedef AppResponsiveWidgetBuilder =
    Widget Function(
      BuildContext context,
      AppBreakpointTier tier,
      BoxConstraints constraints,
    );

/// Immutable descriptor of the current responsive layout state.
@immutable
class AppResponsiveInfo {
  const AppResponsiveInfo({
    required this.tier,
    required this.constraints,
    required this.availableWidth,
  });

  /// The active [AppBreakpointTier] (compact, medium, expanded, or wide).
  final AppBreakpointTier tier;

  /// The layout constraints that produced this responsive state.
  final BoxConstraints constraints;

  /// The effective available width (in logical pixels) for layout.
  final double availableWidth;

  /// Whether the current layout is in the compact (< 600px) tier.
  bool get isCompact => tier == AppBreakpointTier.compact;

  /// Whether the current layout is in the medium (600px - 999px) tier.
  bool get isMedium => tier == AppBreakpointTier.medium;

  /// Whether the current layout is in the expanded (1000px - 1439px) tier.
  bool get isExpanded => tier == AppBreakpointTier.expanded;

  /// Whether the current layout is in the wide (>= 1440px) tier.
  bool get isWide => tier == AppBreakpointTier.wide;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AppResponsiveInfo &&
          runtimeType == other.runtimeType &&
          tier == other.tier &&
          constraints == other.constraints &&
          availableWidth == other.availableWidth;

  @override
  int get hashCode => Object.hash(tier, constraints, availableWidth);
}

/// An [InheritedWidget] that provides the local [AppResponsiveInfo] to descendants.
///
/// Ensures nested containers, sheets, dialogs, and side-panels can adapt to their
/// available width rather than global device screen dimensions.
class AppResponsiveScope extends InheritedWidget {
  const AppResponsiveScope({
    super.key,
    required this.info,
    required super.child,
  });

  /// The responsive layout descriptor.
  final AppResponsiveInfo info;

  /// Returns the nearest [AppResponsiveInfo] from the widget tree, or `null` if none exists.
  static AppResponsiveInfo? maybeOf(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<AppResponsiveScope>()
        ?.info;
  }

  /// Returns the nearest [AppResponsiveInfo], falling back to viewport [MediaQuery] dimensions.
  static AppResponsiveInfo of(BuildContext context) {
    final info = maybeOf(context);
    if (info != null) return info;
    final width = MediaQuery.sizeOf(context).width;
    return AppResponsiveInfo(
      tier: AppBreakpoints.getTier(width),
      constraints: BoxConstraints.tightFor(width: width),
      availableWidth: width,
    );
  }

  @override
  bool updateShouldNotify(covariant AppResponsiveScope oldWidget) {
    return info != oldWidget.info;
  }
}

/// Canonical responsive layout utilities and responsive builder primitives for NexaBiz UI.
class AppResponsive {
  const AppResponsive._();

  /// Obtains the [AppResponsiveInfo] from the nearest [AppResponsiveScope],
  /// or falls back to the current [MediaQuery].
  static AppResponsiveInfo of(BuildContext context) =>
      AppResponsiveScope.of(context);

  /// Obtains the current [AppBreakpointTier] in the given context.
  static AppBreakpointTier tierOf(BuildContext context) =>
      AppResponsiveScope.maybeOf(context)?.tier ?? AppBreakpoints.of(context);

  /// Evaluates and returns a value of type [T] matching the current breakpoint tier.
  ///
  /// Priority: Local [AppResponsiveScope] tier -> Viewport [MediaQuery] tier.
  /// Falls back in hierarchy: `wide` -> `expanded` -> `medium` -> `compact`.
  static T value<T>(
    BuildContext context, {
    required T compact,
    T? medium,
    T? expanded,
    T? wide,
  }) {
    final tier = tierOf(context);

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

  /// Builds a widget tree using the current [AppBreakpointTier] and local layout constraints.
  ///
  /// Wraps the child in an [AppResponsiveScope] so that any descendant calling
  /// [AppResponsive.value], [AppResponsive.tierOf], or [AppBreakpoints.of] correctly
  /// inherits the local container constraints rather than global screen dimensions.
  static Widget builder({
    Key? key,
    required AppResponsiveWidgetBuilder builder,
  }) {
    return LayoutBuilder(
      key: key,
      builder: (context, constraints) {
        final parentScope = AppResponsiveScope.maybeOf(context);
        final availableWidth = constraints.hasBoundedWidth
            ? constraints.maxWidth
            : (parentScope?.availableWidth ?? MediaQuery.sizeOf(context).width);
        final tier = AppBreakpoints.getTier(availableWidth);
        final info = AppResponsiveInfo(
          tier: tier,
          constraints: constraints,
          availableWidth: availableWidth,
        );

        return AppResponsiveScope(
          info: info,
          child: Builder(
            builder: (innerContext) => builder(innerContext, tier, constraints),
          ),
        );
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
    return AppResponsive.builder(
      builder: (context, tier, constraints) {
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
