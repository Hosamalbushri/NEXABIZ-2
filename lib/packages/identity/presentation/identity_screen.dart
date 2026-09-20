import 'package:flutter/widgets.dart';
import 'package:nexabiz_ui/nexabiz_ui.dart';

import '../../../l10n/app_localizations.dart';

/// Describes future identity responsibilities without activating a session.
class IdentityScreen extends StatelessWidget {
  const IdentityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return AppPage(
      header: AppPageHeader(
        title: l10n.identityTitle,
        subtitle: l10n.identitySubtitle,
      ),
      child: AppSection(
        title: l10n.identityStatusFoundationOnly,
        children: [
          AppListTile(title: Text(l10n.identityResponsibilityLocalSession)),
          AppListTile(title: Text(l10n.identityResponsibilityAdminUser)),
          AppListTile(
            title: Text(l10n.identityResponsibilityCompanyMembership),
          ),
          AppListTile(
            title: Text(l10n.identityResponsibilityCompanySwitchEndsSession),
          ),
        ],
      ),
    );
  }
}
