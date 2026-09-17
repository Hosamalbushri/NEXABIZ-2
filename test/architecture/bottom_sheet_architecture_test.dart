import 'dart:io';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('NexaBiz Bottom Sheet Architecture Guardrail Tests', () {
    test('Ensures zero Material showModalBottomSheet calls exist in presentation code', () {
      final libDir = Directory('lib');
      final packagesDir = Directory('packages');

      final forbiddenPatterns = [
        'showModalBottomSheet',
        'showCupertinoModalPopup',
        'CupertinoActionSheet',
      ];

      final violations = <String>[];

      void scanDirectory(Directory dir) {
        if (!dir.existsSync()) return;
        for (final entity in dir.listSync(recursive: true)) {
          if (entity is File && entity.path.endsWith('.dart')) {
            // app_quick_actions_panel.dart explicitly uses showModalBottomSheet per user request
            if (entity.path.endsWith('app_quick_actions_panel.dart')) continue;

            final content = entity.readAsStringSync();
            for (final pattern in forbiddenPatterns) {
              if (content.contains(pattern)) {
                violations.add('${entity.path}: contains forbidden "$pattern"');
              }
            }
          }
        }
      }

      scanDirectory(libDir);
      scanDirectory(packagesDir);

      expect(
        violations,
        isEmpty,
        reason:
            'Forbidden bottom sheet APIs found! Reusable presentation code MUST compose shadcn_flutter bottom sheets exclusively.',
      );
    });
  });
}
