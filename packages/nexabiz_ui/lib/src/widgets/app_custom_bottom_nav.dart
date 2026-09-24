import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shadcn;

import '../theme/tokens/app_spacing.dart';
import '../theme/tokens/app_typography.dart';
import 'app_navigation_item.dart';

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
  bool _focused = false;

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
        child: Shortcuts(
          shortcuts: const {
            SingleActivator(LogicalKeyboardKey.enter): ActivateIntent(),
            SingleActivator(LogicalKeyboardKey.space): ActivateIntent(),
          },
          child: Actions(
            actions: {
              ActivateIntent: CallbackAction<ActivateIntent>(
                onInvoke: (_) {
                  _handleTap();
                  return null;
                },
              ),
            },
            child: FocusableActionDetector(
              onShowFocusHighlight: (value) {
                if (mounted) setState(() => _focused = value);
              },
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
                      border: _focused
                          ? Border.all(color: colorScheme.ring, width: 2)
                          : null,
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
                            child: FadeTransition(
                              opacity: animation,
                              child: child,
                            ),
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
    required this.selectedId,
    required this.items,
    required this.onSelected,
    required this.fabTooltip,
    this.onFabTap,
    this.fabIcon = shadcn.LucideIcons.plus,
    this.isFabOpen = false,
    this.height = barHeight,
    this.notchMargin = QuickActionsFab.notchMargin,
  });

  static const double barHeight = 64.0;

  static double contentHeight(double bottomInset) => barHeight + bottomInset;

  static double bodyBottomInset(double systemBottomInset) =>
      barHeight + systemBottomInset + QuickActionsFab.dockOverlap;

  final String selectedId;
  final List<AppNavigationItem> items;
  final ValueChanged<String> onSelected;
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
    final textScale = MediaQuery.textScalerOf(context).scale(1);
    final effectiveHeight =
        height + ((textScale - 1).clamp(0.0, 2.0) * AppSpacing.lg);

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
          height: effectiveHeight + viewBottomPadding,
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
                      selected: left[i].id == selectedId,
                      onTap: left[i].enabled
                          ? () => onSelected(left[i].id)
                          : null,
                    ),
                  ),
                const SizedBox(width: _fabSlotWidth),
                for (var i = 0; i < right.length; i++)
                  Expanded(
                    child: _NavItem(
                      item: right[i],
                      selected: right[i].id == selectedId,
                      onTap: right[i].enabled
                          ? () => onSelected(right[i].id)
                          : null,
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

  final AppNavigationItem item;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = shadcn.Theme.of(context);
    final colorScheme = theme.colorScheme;
    final activeColor = colorScheme.primary;
    final inactiveColor = colorScheme.mutedForeground;

    final iconData = selected && item.selectedIcon != null
        ? item.selectedIcon!
        : item.icon;

    return Semantics(
      button: true,
      selected: selected,
      enabled: item.enabled,
      label: item.label,
      child: shadcn.Button(
        // The bar itself owns the touch-target height. Removing shadcn's
        // additional vertical button padding leaves the full local constraint
        // available to the icon/label stack, including at larger text scales.
        style: const shadcn.ButtonStyle.ghost(
          density: shadcn.ButtonDensity.compact,
        ),
        onPressed: onTap == null
            ? null
            : () {
                HapticFeedback.selectionClick();
                onTap!();
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
