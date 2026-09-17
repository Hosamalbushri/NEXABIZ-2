import 'package:flutter/widgets.dart';
import 'package:nexabiz_ui/nexabiz_ui.dart';

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
    return AppDashboardPage(
      title: 'NexaBiz Dashboard',
      subtitle: 'Welcome back to NexaBiz ERP',
      statsGrid: const _DashboardKpiGrid(),
      carousel: const _DashboardCarouselSection(),
      content: const _SystemStatusBanner(),
      recentActivity: const _RecentActivitySection(),
    );
  }
}

class _DashboardCarouselSection extends StatelessWidget {
  const _DashboardCarouselSection();

  static const List<_DashboardHighlightItem> _highlights = [
    _DashboardHighlightItem(
      title: 'Q3 Financial Revenue Peak',
      subtitle: 'Sales target exceeded by +14.2% with \$124,500.00 total volume.',
      badge: 'Financial Highlight',
      icon: AppIcons.trendingUp,
    ),
    _DashboardHighlightItem(
      title: 'Inventory Reorder Alert',
      subtitle: '18 active purchase orders in transit across main warehouses.',
      badge: 'Supply Chain',
      icon: AppIcons.box,
    ),
    _DashboardHighlightItem(
      title: 'Automated Voucher Sync',
      subtitle: 'All real-time receipt & payment voucher ledgers fully synchronized.',
      badge: 'Real-time Ledger',
      icon: AppIcons.wallet,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.sm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: AppSpacing.xs),
            child: Text(
              'Enterprise Highlights',
              style: AppTypography.sectionTitle(context),
            ),
          ),
          AppCarousel<_DashboardHighlightItem>(
            height: 156,
            autoplay: true,
            autoplaySpeed: const Duration(seconds: 5),
            items: _highlights,
            itemBuilder: (context, item, index) {
              return AppSurface(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.sm,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                      children: [
                        AppStatusBadge(
                          label: item.badge,
                          tone: AppStatusTone.info,
                          animate: false,
                        ),
                        const Spacer(),
                        Icon(item.icon, size: 20, color: AppColors.primaryBlue),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      item.title,
                      style: AppTypography.bodyBold(context),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item.subtitle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.caption(context),
                    ),
                  ],
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
    return AppSurface(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Modular Clean Architecture Active',
                  style: AppTypography.bodyBold(context),
                ),
                const SizedBox(height: AppSpacing.xxs),
                Text(
                  'System operational • Real-time capability synchronization enabled',
                  style: AppTypography.caption(context),
                ),
              ],
            ),
          ),
          const AppStatusBadge(
            label: 'Online',
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
    return const AppGrid(
      children: [
        _KpiTile(
          title: 'Total Sales',
          value: '\$124,500.00',
          subtitle: '+12.5% this month',
          icon: AppIcons.trendingUp,
          tone: AppStatusTone.success,
        ),
        _KpiTile(
          title: 'Purchases',
          value: '\$45,210.00',
          subtitle: '18 active POs',
          icon: AppIcons.shoppingBag,
          tone: AppStatusTone.info,
        ),
        _KpiTile(
          title: 'Receivables',
          value: '\$18,400.00',
          subtitle: '4 pending invoices',
          icon: AppIcons.wallet,
          tone: AppStatusTone.warning,
        ),
        _KpiTile(
          title: 'Stock Valuation',
          value: '\$310,900.00',
          subtitle: '1,240 inventory items',
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
            alignment: Alignment.centerLeft,
            child: Text(
              value,
              style: AppTypography.numericValue(context),
            ),
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
    final captionStyle = AppTypography.caption(context);
    return AppSection(
      title: 'Recent Activity',
      child: AppCard(
        child: Column(
          children: [
            AppListTile(
              leading: const Icon(AppIcons.receipt, color: AppColors.primaryBlue),
              title: const Text('Sales Invoice #INV-2026-0042'),
              subtitle: const Text('Customer: Acma Trading Co. • \$3,450.00'),
              trailing: Text('10 mins ago', style: captionStyle),
            ),
            const AppDivider(),
            AppListTile(
              leading: const Icon(AppIcons.refresh, color: AppColors.secondaryTeal),
              title: const Text('Stock Transfer #TR-902'),
              subtitle: const Text('Main Warehouse → Retail Branch B'),
              trailing: Text('1 hour ago', style: captionStyle),
            ),
            const AppDivider(),
            AppListTile(
              leading: const Icon(AppIcons.check, color: AppColors.success),
              title: const Text('Receipt Voucher #RCV-1021'),
              subtitle: const Text('Payment received for #INV-2026-0019'),
              trailing: Text('3 hours ago', style: captionStyle),
            ),
          ],
        ),
      ),
    );
  }
}
