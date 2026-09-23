import 'dart:io';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Core Authorization & Roles Architecture Guardrail Tests', () {
    test(
      'authorization and roles domain contracts MUST remain pure Dart and framework-neutral',
      () {
        final authDir = Directory('lib/core/authorization');
        final rolesDir = Directory('lib/core/roles');

        final files = <File>[
          if (authDir.existsSync())
            ...authDir.listSync(recursive: true).whereType<File>(),
          if (rolesDir.existsSync())
            ...rolesDir.listSync(recursive: true).whereType<File>(),
        ].where((f) => f.path.endsWith('.dart')).toList();

        expect(
          files,
          isNotEmpty,
          reason: 'Authorization and roles contract files must exist.',
        );

        final importRegex = RegExp(
          r'''^\s*(?:import|export)\s+['"]([^'"]+)['"]''',
          multiLine: true,
        );

        for (final file in files) {
          final content = file.readAsStringSync();
          final matches = importRegex.allMatches(content);

          for (final match in matches) {
            final uri = match.group(1)!;

            expect(
              uri.startsWith('package:flutter/'),
              isFalse,
              reason: '${file.path} must not import flutter ($uri)',
            );

            expect(
              uri,
              isNot('dart:ui'),
              reason: '${file.path} must not import dart:ui',
            );

            expect(
              uri.contains('package:flutter_riverpod/'),
              isFalse,
              reason: '${file.path} must not import riverpod ($uri)',
            );

            expect(
              uri.contains('package:drift/'),
              isFalse,
              reason: '${file.path} must not import drift ($uri)',
            );

            expect(
              uri.contains('package:nexabiz_ui/'),
              isFalse,
              reason: '${file.path} must not import nexabiz_ui ($uri)',
            );

            expect(
              uri.contains('/presentation/'),
              isFalse,
              reason: '${file.path} must not import presentation code ($uri)',
            );

            expect(
              uri.contains('/app/'),
              isFalse,
              reason:
                  '${file.path} must not import app infrastructure code ($uri)',
            );
          }
        }
      },
    );
  });
}
