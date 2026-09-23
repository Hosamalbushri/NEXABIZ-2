import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:nexabiz_ui/nexabiz_ui.dart';

import '../../../l10n/app_localizations.dart';

class _DashboardHighlightItem {
  final String title;
  final String subtitle;
  final String badge;
  final IconData icon;

  const _DashboardHighlightItem({
    required this.title,
    required this.subtitle,
    required this.badge,
    required this.icon,
  });
}

/// Primary Dashboard screen built strictly using canonical `nexabiz_ui` component definitions.
class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return AppDashboardPage(
      title: l10n.dashboardTitle,
      subtitle: l10n.dashboardSubtitle,
      headerActions: [
        AppIconButton(
          variant: AppIconButtonVariant.ghost,
          icon: AppIcons.layers,
          tooltip: l10n.quickActionMobilePlayground,
          onPressed: () => context.push('/playground'),
        ),
      ],
      statsGrid: const _DashboardKpiGrid(),
      carousel: const _DashboardCarouselSection(),
      quickActions: const _DashboardPlaygroundBanner(),
      content: const _SystemStatusBanner(),
      recentActivity: const _RecentActivitySection(),
    );
  }
}

class _DashboardPlaygroundBanner extends StatelessWidget {
  const _DashboardPlaygroundBanner();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return AppCard(
      padding: EdgeInsets.zero,
      child: AppListTile(
        onTap: () => context.push('/playground'),
        leading: DecoratedBox(
          decoration: BoxDecoration(
            color: AppColors.primaryBlue.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(AppRadii.md),
          ),
          child: const Padding(
            padding: EdgeInsets.all(AppSpacing.xs),
            child: Icon(
              AppIcons.layers,
              color: AppColors.primaryBlue,
              size: 24,
            ),
          ),
        ),
        title: Wrap(
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: AppSpacing.xs,
          runSpacing: AppSpacing.xxs,
          children: [
            Text(
              l10n.quickActionMobilePlayground,
              style: AppTypography.bodyBold(context),
            ),
            AppStatusBadge(
              label: l10n.dashboardMobilePlaygroundBadge,
              tone: AppStatusTone.info,
              animate: false,
            ),
          ],
        ),
        subtitle: Text(
          l10n.quickActionMobilePlaygroundDesc,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: const Icon(
          AppIcons.chevronRight,
          size: 18,
          color: AppColors.primaryBlue,
        ),
      ),
    );
  }
}

class _DashboardCarouselSection extends StatelessWidget {
  const _DashboardCarouselSection();

  List<_DashboardHighlightItem> _getHighlights(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return [
      _DashboardHighlightItem(
        title: l10n.dashboardHighlight1Title,
        subtitle: l10n.dashboardHighlight1Subtitle,
        badge: l10n.dashboardHighlight1Badge,
        icon: AppIcons.trendingUp,
      ),
      _DashboardHighlightItem(
        title: l10n.dashboardHighlight2Title,
        subtitle: l10n.dashboardHighlight2Subtitle,
        badge: l10n.dashboardHighlight2Badge,
        icon: AppIcons.box,
      ),
      _DashboardHighlightItem(
        title: l10n.dashboardHighlight3Title,
        subtitle: l10n.dashboardHighlight3Subtitle,
        badge: l10n.dashboardHighlight3Badge,
        icon: AppIcons.wallet,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final highlights = _getHighlights(context);

    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.sm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsetsDirectional.only(
              start: AppSpacing.xxs,
              bottom: AppSpacing.xs,
            ),
            child: Text(
              l10n.dashboardEnterpriseHighlights,
              style: AppTypography.sectionTitle(context),
            ),
          ),
          AppCarousel<_DashboardHighlightItem>(
            height: 172,
            autoplay: false,
            autoplaySpeed: const Duration(seconds: 5),
            items: highlights,
            itemBuilder: (context, item, index) {
              return AppSurface(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.sm,
                ),
                child: SingleChildScrollView(
                  physics: const NeverScrollableScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: AppStatusBadge(
                              label: item.badge,
                              tone: AppStatusTone.info,
                              animate: false,
                            ),
                          ),
                          const SizedBox(width: AppSpacing.xs),
                          Icon(
                            item.icon,
                            size: 20,
                            color: AppColors.primaryBlue,
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(item.title, style: AppTypography.bodyBold(context)),
                      const SizedBox(height: 4),
                      Text(
                        item.subtitle,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: AppTypography.caption(context),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _SystemStatusBanner extends StatelessWidget {
  const _SystemStatusBanner();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return AppSurface(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.dashboardArchitectureActive,
                  style: AppTypography.bodyBold(context),
                ),
                const SizedBox(height: AppSpacing.xxs),
                Text(
                  l10n.dashboardArchitectureSubtitle,
                  style: AppTypography.caption(context),
                ),
              ],
            ),
          ),
          AppStatusBadge(
            label: l10n.statusOnline,
            tone: AppStatusTone.success,
            animate: false,
          ),
        ],
      ),
    );
  }
}

class _DashboardKpiGrid extends StatelessWidget {
  const _DashboardKpiGrid();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return AppGrid(
      children: [
        _KpiTile(
          title: l10n.kpiTotalSales,
          value: '\$124,500.00',
          subtitle: l10n.kpiTotalSalesSubtitle,
          icon: AppIcons.trendingUp,
          tone: AppStatusTone.success,
        ),
        _KpiTile(
          title: l10n.kpiPurchases,
          value: '\$45,210.00',
          subtitle: l10n.kpiPurchasesSubtitle,
          icon: AppIcons.shoppingBag,
          tone: AppStatusTone.info,
        ),
        _KpiTile(
          title: l10n.kpiReceivables,
          value: '\$18,400.00',
          subtitle: l10n.kpiReceivablesSubtitle,
          icon: AppIcons.wallet,
          tone: AppStatusTone.warning,
        ),
        _KpiTile(
          title: l10n.kpiStockValuation,
          value: '\$310,900.00',
          subtitle: l10n.kpiStockValuationSubtitle,
          icon: AppIcons.box,
          tone: AppStatusTone.neutral,
        ),
      ],
    );
  }
}

class _KpiTile extends StatelessWidget {
  final String title;
  final String value;
  final String subtitle;
  final IconData icon;
  final AppStatusTone tone;

  const _KpiTile({
    required this.title,
    required this.value,
    required this.subtitle,
    required this.icon,
    required this.tone,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.sm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.caption(context),
                ),
              ),
              Icon(icon, size: 18, color: AppColors.primaryBlue),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: AlignmentDirectional.centerStart,
            child: Text(value, style: AppTypography.numericValue(context)),
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTypography.caption(context),
          ),
        ],
      ),
    );
  }
}

class _RecentActivitySection extends StatelessWidget {
  const _RecentActivitySection();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final captionStyle = AppTypography.caption(context);
    return AppSection(
      title: l10n.recentActivityTitle,
      child: Column(
        children: [
          AppListTile(
            leading: const Icon(AppIcons.receipt, color: AppColors.primaryBlue),
            title: Text(l10n.recentActivityItem1Title),
            subtitle: Text(l10n.recentActivityItem1Subtitle),
            trailing: Text(l10n.recentActivityItem1Time, style: captionStyle),
          ),
          const AppDivider(),
          AppListTile(
            leading: const Icon(
              AppIcons.refresh,
              color: AppColors.secondaryTeal,
            ),
            title: Text(l10n.recentActivityItem2Title),
            subtitle: Text(l10n.recentActivityItem2Subtitle),
            trailing: Text(l10n.recentActivityItem2Time, style: captionStyle),
          ),
          const AppDivider(),
          AppListTile(
            leading: const Icon(AppIcons.check, color: AppColors.success),
            title: Text(l10n.recentActivityItem3Title),
            subtitle: Text(l10n.recentActivityItem3Subtitle),
            trailing: Text(l10n.recentActivityItem3Time, style: captionStyle),
          ),
        ],
      ),
    );
  }
}
