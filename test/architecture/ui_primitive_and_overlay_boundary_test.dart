import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'architecture_exception_registry.dart';

void main() {
  group('Guardrail 7, 8 & 9 — UI Primitive & Overlay Authority Boundary Tests', () {
    test(
      'Rule 7: Feature code MUST NOT directly import package:shadcn_flutter',
      () {
        final appProductionFiles = _getAppProductionDartFiles();
        final violatingFiles = <String>[];

        for (final file in appProductionFiles) {
          final lines = file.readAsLinesSync();
          for (final line in lines) {
            if (line.contains('package:shadcn_flutter/shadcn_flutter.dart')) {
              violatingFiles.add(file.path);
              break;
            }
          }
        }

        ArchitectureExceptionRegistry.assertExactViolations(
          ruleId: 'RULE-03-DIRECT-SHADCN',
          scannedViolatingFiles: violatingFiles,
        );
      },
    );

    test(
      'Rule 8: Presentation screens MUST NOT directly import flutter/material.dart for UI primitives',
      () {
        final presentationFiles = _getAppPresentationDartFiles();
        final violatingFiles = <String>[];

        for (final file in presentationFiles) {
          final lines = file.readAsLinesSync();
          for (final line in lines) {
            if (line.contains("import 'package:flutter/material.dart'") ||
                line.contains('import "package:flutter/material.dart"')) {
              violatingFiles.add(file.path);
              break;
            }
          }
        }

        ArchitectureExceptionRegistry.assertExactViolations(
          ruleId: 'RULE-04-MATERIAL-PRESENTATION-IMPORT',
          scannedViolatingFiles: violatingFiles,
        );
      },
    );

    test(
      'Rule 9: Feature code MUST NOT bypass overlay authority with direct showDialog / showModalBottomSheet',
      () {
        final appProductionFiles = _getAppProductionDartFiles();
        final violatingFiles = <String>[];

        for (final file in appProductionFiles) {
          final lines = file.readAsLinesSync();
          for (final line in lines) {
            if (RegExp(r'\bshowDialog\b').hasMatch(line) ||
                RegExp(r'\bshowModalBottomSheet\b').hasMatch(line)) {
              violatingFiles.add(file.path);
              break;
            }
          }
        }

        ArchitectureExceptionRegistry.assertExactViolations(
          ruleId: 'RULE-05-OVERLAY-AUTHORITY-BYPASS',
          scannedViolatingFiles: violatingFiles,
        );
      },
    );
  });
}

List<File> _getAppProductionDartFiles() {
  final files = <File>[];
  final libDir = Directory('lib');
  if (libDir.existsSync()) {
    files.addAll(_collectDartFiles(libDir));
  }

  final packagesDir = Directory('packages');
  if (packagesDir.existsSync()) {
    final featureDirs = packagesDir.listSync().whereType<Directory>().where(
      (d) => !d.path.replaceAll('\\', '/').endsWith('packages/nexabiz_ui'),
    );
    for (final dir in featureDirs) {
      files.addAll(_collectDartFiles(dir));
    }
  }
  return files;
}

List<File> _getAppPresentationDartFiles() {
  return _getAppProductionDartFiles()
      .where((f) => f.path.replaceAll('\\', '/').contains('/presentation/'))
      .toList();
}

List<File> _collectDartFiles(Directory dir) {
  return dir
      .listSync(recursive: true)
      .whereType<File>()
      .where(
        (f) =>
            f.path.endsWith('.dart') &&
            !f.path.endsWith('.g.dart') &&
            !f.path.endsWith('.freezed.dart'),
      )
      .toList();
}
