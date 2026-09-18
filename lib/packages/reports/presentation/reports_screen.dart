import 'package:flutter/widgets.dart';
import 'package:nexabiz_ui/nexabiz_ui.dart';

import '../../../l10n/app_localizations.dart';

/// Enterprise Reports screen built strictly using canonical `nexabiz_ui` primitives.
class ReportsScreen extends StatelessWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return AppDashboardPage(
      title: l10n.reportsTitle,
      subtitle: l10n.reportsSubtitle,
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppSection(
            title: l10n.reportsEngineStatus,
            child: AppSurface(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Row(
                children: [
                  const Icon(AppIcons.chart, color: AppColors.primaryBlue),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(
                      l10n.reportsEngineStatusBody,
                      style: AppTypography.caption(context),
                    ),
                  ),
                  AppStatusBadge(
                    label: l10n.statusStandby,
                    tone: AppStatusTone.warning,
                    animate: false,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          AppSection(
            title: l10n.reportsFinancialReports,
            child: AppModuleHubGrid(
              children: [
                AppModuleHubTile(
                  title: l10n.reportsTrialBalance,
                  subtitle: l10n.reportsTrialBalanceSubtitle,
                  icon: AppIcons.wallet,
                  onTap: () {},
                ),
                AppModuleHubTile(
                  title: l10n.reportsBalanceSheet,
                  subtitle: l10n.reportsBalanceSheetSubtitle,
                  icon: AppIcons.chart,
                  onTap: () {},
                ),
                AppModuleHubTile(
                  title: l10n.reportsProfitLoss,
                  subtitle: l10n.reportsProfitLossSubtitle,
                  icon: AppIcons.grid,
                  onTap: () {},
                ),
                AppModuleHubTile(
                  title: l10n.reportsGLAudit,
                  subtitle: l10n.reportsGLAuditSubtitle,
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
