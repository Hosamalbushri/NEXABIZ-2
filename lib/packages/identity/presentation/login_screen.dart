import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:nexabiz_ui/nexabiz_ui.dart';

import '../../../core/identity/authenticate_local_user.dart';
import '../../../core/session/core_session_controller.dart';
import '../../../l10n/app_localizations.dart';

/// Canonical identity login screen adhering to NexaBiz UI contracts.
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key, this.sessionController});

  final CoreSessionController? sessionController;

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _identifierController = TextEditingController();
  final _passwordController = TextEditingController();

  CoreAuthenticationStatus? _authStatus;
  bool _invalidInput = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _identifierController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    final controller = widget.sessionController;
    if (controller == null || _isLoading) return;

    final identifier = _identifierController.text.trim();
    final password = _passwordController.text;

    if (identifier.isEmpty || password.isEmpty) {
      setState(() {
        _invalidInput = true;
        _authStatus = null;
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _invalidInput = false;
      _authStatus = null;
    });

    try {
      final result = await controller.login(
        CoreAuthenticationInput(
          identifier: identifier,
          password: password,
        ),
      );

      if (!mounted) return;

      if (result.isSuccess) {
        _passwordController.clear();
        final session = controller.currentSession;
        if (session.requiresCompanySelection) {
          context.go('/company-selection');
        } else {
          context.go('/dashboard');
        }
      } else {
        setState(() {
          _authStatus = result.status;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _authStatus = CoreAuthenticationStatus.invalidCredentials;
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

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    final errorText = _invalidInput
        ? l10n.loginValidation
        : switch (_authStatus) {
            CoreAuthenticationStatus.invalidCredentials =>
              l10n.loginInvalidCredentials,
            CoreAuthenticationStatus.userInactive => l10n.loginUserInactive,
            CoreAuthenticationStatus.noActiveMemberships =>
              l10n.loginNoCompanies,
            _ => null,
          };

    return AppFormPage(
      title: l10n.loginTitle,
      subtitle: l10n.loginSubtitle,
      showBackButton: false,
      submitLabel: l10n.loginSubmit,
      isLoading: _isLoading,
      errorText: errorText,
      onSubmit: _handleLogin,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppTextField(
            controller: _identifierController,
            label: l10n.loginIdentifier,
            required: true,
          ),
          const SizedBox(height: AppSpacing.md),
          AppTextField(
            controller: _passwordController,
            label: l10n.loginPassword,
            required: true,
            obscureText: true,
          ),
        ],
      ),
    );
  }
}
