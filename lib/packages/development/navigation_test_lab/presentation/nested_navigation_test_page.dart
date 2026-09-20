import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:nexabiz_ui/nexabiz_ui.dart';

import '../../../../app/localization/app_locale_controller.dart';
import '../../../../l10n/app_localizations.dart';

enum NestedNavigationTestNode { root, details, audit, settings, advanced }

/// Manual verification surface for nested route and locale behavior.
class NestedNavigationTestPage extends StatelessWidget {
  const NestedNavigationTestPage({super.key, required this.node});

  final NestedNavigationTestNode node;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final title = switch (node) {
      NestedNavigationTestNode.root => l10n.navLabNestedRootTitle,
      NestedNavigationTestNode.details => l10n.navLabNestedDetailsTitle,
      NestedNavigationTestNode.audit => l10n.navLabNestedAuditTitle,
      NestedNavigationTestNode.settings => l10n.navLabNestedSettingsTitle,
      NestedNavigationTestNode.advanced => l10n.navLabNestedAdvancedTitle,
    };
    final destination = switch (node) {
      NestedNavigationTestNode.root => '/navigation-test-lab/details',
      NestedNavigationTestNode.details => '/navigation-test-lab/details/audit',
      NestedNavigationTestNode.settings =>
        '/navigation-test-lab/settings/advanced',
      _ => null,
    };
    final destinationLabel = switch (node) {
      NestedNavigationTestNode.root => l10n.navLabNestedOpenDetails,
      NestedNavigationTestNode.details => l10n.navLabNestedOpenAudit,
      NestedNavigationTestNode.settings => l10n.navLabNestedOpenAdvanced,
      _ => null,
    };

    return AppPage(
      header: AppPageHeader(title: title, subtitle: l10n.navLabNestedSubtitle),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppSection(
            title: l10n.navLabNestedActionsTitle,
            child: Column(
              children: [
                if (destination != null && destinationLabel != null)
                  AppListTile(
                    title: Text(destinationLabel),
                    subtitle: Text(destination),
                    onTap: () => context.push(destination),
                  ),
                if (node == NestedNavigationTestNode.root)
                  AppListTile(
                    title: Text(l10n.navLabNestedOpenSettings),
                    subtitle: const Text('/navigation-test-lab/settings'),
                    onTap: () => context.push('/navigation-test-lab/settings'),
                  ),
                AppListTile(
                  title: Text(l10n.navLabNestedToggleLanguage),
                  onTap: () => AppLocaleController.toggleLanguage(),
                ),
                if (context.canPop())
                  AppListTile(
                    title: Text(l10n.navLabBackPop),
                    onTap: () => context.pop(),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
