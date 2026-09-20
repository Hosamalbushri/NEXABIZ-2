import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:nexabiz_ui/nexabiz_ui.dart';

import '../../../core/identity/authenticate_local_user.dart';
import '../../../core/session/core_session_controller.dart';
import '../../../l10n/app_localizations.dart';

/// Screen allowing authenticated user to select an active company workspace.
class CompanySelectionScreen extends StatefulWidget {
  const CompanySelectionScreen({super.key, this.sessionController});

  final CoreSessionController? sessionController;

  @override
  State<CompanySelectionScreen> createState() => _CompanySelectionScreenState();
}

class _CompanySelectionScreenState extends State<CompanySelectionScreen> {
  bool _isLoading = false;
  bool _hasError = false;

  Future<void> _selectCompany(String companyId) async {
    final controller = widget.sessionController;
    if (controller == null || _isLoading) return;

    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    try {
      final success = await controller.selectOrSwitchCompany(companyId);
      if (!mounted) return;

      if (success) {
        context.go('/dashboard');
      } else {
        setState(() {
          _hasError = true;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _hasError = true;
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _handleLogout() {
    widget.sessionController?.logout();
    context.go('/login');
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final session = widget.sessionController?.currentSession;
    final companies = session?.availableCompanies ?? const <CoreAuthCompanyRef>[];

    return AppListPage<CoreAuthCompanyRef>(
      title: l10n.companySelectionTitle,
      subtitle: l10n.companySelectionSubtitle,
      showBackButton: false,
      items: companies,
      isLoading: _isLoading,
      errorText: _hasError ? l10n.setupStorageFailure : null,
      headerActions: [
        AppButton(
          label: l10n.actionLogout,
          variant: AppButtonVariant.text,
          onPressed: _handleLogout,
        ),
      ],
      contentBuilder: (context, items) {
        return ListView.separated(
          padding: const EdgeInsets.all(AppSpacing.md),
          itemCount: items.length,
          separatorBuilder: (context, index) => const SizedBox(height: AppSpacing.sm),
          itemBuilder: (context, index) {
            final company = items[index];
            final isCurrent = session?.companyId?.value == company.id;

            return AppListTile(
              title: Text(company.name),
              subtitle: Text(
                '${company.code} • ${l10n.companySelectionCurrentRole(company.role)}',
              ),
              trailing: isCurrent
                  ? AppStatusBadge(
                      label: l10n.statusPrimary,
                      tone: AppStatusTone.success,
                    )
                  : AppButton(
                      label: l10n.loginSubmit,
                      onPressed: () => _selectCompany(company.id),
                    ),
              onTap: () => _selectCompany(company.id),
            );
          },
        );
      },
    );
  }
}
