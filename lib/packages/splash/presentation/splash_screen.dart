import 'package:flutter/widgets.dart';
import 'package:nexabiz_ui/nexabiz_ui.dart';

import '../../../l10n/app_localizations.dart';

/// Canonical startup splash screen adhering to NexaBiz UI contracts.
///
/// Serves as the initial safe route while GoRouter central redirect logic
/// resolves core readiness, session state, and target destination.
class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  static const String _iconAsset =
      'assets/branding/app_icon/nexabiz_legacy_icon_1024.png';

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = AppTheme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = AppThemeController.isDark(context);
    final bgSurface = isDark
        ? AppColors.darkBackground
        : AppColors.lightBackground;

    return AppPage(
      scrollable: false,
      padding: EdgeInsets.zero,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Ambient linear background gradient
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    bgSurface,
                    bgSurface,
                    Color.alphaBlend(
                      colorScheme.primary.withValues(alpha: 0.05),
                      bgSurface,
                    ),
                  ],
                  stops: const [0.0, 0.55, 1.0],
                ),
              ),
            ),
          ),

          // Glowing Ambient Orbs
          PositionedDirectional(
            top: -80,
            start: -60,
            child: IgnorePointer(
              child: Container(
                width: 220,
                height: 220,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: colorScheme.primary.withValues(alpha: 0.10),
                ),
              ),
            ),
          ),
          PositionedDirectional(
            bottom: 40,
            end: -50,
            child: IgnorePointer(
              child: Container(
                width: 180,
                height: 180,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: colorScheme.secondary.withValues(alpha: 0.08),
                ),
              ),
            ),
          ),

          // Center Brand Content
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.xl,
                vertical: AppSpacing.lg,
              ),
              child: Column(
                children: [
                  const Spacer(flex: 3),
                  DecoratedBox(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(AppRadii.lg),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.shadow.withValues(
                            alpha: isDark ? 0.35 : 0.12,
                          ),
                          blurRadius: 28,
                          offset: const Offset(0, 12),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(AppRadii.lg),
                      child: Image.asset(
                        _iconAsset,
                        width: 96,
                        height: 96,
                        filterQuality: FilterQuality.high,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Text(
                    l10n.splashTitle,
                    textAlign: TextAlign.center,
                    style: AppTypography.pageTitle(context).copyWith(
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.8,
                      height: 1.1,
                      color: colorScheme.foreground,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    l10n.authAppSubtitle,
                    textAlign: TextAlign.center,
                    style: AppTypography.sectionTitle(context).copyWith(
                      fontWeight: FontWeight.w500,
                      letterSpacing: 0.2,
                      color: colorScheme.mutedForeground,
                      height: 1.35,
                    ),
                  ),
                  const Spacer(flex: 4),
                  const SizedBox(
                    width: 22,
                    height: 22,
                    child: AppLoading(
                      style: AppLoadingStyle.circular,
                      showMessage: false,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    l10n.splashSubtitle,
                    textAlign: TextAlign.center,
                    style: AppTypography.caption(
                      context,
                    ).copyWith(letterSpacing: 0.3),
                  ),
                  const SizedBox(height: AppSpacing.md),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
