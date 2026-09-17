import 'dart:io';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('UI Architecture Guardrails (UI-01..04)', () {
    final presentationDirs = [
      Directory('lib/app/presentation'),
      Directory('lib/app/shell'),
      Directory('lib/packages/dashboard/presentation'),
      Directory('lib/packages/services/presentation'),
      Directory('lib/packages/reports/presentation'),
      Directory('lib/packages/settings/presentation'),
    ];

    List<File> getDartFiles() {
      final files = <File>[];
      for (final dir in presentationDirs) {
        if (dir.existsSync()) {
          files.addAll(
            dir
                .listSync(recursive: true)
                .whereType<File>()
                .where((f) => f.path.endsWith('.dart')),
          );
        }
      }
      return files;
    }

    test('UI-01 & UI-03: Presentation files MUST NOT directly import shadcn_flutter', () {
      final files = getDartFiles();
      for (final file in files) {
        final content = file.readAsStringSync();
        final containsShadcnImport = content.contains("import 'package:shadcn_flutter") ||
            content.contains('import "package:shadcn_flutter');
        expect(
          containsShadcnImport,
          isFalse,
          reason:
              'File ${file.path} directly imports shadcn_flutter. All shadcn_flutter usages must be encapsulated within packages/nexabiz_ui.',
        );
      }
    });

    test('UI-02: Presentation screens MUST NOT directly import flutter/material.dart for UI primitives', () {
      final files = getDartFiles();
      for (final file in files) {
        final content = file.readAsStringSync();
        final containsMaterialImport = content.contains("import 'package:flutter/material.dart'") ||
            content.contains('import "package:flutter/material.dart"');
        expect(
          containsMaterialImport,
          isFalse,
          reason:
              'File ${file.path} directly imports flutter/material.dart. Presentation code must depend on packages/nexabiz_ui or package:flutter/widgets.dart.',
        );
      }
    });

    test('UI-04: Reusable visual components live in packages/nexabiz_ui', () {
      final nexabizUiWidgetsDir = Directory('packages/nexabiz_ui/lib/src/widgets');
      expect(
        nexabizUiWidgetsDir.existsSync(),
        isTrue,
        reason: 'packages/nexabiz_ui/lib/src/widgets directory must exist.',
      );
      final widgetFiles = nexabizUiWidgetsDir.listSync().whereType<File>();
      expect(
        widgetFiles.isNotEmpty,
        isTrue,
        reason: 'packages/nexabiz_ui must contain shared UI primitives.',
      );
    });
  });
}
