import 'package:flutter/widgets.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shadcn;

import '../theme/tokens/app_colors.dart';
import '../theme/tokens/app_radii.dart';

enum AppIconAvatarTone {
  primary,
  secondary,
  success,
  warning,
  error,
  info,
  neutral,
}

enum AppIconAvatarSize { sm, md, lg }

/// Canonical icon tile avatar widget for NexaBiz ERP.
///
/// Displays icons inside structured, rounded surface tiles with
/// soft tint backgrounds and crisp borders built on shadcn theme tokens.
class AppIconAvatar extends StatelessWidget {
  const AppIconAvatar({
    super.key,
    required this.icon,
    this.tone = AppIconAvatarTone.primary,
    this.size = AppIconAvatarSize.md,
    this.customColor,
    this.semanticLabel,
  });

  final IconData icon;
  final AppIconAvatarTone tone;
  final AppIconAvatarSize size;
  final Color? customColor;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final theme = shadcn.Theme.of(context);
    final colorScheme = theme.colorScheme;

    final double dimension = switch (size) {
      AppIconAvatarSize.sm => 36.0,
      AppIconAvatarSize.md => 44.0,
      AppIconAvatarSize.lg => 56.0,
    };

    final double iconSize = switch (size) {
      AppIconAvatarSize.sm => 18.0,
      AppIconAvatarSize.md => 22.0,
      AppIconAvatarSize.lg => 28.0,
    };

    final Color baseColor =
        customColor ??
        switch (tone) {
          AppIconAvatarTone.primary => colorScheme.primary,
          AppIconAvatarTone.secondary => colorScheme.secondary,
          AppIconAvatarTone.success => AppColors.success,
          AppIconAvatarTone.warning => AppColors.warning,
          AppIconAvatarTone.error => colorScheme.destructive,
          AppIconAvatarTone.info => AppColors.info,
          AppIconAvatarTone.neutral => colorScheme.mutedForeground,
        };

    final Color bgColor = baseColor.withValues(alpha: 0.12);
    final Color borderColor = baseColor.withValues(alpha: 0.24);

    final avatarWidget = Container(
      width: dimension,
      height: dimension,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(AppRadii.md),
        border: Border.all(color: borderColor, width: 1.0),
      ),
      child: Center(
        child: Icon(icon, size: iconSize, color: baseColor),
      ),
    );

    if (semanticLabel != null && semanticLabel!.isNotEmpty) {
      return Semantics(label: semanticLabel, image: true, child: avatarWidget);
    }

    return avatarWidget;
  }
}
