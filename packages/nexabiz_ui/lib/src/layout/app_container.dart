import 'package:flutter/widgets.dart';

import '../theme/tokens/app_spacing.dart';
import 'app_breakpoints.dart';
import 'app_responsive.dart';

/// Semantic container width presets for the NexaBiz ERP UI foundation.
class AppContainerWidths {
  const AppContainerWidths._();

  /// Compact/Mobile readable width (max 600px).
  static const double compact = AppBreakpoints.mobile;

  /// Form input container width (max 640px).
  static const double form = 640.0;

  /// Readable document/article width (max 800px).
  static const double readable = 800.0;

  /// Detail summary view container width (max 960px).
  static const double details = 960.0;

  /// Standard expanded layout width (max 1200px).
  static const double expanded = AppBreakpoints.desktop;

  /// Accounting dashboard & data grid layout width (max 1440px).
  static const double dashboard = AppBreakpoints.largeDesktop;

  /// Full width layout (unconstrained).
  static const double full = double.infinity;
}

/// Canonical responsive container primitive for NexaBiz ERP pages and components.
///
/// Automatically enforces semantic max/min widths, responsive horizontal padding,
/// vertical content spacing, safe area alignment, and scroll policies across
/// Mobile, Tablet, Desktop, and Large Desktop viewports.
class AppContainer extends StatelessWidget {
  const AppContainer({
    super.key,
    required this.child,
    this.maxWidth = AppContainerWidths.expanded,
    this.minWidth,
    this.padding,
    this.alignment = Alignment.topCenter,
    this.centerContent = true,
    this.scrollable = false,
    this.scrollController,
    this.physics,
  });

  /// Page root container preset (max 1200px wide, top-centered).
  const AppContainer.page({
    super.key,
    required this.child,
    this.padding,
    this.scrollable = true,
    this.scrollController,
    this.physics,
  }) : maxWidth = AppContainerWidths.expanded,
       minWidth = null,
       alignment = Alignment.topCenter,
       centerContent = true;

  /// Form section container preset (max 640px wide).
  const AppContainer.form({
    super.key,
    required this.child,
    this.padding,
    this.scrollable = true,
    this.scrollController,
    this.physics,
  }) : maxWidth = AppContainerWidths.form,
       minWidth = null,
       alignment = Alignment.topCenter,
       centerContent = true;

  /// Entity details view container preset (max 960px wide).
  const AppContainer.details({
    super.key,
    required this.child,
    this.padding,
    this.scrollable = true,
    this.scrollController,
    this.physics,
  }) : maxWidth = AppContainerWidths.details,
       minWidth = null,
       alignment = Alignment.topCenter,
       centerContent = true;

  /// Dense accounting data table container preset (max 1440px or full width).
  const AppContainer.table({
    super.key,
    required this.child,
    this.padding,
    this.scrollable = false,
    this.scrollController,
    this.physics,
  }) : maxWidth = AppContainerWidths.dashboard,
       minWidth = null,
       alignment = Alignment.topCenter,
       centerContent = true;

  /// ERP Dashboard container preset (max 1440px wide).
  const AppContainer.dashboard({
    super.key,
    required this.child,
    this.padding,
    this.scrollable = true,
    this.scrollController,
    this.physics,
  }) : maxWidth = AppContainerWidths.dashboard,
       minWidth = null,
       alignment = Alignment.topCenter,
       centerContent = true;

  /// Application Settings container preset (max 800px wide).
  const AppContainer.settings({
    super.key,
    required this.child,
    this.padding,
    this.scrollable = true,
    this.scrollController,
    this.physics,
  }) : maxWidth = AppContainerWidths.readable,
       minWidth = null,
       alignment = Alignment.topCenter,
       centerContent = true;

  /// Modal overlay dialog/sheet container preset (max 600px wide).
  const AppContainer.modal({
    super.key,
    required this.child,
    this.padding,
    this.scrollable = false,
    this.scrollController,
    this.physics,
  }) : maxWidth = AppContainerWidths.compact,
       minWidth = null,
       alignment = Alignment.center,
       centerContent = true;

  final Widget child;
  final double maxWidth;
  final double? minWidth;
  final EdgeInsetsGeometry? padding;
  final AlignmentGeometry alignment;
  final bool centerContent;
  final bool scrollable;
  final ScrollController? scrollController;
  final ScrollPhysics? physics;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final parentScope = AppResponsiveScope.maybeOf(context);
        final availableWidth = constraints.hasBoundedWidth
            ? constraints.maxWidth
            : (parentScope?.availableWidth ?? MediaQuery.sizeOf(context).width);
        final isCompact = AppBreakpoints.isCompact(availableWidth);

        // Responsive default horizontal padding: compact = 16px, tablet/desktop = 24px
        final defaultPadding = EdgeInsets.symmetric(
          horizontal: isCompact ? AppSpacing.md : AppSpacing.lg,
          vertical: isCompact ? AppSpacing.md : AppSpacing.lg,
        );

        final effectivePadding = padding ?? defaultPadding;

        Widget content =
            BoxConstraints(maxWidth: maxWidth, minWidth: minWidth ?? 0.0) !=
                const BoxConstraints()
            ? ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: maxWidth,
                  minWidth: minWidth ?? 0.0,
                ),
                child: Padding(padding: effectivePadding, child: child),
              )
            : Padding(padding: effectivePadding, child: child);

        if (centerContent) {
          content = Align(alignment: alignment, child: content);
        }

        if (scrollable) {
          content = SingleChildScrollView(
            controller: scrollController,
            physics: physics ?? const BouncingScrollPhysics(),
            child: content,
          );
        }

        return content;
      },
    );
  }
}
