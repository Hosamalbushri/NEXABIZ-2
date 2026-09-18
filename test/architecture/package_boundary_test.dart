import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'architecture_exception_registry.dart';

void main() {
  group('Guardrail 5 — Public Package Boundary Architecture Tests', () {
    test('Application and feature code MUST NOT import package:nexabiz_ui/src/...', () {
      final appProductionFiles = _getAppProductionDartFiles();
      final violatingFiles = <String>[];

      for (final file in appProductionFiles) {
        final lines = file.readAsLinesSync();
        for (final line in lines) {
          if (line.contains('package:nexabiz_ui/src/')) {
            violatingFiles.add(file.path);
            break;
          }
        }
      }

      ArchitectureExceptionRegistry.assertExactViolations(
        ruleId: 'RULE-01-PACKAGE-SRC-IMPORT',
        scannedViolatingFiles: violatingFiles,
      );
    });
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
    final featureDirs = packagesDir
        .listSync()
        .whereType<Directory>()
        .where((d) => !d.path.replaceAll('\\', '/').endsWith('packages/nexabiz_ui'));
    for (final dir in featureDirs) {
      files.addAll(_collectDartFiles(dir));
    }
  }
  return files;
}

List<File> _collectDartFiles(Directory dir) {
  return dir
      .listSync(recursive: true)
      .whereType<File>()
      .where((f) =>
          f.path.endsWith('.dart') &&
          !f.path.endsWith('.g.dart') &&
          !f.path.endsWith('.freezed.dart'))
      .toList();
}
