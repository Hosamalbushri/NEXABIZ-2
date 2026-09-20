import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:nexabiz_ui/nexabiz_ui.dart';

import '../../../core/setup/initialize_nexabiz_core.dart';
import '../../../core/setup/nexabiz_setup_readiness.dart';
import '../../../l10n/app_localizations.dart';

/// Dedicated Core-only first-run form; persistence stays in the use case.
class SystemSetupScreen extends StatefulWidget {
  const SystemSetupScreen({super.key, this.initializer, this.readiness});

  final InitializeNexaBizCore? initializer;
  final NexaBizSetupReadiness? readiness;

  @override
  State<SystemSetupScreen> createState() => _SystemSetupScreenState();
}

class _SystemSetupScreenState extends State<SystemSetupScreen> {
  final _companyCode = TextEditingController();
  final _companyName = TextEditingController();
  final _adminName = TextEditingController();
  final _adminEmail = TextEditingController();
  final _password = TextEditingController();
  final _confirmation = TextEditingController();
  CoreInitializationFailure? _failure;
  bool _mismatch = false;
  bool _busy = false;

  @override
  void dispose() {
    _companyCode.dispose();
    _companyName.dispose();
    _adminName.dispose();
    _adminEmail.dispose();
    _password.dispose();
    _confirmation.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final initializer = widget.initializer;
    if (initializer == null || _busy) return;

    final companyCode = _companyCode.text;
    final companyName = _companyName.text;
    final adminName = _adminName.text;
    final adminEmail = _adminEmail.text;
    final password = _password.text;
    final confirmation = _confirmation.text;

    if (password != confirmation) {
      setState(() {
        _mismatch = true;
        _failure = null;
      });
      return;
    }

    setState(() {
      _busy = true;
      _mismatch = false;
      _failure = null;
    });

    try {
      await initializer(
        CoreInitializationInput(
          companyCode: companyCode,
          companyName: companyName,
          adminName: adminName,
          adminEmail: adminEmail,
          password: password,
        ),
      );
      if (mounted) {
        _password.clear();
        _confirmation.clear();
        // First-run completion is a root transition; it requires authentication next.
        context.go('/login');
      }
    } on CoreInitializationException catch (error) {
      if (mounted) setState(() => _failure = error.failure);
    } catch (_) {
      if (mounted) {
        setState(() => _failure = CoreInitializationFailure.storageFailure);
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final state = widget.readiness?.state;
    final blocked =
        state == NexaBizSetupState.inProgress ||
        state == NexaBizSetupState.blocked;
    final error = _mismatch
        ? l10n.setupPasswordMismatch
        : switch (_failure) {
            CoreInitializationFailure.invalidInput => l10n.setupValidation,
            CoreInitializationFailure.alreadyInitialized =>
              l10n.setupAlreadyInitialized,
            CoreInitializationFailure.recoveryRequired =>
              l10n.setupRecoveryRequired,
            CoreInitializationFailure.credentialFailure =>
              l10n.setupCredentialFailure,
            CoreInitializationFailure.storageFailure =>
              l10n.setupStorageFailure,
            null => null,
          };

    return AppFormPage(
      title: l10n.systemSetupTitle,
      subtitle: l10n.systemSetupSubtitle,
      showBackButton: false,
      submitLabel: l10n.setupCreate,
      isLoading: _busy,
      errorText: blocked
          ? l10n.setupRecoveryRequired
          : state == NexaBizSetupState.ready
          ? l10n.setupAlreadyInitialized
          : null,
      onSubmit: blocked || state == NexaBizSetupState.ready ? null : _submit,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (error != null) ...[
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              margin: const EdgeInsets.only(bottom: AppSpacing.md),
              decoration: BoxDecoration(
                color: AppColors.errorContainer,
                borderRadius: BorderRadius.circular(AppSpacing.sm),
                border: Border.all(color: AppColors.error),
              ),
              child: Text(
                error,
                style: const TextStyle(
                  color: AppColors.error,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
          AppTextField(
            controller: _companyCode,
            label: l10n.setupCompanyCode,
            required: true,
            textInputAction: TextInputAction.next,
          ),
          const SizedBox(height: AppSpacing.md),
          AppTextField(
            controller: _companyName,
            label: l10n.setupCompanyName,
            required: true,
            textInputAction: TextInputAction.next,
          ),
          const SizedBox(height: AppSpacing.md),
          AppTextField(
            controller: _adminName,
            label: l10n.setupAdminName,
            required: true,
            textInputAction: TextInputAction.next,
          ),
          const SizedBox(height: AppSpacing.md),
          AppTextField(
            controller: _adminEmail,
            label: l10n.setupAdminEmail,
            required: true,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
          ),
          const SizedBox(height: AppSpacing.md),
          AppTextField(
            controller: _password,
            label: l10n.setupPassword,
            required: true,
            obscureText: true,
            textInputAction: TextInputAction.next,
          ),
          const SizedBox(height: AppSpacing.md),
          AppTextField(
            controller: _confirmation,
            label: l10n.setupConfirmPassword,
            required: true,
            obscureText: true,
            textInputAction: TextInputAction.done,
            onSubmitted: (_) => _submit(),
          ),
        ],
      ),
    );
  }
}
