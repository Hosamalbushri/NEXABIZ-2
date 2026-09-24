import 'dart:io';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nexabiz_ui/nexabiz_ui.dart';

void main() {
  group('Phase 06: Responsive Architecture Guardrails', () {
    late Directory nexabizUiDir;

    setUpAll(() {
      final defaultDir = Directory('packages/nexabiz_ui');
      final relativeDir = Directory('.');
      if (defaultDir.existsSync()) {
        nexabizUiDir = defaultDir;
      } else if (relativeDir.existsSync() &&
          File('${relativeDir.path}/pubspec.yaml').existsSync()) {
        nexabizUiDir = relativeDir;
      } else {
        fail('Could not locate packages/nexabiz_ui directory');
      }
    });

    test(
      'GUARD-RESPONSIVE-01: No unauthorized responsive scaling packages (flutter_screenutil, responsive_sizer, Sizer)',
      () {
        final pubspecFile = File('${nexabizUiDir.path}/pubspec.yaml');
        expect(pubspecFile.existsSync(), isTrue);
        final pubspecContent = pubspecFile.readAsStringSync();

        expect(
          pubspecContent.contains('flutter_screenutil'),
          isFalse,
          reason:
              'flutter_screenutil is forbidden in NexaBiz ERP architecture!',
        );
        expect(
          pubspecContent.contains('responsive_sizer'),
          isFalse,
          reason: 'responsive_sizer is forbidden in NexaBiz ERP architecture!',
        );
        expect(
          pubspecContent.contains('sizer:'),
          isFalse,
          reason: 'Sizer package is forbidden in NexaBiz ERP architecture!',
        );

        final dartFiles = Directory('${nexabizUiDir.path}/lib')
            .listSync(recursive: true)
            .whereType<File>()
            .where((f) => f.path.endsWith('.dart'));

        for (final file in dartFiles) {
          final content = file.readAsStringSync();
          expect(
            content.contains('flutter_screenutil') ||
                content.contains('responsive_sizer') ||
                content.contains('package:sizer/'),
            isFalse,
            reason:
                'File ${file.path} contains forbidden responsive scaling package imports!',
          );
        }
      },
    );

    test(
      'GUARD-RESPONSIVE-02: Single Source of Truth for Breakpoints in AppBreakpoints',
      () {
        expect(AppBreakpoints.mobile, equals(600.0));
        expect(AppBreakpoints.tablet, equals(1000.0));
        expect(AppBreakpoints.desktop, equals(1200.0));
        expect(AppBreakpoints.largeDesktop, equals(1440.0));

        expect(AppBreakpoints.isCompact(599.9), isTrue);
        expect(AppBreakpoints.isCompact(600.0), isFalse);

        expect(AppBreakpoints.isMedium(600.0), isTrue);
        expect(AppBreakpoints.isMedium(999.9), isTrue);
        expect(AppBreakpoints.isMedium(1000.0), isFalse);

        expect(AppBreakpoints.isExpanded(1000.0), isTrue);
        expect(AppBreakpoints.isExpanded(1439.9), isTrue);
        expect(AppBreakpoints.isExpanded(1440.0), isFalse);

        expect(AppBreakpoints.isWide(1440.0), isTrue);
      },
    );

    test(
      'GUARD-RESPONSIVE-03: AppResponsiveScope and AppResponsiveInfo exist and export',
      () {
        const info = AppResponsiveInfo(
          tier: AppBreakpointTier.compact,
          constraints: BoxConstraints(),
          availableWidth: 320.0,
        );

        expect(info.isCompact, isTrue);
        expect(info.isMedium, isFalse);
        expect(info.isExpanded, isFalse);
        expect(info.isWide, isFalse);
        expect(info.availableWidth, equals(320.0));
      },
    );

    test(
      'GUARD-RESPONSIVE-04: Layout containers do not use direct MediaQuery width without local scope resolution',
      () {
        final layoutFiles = [
          '${nexabizUiDir.path}/lib/src/layout/app_content.dart',
          '${nexabizUiDir.path}/lib/src/layout/app_container.dart',
          '${nexabizUiDir.path}/lib/src/layout/app_page.dart',
          '${nexabizUiDir.path}/lib/src/layout/app_form_page.dart',
        ];

        for (final filePath in layoutFiles) {
          final file = File(filePath);
          expect(file.existsSync(), isTrue);
          final content = file.readAsStringSync();

          // Direct un-scoped query pattern: MediaQuery.of(context).size.width
          expect(
            content.contains('MediaQuery.of(context).size.width'),
            isFalse,
            reason:
                'File $filePath uses un-scoped MediaQuery.of(context).size.width! Must check local constraints / AppResponsiveScope first.',
          );
        }
      },
    );

    test(
      'GUARD-RESPONSIVE-05: AppGrid supports fluid minItemWidth and maxColumns parameters',
      () {
        const grid = AppGrid(minItemWidth: 280, maxColumns: 4, children: []);

        expect(grid.minItemWidth, equals(280.0));
        expect(grid.maxColumns, equals(4));
        expect(grid.compactColumns, equals(1));
        expect(grid.mediumColumns, equals(2));
        expect(grid.expandedColumns, equals(3));
        expect(grid.wideColumns, equals(4));
      },
    );
  });
}
