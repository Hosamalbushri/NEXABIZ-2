import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:nexabiz_ui/nexabiz_ui.dart';

import '../../../../l10n/app_localizations.dart';

/// Root Dashboard for the Navigation Test Lab.
/// Serves as the manual test hub featuring test checklists, step-by-step instructions,
/// branch launchers, and event logging controls.
class NavigationTestLabDashboard extends StatefulWidget {
  const NavigationTestLabDashboard({super.key});

  @override
  State<NavigationTestLabDashboard> createState() =>
      _NavigationTestLabDashboardState();
}

class _NavigationTestLabDashboardState
    extends State<NavigationTestLabDashboard> {
  final List<String> _eventLogs = [];

  void _logEvent(String event) {
    setState(() {
      final timestamp = DateTime.now().toIso8601String().substring(11, 19);
      _eventLogs.insert(0, '[$timestamp] $event');
    });
  }

  void _clearLogs() {
    setState(() {
      _eventLogs.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return AppPage(
      header: AppPageHeader(
        title: l10n.navLabTitle,
        subtitle: l10n.navLabSubtitle,
        actions: [
          AppStatusBadge(
            label: l10n.navLabBadge,
            tone: AppStatusTone.info,
            animate: true,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Telemetry Summary Card
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: AppColors.lightBackground,
              borderRadius: AppRadii.radiusMd,
              border: Border.all(color: AppColors.borderLight),
            ),
            child: Column(
              children: [
                _DashRow(
                  label: l10n.navLabTelemetryLabRoot,
                  value: '/dev/navigation',
                ),
                const AppDivider(),
                _DashRow(
                  label: l10n.navLabTelemetryTargetRouter,
                  value: l10n.navLabTargetRouterValue,
                ),
                const AppDivider(),
                _DashRow(
                  label: l10n.navLabTelemetryRootScope,
                  value: l10n.navLabRootScopeValue,
                ),
                const AppDivider(),
                _DashRow(
                  label: l10n.navLabTelemetryStackStrategy,
                  value: l10n.navLabStackStrategyValue,
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),

          // Manual Test Scenarios & Branch Launchers
          AppSection(
            title: l10n.navLabBranchLaunchersSection,
            child: Column(
              children: [
                AppListTile(
                  leading: const Icon(
                    AppIcons.layers,
                    color: AppColors.primaryBlue,
                  ),
                  title: Text(l10n.navLabNestedRootTitle),
                  subtitle: Text(l10n.navLabNestedSubtitle),
                  onTap: () => context.push('/navigation-test-lab'),
                ),
                const AppDivider(),
                AppListTile(
                  leading: const Icon(
                    AppIcons.compass,
                    color: AppColors.primaryBlue,
                  ),
                  title: Text(l10n.navLabBranchATitle),
                  subtitle: Text(l10n.navLabBranchAPath),
                  trailing: AppStatusBadge(
                    label: l10n.navLabFourLevels,
                    tone: AppStatusTone.info,
                    animate: false,
                  ),
                  onTap: () {
                    _logEvent(l10n.navLabEventPushPath('/dev/navigation/a'));
                    context.push('/dev/navigation/a');
                  },
                ),
                const AppDivider(),
                AppListTile(
                  leading: const Icon(
                    AppIcons.compass,
                    color: AppColors.secondaryTeal,
                  ),
                  title: Text(l10n.navLabBranchBTitle),
                  subtitle: Text(l10n.navLabBranchBPath),
                  trailing: AppStatusBadge(
                    label: l10n.navLabThreeLevels,
                    tone: AppStatusTone.success,
                    animate: false,
                  ),
                  onTap: () {
                    _logEvent(l10n.navLabEventPushPath('/dev/navigation/b'));
                    context.push('/dev/navigation/b');
                  },
                ),
                const AppDivider(),
                AppListTile(
                  leading: const Icon(
                    AppIcons.compass,
                    color: AppColors.accentPurple,
                  ),
                  title: Text(l10n.navLabBranchCTitle),
                  subtitle: Text(l10n.navLabBranchCPath),
                  trailing: AppStatusBadge(
                    label: l10n.navLabFourLevels,
                    tone: AppStatusTone.warning,
                    animate: false,
                  ),
                  onTap: () {
                    _logEvent(l10n.navLabEventPushPath('/dev/navigation/c'));
                    context.push('/dev/navigation/c');
                  },
                ),
                const AppDivider(),
                AppListTile(
                  leading: const Icon(AppIcons.box, color: AppColors.warning),
                  title: Text(l10n.navLabBranchParamTitle),
                  subtitle: Text(l10n.navLabParamPath),
                  trailing: AppStatusBadge(
                    label: l10n.navLabParamTestBadge,
                    tone: AppStatusTone.info,
                    animate: false,
                  ),
                  onTap: () {
                    _logEvent(
                      l10n.navLabEventPushPath('/dev/navigation/param/100'),
                    );
                    context.push('/dev/navigation/param/100');
                  },
                ),
                const AppDivider(),
                AppListTile(
                  leading: const Icon(AppIcons.warning, color: AppColors.error),
                  title: Text(l10n.navLabBranchDestructiveTitle),
                  subtitle: Text(l10n.navLabDestructiveComparison),
                  trailing: AppStatusBadge(
                    label: l10n.navLabDemoOnlyBadge,
                    tone: AppStatusTone.error,
                    animate: false,
                  ),
                  onTap: () {
                    _logEvent(
                      l10n.navLabEventPushPath('/dev/navigation/destructive'),
                    );
                    context.push('/dev/navigation/destructive');
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),

          // Manual Test Instructions Summary
          AppSection(
            title: l10n.navLabManualInstructionsSection,
            child: Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: AppColors.lightBackground,
                borderRadius: AppRadii.radiusMd,
                border: Border.all(color: AppColors.borderLight),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.navLabInstructionDeepPush,
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.mutedTextLight,
                    ),
                  ),
                  SizedBox(height: AppSpacing.xs),
                  Text(
                    l10n.navLabInstructionSiblings,
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.mutedTextLight,
                    ),
                  ),
                  SizedBox(height: AppSpacing.xs),
                  Text(
                    l10n.navLabInstructionOverlay,
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.mutedTextLight,
                    ),
                  ),
                  SizedBox(height: AppSpacing.xs),
                  Text(
                    l10n.navLabInstructionRootExit,
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.mutedTextLight,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),

          // Development Navigation Event Log
          AppSection(
            title: l10n.navLabEventLogSection,
            child: Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: AppColors.darkSurface,
                borderRadius: AppRadii.radiusMd,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        l10n.navLabRecentTelemetryEvents,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: AppColors.lightSurface,
                        ),
                      ),
                      AppButton(
                        label: l10n.actionClearLog,
                        variant: AppButtonVariant.text,
                        isCompact: true,
                        onPressed: _clearLogs,
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  if (_eventLogs.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: AppSpacing.sm,
                      ),
                      child: Text(
                        l10n.navLabNoEventsLogged,
                        style: const TextStyle(
                          fontSize: 11,
                          fontStyle: FontStyle.italic,
                          color: AppColors.mutedTextDark,
                        ),
                      ),
                    )
                  else
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        for (final log in _eventLogs.take(5))
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 2.0),
                            child: Text(
                              log,
                              style: const TextStyle(
                                fontSize: 11,
                                fontFamily: 'monospace',
                                color: AppColors.secondaryTeal,
                              ),
                            ),
                          ),
                      ],
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DashRow extends StatelessWidget {
  final String label;
  final String value;
  const _DashRow({required this.label, required this.value});

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
