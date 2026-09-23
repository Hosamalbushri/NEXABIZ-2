import 'package:flutter/services.dart';
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
  DateTime? _lockoutExpiresAt;
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
        _lockoutExpiresAt = null;
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _invalidInput = false;
      _authStatus = null;
      _lockoutExpiresAt = null;
    });

    try {
      final result = await controller.login(
        CoreAuthenticationInput(identifier: identifier, password: password),
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
          _lockoutExpiresAt = result.lockoutExpiresAt;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _authStatus = CoreAuthenticationStatus.storageFailure;
          _lockoutExpiresAt = null;
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

  String _resolveLockoutMessage(AppLocalizations l10n) {
    final expiresAt = _lockoutExpiresAt;
    if (expiresAt != null) {
      final now = DateTime.now().toUtc();
      final remaining = expiresAt.toUtc().difference(now);
      if (remaining.inMinutes >= 1) {
        final minutes =
            remaining.inMinutes + (remaining.inSeconds % 60 > 0 ? 1 : 0);
        return l10n.loginLockedOutMinutes(minutes);
      } else if (remaining.inSeconds > 0) {
        return l10n.loginLockedOutSeconds(remaining.inSeconds);
      }
    }
    return l10n.loginLockedOut;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = AppTheme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = AppThemeController.isDark(context);
    final bgSurface = isDark
        ? AppColors.darkBackground
        : AppColors.lightBackground;

    final errorText = _invalidInput
        ? l10n.loginValidation
        : switch (_authStatus) {
            CoreAuthenticationStatus.invalidCredentials =>
              l10n.loginInvalidCredentials,
            CoreAuthenticationStatus.userInactive => l10n.loginUserInactive,
            CoreAuthenticationStatus.noActiveMemberships =>
              l10n.loginNoCompanies,
            CoreAuthenticationStatus.lockedOut => _resolveLockoutMessage(l10n),
            CoreAuthenticationStatus.storageFailure => l10n.loginStorageFailure,
            _ => null,
          };

    return AppPage(
      scrollable: false,
      padding: EdgeInsets.zero,
      maxWidth: double.infinity,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Background Canvas with Deep Gradient
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: bgSurface,
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    bgSurface,
                    Color.alphaBlend(
                      colorScheme.primary.withValues(alpha: 0.08),
                      bgSurface,
                    ),
                    Color.alphaBlend(
                      AppColors.tertiaryIndigo.withValues(alpha: 0.05),
                      bgSurface,
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Top End Ambient Light Glow
          PositionedDirectional(
            top: -100,
            end: -100,
            child: IgnorePointer(
              child: Container(
                width: 340,
                height: 340,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      colorScheme.primary.withValues(alpha: 0.22),
                      colorScheme.primary.withValues(alpha: 0.0),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Bottom Start Ambient Light Glow
          PositionedDirectional(
            bottom: -90,
            start: -90,
            child: IgnorePointer(
              child: Container(
                width: 300,
                height: 300,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      AppColors.tertiaryIndigo.withValues(alpha: 0.18),
                      AppColors.tertiaryIndigo.withValues(alpha: 0.0),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Main Content Area
          Center(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.lg,
              ),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 580),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Enterprise Brand Emblem Banner
                    Center(
                      child: Column(
                        children: [
                          Container(
                            width: 84,
                            height: 84,
                            decoration: BoxDecoration(
                              color: colorScheme.primary,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: colorScheme.primary.withValues(
                                  alpha: 0.3,
                                ),
                                width: 3,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: colorScheme.primary.withValues(
                                    alpha: 0.35,
                                  ),
                                  blurRadius: 30,
                                  offset: const Offset(0, 10),
                                ),
                              ],
                            ),
                            child: Center(
                              child: Icon(
                                AppIcons.shield,
                                size: 42,
                                color: colorScheme.primaryForeground,
                              ),
                            ),
                          ),
                          const SizedBox(height: AppSpacing.md),
                          Text(
                            l10n.appName,
                            style: AppTypography.pageTitle(context).copyWith(
                              fontWeight: FontWeight.w900,
                              letterSpacing: -0.5,
                              color: colorScheme.foreground,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.xxs),
                          Text(
                            l10n.authAppSubtitle,
                            textAlign: TextAlign.center,
                            style: AppTypography.bodyMedium(context).copyWith(
                              color: colorScheme.mutedForeground,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: AppSpacing.xl),

                    // Glassmorphic Card Container
                    Container(
                      padding: const EdgeInsets.all(AppSpacing.lg),
                      decoration: BoxDecoration(
                        color:
                            (isDark
                                    ? AppColors.darkSurface
                                    : AppColors.lightSurface)
                                .withValues(alpha: isDark ? 0.90 : 0.98),
                        borderRadius: BorderRadius.circular(28),
                        border: Border.all(
                          color: colorScheme.primary.withValues(
                            alpha: isDark ? 0.25 : 0.15,
                          ),
                          width: 1.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.shadow.withValues(
                              alpha: isDark ? 0.40 : 0.08,
                            ),
                            blurRadius: 40,
                            spreadRadius: -2,
                            offset: const Offset(0, 20),
                          ),
                          BoxShadow(
                            color: colorScheme.primary.withValues(
                              alpha: isDark ? 0.15 : 0.06,
                            ),
                            blurRadius: 24,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Error Alert Banner
                          if (errorText != null) ...[
                            Container(
                              padding: const EdgeInsets.all(AppSpacing.sm + 2),
                              decoration: BoxDecoration(
                                color: AppColors.errorContainer.withValues(
                                  alpha: 0.7,
                                ),
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                  color: AppColors.error.withValues(alpha: 0.4),
                                ),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    AppIcons.warning,
                                    color: AppColors.error,
                                    size: 22,
                                  ),
                                  const SizedBox(width: AppSpacing.sm),
                                  Expanded(
                                    child: Text(
                                      errorText,
                                      style: AppTypography.bodySmall(context)
                                          .copyWith(
                                            color: AppColors.error,
                                            fontWeight: FontWeight.w600,
                                          ),
                                    ),
                                  ),
                                  const SizedBox(width: AppSpacing.xs),
                                  AppButton(
                                    label: l10n.loginRetry,
                                    variant: AppButtonVariant.text,
                                    isCompact: true,
                                    onPressed: () => setState(() {
                                      _authStatus = null;
                                      _invalidInput = false;
                                      _lockoutExpiresAt = null;
                                    }),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: AppSpacing.md),
                          ],

                          // Email / Identifier Field
                          AppTextField(
                            controller: _identifierController,
                            label: l10n.loginIdentifier,
                            prefixIcon: AppIcons.mail,
                            density: AppFieldDensity.large,
                            required: true,
                            textInputAction: TextInputAction.next,
                            onChanged: (_) {
                              if (_invalidInput || _authStatus != null) {
                                setState(() {
                                  _invalidInput = false;
                                  _authStatus = null;
                                  _lockoutExpiresAt = null;
                                });
                              }
                            },
                          ),

                          const SizedBox(height: AppSpacing.md),

                          // Password Field
                          AppTextField(
                            controller: _passwordController,
                            label: l10n.loginPassword,
                            prefixIcon: AppIcons.lock,
                            density: AppFieldDensity.large,
                            required: true,
                            obscureText: true,
                            showPasswordToggle: true,
                            textInputAction: TextInputAction.done,
                            onSubmitted: (_) => _handleLogin(),
                            onChanged: (_) {
                              if (_invalidInput || _authStatus != null) {
                                setState(() {
                                  _invalidInput = false;
                                  _authStatus = null;
                                  _lockoutExpiresAt = null;
                                });
                              }
                            },
                          ),

                          const SizedBox(height: AppSpacing.lg),

                          // Sign In Action Button
                          AppButton(
                            label: l10n.loginSubmit,
                            expand: true,
                            isLoading: _isLoading,
                            onPressed: _isLoading ? null : _handleLogin,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: AppSpacing.xl),

                    // Enterprise Security Footer
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.sm,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              AppIcons.lock,
                              size: 14,
                              color: colorScheme.mutedForeground.withValues(
                                alpha: 0.7,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Flexible(
                              child: Text(
                                l10n.authFooterNote,
                                textAlign: TextAlign.center,
                                style: AppTypography.caption(context).copyWith(
                                  color: colorScheme.mutedForeground.withValues(
                                    alpha: 0.7,
                                  ),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
