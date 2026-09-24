import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:nexabiz_ui/nexabiz_ui.dart';

import '../../../app/authorization/app_permission_gate.dart';
import '../../../app/localization/app_locale_controller.dart';
import '../../../core/authorization/administration/nexabiz_authorization_administration_permissions.dart';
import '../../../core/session/core_session_controller.dart';
import '../../../core/session/nexabiz_session.dart';
import '../../../l10n/app_localizations.dart';

const _supportEmailAddress = 'support@nexabiz.com';

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
            wrapTrailing: false,
            leading: const Icon(
              AppIcons.globe,
              size: 18,
              color: AppColors.primaryBlue,
            ),
            title: Text(l10n.languageEnglish),
            subtitle: Text(l10n.languageEnglishSubtitle),
            trailing: currentCode == 'en'
                ? const Icon(AppIcons.check, size: 16, color: AppColors.success)
                : null,
            onTap: () {
              AppLocaleController.setLocale(const Locale('en'));
              Navigator.of(context, rootNavigator: true).pop();
            },
          ),
          const AppDivider(),
          AppListTile(
            wrapTrailing: false,
            leading: const Icon(
              AppIcons.globe,
              size: 18,
              color: AppColors.secondaryTeal,
            ),
            title: Text(l10n.languageArabic),
            subtitle: Text(l10n.languageArabicSubtitle),
            trailing: currentCode == 'ar'
                ? const Icon(AppIcons.check, size: 16, color: AppColors.success)
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

  void _showQrDialog(
    BuildContext context,
    AppLocalizations l10n,
    NexaBizSession? session,
  ) {
    final companyCode = session?.companyCode ?? '773939279';
    final roleName = session?.role ?? l10n.settingsDefaultRole;
    final userName = session?.userName ?? l10n.settingsDefaultUser;

    AppDialog.show<void>(
      context: context,
      title: l10n.settingsQrTitle,
      description: l10n.settingsQrDescription,
      size: AppDialogSize.small,
      showActions: false,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: AppColors.lightSurface,
              borderRadius: BorderRadius.circular(AppRadius.lg),
              border: Border.all(color: AppColors.borderLight),
            ),
            child: const Icon(
              AppIcons.qr,
              size: 130,
              color: AppColors.darkBackground,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            userName,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 2),
          Text(
            '${l10n.settingsAccountCode}: $companyCode • $roleName',
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.mutedTextLight,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  void _showDeviceManagementDialog(
    BuildContext context,
    AppLocalizations l10n,
    NexaBizSession? session,
  ) {
    final sessionId = session?.sessionId ?? 'sess_local_7739';

    AppDialog.show<void>(
      context: context,
      title: l10n.settingsDeviceManagement,
      description: l10n.settingsDeviceManagementSubtitle,
      size: AppDialogSize.medium,
      showActions: false,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppListTile(
            wrapTrailing: false,
            leading: const Icon(
              AppIcons.sliders,
              size: 18,
              color: AppColors.secondaryTeal,
            ),
            title: Text(l10n.settingsActiveDevice),
            subtitle: Text(l10n.settingsActiveDeviceDesc),
            trailing: AppStatusBadge(
              label: l10n.statusOnline,
              tone: AppStatusTone.success,
              animate: false,
            ),
          ),
          const AppDivider(),
          AppListTile(
            wrapTrailing: false,
            leading: const Icon(
              AppIcons.lock,
              size: 18,
              color: AppColors.primaryBlue,
            ),
            title: Text(l10n.settingsSessionId),
            subtitle: Text(sessionId),
            trailing: AppStatusBadge(
              label: l10n.statusPrimary,
              tone: AppStatusTone.info,
              animate: false,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileHeaderCard(
    BuildContext context,
    AppLocalizations l10n,
    NexaBizSession? session,
    bool isDark,
  ) {
    final userName = session?.userName ?? l10n.settingsDefaultUser;
    final companyCode = session?.companyCode ?? '773939279';
    final roleName = session?.role ?? l10n.settingsDefaultRole;

    return AppSurface(
      variant: AppSurfaceVariant.outlined,
      padding: const EdgeInsets.all(AppSpacing.sm),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Sleek 54px circular avatar
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isDark ? AppColors.darkSurface : AppColors.lightBackground,
              border: Border.all(
                color: isDark ? AppColors.borderDark : AppColors.borderLight,
                width: 1.5,
              ),
            ),
            child: const Center(
              child: Icon(
                AppIcons.user,
                size: 26,
                color: AppColors.primaryBlue,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            userName,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
          ),
          if (session?.companyName != null) ...[
            const SizedBox(height: 2),
            Text(
              session!.companyName!,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.mutedTextLight,
              ),
            ),
          ],
          const SizedBox(height: AppSpacing.sm),
          // Compact Stats & QR row
          AppSurface(
            variant: AppSurfaceVariant.flat,
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.sm,
              vertical: 6.0,
            ),
            borderRadius: BorderRadius.circular(AppRadius.md),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        l10n.settingsAccountCode,
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppColors.mutedTextLight,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        companyCode,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
                Container(
                  width: 1,
                  height: 24,
                  color: isDark ? AppColors.borderDark : AppColors.borderLight,
                ),
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        l10n.settingsRoleLabel,
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppColors.mutedTextLight,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        roleName,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: AppSpacing.xs),
                GestureDetector(
                  onTap: () => _showQrDialog(context, l10n, session),
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: AppColors.error,
                      borderRadius: BorderRadius.circular(AppRadius.sm),
                    ),
                    child: const Center(
                      child: Icon(
                        AppIcons.qr,
                        color: AppColors.lightSurface,
                        size: 18,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final session = sessionController?.currentSession;

    return ValueListenableBuilder(
      valueListenable: AppThemeController.themeModeNotifier,
      builder: (context, themeMode, _) {
        final isDark = AppThemeController.isDark(context);
        final currentLangName =
            AppLocaleController.currentLocale.languageCode == 'ar'
            ? l10n.languageArabic
            : l10n.languageEnglish;

        return AppSettingsPage(
          title: l10n.settingsTitle,
          subtitle: l10n.settingsSubtitle,
          sections: [
            // 1. Executive / Profile Header Card
            _buildProfileHeaderCard(context, l10n, session, isDark),

            // 2. Offline Sync Card (Standalone action)
            AppCard(
              padding: EdgeInsets.zero,
              child: AppListTile(
                wrapTrailing: false,
                leading: const Icon(
                  AppIcons.refresh,
                  size: 18,
                  color: AppColors.primaryBlue,
                ),
                title: Text(l10n.settingsOfflineSync),
                subtitle: Text(l10n.settingsOfflineSyncSubtitle),
                trailing: AppStatusBadge(
                  label: l10n.statusSynced,
                  tone: AppStatusTone.success,
                  animate: false,
                ),
                onTap: () {
                  showAppSnackBar(
                    context,
                    message: l10n.settingsOfflineSyncSubtitle,
                    isSuccess: true,
                  );
                },
              ),
            ),

            // 3. Device & Session Management (Standalone action)
            AppCard(
              padding: EdgeInsets.zero,
              child: AppListTile(
                wrapTrailing: false,
                leading: const Icon(
                  AppIcons.sliders,
                  size: 18,
                  color: AppColors.secondaryTeal,
                ),
                title: Text(l10n.settingsDeviceManagement),
                subtitle: Text(l10n.settingsDeviceManagementSubtitle),
                trailing: Icon(AppIcons.chevronForward(context), size: 14),
                onTap: () =>
                    _showDeviceManagementDialog(context, l10n, session),
              ),
            ),

            // 4. Company Profile Accordion Card
            AppAccordionCard(
              initiallyExpanded: true,
              leading: const Icon(
                AppIcons.bank,
                size: 18,
                color: AppColors.primaryBlue,
              ),
              title: Text(l10n.settingsCompanyProfileSection),
              subtitle: Text(
                session?.companyName ?? l10n.settingsCompanyProfileSubtitle,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AppListTile(
                    wrapTrailing: false,
                    leading: const Icon(
                      AppIcons.building,
                      size: 16,
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
                    wrapTrailing: false,
                    leading: const Icon(
                      AppIcons.layers,
                      size: 16,
                      color: AppColors.accentPurple,
                    ),
                    title: Text(l10n.companySelectionTitle),
                    subtitle: Text(l10n.companySelectionSubtitle),
                    trailing: Icon(AppIcons.chevronForward(context), size: 14),
                    onTap: () => context.push('/company-selection'),
                  ),
                  const AppDivider(),
                  AppListTile(
                    wrapTrailing: false,
                    leading: const Icon(
                      AppIcons.wallet,
                      size: 16,
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

            // 5. Security & Access Controls (Permission-gated Accordion)
            AppPermissionGate(
              permissionId:
                  NexaBizAuthorizationAdministrationPermissions.policyReview,
              child: AppAccordionCard(
                leading: const Icon(
                  AppIcons.shield,
                  size: 18,
                  color: AppColors.primaryBlue,
                ),
                title: Text(l10n.settingsSecurityControls),
                subtitle: Text(l10n.settingsSecurityControlsSubtitle),
                child: AppListTile(
                  wrapTrailing: false,
                  leading: const Icon(
                    AppIcons.lock,
                    size: 16,
                    color: AppColors.primaryBlue,
                  ),
                  title: Text(l10n.settingsSecurityControls),
                  subtitle: Text(l10n.settingsSecurityControlsSubtitle),
                  trailing: Icon(AppIcons.chevronForward(context), size: 14),
                  onTap: () => context.push('/permissions/roles'),
                ),
              ),
            ),

            // 6. Application Preferences & Customization Accordion Card
            AppAccordionCard(
              initiallyExpanded: true,
              leading: const Icon(
                AppIcons.palette,
                size: 18,
                color: AppColors.accentPurple,
              ),
              title: Text(l10n.settingsAppPreferencesSection),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AppListTile(
                    wrapTrailing: false,
                    leading: const Icon(
                      AppIcons.sparkles,
                      size: 16,
                      color: AppColors.accentPurple,
                    ),
                    title: Text(l10n.settingsDarkMode),
                    subtitle: Text(
                      isDark
                          ? l10n.settingsDarkModeOn
                          : l10n.settingsDarkModeOff,
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
                    wrapTrailing: false,
                    leading: const Icon(
                      AppIcons.globe,
                      size: 16,
                      color: AppColors.primaryBlue,
                    ),
                    title: Text(l10n.settingsLanguage),
                    subtitle: Text(currentLangName),
                    trailing: Icon(AppIcons.chevronForward(context), size: 14),
                    onTap: () => _showLanguageSelector(context),
                  ),
                ],
              ),
            ),

            // 7. Developer & Design System Tools Accordion Card
            AppAccordionCard(
              leading: const Icon(
                AppIcons.settings,
                size: 18,
                color: AppColors.secondaryTeal,
              ),
              title: Text(l10n.settingsDevToolsSection),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AppListTile(
                    wrapTrailing: false,
                    leading: const Icon(
                      AppIcons.layers,
                      size: 16,
                      color: AppColors.accentPurple,
                    ),
                    title: Text(l10n.settingsNavTestLab),
                    subtitle: Text(l10n.settingsNavTestLabSubtitle),
                    trailing: Icon(AppIcons.chevronForward(context), size: 14),
                    onTap: () => context.push('/dev/navigation'),
                  ),
                  const AppDivider(),
                  AppListTile(
                    wrapTrailing: false,
                    leading: const Icon(
                      AppIcons.grid,
                      size: 16,
                      color: AppColors.primaryBlue,
                    ),
                    title: Text(l10n.settingsGallery),
                    subtitle: Text(l10n.settingsGallerySubtitle),
                    trailing: Icon(AppIcons.chevronForward(context), size: 14),
                    onTap: () => context.push('/gallery'),
                  ),
                ],
              ),
            ),

            // 8. Help & Support Accordion Card
            AppAccordionCard(
              leading: const Icon(
                AppIcons.circleHelp,
                size: 18,
                color: AppColors.secondaryTeal,
              ),
              title: Text(l10n.settingsHelpSupport),
              subtitle: Text(l10n.settingsHelpSupportSubtitle),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AppListTile(
                    wrapTrailing: false,
                    leading: const Icon(
                      AppIcons.circleHelp,
                      size: 16,
                      color: AppColors.primaryBlue,
                    ),
                    title: Text(l10n.settingsSupportTitle),
                    subtitle: Text(l10n.settingsSupportVersion),
                    trailing: AppStatusBadge(
                      label: l10n.statusOnline,
                      tone: AppStatusTone.success,
                      animate: false,
                    ),
                  ),
                  const AppDivider(),
                  AppListTile(
                    wrapTrailing: false,
                    leading: const Icon(
                      AppIcons.mail,
                      size: 16,
                      color: AppColors.secondaryTeal,
                    ),
                    title: const Text(_supportEmailAddress),
                    subtitle: Text(l10n.settingsSupportAssistance),
                    trailing: Icon(AppIcons.chevronForward(context), size: 14),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}
