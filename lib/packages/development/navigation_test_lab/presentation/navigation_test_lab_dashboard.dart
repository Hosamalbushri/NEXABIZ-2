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
                _DashRow(label: l10n.navLabTelemetryLabRoot, value: '/dev/navigation'),
                const AppDivider(),
                _DashRow(label: l10n.navLabTelemetryTargetRouter, value: 'Production GoRouter'),
                const AppDivider(),
                _DashRow(label: l10n.navLabTelemetryRootScope, value: 'AppExitPopScope'),
                const AppDivider(),
                _DashRow(label: l10n.navLabTelemetryStackStrategy, value: 'PUSH (Stack Preserving)'),
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
                  leading: const Icon(AppIcons.compass, color: AppColors.primaryBlue),
                  title: Text(l10n.navLabBranchATitle),
                  subtitle: const Text('Path: /dev/navigation/a -> A1 -> A1.1 -> A1.1.1'),
                  trailing: const AppStatusBadge(
                    label: '4 Levels',
                    tone: AppStatusTone.info,
                    animate: false,
                  ),
                  onTap: () {
                    _logEvent('PUSH -> /dev/navigation/a');
                    context.push('/dev/navigation/a');
                  },
                ),
                const AppDivider(),
                AppListTile(
                  leading: const Icon(AppIcons.compass, color: AppColors.secondaryTeal),
                  title: Text(l10n.navLabBranchBTitle),
                  subtitle: const Text('Path: /dev/navigation/b -> B1 -> B1.2 / B2.1'),
                  trailing: const AppStatusBadge(
                    label: '3 Levels',
                    tone: AppStatusTone.success,
                    animate: false,
                  ),
                  onTap: () {
                    _logEvent('PUSH -> /dev/navigation/b');
                    context.push('/dev/navigation/b');
                  },
                ),
                const AppDivider(),
                AppListTile(
                  leading: const Icon(AppIcons.compass, color: AppColors.accentPurple),
                  title: Text(l10n.navLabBranchCTitle),
                  subtitle: const Text('Path: /dev/navigation/c -> C1 -> C1.1 -> C1.1.1'),
                  trailing: const AppStatusBadge(
                    label: '4 Levels',
                    tone: AppStatusTone.warning,
                    animate: false,
                  ),
                  onTap: () {
                    _logEvent('PUSH -> /dev/navigation/c');
                    context.push('/dev/navigation/c');
                  },
                ),
                const AppDivider(),
                AppListTile(
                  leading: const Icon(AppIcons.box, color: AppColors.warning),
                  title: Text(l10n.navLabBranchParamTitle),
                  subtitle: const Text('Path: /dev/navigation/param/100 & 200'),
                  trailing: const AppStatusBadge(
                    label: 'Param Test',
                    tone: AppStatusTone.info,
                    animate: false,
                  ),
                  onTap: () {
                    _logEvent('PUSH -> /dev/navigation/param/100');
                    context.push('/dev/navigation/param/100');
                  },
                ),
                const AppDivider(),
                AppListTile(
                  leading: const Icon(AppIcons.warning, color: AppColors.error),
                  title: Text(l10n.navLabBranchDestructiveTitle),
                  subtitle: const Text('Explicit REPLACE (context.go) vs PUSH comparison'),
                  trailing: const AppStatusBadge(
                    label: 'Demo Only',
                    tone: AppStatusTone.error,
                    animate: false,
                  ),
                  onTap: () {
                    _logEvent('PUSH -> /dev/navigation/destructive');
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
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '1. Deep Push: Open Branch A -> A1 -> A1.1 -> A1.1.1. Press Android Back 4 times. Verify each parent node restores without exit dialog.',
                    style: TextStyle(fontSize: 12, color: AppColors.mutedTextLight),
                  ),
                  SizedBox(height: AppSpacing.xs),
                  Text(
                    '2. Siblings: Open A1 -> A1.1 -> Back -> A1.2 -> Back. Verify Node A1 is perfectly restored.',
                    style: TextStyle(fontSize: 12, color: AppColors.mutedTextLight),
                  ),
                  SizedBox(height: AppSpacing.xs),
                  Text(
                    '3. Overlay: On any node, tap "Open Test Dialog" or "Open Test Sheet". Press Android Back. Verify overlay closes and current route remains active.',
                    style: TextStyle(fontSize: 12, color: AppColors.mutedTextLight),
                  ),
                  SizedBox(height: AppSpacing.xs),
                  Text(
                    '4. Root Exit: Pop back to true app root (/dashboard). Press Android Back. Verify "Exit Application" dialog appears.',
                    style: TextStyle(fontSize: 12, color: AppColors.mutedTextLight),
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
                      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
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
