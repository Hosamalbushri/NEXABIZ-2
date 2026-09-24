import 'dart:math' as math;

import 'package:flutter/widgets.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shadcn;

import '../localization/nexabiz_ui_localizations.dart';
import '../layout/app_layout_tokens.dart';
import '../theme/tokens/tokens.dart';
import 'app_icon_button.dart';
import 'app_breadcrumb.dart';
import 'app_expandable_text.dart';

/// Canonical page header composite for NexaBiz ERP screens built on [shadcn_flutter],
/// visually matching the application's canonical [CustomAppBar] formatting and scaling.
class AppPageHeader extends StatelessWidget {
  const AppPageHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.breadcrumbs,
    this.actions,
    this.leading,
    this.centerTitle = true,
    this.showBackButton,
    this.onBack,
    this.onFilterTap,
    this.filterCount = 0,
    this.useSurfaceContainer = true,
    this.onSearchTap,
    this.isSearching = false,
  });

  final String title;
  final String? subtitle;
  final List<String>? breadcrumbs;
  final List<Widget>? actions;
  final Widget? leading;
  final bool centerTitle;
  final bool? showBackButton;
  final VoidCallback? onBack;
  final VoidCallback? onFilterTap;
  final int filterCount;
  final bool useSurfaceContainer;

  // Search parameters
  final VoidCallback? onSearchTap;
  final bool isSearching;

  @override
  Widget build(BuildContext context) {
    final theme = shadcn.Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final loc = NexaBizUiLocalizations.of(context);

    final isRtl = Directionality.of(context) == TextDirection.rtl;
    final canPop = Navigator.canPop(context);
    final shouldShowBack = showBackButton ?? canPop;

    final backButton = shouldShowBack
        ? AppIconButton(
            variant: AppIconButtonVariant.chip,
            iconSize: 18.0,
            icon: isRtl
                ? shadcn.LucideIcons.arrowRight
                : shadcn.LucideIcons.arrowLeft,
            tooltip: loc.back,
            onPressed: onBack ?? () => Navigator.of(context).maybePop(),
          )
        : null;

    final filterButton = onFilterTap != null
        ? AppIconButton(
            variant: AppIconButtonVariant.chip,
            iconSize: 18.0,
            icon: shadcn.LucideIcons.slidersHorizontal,
            tooltip: loc.filter,
            badgeCount: filterCount > 0 ? filterCount : null,
            onPressed: onFilterTap,
          )
        : null;

    final searchButton = onSearchTap != null
        ? AppIconButton(
            variant: AppIconButtonVariant.chip,
            iconSize: 18.0,
            icon: isSearching
                ? shadcn.LucideIcons.x
                : shadcn.LucideIcons.search,
            tooltip: isSearching ? loc.closeSearch : loc.search,
            onPressed: onSearchTap,
          )
        : null;

    final startCluster = <Widget>[?backButton, ?leading];

    final endCluster = <Widget>[?searchButton, ?filterButton, ...?actions];

    final titleWidget = Text(
      title,
      textAlign: centerTitle ? TextAlign.center : TextAlign.start,
      style: theme.typography.h3.copyWith(
        fontWeight: FontWeight.w700,
        letterSpacing: -0.6,
        height: 1.05,
        color: colorScheme.foreground,
      ),
    );
    final titleBlock = Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: centerTitle
          ? CrossAxisAlignment.center
          : CrossAxisAlignment.start,
      children: [
        titleWidget,
        if (subtitle != null && subtitle!.isNotEmpty) ...[
          const SizedBox(height: 2),
          AppExpandableText(
            text: subtitle!,
            maxCollapsedLines: 2,
            style: theme.typography.xSmall.copyWith(
              color: colorScheme.mutedForeground,
            ),
          ),
        ],
      ],
    );
    final startActions = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 0; i < startCluster.length; i++) ...[
          if (i > 0) const SizedBox(width: AppSpacing.sm),
          startCluster[i],
        ],
      ],
    );
    final endActions = Wrap(
      alignment: WrapAlignment.end,
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.xs,
      children: endCluster,
    );

    final headerContent = Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: centerTitle
          ? CrossAxisAlignment.center
          : CrossAxisAlignment.start,
      children: [
        if (breadcrumbs != null && breadcrumbs!.isNotEmpty) ...[
          AppBreadcrumb(
            items: [
              for (final label in breadcrumbs!) AppBreadcrumbItem(label: label),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
        ],

        LayoutBuilder(
          builder: (context, constraints) {
            final stackControls =
                (startCluster.isNotEmpty || endCluster.isNotEmpty) &&
                (!constraints.hasBoundedWidth ||
                    constraints.maxWidth <
                        AppLayoutTokens.sectionHeaderStackMaxWidth);
            if (stackControls) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (startCluster.isNotEmpty) startActions,
                      if (startCluster.isNotEmpty && endCluster.isNotEmpty)
                        const SizedBox(width: AppSpacing.sm),
                      if (endCluster.isNotEmpty) Expanded(child: endActions),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  titleBlock,
                ],
              );
            }

            return Stack(
              alignment: Alignment.center,
              children: [
                if (startCluster.isNotEmpty)
                  Align(
                    alignment: AlignmentDirectional.centerStart,
                    child: startActions,
                  ),
                Padding(
                  padding: centerTitle
                      ? EdgeInsets.symmetric(
                          horizontal:
                              (startCluster.isNotEmpty || endCluster.isNotEmpty)
                              ? math.max(
                                  52.0,
                                  math.max(
                                    startCluster.isEmpty
                                        ? 0.0
                                        : startCluster.length * 36.0 +
                                              (startCluster.length - 1) * 8.0 +
                                              12.0,
                                    endCluster.isEmpty
                                        ? 0.0
                                        : endCluster.length * 36.0 +
                                              (endCluster.length - 1) * 8.0 +
                                              12.0,
                                  ),
                                )
                              : 0.0,
                        )
                      : EdgeInsetsDirectional.only(
                          start: startCluster.isNotEmpty
                              ? math.max(
                                  52.0,
                                  startCluster.length * 36.0 +
                                      (startCluster.length - 1) * 8.0 +
                                      12.0,
                                )
                              : 0.0,
                          end: endCluster.isNotEmpty
                              ? math.max(
                                  52.0,
                                  endCluster.length * 36.0 +
                                      (endCluster.length - 1) * 8.0 +
                                      12.0,
                                )
                              : 0.0,
                        ),
                  child: titleBlock,
                ),
                if (endCluster.isNotEmpty)
                  Align(
                    alignment: AlignmentDirectional.centerEnd,
                    child: endActions,
                  ),
              ],
            );
          },
        ),
      ],
    );

    if (!useSurfaceContainer) {
      return Padding(
        padding: const EdgeInsets.only(bottom: AppSpacing.md),
        child: headerContent,
      );
    }

    final backgroundColor = isDark ? colorScheme.muted : colorScheme.card;

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(24.0),
        border: Border.all(
          color: colorScheme.border.withValues(alpha: isDark ? 0.6 : 0.4),
          width: 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: colorScheme.primary.withValues(alpha: isDark ? 0.18 : 0.12),
            blurRadius: 19.2,
            offset: const Offset(0, 3.6),
          ),
        ],
      ),
      child: headerContent,
    );
  }
}
