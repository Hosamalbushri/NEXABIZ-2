import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:nexabiz_ui/nexabiz_ui.dart';

import '../../../../l10n/app_localizations.dart';

/// Parameterized route test page (`/dev/navigation/param/:id`).
class NavigationTestParamScreen extends StatelessWidget {
  final String itemId;

  const NavigationTestParamScreen({super.key, required this.itemId});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final routePath = '/dev/navigation/param/$itemId';

    return AppPage(
      header: AppPageHeader(
        title: l10n.navLabParamTitle(itemId),
        subtitle: l10n.navLabParamSubtitle,
        actions: [
          AppStatusBadge(
            label: l10n.navLabParamRouteBadge,
            tone: AppStatusTone.info,
            animate: false,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppSection(
            title: l10n.navLabParamTelemetry,
            child: Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: AppColors.lightBackground,
                borderRadius: AppRadii.radiusMd,
                border: Border.all(color: AppColors.borderLight),
              ),
              child: Column(
                children: [
                  _Row(label: l10n.navLabParamId, value: itemId),
                  const AppDivider(),
                  _Row(label: l10n.navLabRoutePath, value: routePath),
                  const AppDivider(),
                  _Row(label: l10n.navLabParentRoute, value: '/dev/navigation'),
                  const AppDivider(),
                  _Row(label: l10n.navLabStackDepth, value: '2'),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          AppSection(
            title: l10n.navLabParamActions,
            child: Column(
              children: [
                AppListTile(
                  leading: const Icon(
                    AppIcons.box,
                    color: AppColors.primaryBlue,
                  ),
                  title: Text(l10n.navLabNavigateToItem100),
                  subtitle: Text(
                    l10n.navLabPushPath('/dev/navigation/param/100'),
                  ),
                  onTap: () {
                    context.push('/dev/navigation/param/100');
                  },
                ),
                const AppDivider(),
                AppListTile(
                  leading: const Icon(
                    AppIcons.box,
                    color: AppColors.secondaryTeal,
                  ),
                  title: Text(l10n.navLabNavigateToItem200),
                  subtitle: Text(
                    l10n.navLabPushPath('/dev/navigation/param/200'),
                  ),
                  onTap: () {
                    context.push('/dev/navigation/param/200');
                  },
                ),
                const AppDivider(),
                AppListTile(
                  leading: const Icon(
                    AppIcons.chevronLeft,
                    color: AppColors.mutedTextLight,
                  ),
                  title: Text(l10n.navLabBackPop),
                  subtitle: Text(l10n.navLabBackPopSubtitle),
                  onTap: () {
                    if (context.canPop()) {
                      context.pop();
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Row extends StatelessWidget {
  final String label;
  final String value;
  const _Row({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: AppColors.mutedTextLight,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: AppColors.darkBackground,
            ),
          ),
        ],
      ),
    );
  }
}
