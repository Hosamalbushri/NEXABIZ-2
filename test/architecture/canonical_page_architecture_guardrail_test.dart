import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'architecture_exception_registry.dart';

void main() {
  group('Guardrail 6 — Canonical Page Architecture Tests', () {
    test('New feature code MUST NOT consume deprecated page wrappers', () {
      final appProductionFiles = _getAppProductionDartFiles();
      final legacyWrappers = [
        'AppPageShell',
        'AppListPagePattern',
        'AppFormPagePattern',
        'AppDetailPagePattern',
        'ModuleListScaffold',
        'ModuleFormScaffold',
      ];

      final violatingFiles = <String>[];

      for (final file in appProductionFiles) {
        final content = file.readAsStringSync();
        for (final wrapper in legacyWrappers) {
          if (content.contains(wrapper)) {
            violatingFiles.add(file.path);
            break;
          }
        }
      }

      ArchitectureExceptionRegistry.assertExactViolations(
        ruleId: 'RULE-02-DEPRECATED-PAGE-WRAPPERS',
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
