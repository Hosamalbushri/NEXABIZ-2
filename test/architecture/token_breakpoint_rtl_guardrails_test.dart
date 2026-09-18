import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'architecture_exception_registry.dart';

void main() {
  group('Guardrail 10, 11 & 12 — Token, Breakpoint & RTL Guardrails', () {
    test('Rule 10: Feature UI MUST NOT use hardcoded Color(0xFF...) literals', () {
      final appProductionFiles = _getAppProductionDartFiles();
      final colorRegex = RegExp(r'Color\(0x[0-9a-fA-F]{8}\)');
      final violatingFiles = <String>[];

      for (final file in appProductionFiles) {
        final lines = file.readAsLinesSync();
        for (final line in lines) {
          if (colorRegex.hasMatch(line)) {
            violatingFiles.add(file.path);
            break;
          }
        }
      }

      ArchitectureExceptionRegistry.assertExactViolations(
        ruleId: 'RULE-06-HARDCODED-COLORS',
        scannedViolatingFiles: violatingFiles,
      );
    });

    test('Rule 11: Feature code MUST use canonical AppBreakpoints instead of arbitrary MediaQuery width checks', () {
      final appProductionFiles = _getAppProductionDartFiles();
      final breakpointRegex = RegExp(r'width\s*(?:<|<=|>|>=)\s*\d+|MediaQuery\.of\(context\)\.size\.width');
      final violatingFiles = <String>[];

      for (final file in appProductionFiles) {
        final lines = file.readAsLinesSync();
        for (final line in lines) {
          if (breakpointRegex.hasMatch(line)) {
            violatingFiles.add(file.path);
            break;
          }
        }
      }

      ArchitectureExceptionRegistry.assertExactViolations(
        ruleId: 'RULE-07-BREAKPOINT-AUTHORITY',
        scannedViolatingFiles: violatingFiles,
      );
    });

    test('Rule 12: Production UI MUST use directional geometry (EdgeInsetsDirectional, AlignmentDirectional) where applicable', () {
      final appProductionFiles = _getAppProductionDartFiles();
      final rtlRegexes = [
        RegExp(r'EdgeInsets\.only\s*\([^)]*\b(left|right):'),
        RegExp(r'Alignment\.centerLeft'),
        RegExp(r'Alignment\.centerRight'),
        RegExp(r'Positioned\s*\([^)]*\b(left|right):'),
      ];

      final violatingFiles = <String>[];

      for (final file in appProductionFiles) {
        final lines = file.readAsLinesSync();
        for (final line in lines) {
          bool matched = false;
          for (final r in rtlRegexes) {
            if (r.hasMatch(line)) {
              violatingFiles.add(file.path);
              matched = true;
              break;
            }
          }
          if (matched) break;
        }
      }

      ArchitectureExceptionRegistry.assertExactViolations(
        ruleId: 'RULE-08-RTL-DIRECTIONALITY',
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
