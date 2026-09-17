import 'package:flutter/widgets.dart';
import 'package:nexabiz_ui/nexabiz_ui.dart';

/// Settings & Configuration screen built strictly using canonical `nexabiz_ui` component definitions.
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppSettingsPage(
      title: 'Settings & Configuration',
      subtitle: 'Application preferences and enterprise profile management',
      sections: [
        AppSection(
          title: 'Application Preferences',
          child: AppCard(
            child: Column(
              children: [
                ValueListenableBuilder(
                  valueListenable: AppThemeController.themeModeNotifier,
                  builder: (context, mode, _) {
                    final isDark = AppThemeController.isDark(context);
                    return AppListTile(
                      leading: const Icon(AppIcons.settings),
                      title: const Text('Dark Mode'),
                      subtitle: Text(
                          isDark ? 'Dark theme enabled' : 'Light theme enabled'),
                      trailing: AppSwitch(
                        value: isDark,
                        onChanged: (val) {
                          AppThemeController.toggleTheme(val);
                        },
                      ),
                    );
                  },
                ),
                const AppDivider(),
                AppListTile(
                  leading: const Icon(AppIcons.globe),
                  title: const Text('Language & Localization'),
                  subtitle: const Text('English (US)'),
                  trailing: const Icon(AppIcons.chevronRight),
                  onTap: () {},
                ),
              ],
            ),
          ),
        ),
        AppSection(
          title: 'Company & Currency Profile',
          child: AppCard(
            child: Column(
              children: [
                AppListTile(
                  leading: const Icon(AppIcons.building),
                  title: const Text('Company Profile'),
                  subtitle: const Text('NexaBiz Enterprise Corp.'),
                  trailing: const Icon(AppIcons.chevronRight),
                  onTap: () {},
                ),
                const AppDivider(),
                const AppListTile(
                  leading: Icon(AppIcons.wallet),
                  title: Text('Functional Currency'),
                  subtitle: Text('USD - United States Dollar'),
                  trailing: AppStatusBadge(
                    label: 'Primary',
                    tone: AppStatusTone.info,
                    animate: false,
                  ),
                ),
              ],
            ),
          ),
        ),
        AppSection(
          title: 'Security & Sync',
          child: AppCard(
            child: Column(
              children: [
                AppListTile(
                  leading: const Icon(AppIcons.shield),
                  title: const Text('Security & Access Controls'),
                  subtitle: const Text('Manage user roles and capability permissions'),
                  trailing: const Icon(AppIcons.chevronRight),
                  onTap: () {},
                ),
                const AppDivider(),
                const AppListTile(
                  leading: Icon(AppIcons.refresh),
                  title: Text('Offline Sync & Storage'),
                  subtitle: Text('All local databases up to date'),
                  trailing: AppStatusBadge(
                    label: 'Synced',
                    tone: AppStatusTone.success,
                    animate: false,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
