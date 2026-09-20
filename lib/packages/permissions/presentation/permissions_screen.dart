import 'package:flutter/widgets.dart';
import 'package:nexabiz_ui/nexabiz_ui.dart';

import '../../../l10n/app_localizations.dart';

/// Informational permission catalog placeholder with no runtime decisions.
class PermissionsScreen extends StatelessWidget {
  const PermissionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return AppPage(
      header: AppPageHeader(
        title: l10n.permissionsTitle,
        subtitle: l10n.permissionsSubtitle,
      ),
      child: AppSection(
        title: l10n.permissionsStatusFoundationOnly,
        children: [
          AppListTile(title: Text(l10n.permissionsResponsibilityCatalog)),
          AppListTile(title: Text(l10n.permissionsResponsibilityRouteIntent)),
          AppListTile(
            title: Text(l10n.permissionsResponsibilityOperationIntent),
          ),
          AppListTile(
            title: Text(l10n.permissionsResponsibilityNoRuntimeGrants),
          ),
        ],
      ),
    );
  }
}
