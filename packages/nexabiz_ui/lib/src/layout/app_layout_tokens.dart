import 'package:flutter/widgets.dart';

import '../theme/tokens/app_spacing.dart';

/// Single authoritative source for layout dimensions, max widths, gaps, and spacing tokens across NexaBiz.
class AppLayoutTokens {
  const AppLayoutTokens._();

  // Content Max Widths (px)
  static const double maxPageWidth = 1400.0;
  static const double maxFormWidth = 720.0;
  static const double maxWideFormWidth = 1000.0;
  static const double maxTableWidth = 1600.0;
  static const double maxDashboardWidth = 1600.0;
  static const double maxDetailsWidth = 1400.0;
  static const double maxSettingsWidth = 1000.0;

  // Page Level Spacing (px)
  static const double pagePaddingCompact = AppSpacing.sm;
  static const double pagePaddingStandard = AppSpacing.md;
  static const double pagePaddingSpacious = AppSpacing.lg;
  static const double pageHeaderGap = 20.0;

  // Section Spacing (px)
  static const double sectionGap = AppSpacing.lg;
  static const double sectionTitleGap = AppSpacing.sm;
  static const double sectionInnerGap = AppSpacing.md;
  static const double sectionPadding = AppSpacing.md;

  // Form Spacing (px)
  static const double formFieldGap = AppSpacing.md;
  static const double formGroupGap = AppSpacing.lg;
  static const double formActionsGap = AppSpacing.md;
  static const double formSectionGap = 20.0;
  static const double formColumnMinWidth = 280.0;
  static const int formMaxColumns = 3;
  static const double actionStackMaxWidth = 480.0;
  static const double sectionHeaderStackMaxWidth = 520.0;

  // Table Spacing (px)
  static const double tableToolbarGap = AppSpacing.md;
  static const double tableFilterGap = AppSpacing.sm;
  static const double tablePaginationGap = AppSpacing.md;
  static const double tableHeaderRowGap = AppSpacing.sm;

  // Dashboard Spacing (px)
  static const double dashboardGridGap = AppSpacing.md;
  static const double dashboardCardGap = AppSpacing.md;
  static const double dashboardKpiGap = AppSpacing.md;
  static const double dashboardSectionGap = AppSpacing.lg;

  // Navigation Spacing (px)
  static const double navItemGap = AppSpacing.xs;
  static const double navSidebarWidth = 260.0;
  static const double navCollapsedSidebarWidth = 64.0;

  // EdgeInset Directional Helpers for RTL Compliance
  static const EdgeInsetsGeometry pagePaddingDirectionalCompact =
      EdgeInsetsDirectional.all(pagePaddingCompact);
  static const EdgeInsetsGeometry pagePaddingDirectionalStandard =
      EdgeInsetsDirectional.all(pagePaddingStandard);
  static const EdgeInsetsGeometry pagePaddingDirectionalSpacious =
      EdgeInsetsDirectional.all(pagePaddingSpacious);

  static const EdgeInsetsGeometry sectionPaddingDirectional =
      EdgeInsetsDirectional.all(sectionPadding);
}
