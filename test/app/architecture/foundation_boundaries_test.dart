import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
    'capability contracts and navigation metadata remain framework-neutral',
    () {
      final files = [
        ...Directory('lib/core/capabilities').listSync().whereType<File>(),
        ...Directory('lib/core/navigation').listSync().whereType<File>().where(
          (file) => !file.path.endsWith('nexabiz_navigation_controller.dart'),
        ),
      ].where((file) => file.path.endsWith('.dart'));
      final imports = RegExp(
        r'''^\s*(?:import|export)\s+['"]([^'"]+)['"]''',
        multiLine: true,
      );
      for (final file in files) {
        for (final match in imports.allMatches(file.readAsStringSync())) {
          final dependency = match.group(1)!;
          expect(
            dependency.startsWith('package:'),
            isFalse,
            reason:
                '${file.path} imports framework/package dependency $dependency',
          );
          expect(
            dependency.contains('/app/'),
            isFalse,
            reason: '${file.path} imports infrastructure $dependency',
          );
          expect(
            dependency.contains('/presentation/'),
            isFalse,
            reason: '${file.path} imports presentation $dependency',
          );
        }
      }
    },
  );

  test('capability declarations do not expose router implementation types', () {
    final files = Directory('lib/packages')
        .listSync(recursive: true)
        .whereType<File>()
        .where((file) => file.path.endsWith('_capability.dart'));
    for (final file in files) {
      final source = file.readAsStringSync();
      expect(source.contains('package:go_router/'), isFalse, reason: file.path);
      expect(source.contains('dynamic state'), isFalse, reason: file.path);
    }
  });
}
