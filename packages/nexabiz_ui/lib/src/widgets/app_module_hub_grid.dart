import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../theme/app_radius.dart';
import '../theme/app_shadows.dart';
import '../theme/app_spacing.dart';

/// Single item descriptor for module hub pages.
class AppModuleHubItem {
  const AppModuleHubItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.animationDelay = Duration.zero,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final Duration animationDelay;
}

/// Single item tile for module hub service grids.
class AppModuleHubTile extends StatelessWidget {
  const AppModuleHubTile({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.animate = true,
    this.animationDelay = Duration.zero,
    this.mirrorIconInRtl = false,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final bool animate;
  final Duration animationDelay;
  final bool mirrorIconInRtl;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final brightness = theme.brightness;

    final card = LayoutBuilder(
      builder: (context, constraints) {
        final isCompactWidth = constraints.maxWidth < 190;
        final isCompactHeight = constraints.maxHeight < 140;
        final isHorizontal = isCompactHeight || isCompactWidth;

        final isConstrainedVertical =
            constraints.maxHeight < 210 || constraints.maxWidth < 240;
        final iconBoxSize = isConstrainedVertical ? 44.0 : 58.0;
        final iconGraphicSize = isConstrainedVertical ? 22.0 : 28.0;
        final tilePadding = isConstrainedVertical
            ? const EdgeInsets.all(AppSpacing.sm)
            : const EdgeInsets.all(AppSpacing.md);
        final gapSize = isConstrainedVertical ? 4.0 : AppSpacing.sm;

        Widget buildTileIcon(double size) {
          final isRtl = Directionality.of(context) == TextDirection.rtl;
          final shouldFlip =
              isRtl && (icon.matchTextDirection || mirrorIconInRtl);
          final iconWidget = Icon(icon, color: colorScheme.primary, size: size);
          if (shouldFlip) {
            return Transform.flip(flipX: true, child: iconWidget);
          }
          return iconWidget;
        }

        final content = isHorizontal
            ? Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.sm,
                ),
                child: Row(
                  children: [
                    DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: AlignmentDirectional.topStart,
                          end: AlignmentDirectional.bottomEnd,
                          colors: [
                            colorScheme.primary.withValues(alpha: 0.16),
                            colorScheme.secondary.withValues(alpha: 0.10),
                          ],
                        ),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: colorScheme.primary.withValues(alpha: 0.12),
                        ),
                      ),
                      child: SizedBox(
                        width: 44,
                        height: 44,
                        child: buildTileIcon(22),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                              letterSpacing: -0.2,
                              height: 1.2,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Flexible(
                            child: Text(
                              subtitle,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: colorScheme.onSurfaceVariant,
                                height: 1.25,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              )
            : Padding(
                padding: tilePadding,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: AlignmentDirectional.topStart,
                          end: AlignmentDirectional.bottomEnd,
                          colors: [
                            colorScheme.primary.withValues(alpha: 0.16),
                            colorScheme.secondary.withValues(alpha: 0.10),
                          ],
                        ),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: colorScheme.primary.withValues(alpha: 0.12),
                        ),
                      ),
                      child: SizedBox(
                        width: iconBoxSize,
                        height: iconBoxSize,
                        child: buildTileIcon(iconGraphicSize),
                      ),
                    ),
                    SizedBox(height: gapSize),
                    Flexible(
                      child: Text(
                        title,
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.2,
                          height: 1.2,
                        ),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Flexible(
                      child: Text(
                        subtitle,
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                          height: 1.25,
                        ),
                      ),
                    ),
                  ],
                ),
              );

        return Semantics(
          container: true,
          button: true,
          label: title,
          hint: subtitle,
          child: Material(
            color: Colors.transparent,
            elevation: 0,
            child: InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(AppRadius.lg),
              child: Ink(
                decoration: BoxDecoration(
                  color: colorScheme.surface,
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                  border: Border.all(
                    color: colorScheme.outlineVariant.withValues(alpha: 0.55),
                  ),
                  boxShadow: AppShadows.card(brightness),
                ),
                child: content,
              ),
            ),
          ),
        );
      },
    );

    if (!animate) {
      return card;
    }

    return card
        .animate(delay: animationDelay)
        .fadeIn(duration: 260.ms)
        .slideY(begin: 0.04, end: 0, duration: 260.ms);
  }
}

/// Responsive grid layout for module hub pages.
class AppModuleHubGrid extends StatelessWidget {
  const AppModuleHubGrid({
    super.key,
    required this.children,
    this.crossAxisSpacing = AppSpacing.md,
    this.mainAxisSpacing = AppSpacing.md,
  });

  final List<Widget> children;
  final double crossAxisSpacing;
  final double mainAxisSpacing;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        int crossAxisCount;
        double childAspectRatio;

        if (width < 360) {
          crossAxisCount = 1;
          childAspectRatio = 2.8;
        } else if (width < 600) {
          crossAxisCount = 2;
          childAspectRatio = 0.95;
        } else if (width < 900) {
          crossAxisCount = 3;
          childAspectRatio = 0.90;
        } else {
          crossAxisCount = 4;
          childAspectRatio = 0.95;
        }

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: children.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: crossAxisSpacing,
            mainAxisSpacing: mainAxisSpacing,
            childAspectRatio: childAspectRatio,
          ),
          itemBuilder: (context, index) => children[index],
        );
      },
    );
  }
}

/// Dual-mode layout widget rendering either a Grid or List of module items.
class AppModuleHubView extends StatelessWidget {
  const AppModuleHubView({
    super.key,
    required this.isGrid,
    required this.children,
  });

  final bool isGrid;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    if (isGrid) {
      return AppModuleHubGrid(children: children);
    }

    return Column(
      children: [
        for (var i = 0; i < children.length; i++) ...[
          if (i > 0) const SizedBox(height: AppSpacing.md),
          children[i],
        ],
      ],
    );
  }
}

/// Standard Section Header with title, subtitle, and action toggle.
class AppModuleHubHeader extends StatelessWidget {
  const AppModuleHubHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.trailing,
  });

  final String title;
  final String? subtitle;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.2,
                ),
              ),
              if (subtitle != null) ...[
                const SizedBox(height: AppSpacing.xs),
                Text(
                  subtitle!,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    height: 1.4,
                  ),
                ),
              ],
            ],
          ),
        ),
        if (trailing != null) ...[
          const SizedBox(width: AppSpacing.md),
          trailing!,
        ],
      ],
    );
  }
}
