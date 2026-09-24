import 'package:flutter_test/flutter_test.dart';
import 'package:nexabiz_ui/nexabiz_ui.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shadcn;

void main() {
  group('Phase 02 — Design System Token & SSoT Architecture Guardrails', () {
    test(
      'GUARD-TOKEN-01: AppDimensions sidebar layout dimensions delegate to AppLayoutTokens',
      () {
        // ignore: deprecated_member_use_from_same_package
        expect(
          AppDimensions.navSidebarWidth,
          equals(AppLayoutTokens.navSidebarWidth),
        );
        expect(AppDimensions.navSidebarWidth, equals(260.0));

        // ignore: deprecated_member_use_from_same_package
        expect(
          AppDimensions.navCollapsedSidebarWidth,
          equals(AppLayoutTokens.navCollapsedSidebarWidth),
        );
        expect(AppDimensions.navCollapsedSidebarWidth, equals(64.0));
        expect(
          AppDimensions.navRailWidth,
          equals(AppLayoutTokens.navCollapsedSidebarWidth),
        );
      },
    );

    test('GUARD-TOKEN-02: AppRadius alias delegates strictly to AppRadii', () {
      expect(AppRadius.zero, equals(AppRadii.zero));
      expect(AppRadius.xs, equals(AppRadii.xs));
      expect(AppRadius.sm, equals(AppRadii.sm));
      expect(AppRadius.md, equals(AppRadii.md));
      expect(AppRadius.lg, equals(AppRadii.lg));
      expect(AppRadius.xl, equals(AppRadii.xl));
      expect(AppRadius.pill, equals(AppRadii.pill));
      expect(AppRadius.full, equals(AppRadii.full));

      expect(AppRadius.control, equals(AppRadii.control));
      expect(AppRadius.surface, equals(AppRadii.surface));
      expect(AppRadius.dialog, equals(AppRadii.dialog));
      expect(AppRadius.header, equals(AppRadii.header));

      expect(AppRadius.radiusZero, equals(AppRadii.radiusZero));
      expect(AppRadius.radiusXs, equals(AppRadii.radiusXs));
      expect(AppRadius.radiusSm, equals(AppRadii.radiusSm));
      expect(AppRadius.radiusMd, equals(AppRadii.radiusMd));
      expect(AppRadius.radiusLg, equals(AppRadii.radiusLg));
      expect(AppRadius.radiusXl, equals(AppRadii.radiusXl));
      expect(AppRadius.radiusPill, equals(AppRadii.radiusPill));
      expect(AppRadius.radiusFull, equals(AppRadii.radiusFull));
    });

    test(
      'GUARD-TOKEN-03: AppLayoutTokens semantic spacing values derive from AppSpacing primitives',
      () {
        expect(
          AppLayoutTokens.pagePaddingCompact,
          equals(AppSpacing.sm),
        ); // 12.0
        expect(
          AppLayoutTokens.pagePaddingStandard,
          equals(AppSpacing.md),
        ); // 16.0
        expect(
          AppLayoutTokens.pagePaddingSpacious,
          equals(AppSpacing.lg),
        ); // 24.0

        expect(AppLayoutTokens.sectionGap, equals(AppSpacing.lg)); // 24.0
        expect(AppLayoutTokens.sectionTitleGap, equals(AppSpacing.sm)); // 12.0
        expect(AppLayoutTokens.sectionInnerGap, equals(AppSpacing.md)); // 16.0
        expect(AppLayoutTokens.sectionPadding, equals(AppSpacing.md)); // 16.0

        expect(AppLayoutTokens.formFieldGap, equals(AppSpacing.md)); // 16.0
        expect(AppLayoutTokens.formGroupGap, equals(AppSpacing.lg)); // 24.0
        expect(AppLayoutTokens.formActionsGap, equals(AppSpacing.md)); // 16.0

        expect(AppLayoutTokens.tableToolbarGap, equals(AppSpacing.md)); // 16.0
        expect(AppLayoutTokens.tableFilterGap, equals(AppSpacing.sm)); // 12.0
        expect(
          AppLayoutTokens.tablePaginationGap,
          equals(AppSpacing.md),
        ); // 16.0
        expect(
          AppLayoutTokens.tableHeaderRowGap,
          equals(AppSpacing.sm),
        ); // 12.0

        expect(AppLayoutTokens.dashboardGridGap, equals(AppSpacing.md)); // 16.0
        expect(AppLayoutTokens.dashboardCardGap, equals(AppSpacing.md)); // 16.0
        expect(AppLayoutTokens.dashboardKpiGap, equals(AppSpacing.md)); // 16.0
        expect(
          AppLayoutTokens.dashboardSectionGap,
          equals(AppSpacing.lg),
        ); // 24.0

        expect(AppLayoutTokens.navItemGap, equals(AppSpacing.xs)); // 8.0
      },
    );

    test(
      'GUARD-TOKEN-04: AppFieldDensity heights resolve to AppDimensions input heights',
      () {
        expect(
          AppFieldDensity.compact.height,
          equals(AppDimensions.desktopInputHeight),
        );
        expect(AppFieldDensity.compact.height, equals(40.0));

        expect(
          AppFieldDensity.standard.height,
          equals(AppDimensions.inputHeight),
        );
        expect(AppFieldDensity.standard.height, equals(48.0));

        expect(
          AppFieldDensity.large.height,
          equals(AppDimensions.inputHeightLarge),
        );
        expect(AppFieldDensity.large.height, equals(56.0));
      },
    );

    test(
      'GUARD-TOKEN-05: AppBreakpoints tiers are contiguous and ordered monotonically',
      () {
        expect(AppBreakpoints.compactMax, lessThan(AppBreakpoints.mediumMin));
        expect(AppBreakpoints.mediumMin, equals(AppBreakpoints.mobile));
        expect(AppBreakpoints.mediumMax, lessThan(AppBreakpoints.expandedMin));
        expect(AppBreakpoints.expandedMin, equals(AppBreakpoints.tablet));
        expect(AppBreakpoints.largeDesktop, equals(AppBreakpoints.wideMin));

        expect(
          AppBreakpoints.getTier(320.0),
          equals(AppBreakpointTier.compact),
        );
        expect(
          AppBreakpoints.getTier(599.0),
          equals(AppBreakpointTier.compact),
        );
        expect(AppBreakpoints.getTier(600.0), equals(AppBreakpointTier.medium));
        expect(AppBreakpoints.getTier(999.0), equals(AppBreakpointTier.medium));
        expect(
          AppBreakpoints.getTier(1000.0),
          equals(AppBreakpointTier.expanded),
        );
        expect(
          AppBreakpoints.getTier(1200.0),
          equals(AppBreakpointTier.expanded),
        );
        expect(
          AppBreakpoints.getTier(1439.0),
          equals(AppBreakpointTier.expanded),
        );
        expect(AppBreakpoints.getTier(1440.0), equals(AppBreakpointTier.wide));
        expect(AppBreakpoints.getTier(1920.0), equals(AppBreakpointTier.wide));
      },
    );

    test(
      'GUARD-TOKEN-06: AppTheme constructs native shadcn.ThemeData with Cairo typography and AppColors',
      () {
        final lightTheme = AppTheme.light();
        final darkTheme = AppTheme.dark();

        expect(lightTheme, isA<shadcn.ThemeData>());
        expect(darkTheme, isA<shadcn.ThemeData>());

        expect(lightTheme.colorScheme.primary, equals(AppColors.primaryBlue));
        expect(darkTheme.colorScheme.primary, equals(AppColors.primaryBlue));

        expect(lightTheme.colorScheme.destructive, equals(AppColors.error));
        expect(darkTheme.colorScheme.destructive, equals(AppColors.error));

        expect(lightTheme.typography.sans.fontFamily, equals('Cairo'));
        expect(darkTheme.typography.sans.fontFamily, equals('Cairo'));
      },
    );
  });
}
