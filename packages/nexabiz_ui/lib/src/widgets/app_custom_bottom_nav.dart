import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shadcn;

import '../theme/tokens/app_spacing.dart';
import '../theme/tokens/app_typography.dart';

/// Item definition for [AppCustomBottomNav].
class AppNavItem {
  final String label;
  final IconData icon;
  final IconData? activeIcon;
  final String routePath;

  const AppNavItem({
    required this.label,
    required this.icon,
    this.activeIcon,
    required this.routePath,
  });
}

/// Center-docked quick-actions FAB for the NexaBiz platform shell,
/// built natively on `shadcn_flutter` v0.0.53 theme tokens and primitives.
class QuickActionsFab extends StatefulWidget {
  const QuickActionsFab({
    super.key,
    required this.tooltip,
    required this.isOpen,
    required this.onPressed,
    this.icon = shadcn.LucideIcons.plus,
  });

  static const double size = 56.0;
  static const double cornerRadius = 12.0;
  static const double notchMargin = 8.0;
  static const double dockOverlap = size / 2;

  final String tooltip;
  final bool isOpen;
  final VoidCallback onPressed;
  final IconData icon;

  @override
  State<QuickActionsFab> createState() => _QuickActionsFabState();
}

class _QuickActionsFabState extends State<QuickActionsFab>
    with SingleTickerProviderStateMixin {
  static const Duration _pressDuration = Duration(milliseconds: 120);
  static const Duration _releaseDuration = Duration(milliseconds: 160);
  static const Duration _iconDuration = Duration(milliseconds: 220);

  bool _pressed = false;

  void _setPressed(bool value) {
    if (_pressed == value || !mounted) return;
    setState(() => _pressed = value);
  }

  void _handleTap() {
    HapticFeedback.lightImpact();
    widget.onPressed();
  }

  @override
  Widget build(BuildContext context) {
    final theme = shadcn.Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final reduceMotion = MediaQuery.disableAnimationsOf(context);

    final pressScale = _pressed ? 0.93 : 1.0;
    final pressDuration = _pressed ? _pressDuration : _releaseDuration;

    return Semantics(
      button: true,
      enabled: true,
      label: widget.tooltip,
      child: shadcn.Tooltip(
        tooltip: (context) =>
            shadcn.TooltipContainer(child: Text(widget.tooltip)),
        child: GestureDetector(
          onTap: _handleTap,
          onTapDown: (_) => _setPressed(true),
          onTapUp: (_) => _setPressed(false),
          onTapCancel: () => _setPressed(false),
          child: AnimatedScale(
            scale: pressScale,
            duration: reduceMotion ? Duration.zero : pressDuration,
            curve: Curves.easeOutCubic,
            child: Container(
              width: QuickActionsFab.size,
              height: QuickActionsFab.size,
              decoration: BoxDecoration(
                color: colorScheme.primary,
                borderRadius: BorderRadius.circular(
                  QuickActionsFab.cornerRadius,
                ),
                boxShadow: [
                  BoxShadow(
                    color: colorScheme.primary.withValues(
                      alpha: isDark ? 0.45 : 0.25,
                    ),
                    blurRadius: _pressed ? 6 : 14,
                    offset: Offset(0, _pressed ? 2 : 5),
                  ),
                ],
              ),
              child: Center(
                child: AnimatedSwitcher(
                  duration: reduceMotion ? Duration.zero : _iconDuration,
                  switchInCurve: Curves.easeOutCubic,
                  switchOutCurve: Curves.easeInCubic,
                  transitionBuilder: (child, animation) {
                    return ScaleTransition(
                      scale: animation,
                      child: FadeTransition(opacity: animation, child: child),
                    );
                  },
                  child: Icon(
                    widget.isOpen ? shadcn.LucideIcons.x : widget.icon,
                    key: ValueKey<bool>(widget.isOpen),
                    size: 24,
                    color: colorScheme.primaryForeground,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Canonical Notched Shell Custom Bottom Navigation Bar for NexaBiz Mobile Shell,
/// built natively using `shadcn_flutter` layout and theme primitives.
class AppCustomBottomNav extends StatelessWidget {
  const AppCustomBottomNav({
    super.key,
    required this.currentIndex,
    required this.items,
    required this.onTap,
    this.onFabTap,
    this.fabIcon = shadcn.LucideIcons.plus,
    this.fabTooltip = 'Quick Actions',
    this.isFabOpen = false,
    this.height = barHeight,
    this.notchMargin = QuickActionsFab.notchMargin,
  });

  static const double barHeight = 64.0;

  static double contentHeight(double bottomInset) => barHeight + bottomInset;

  static double bodyBottomInset(double systemBottomInset) =>
      barHeight + systemBottomInset + QuickActionsFab.dockOverlap;

  final int currentIndex;
  final List<AppNavItem> items;
  final ValueChanged<int> onTap;
  final VoidCallback? onFabTap;
  final IconData fabIcon;
  final String fabTooltip;
  final bool isFabOpen;
  final double height;
  final double notchMargin;

  static const double _fabSlotWidth = QuickActionsFab.size + 16;

  @override
  Widget build(BuildContext context) {
    final theme = shadcn.Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    final mid = items.length ~/ 2;
    final left = items.take(mid).toList(growable: false);
    final right = items.skip(mid).toList(growable: false);

    final viewBottomPadding = MediaQuery.viewPaddingOf(context).bottom;

    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.bottomCenter,
      children: [
        // Main Navigation Bar Surface
        Container(
          height: height + viewBottomPadding,
          padding: EdgeInsets.only(bottom: viewBottomPadding),
          decoration: BoxDecoration(
            color: colorScheme.popover,
            border: Border(
              top: BorderSide(color: colorScheme.border, width: 1.0),
            ),
            boxShadow: [
              BoxShadow(
                color: colorScheme.primary.withValues(
                  alpha: isDark ? 0.20 : 0.08,
                ),
                blurRadius: 16,
                offset: const Offset(0, -4),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
            child: Row(
              children: [
                for (var i = 0; i < left.length; i++)
                  Expanded(
                    child: _NavItem(
                      item: left[i],
                      selected: i == currentIndex,
                      onTap: () => onTap(i),
                    ),
                  ),
                const SizedBox(width: _fabSlotWidth),
                for (var i = 0; i < right.length; i++)
                  Expanded(
                    child: _NavItem(
                      item: right[i],
                      selected: (mid + i) == currentIndex,
                      onTap: () => onTap(mid + i),
                    ),
                  ),
              ],
            ),
          ),
        ),

        // Elevated Quick Actions FAB Floating ON TOP of Bottom Bar
        if (onFabTap != null)
          Positioned(
            top: -(QuickActionsFab.size / 2) + 6,
            child: QuickActionsFab(
              tooltip: fabTooltip,
              isOpen: isFabOpen,
              onPressed: onFabTap!,
              icon: fabIcon,
            ),
          ),
      ],
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.item,
    required this.selected,
    required this.onTap,
  });

  final AppNavItem item;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = shadcn.Theme.of(context);
    final colorScheme = theme.colorScheme;
    final activeColor = colorScheme.primary;
    final inactiveColor = colorScheme.mutedForeground;

    final iconData = selected && item.activeIcon != null
        ? item.activeIcon!
        : item.icon;

    return Semantics(
      button: true,
      selected: selected,
      label: item.label,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          HapticFeedback.selectionClick();
          onTap();
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOutCubic,
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
          decoration: BoxDecoration(
            color: selected
                ? activeColor.withValues(alpha: 0.08)
                : const Color(0x00000000),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedScale(
                scale: selected ? 1.08 : 1.0,
                duration: const Duration(milliseconds: 220),
                curve: Curves.easeOutCubic,
                child: Icon(
                  iconData,
                  size: 22,
                  color: selected ? activeColor : inactiveColor,
                ),
              ),
              const SizedBox(height: 4),
              AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 220),
                curve: Curves.easeOutCubic,
                style: TextStyle(
                  fontFamily: AppTypography.fontFamilyName,
                  fontSize: 11.0,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                  color: selected ? activeColor : inactiveColor,
                  letterSpacing: -0.1,
                  height: 1.1,
                ),
                child: Text(
                  item.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
