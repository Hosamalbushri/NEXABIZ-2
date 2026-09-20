import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:nexabiz_ui/nexabiz_ui.dart';

import '../../../app/localization/app_locale_controller.dart';
import '../../../core/session/core_session_controller.dart';
import '../../../l10n/app_localizations.dart';

/// Settings & Configuration screen built strictly using canonical `nexabiz_ui` primitives.
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key, this.sessionController});

  final CoreSessionController? sessionController;

  void _showLanguageSelector(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final currentCode = AppLocaleController.currentLocale.languageCode;

    AppDialog.show<void>(
      context: context,
      title: l10n.settingsLanguageSelectTitle,
      size: AppDialogSize.small,
      showActions: false,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AppListTile(
            leading: const Icon(AppIcons.globe, color: AppColors.primaryBlue),
            title: Text(l10n.languageEnglish),
            subtitle: Text(l10n.languageEnglishSubtitle),
            trailing: currentCode == 'en'
                ? const Icon(AppIcons.check, color: AppColors.success)
                : null,
            onTap: () {
              AppLocaleController.setLocale(const Locale('en'));
              Navigator.of(context, rootNavigator: true).pop();
            },
          ),
          const AppDivider(),
          AppListTile(
            leading: const Icon(AppIcons.globe, color: AppColors.secondaryTeal),
            title: Text(l10n.languageArabic),
            subtitle: Text(l10n.languageArabicSubtitle),
            trailing: currentCode == 'ar'
                ? const Icon(AppIcons.check, color: AppColors.success)
                : null,
            onTap: () {
              AppLocaleController.setLocale(const Locale('ar'));
              Navigator.of(context, rootNavigator: true).pop();
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final session = sessionController?.currentSession;

    return AppDashboardPage(
      title: l10n.settingsTitle,
      subtitle: l10n.settingsSubtitle,
      content: ValueListenableBuilder(
        valueListenable: AppThemeController.themeModeNotifier,
        builder: (context, themeMode, _) {
          final isDark = AppThemeController.isDark(context);
          final currentLangName = AppLocaleController.isRtl
              ? l10n.languageArabic
              : l10n.languageEnglish;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppSection(
                title: l10n.settingsDevToolsSection,
                child: Column(
                  children: [
                    AppListTile(
                      leading: const Icon(
                        AppIcons.layers,
                        color: AppColors.accentPurple,
                      ),
                      title: Text(l10n.settingsNavTestLab),
                      subtitle: Text(l10n.settingsNavTestLabSubtitle),
                      trailing: const Icon(
                        AppIcons.chevronRight,
                        size: 16,
                      ),
                      onTap: () => context.push('/dev/navigation'),
                    ),
                    const AppDivider(),
                    AppListTile(
                      leading: const Icon(
                        AppIcons.grid,
                        color: AppColors.primaryBlue,
                      ),
                      title: Text(l10n.settingsGallery),
                      subtitle: Text(l10n.settingsGallerySubtitle),
                      trailing: const Icon(
                        AppIcons.chevronRight,
                        size: 16,
                      ),
                      onTap: () => context.push('/gallery'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              AppSection(
                title: l10n.settingsAppPreferencesSection,
                child: Column(
                  children: [
                    AppListTile(
                      leading: const Icon(
                        AppIcons.settings,
                        color: AppColors.secondaryTeal,
                      ),
                      title: Text(l10n.settingsDarkMode),
                      subtitle: Text(
                        isDark ? l10n.settingsDarkModeOn : l10n.settingsDarkModeOff,
                      ),
                      trailing: AppSwitch(
                        value: isDark,
                        onChanged: (val) {
                          AppThemeController.toggleTheme(val);
                        },
                      ),
                    ),
                    const AppDivider(),
                    AppListTile(
                      leading: const Icon(
                        AppIcons.globe,
                        color: AppColors.primaryBlue,
                      ),
                      title: Text(l10n.settingsLanguage),
                      subtitle: Text(currentLangName),
                      trailing: const Icon(
                        AppIcons.chevronRight,
                        size: 16,
                      ),
                      onTap: () => _showLanguageSelector(context),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              AppSection(
                title: l10n.settingsCompanyProfileSection,
                child: Column(
                  children: [
                    AppListTile(
                      leading: const Icon(
                        AppIcons.bank,
                        color: AppColors.primaryBlue,
                      ),
                      title: Text(
                        session?.companyName ?? l10n.settingsCompanyProfile,
                      ),
                      subtitle: Text(
                        session?.companyCode != null
                            ? '${session!.companyCode} • ${l10n.companySelectionCurrentRole(session.role ?? "")}'
                            : l10n.settingsCompanyProfileSubtitle,
                      ),
                      trailing: session?.hasActiveCompany == true
                          ? AppStatusBadge(
                              label: l10n.statusPrimary,
                              tone: AppStatusTone.success,
                            )
                          : null,
                    ),
                    const AppDivider(),
                    AppListTile(
                      leading: const Icon(
                        AppIcons.layers,
                        color: AppColors.accentPurple,
                      ),
                      title: Text(l10n.companySelectionTitle),
                      subtitle: Text(l10n.companySelectionSubtitle),
                      trailing: const Icon(
                        AppIcons.chevronRight,
                        size: 16,
                      ),
                      onTap: () => context.push('/company-selection'),
                    ),
                    const AppDivider(),
                    AppListTile(
                      leading: const Icon(
                        AppIcons.wallet,
                        color: AppColors.secondaryTeal,
                      ),
                      title: Text(l10n.settingsFunctionalCurrency),
                      subtitle: Text(l10n.settingsFunctionalCurrencySubtitle),
                      trailing: AppStatusBadge(
                        label: l10n.statusPrimary,
                        tone: AppStatusTone.info,
                        animate: false,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              AppSection(
                title: l10n.settingsSecuritySyncSection,
                child: Column(
                  children: [
                    AppListTile(
                      leading: const Icon(
                        AppIcons.check,
                        color: AppColors.success,
                      ),
                      title: Text(l10n.settingsSecurityControls),
                      subtitle: Text(l10n.settingsSecurityControlsSubtitle),
                    ),
                    const AppDivider(),
                    AppListTile(
                      leading: const Icon(
                        AppIcons.refresh,
                        color: AppColors.primaryBlue,
                      ),
                      title: Text(l10n.settingsOfflineSync),
                      subtitle: Text(l10n.settingsOfflineSyncSubtitle),
                      trailing: AppStatusBadge(
                        label: l10n.statusSynced,
                        tone: AppStatusTone.success,
                        animate: false,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
