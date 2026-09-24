import 'package:flutter/widgets.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shadcn;

import '../theme/tokens/app_icons.dart';
import '../theme/tokens/app_spacing.dart';
import 'app_card.dart';
import 'app_separator.dart';

/// Canonical collapsible accordion card for NexaBiz UI ERP applications.
///
/// Encapsulates an interactive header surface with an animated expansion chevron
/// that smoothly reveals or collapses child content.
class AppAccordionCard extends StatefulWidget {
  const AppAccordionCard({
    super.key,
    required this.title,
    this.subtitle,
    this.leading,
    this.trailing,
    required this.child,
    this.initiallyExpanded = false,
    this.onExpansionChanged,
    this.padding = const EdgeInsets.symmetric(
      horizontal: AppSpacing.md,
      vertical: AppSpacing.sm,
    ),
    this.contentPadding = const EdgeInsets.all(AppSpacing.sm),
    this.duration = const Duration(milliseconds: 200),
  });

  final Widget title;
  final Widget? subtitle;
  final Widget? leading;
  final Widget? trailing;
  final Widget child;
  final bool initiallyExpanded;
  final ValueChanged<bool>? onExpansionChanged;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry contentPadding;
  final Duration duration;

  @override
  State<AppAccordionCard> createState() => _AppAccordionCardState();
}

class _AppAccordionCardState extends State<AppAccordionCard>
    with SingleTickerProviderStateMixin {
  late bool _isExpanded;

  @override
  void initState() {
    super.initState();
    _isExpanded = widget.initiallyExpanded;
  }

  void _toggle() {
    setState(() {
      _isExpanded = !_isExpanded;
    });
    widget.onExpansionChanged?.call(_isExpanded);
  }

  @override
  Widget build(BuildContext context) {
    final theme = shadcn.Theme.of(context);
    final colorScheme = theme.colorScheme;

    final header = GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: _toggle,
      child: Padding(
        padding: widget.padding,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            if (widget.leading != null) ...[
              widget.leading!,
              const SizedBox(width: AppSpacing.sm),
            ],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  DefaultTextStyle(
                    style: theme.typography.p.copyWith(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: colorScheme.foreground,
                    ),
                    child: widget.title,
                  ),
                  if (widget.subtitle != null) ...[
                    const SizedBox(height: 2),
                    DefaultTextStyle(
                      style: theme.typography.small.copyWith(
                        fontSize: 12,
                        color: colorScheme.mutedForeground,
                      ),
                      child: widget.subtitle!,
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.xs),
            widget.trailing ??
                AnimatedRotation(
                  turns: _isExpanded ? 0.5 : 0.0,
                  duration: widget.duration,
                  curve: Curves.easeInOut,
                  child: Icon(
                    AppIcons.chevronDown,
                    size: 16,
                    color: colorScheme.mutedForeground,
                  ),
                ),
          ],
        ),
      ),
    );

    return AppCard(
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          header,
          AnimatedCrossFade(
            firstChild: const SizedBox.shrink(),
            secondChild: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                const AppDivider(),
                Padding(
                  padding: widget.contentPadding,
                  child: widget.child,
                ),
              ],
            ),
            crossFadeState: _isExpanded
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            duration: widget.duration,
            sizeCurve: Curves.easeInOut,
          ),
        ],
      ),
    );
  }
}
