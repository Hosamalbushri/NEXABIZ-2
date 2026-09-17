import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:nexabiz_ui/nexabiz_ui.dart';

/// Services capability hub built strictly using canonical `nexabiz_ui` primitives.
class ServicesScreen extends StatelessWidget {
  const ServicesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppDashboardPage(
      title: 'Services Hub',
      subtitle: 'Available Business Capabilities & Service Launchers',
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppSection(
            title: 'System & Developer Tools',
            subtitle: 'UI design system and component playground',
            child: AppModuleHubGrid(
              children: [
                AppModuleHubTile(
                  title: 'Component Gallery',
                  subtitle: 'Interactive shadcn_flutter playground',
                  icon: AppIcons.grid,
                  onTap: () {
                    context.go('/gallery');
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          AppSection(
            title: 'Financial & Accounting',
            subtitle: 'Core financial management tools',
            child: AppModuleHubGrid(
              children: [
                AppModuleHubTile(
                  title: 'General Ledger',
                  subtitle: 'Journal entries & COA',
                  icon: AppIcons.bank,
                  onTap: () {},
                ),
                AppModuleHubTile(
                  title: 'Treasury & Cash',
                  subtitle: 'Bank accounts & cash flow',
                  icon: AppIcons.wallet,
                  onTap: () {},
                ),
                AppModuleHubTile(
                  title: 'Voucher Books',
                  subtitle: 'Document numbering & books',
                  icon: AppIcons.receipt,
                  onTap: () {},
                ),
                AppModuleHubTile(
                  title: 'Tax & VAT',
                  subtitle: 'Tax rates & reporting',
                  icon: AppIcons.chart,
                  onTap: () {},
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          AppSection(
            title: 'Supply Chain & Commerce',
            subtitle: 'Inventory valuation, purchasing, & sales operations',
            child: AppModuleHubGrid(
              children: [
                AppModuleHubTile(
                  title: 'Inventory & Warehouses',
                  subtitle: 'Stock balances & transfers',
                  icon: AppIcons.box,
                  onTap: () {},
                ),
                AppModuleHubTile(
                  title: 'Sales & Billing',
                  subtitle: 'Invoices, orders & customers',
                  icon: AppIcons.shoppingBag,
                  onTap: () {},
                ),
                AppModuleHubTile(
                  title: 'Purchasing & POs',
                  subtitle: 'Purchase orders & suppliers',
                  icon: AppIcons.cart,
                  onTap: () {},
                ),
                AppModuleHubTile(
                  title: 'Logistics & Shipping',
                  subtitle: 'Shipment tracking & dispatch',
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
