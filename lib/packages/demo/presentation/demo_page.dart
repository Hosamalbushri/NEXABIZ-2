import 'package:flutter/widgets.dart';
import 'package:nexabiz_ui/nexabiz_ui.dart';

import '../../../l10n/app_localizations.dart';

class DemoPage extends StatelessWidget {
  const DemoPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return AppDashboardPage(
      title: l10n.demoTitle,
      subtitle: l10n.demoSubtitle,
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppSurface(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: AppStatusBadge(
                          label: l10n.demoBadge,
                          tone: AppStatusTone.success,
                          animate: false,
                        ),
                      ),
                      const Icon(AppIcons.check, color: AppColors.success),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    l10n.demoDescription,
                    style: AppTypography.body(context),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            AppSection(
              title: l10n.demoArchPrinciples,
              subtitle: l10n.demoArchPrinciplesSubtitle,
              child: AppCard(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(l10n.demoArchPrinciple1, style: AppTypography.body(context)),
                    const SizedBox(height: AppSpacing.xs),
                    Text(l10n.demoArchPrinciple2, style: AppTypography.body(context)),
                    const SizedBox(height: AppSpacing.xs),
                    Text(l10n.demoArchPrinciple3, style: AppTypography.body(context)),
                    const SizedBox(height: AppSpacing.xs),
                    Text(l10n.demoArchPrinciple4, style: AppTypography.body(context)),
                    const SizedBox(height: AppSpacing.xs),
                    Text(l10n.demoArchPrinciple5, style: AppTypography.body(context)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Row(
              children: [
                Expanded(
                  child: AppButton(
                    label: l10n.actionSystemReady,
                    variant: AppButtonVariant.filled,
                    onPressed: () {},
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: AppButton(
                    label: l10n.actionDocumentation,
                    variant: AppButtonVariant.outlined,
                    onPressed: () {},
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
