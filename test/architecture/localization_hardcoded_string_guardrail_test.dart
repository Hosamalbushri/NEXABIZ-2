import 'dart:io';
import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'architecture_exception_registry.dart';

void main() {
  test('English and Arabic ARB message keys and values match', () {
    Map<String, dynamic> messages(String path) =>
        jsonDecode(File(path).readAsStringSync()) as Map<String, dynamic>;
    final english = messages('lib/l10n/app_en.arb');
    final arabic = messages('lib/l10n/app_ar.arb');
    expect(arabic.keys.toSet(), english.keys.toSet());
    for (final key in english.keys.where((key) => !key.startsWith('@'))) {
      expect(
        english[key],
        isA<String>().having((value) => value.trim(), 'text', isNotEmpty),
      );
      expect(
        arabic[key],
        isA<String>().having((value) => value.trim(), 'text', isNotEmpty),
      );
    }
  });

  test(
    'capability name keys are identifiers and are not rendered directly',
    () {
      final capabilityFiles = Directory('lib/packages')
          .listSync(recursive: true)
          .whereType<File>()
          .where((file) => file.path.endsWith('_capability.dart'));
      for (final file in capabilityFiles) {
        final source = file.readAsStringSync();
        for (final match in RegExp(
          r"nameKey:\s*'([^']+)'",
        ).allMatches(source)) {
          expect(
            match.group(1),
            matches(RegExp(r'^[a-z][a-z0-9]*(?:[A-Za-z0-9.]*)$')),
            reason: file.path,
          );
          expect(match.group(1)!.contains(' '), isFalse, reason: file.path);
        }
      }
      for (final file in _getPresentationDartFiles()) {
        expect(
          file.readAsStringSync().contains('.metadata.nameKey'),
          isFalse,
          reason: file.path,
        );
      }
    },
  );

  group(
    'Guardrail 4 — Localization Hardcoded User-Visible Text Architecture Tests',
    () {
      test(
        'Rule 4: Production presentation UI MUST NOT contain hardcoded user-visible string literals',
        () {
          final presentationFiles = _getPresentationDartFiles();
          final textLiteralRegexes = [
            RegExp(r'''\bText\(\s*['"]([^'"]+)['"]'''),
            RegExp(r'''\btitle:\s*['"]([^'"]+)['"]'''),
            RegExp(r'''\bsubtitle:\s*['"]([^'"]+)['"]'''),
            RegExp(r'''\blabel:\s*['"]([^'"]+)['"]'''),
            RegExp(r'''\bdescription:\s*['"]([^'"]+)['"]'''),
          ];

          final violatingFiles = <String>[];

          for (final file in presentationFiles) {
            final lines = file.readAsLinesSync();
            for (final line in lines) {
              final trimmed = line.trim();
              // Skip comments, imports, debug statements, and localization/token/route references
              if (trimmed.startsWith('//') ||
                  trimmed.startsWith('/*') ||
                  trimmed.startsWith('import ') ||
                  trimmed.startsWith('export ') ||
                  trimmed.contains('AppLocalizations') ||
                  trimmed.contains('l10n.') ||
                  trimmed.contains('context.l10n')) {
                continue;
              }

              for (final regex in textLiteralRegexes) {
                final match = regex.firstMatch(line);
                if (match != null) {
                  final literal = match.group(1) ?? '';
                  // Ignore technical identifiers, route paths, keys, asset paths
                  if (_isTechnicalIdentifier(literal)) continue;
                  violatingFiles.add(file.path);
                  break;
                }
              }
            }
          }

          ArchitectureExceptionRegistry.assertExactViolations(
            ruleId: 'RULE-04-HARDCODED-STRINGS',
            scannedViolatingFiles: violatingFiles,
          );
        },
      );
    },
  );
}

bool _isTechnicalIdentifier(String text) {
  if (text.isEmpty) return true;
  if (text.startsWith('/') || text.startsWith('assets/')) return true;
  if (RegExp(r'^[a-z0-9_.-]+$').hasMatch(text) && !text.contains(' ')) {
    return true;
  }
  return false;
}

List<File> _getPresentationDartFiles() {
  final files = <File>[];
  final presentationDirs = [
    Directory('lib/app/presentation'),
    Directory('lib/app/shell'),
    Directory('lib/packages/dashboard/presentation'),
    Directory('lib/packages/services/presentation'),
    Directory('lib/packages/reports/presentation'),
    Directory('lib/packages/settings/presentation'),
    Directory('lib/packages/development/navigation_test_lab/presentation'),
    Directory('lib/packages/gallery/presentation'),
    Directory('lib/packages/system_setup/presentation'),
    Directory('lib/packages/identity/presentation'),
    Directory('lib/packages/company/presentation'),
    Directory('lib/packages/permissions/presentation'),
  ];

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
