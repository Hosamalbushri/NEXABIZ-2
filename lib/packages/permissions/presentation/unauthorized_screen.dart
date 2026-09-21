import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:nexabiz_ui/nexabiz_ui.dart';

import '../../../l10n/app_localizations.dart';

/// Minimal access denied screen rendered when a route's permission requirement fails.
class UnauthorizedScreen extends StatelessWidget {
  const UnauthorizedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return AppPage(
      header: AppPageHeader(
        title: l10n.unauthorizedTitle,
        subtitle: l10n.unauthorizedMessage,
      ),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AppButton(
                label: l10n.actionBackToDashboard,
                variant: AppButtonVariant.filled,
                onPressed: () {
                  if (context.canPop()) {
                    context.pop();
                  } else {
                    context.go('/dashboard');
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
