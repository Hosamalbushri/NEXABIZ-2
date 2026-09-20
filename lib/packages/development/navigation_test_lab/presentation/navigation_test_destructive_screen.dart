import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:nexabiz_ui/nexabiz_ui.dart';

import '../../../../l10n/app_localizations.dart';

/// Destructive Navigation Test Page.
/// Clearly demarcates stack-altering operations (context.go / replace)
/// from normal history-preserving navigation (context.push).
class NavigationTestDestructiveScreen extends StatelessWidget {
  const NavigationTestDestructiveScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return AppPage(
      header: AppPageHeader(
        title: l10n.navLabDestructiveTitle,
        subtitle: l10n.navLabDestructiveSubtitle,
        actions: [
          AppStatusBadge(
            label: l10n.navLabDestructiveBadge,
            tone: AppStatusTone.error,
            animate: false,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: AppColors.errorContainer,
              borderRadius: AppRadii.radiusMd,
              border: Border.all(color: AppColors.error),
            ),
            child: Row(
              children: [
                const Icon(AppIcons.warning, color: AppColors.error),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    l10n.navLabDestructiveWarning,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.error,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),

          AppSection(
            title: l10n.navLabStackReplacementDemos,
            child: Column(
              children: [
                AppListTile(
                  leading: const Icon(AppIcons.refresh, color: AppColors.error),
                  title: Text(l10n.navLabReplaceA11),
                  subtitle: Text(l10n.navLabReplaceA11Subtitle),
                  trailing: AppStatusBadge(
                    label: l10n.navLabReplaceBadge,
                    tone: AppStatusTone.error,
                    animate: false,
                  ),
                  onTap: () {
                    context.go('/dev/navigation/a/a1/a1-1');
                  },
                ),
                const AppDivider(),
                AppListTile(
                  leading: const Icon(
                    AppIcons.dashboard,
                    color: AppColors.error,
                  ),
                  title: Text(l10n.navLabResetLab),
                  subtitle: Text(l10n.navLabResetLabSubtitle),
                  trailing: AppStatusBadge(
                    label: l10n.navLabResetBadge,
                    tone: AppStatusTone.error,
                    animate: false,
                  ),
                  onTap: () {
                    context.go('/dev/navigation');
                  },
                ),
                const AppDivider(),
                AppListTile(
                  leading: const Icon(AppIcons.check, color: AppColors.success),
                  title: Text(l10n.navLabPreserveA11),
                  subtitle: Text(l10n.navLabPreserveA11Subtitle),
                  trailing: AppStatusBadge(
                    label: l10n.navLabPushBadge,
                    tone: AppStatusTone.success,
                    animate: false,
                  ),
                  onTap: () {
                    context.push('/dev/navigation/a/a1/a1-1');
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
