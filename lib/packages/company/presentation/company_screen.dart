import 'package:flutter/widgets.dart';
import 'package:nexabiz_ui/nexabiz_ui.dart';

import '../../../l10n/app_localizations.dart';

/// Describes future company responsibilities without changing company scope.
class CompanyScreen extends StatelessWidget {
  const CompanyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return AppPage(
      header: AppPageHeader(
        title: l10n.companyTitle,
        subtitle: l10n.companySubtitle,
      ),
      child: AppSection(
        title: l10n.companyStatusFoundationOnly,
        children: [
          AppListTile(title: Text(l10n.companyResponsibilityActiveCompany)),
          AppListTile(title: Text(l10n.companyResponsibilityMembership)),
          AppListTile(title: Text(l10n.companyResponsibilityTenantScope)),
          AppListTile(title: Text(l10n.companyResponsibilitySwitchEndsSession)),
        ],
      ),
    );
  }
}
