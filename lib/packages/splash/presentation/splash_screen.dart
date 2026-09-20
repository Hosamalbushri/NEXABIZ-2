import 'package:flutter/widgets.dart';
import 'package:nexabiz_ui/nexabiz_ui.dart';

import '../../../l10n/app_localizations.dart';

/// Canonical startup splash screen adhering to NexaBiz UI contracts.
///
/// Serves as the initial safe route while GoRouter central redirect logic
/// resolves core readiness, session state, and target destination.
class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return AppPage(
      header: AppPageHeader(
        title: l10n.splashTitle,
        subtitle: l10n.splashSubtitle,
        showBackButton: false,
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const AppLoading(
              style: AppLoadingStyle.circular,
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              l10n.splashSubtitle,
              style: const TextStyle(
                color: AppColors.mutedTextLight,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
