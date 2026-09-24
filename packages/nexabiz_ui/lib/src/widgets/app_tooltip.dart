import 'package:flutter/widgets.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shadcn;

/// Canonical tooltip primitive for NexaBiz UI built on `shadcn_flutter`.
///
/// Wraps [shadcn.Tooltip] and [shadcn.TooltipContainer] to provide
/// a concise, declarative API for desktop and mobile overlays.
class AppTooltip extends StatelessWidget {
  /// The target widget that triggers the tooltip on hover or touch.
  final Widget child;

  /// The tooltip text message.
  final String message;

  /// Alignment of the tooltip popup relative to the anchor child.
  final AlignmentGeometry alignment;

  /// Anchor point on the child widget.
  final AlignmentGeometry anchorAlignment;

  /// Delay duration before displaying the tooltip on hover.
  final Duration waitDuration;

  const AppTooltip({
    super.key,
    required this.message,
    required this.child,
    this.alignment = Alignment.topCenter,
    this.anchorAlignment = Alignment.bottomCenter,
    this.waitDuration = const Duration(milliseconds: 500),
  });

  @override
  Widget build(BuildContext context) {
    if (message.isEmpty) return child;

    return shadcn.Tooltip(
      alignment: alignment,
      anchorAlignment: anchorAlignment,
      waitDuration: waitDuration,
      tooltip: (context) => shadcn.TooltipContainer(child: Text(message)),
      child: child,
    );
  }
}
