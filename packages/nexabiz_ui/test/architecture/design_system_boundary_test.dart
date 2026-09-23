import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:nexabiz_ui/nexabiz_ui.dart';

void main() {
  group('Design System Boundary & Token Authority Architecture Tests', () {
    test(
      'Rule A: Application lib directory contains zero package:nexabiz_ui/src/ imports',
      () {
        final appLibDir = Directory('../../lib');
        if (!appLibDir.existsSync()) {
          // Fallback for execution from root directory
          final rootAppLibDir = Directory('lib');
          expect(
            rootAppLibDir.existsSync(),
            isTrue,
            reason: 'Application lib directory must exist',
          );
          _assertNoInternalImports(rootAppLibDir);
        } else {
          _assertNoInternalImports(appLibDir);
        }
      },
    );

    test(
      'Rule B: Canonical Design Token APIs are publicly exported from nexabiz_ui',
      () {
        expect(AppColors, isNotNull);
        expect(AppTypography, isNotNull);
        expect(AppSpacing, isNotNull);
        expect(AppRadii, isNotNull);
        expect(AppRadius, isNotNull);
        expect(AppBorders, isNotNull);
        expect(AppElevation, isNotNull);
        expect(AppShadows, isNotNull);
        expect(AppIcons, isNotNull);
        expect(AppMotion, isNotNull);
        expect(AppDimensions, isNotNull);
        expect(AppBreakpoints, isNotNull);
        expect(AppBreakpointTier, isNotNull);
        expect(AppLayoutTokens, isNotNull);
      },
    );

    test(
      'Rule D: AppBreakpoints resolves to canonical layout implementation',
      () {
        expect(AppBreakpoints.mobile, equals(600.0));
        expect(AppBreakpoints.tablet, equals(1000.0));
        expect(AppBreakpoints.largeDesktop, equals(1440.0));
        expect(AppBreakpoints.getTier(400), equals(AppBreakpointTier.compact));
        expect(AppBreakpoints.getTier(800), equals(AppBreakpointTier.medium));
        expect(
          AppBreakpoints.getTier(1100),
          equals(AppBreakpointTier.expanded),
        );
        expect(AppBreakpoints.getTier(1500), equals(AppBreakpointTier.wide));
      },
    );

    test(
      'Rule E: Phase 03-C Canonical Page Architecture APIs remain publicly exported',
      () {
        expect(AppPage, isNotNull);
        expect(AppListPage, isNotNull);
        expect(AppFormPage, isNotNull);
        expect(AppDetailsPage, isNotNull);
        expect(AppTablePage, isNotNull);
        expect(AppDashboardPage, isNotNull);
        expect(AppSettingsPage, isNotNull);
        expect(AppMasterDetailPage, isNotNull);
      },
    );
  });
}

void _assertNoInternalImports(Directory dir) {
  final List<String> violations = [];
  final files = dir.listSync(recursive: true).whereType<File>();

  for (final file in files) {
    if (!file.path.endsWith('.dart')) continue;
    final lines = file.readAsLinesSync();
    for (int i = 0; i < lines.length; i++) {
      final line = lines[i];
      if (line.contains('package:nexabiz_ui/src/')) {
        violations.add('${file.path}:${i + 1}: $line');
      }
    }
  }

  expect(
    violations,
    isEmpty,
    reason:
        'Found direct internal package:nexabiz_ui/src/ imports in app feature code:\n'
        '${violations.join('\n')}',
  );
}
