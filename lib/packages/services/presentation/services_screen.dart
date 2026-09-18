import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:nexabiz_ui/nexabiz_ui.dart';

import '../../../l10n/app_localizations.dart';

/// Services capability hub built strictly using canonical `nexabiz_ui` primitives.
class ServicesScreen extends StatelessWidget {
  const ServicesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return AppDashboardPage(
      title: l10n.servicesTitle,
      subtitle: l10n.servicesSubtitle,
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppSection(
            title: l10n.servicesDevSection,
            subtitle: l10n.servicesDevSectionSubtitle,
            child: AppModuleHubGrid(
              children: [
                AppModuleHubTile(
                  title: l10n.quickActionComponentGallery,
                  subtitle: l10n.servicesComponentGallerySubtitle,
                  icon: AppIcons.grid,
                  onTap: () {
                    context.push('/gallery');
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          AppSection(
            title: l10n.servicesFinancialSection,
            subtitle: l10n.servicesFinancialSectionSubtitle,
            child: AppModuleHubGrid(
              children: [
                AppModuleHubTile(
                  title: l10n.servicesGeneralLedger,
                  subtitle: l10n.servicesGeneralLedgerSubtitle,
                  icon: AppIcons.bank,
                  onTap: () {},
                ),
                AppModuleHubTile(
                  title: l10n.servicesTreasuryCash,
                  subtitle: l10n.servicesTreasuryCashSubtitle,
                  icon: AppIcons.wallet,
                  onTap: () {},
                ),
                AppModuleHubTile(
                  title: l10n.servicesVoucherBooks,
                  subtitle: l10n.servicesVoucherBooksSubtitle,
                  icon: AppIcons.receipt,
                  onTap: () {},
                ),
                AppModuleHubTile(
                  title: l10n.servicesTaxVat,
                  subtitle: l10n.servicesTaxVatSubtitle,
                  icon: AppIcons.chart,
                  onTap: () {},
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          AppSection(
            title: l10n.servicesSupplyChainSection,
            subtitle: l10n.servicesSupplyChainSectionSubtitle,
            child: AppModuleHubGrid(
              children: [
                AppModuleHubTile(
                  title: l10n.servicesInventoryWarehouses,
                  subtitle: l10n.servicesInventoryWarehousesSubtitle,
                  icon: AppIcons.box,
                  onTap: () {},
                ),
                AppModuleHubTile(
                  title: l10n.servicesSalesBilling,
                  subtitle: l10n.servicesSalesBillingSubtitle,
                  icon: AppIcons.shoppingBag,
                  onTap: () {},
                ),
                AppModuleHubTile(
                  title: l10n.servicesPurchasingPOs,
                  subtitle: l10n.servicesPurchasingPOSubtitle,
                  icon: AppIcons.cart,
                  onTap: () {},
                ),
                AppModuleHubTile(
                  title: l10n.servicesLogisticsShipping,
                  subtitle: l10n.servicesLogisticsShippingSubtitle,
                  icon: AppIcons.refresh,
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
