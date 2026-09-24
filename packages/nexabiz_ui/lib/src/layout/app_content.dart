import 'package:flutter/widgets.dart';

import 'app_breakpoints.dart';
import 'app_layout_tokens.dart';
import 'app_responsive.dart';

/// Central container managing maximum content width, alignment, and responsive padding.
class AppContent extends StatelessWidget {
  const AppContent({
    super.key,
    required this.child,
    this.maxWidth = AppLayoutTokens.maxPageWidth,
    this.padding,
    this.alignment = AlignmentDirectional.topCenter,
  });

  final Widget child;
  final double maxWidth;
  final EdgeInsetsGeometry? padding;
  final AlignmentGeometry alignment;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final parentScope = AppResponsiveScope.maybeOf(context);
        final availableWidth = constraints.hasBoundedWidth
            ? constraints.maxWidth
            : (parentScope?.availableWidth ?? MediaQuery.sizeOf(context).width);

        final defaultPadding = AppBreakpoints.isCompact(availableWidth)
            ? AppLayoutTokens.pagePaddingDirectionalCompact
            : AppLayoutTokens.pagePaddingDirectionalStandard;

        return Align(
          alignment: alignment,
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: maxWidth),
            child: Padding(padding: padding ?? defaultPadding, child: child),
          ),
        );
      },
    );
  }
}
