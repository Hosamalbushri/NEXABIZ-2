import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:nexabiz_ui/nexabiz_ui.dart';

import '../../../../l10n/app_localizations.dart';
import '../navigation_test_lab_capability.dart';

/// Reusable canonical node page for Navigation Test Lab deep route trees.
/// Strictly uses [AppPage] and [nexabiz_ui] design tokens.
class NavigationTestNodeScreen extends StatelessWidget {
  final String nodeName;
  final String routePath;
  final String parentPath;
  final int depth;
  final String branch;
  final List<TestNodeChild> children;

  const NavigationTestNodeScreen({
    super.key,
    required this.nodeName,
    required this.routePath,
    required this.parentPath,
    required this.depth,
    required this.branch,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return AppPage(
      header: AppPageHeader(
        title: nodeName,
        subtitle: l10n.navLabNodeSubtitle(branch, depth.toString()),
        actions: [
          AppStatusBadge(
            label: l10n.navLabBranchBadge(branch),
            tone: branch == 'A'
                ? AppStatusTone.info
                : branch == 'B'
                ? AppStatusTone.success
                : AppStatusTone.warning,
            animate: false,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Telemetry Card (Current Route Instrumentation)
          AppSection(
            title: l10n.navLabNodeTelemetry,
            child: Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: AppColors.lightBackground,
                borderRadius: AppRadii.radiusMd,
                border: Border.all(color: AppColors.borderLight),
              ),
              child: Column(
                children: [
                  _TelemetryRow(label: l10n.navLabNodeName, value: nodeName),
                  const AppDivider(),
                  _TelemetryRow(label: l10n.navLabRoutePath, value: routePath),
                  const AppDivider(),
                  _TelemetryRow(
                    label: l10n.navLabParentRoute,
                    value: parentPath,
                  ),
                  const AppDivider(),
                  _TelemetryRow(label: l10n.navLabStackDepth, value: '$depth'),
                  const AppDivider(),
                  _TelemetryRow(label: l10n.navLabBranch, value: branch),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),

          // Child Navigation Actions
          if (children.isNotEmpty) ...[
            AppSection(
              title: l10n.navLabChildNavigationPush,
              child: Column(
                children: [
                  for (final childNode in children) ...[
                    AppListTile(
                      leading: const Icon(
                        AppIcons.chevronRight,
                        color: AppColors.primaryBlue,
                      ),
                      title: Text(childNode.label),
                      subtitle: Text(l10n.navLabPushPath(childNode.path)),
                      trailing: AppStatusBadge(
                        label: l10n.navLabPushBadge,
                        tone: AppStatusTone.neutral,
                        animate: false,
                      ),
                      onTap: () {
                        context.push(childNode.path);
                      },
                    ),
                    const AppDivider(),
                  ],
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
          ],

          // Stack & Overlay Action Controls
          AppSection(
            title: l10n.navLabTestControls,
            child: Column(
              children: [
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
                const AppDivider(),
                AppListTile(
                  leading: const Icon(
                    AppIcons.shield,
                    color: AppColors.accentPurple,
                  ),
                  title: Text(l10n.navLabOpenTestDialog),
                  subtitle: Text(l10n.navLabOpenTestDialogSubtitle),
                  onTap: () async {
                    await AppDialog.confirm(
                      context: context,
                      title: l10n.navLabTestOverlayDialogTitle,
                      message: l10n.navLabTestOverlayDialogMessage,
                      confirmLabel: l10n.actionOk,
                      cancelLabel: l10n.actionClose,
                      tone: AppDialogTone.info,
                    );
                  },
                ),
                const AppDivider(),
                AppListTile(
                  leading: const Icon(
                    AppIcons.plus,
                    color: AppColors.secondaryTeal,
                  ),
                  title: Text(l10n.navLabOpenTestSheet),
                  subtitle: Text(l10n.navLabOpenTestSheetSubtitle),
                  onTap: () async {
                    await AppQuickActionsPanel.show<void>(
                      context,
                      title: l10n.navLabTestSheetTitle,
                      subtitle: l10n.navLabTestSheetSubtitle,
                      items: [
                        AppQuickActionItem(
                          label: l10n.navLabSampleAction,
                          icon: AppIcons.info,
                          onTap: () {},
                        ),
                      ],
                    );
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

class _TelemetryRow extends StatelessWidget {
  final String label;
  final String value;
  const _TelemetryRow({required this.label, required this.value});

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
