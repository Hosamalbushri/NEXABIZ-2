import 'package:flutter/widgets.dart';
import 'package:nexabiz_ui/nexabiz_ui.dart';

/// Enterprise Reports screen built strictly using canonical `nexabiz_ui` primitives.
class ReportsScreen extends StatelessWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppDashboardPage(
      title: 'Reports Hub',
      subtitle: 'Financial, Operational, & Analytical Reports',
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppSection(
            title: 'Engine Status',
            child: AppSurface(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Row(
                children: [
                  const Icon(AppIcons.chart, color: AppColors.primaryBlue),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(
                      'Reporting Engine Integration Standby • Clean data adapters ready',
                      style: AppTypography.caption(context),
                    ),
                  ),
                  const AppStatusBadge(
                    label: 'Standby',
                    tone: AppStatusTone.warning,
                    animate: false,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          AppSection(
            title: 'Financial Reports',
            child: AppModuleHubGrid(
              children: [
                AppModuleHubTile(
                  title: 'Trial Balance',
                  subtitle: 'Debit/Credit summaries',
                  icon: AppIcons.wallet,
                  onTap: () {},
                ),
                AppModuleHubTile(
                  title: 'Balance Sheet',
                  subtitle: 'Assets & Liabilities',
                  icon: AppIcons.chart,
                  onTap: () {},
                ),
                AppModuleHubTile(
                  title: 'Profit & Loss',
                  subtitle: 'Income vs Expense',
                  icon: AppIcons.grid,
                  onTap: () {},
                ),
                AppModuleHubTile(
                  title: 'General Ledger Audit',
                  subtitle: 'Journal verification',
                  icon: AppIcons.check,
                  onTap: () {},
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
