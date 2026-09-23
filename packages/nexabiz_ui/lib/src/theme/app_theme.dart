import 'package:flutter/material.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shadcn;

import 'app_colors.dart';
import 'app_typography.dart';

/// Central Design System Theme Architecture for NexaBiz ERP.
///
/// Built on top of [shadcn_flutter] as the sole canonical visual authority.
class AppTheme {
  const AppTheme._();

  /// Canonical theme data accessor from current context.
  static shadcn.ThemeData of(BuildContext context) => shadcn.Theme.of(context);

  /// Canonical Native shadcn_flutter Light ThemeData
  static shadcn.ThemeData light({
    double radius = 0.5,
    double surfaceOpacity = 0.95,
    double surfaceBlur = 4.0,
    shadcn.Density density = shadcn.Density.defaultDensity,
  }) {
    final baseColorScheme = shadcn.ColorSchemes.lightSlate;
    return shadcn.ThemeData(
      colorScheme: baseColorScheme.copyWith(
        primary: () => AppColors.primaryBlue,
        primaryForeground: () => Colors.white,
        secondary: () => AppColors.secondaryTeal,
        secondaryForeground: () => Colors.white,
        background: () => AppColors.lightBackground,
        card: () => AppColors.lightSurface,
        popover: () => AppColors.lightSurface,
        border: () => AppColors.borderLight,
        input: () => AppColors.borderLight,
        ring: () => AppColors.primaryBlue,
        destructive: () => AppColors.error,
        destructiveForeground: () => Colors.white,
      ),
      typography: AppTypography.shadcnTypography(),
      density: density,
      radius: radius,
      surfaceOpacity: surfaceOpacity,
      surfaceBlur: surfaceBlur,
    );
  }

  /// Canonical Native shadcn_flutter Dark ThemeData
  static shadcn.ThemeData dark({
    double radius = 0.5,
    double surfaceOpacity = 0.95,
    double surfaceBlur = 4.0,
    shadcn.Density density = shadcn.Density.defaultDensity,
  }) {
    final baseColorScheme = shadcn.ColorSchemes.darkSlate;
    return shadcn.ThemeData.dark(
      colorScheme: baseColorScheme.copyWith(
        primary: () => AppColors.primaryBlue,
        primaryForeground: () => Colors.white,
        secondary: () => AppColors.secondaryTeal,
        secondaryForeground: () => Colors.white,
        background: () => AppColors.darkBackground,
        card: () => AppColors.darkSurface,
        popover: () => AppColors.darkSurface,
        border: () => AppColors.borderDark,
        input: () => AppColors.borderDark,
        ring: () => AppColors.primaryBlue,
        destructive: () => AppColors.error,
        destructiveForeground: () => Colors.white,
      ),
      typography: AppTypography.shadcnTypography(),
      density: density,
      radius: radius,
      surfaceOpacity: surfaceOpacity,
      surfaceBlur: surfaceBlur,
    );
  }

  /// Backwards-compatible alias for light shadcn theme.
  static shadcn.ThemeData shadcnLight({
    double radius = 0.5,
    double surfaceOpacity = 0.95,
    double surfaceBlur = 4.0,
    shadcn.Density density = shadcn.Density.defaultDensity,
  }) => light(
    radius: radius,
    surfaceOpacity: surfaceOpacity,
    surfaceBlur: surfaceBlur,
    density: density,
  );

  /// Backwards-compatible alias for dark shadcn theme.
  static shadcn.ThemeData shadcnDark({
    double radius = 0.5,
    double surfaceOpacity = 0.95,
    double surfaceBlur = 4.0,
    shadcn.Density density = shadcn.Density.defaultDensity,
  }) => dark(
    radius: radius,
    surfaceOpacity: surfaceOpacity,
    surfaceBlur: surfaceBlur,
    density: density,
  );

  /// Supplementary Material ThemeData for infrastructure interoperability.
  static ThemeData materialLight() {
    const colorScheme = ColorScheme(
      brightness: Brightness.light,
      primary: AppColors.primaryBlue,
      onPrimary: Colors.white,
      secondary: AppColors.secondaryTeal,
      onSecondary: Colors.white,
      error: AppColors.error,
      onError: Colors.white,
      surface: AppColors.lightSurface,
      onSurface: Color(0xFF0F172A),
      surfaceContainer: AppColors.lightBackground,
      surfaceContainerLow: AppColors.lightBackground,
      surfaceContainerHigh: Color(0xFFF1F5F9),
      surfaceContainerHighest: Color(0xFFE2E8F0),
      onSurfaceVariant: AppColors.mutedTextLight,
      outline: Color(0xFFCBD5E1),
      outlineVariant: AppColors.borderLight,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: AppColors.lightBackground,
      canvasColor: AppColors.lightSurface,
      cardColor: AppColors.lightSurface,
      dividerColor: AppColors.borderLight,
      fontFamily: AppTypography.fontFamily,
    );
  }

  /// Supplementary Material ThemeData for infrastructure interoperability.
  static ThemeData materialDark() {
    const colorScheme = ColorScheme(
      brightness: Brightness.dark,
      primary: AppColors.primaryBlue,
      onPrimary: Colors.white,
      secondary: AppColors.secondaryTeal,
      onSecondary: Colors.white,
      error: AppColors.error,
      onError: Colors.white,
      surface: AppColors.darkSurface,
      onSurface: Color(0xFFF8FAFC),
      surfaceContainer: AppColors.darkBackground,
      surfaceContainerLow: AppColors.darkBackground,
      surfaceContainerHigh: Color(0xFF334155),
      surfaceContainerHighest: Color(0xFF475569),
      onSurfaceVariant: AppColors.mutedTextDark,
      outline: Color(0xFF64748B),
      outlineVariant: AppColors.borderDark,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: AppColors.darkBackground,
      canvasColor: AppColors.darkSurface,
      cardColor: AppColors.darkSurface,
      dividerColor: AppColors.borderDark,
      fontFamily: AppTypography.fontFamily,
    );
  }
}
