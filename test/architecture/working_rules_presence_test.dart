import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('mandatory working rules exist and point to architecture contracts', () {
    const ruleNames = [
      'README.md',
      '00_MODEL_WORKFLOW_RULES.md',
      '01_CAPABILITY_CREATION_RULES.md',
      '02_NAVIGATION_RULES.md',
      '03_LOCALIZATION_RULES.md',
      '04_UI_USAGE_RULES.md',
      '05_BASIC_MODULE_BOUNDARIES.md',
    ];

    final agents = File('AGENTS.md').readAsStringSync();
    expect(agents, contains('docs/rules/README.md'));
    expect(agents, contains('00_PROJECT_CONSTITUTION.md'));

    final index = File('docs/rules/README.md').readAsStringSync();
    expect(index, contains('docs/architecture/'));
    for (final name in ruleNames) {
      final file = File('docs/rules/$name');
      expect(file.existsSync(), isTrue, reason: name);
      expect(file.readAsStringSync().trim(), isNotEmpty, reason: name);
      if (name != 'README.md') {
        expect(index, contains(name), reason: name);
        expect(
          file.readAsStringSync(),
          contains('../architecture/'),
          reason: name,
        );
      }
    }
  });
}
