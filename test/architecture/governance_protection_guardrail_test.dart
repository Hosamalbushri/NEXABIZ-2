import 'dart:io';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Guardrail 5 — Governance Contract Integrity Tests', () {
    test(
      'Rule 5: Root AGENTS.md MUST exist and contain mandatory governance headers',
      () {
        final agentsFile = File('AGENTS.md');
        expect(
          agentsFile.existsSync(),
          isTrue,
          reason:
              'Root AGENTS.md MUST exist as the single architecture entry point.',
        );

        final content = agentsFile.readAsStringSync();
        expect(
          content.contains('# NEXABIZ MANDATORY DEVELOPMENT CONTRACT'),
          isTrue,
          reason:
              'AGENTS.md must prominently contain mandatory development contract header.',
        );
        expect(
          content.contains('ARCHITECTURE DECISION REQUIRED'),
          isTrue,
          reason:
              'AGENTS.md must mandate ARCHITECTURE DECISION REQUIRED on conflict.',
        );
        expect(
          content.contains('00_PROJECT_CONSTITUTION.md'),
          isTrue,
          reason: 'AGENTS.md must index 00_PROJECT_CONSTITUTION.md.',
        );
      },
    );

    test(
      'Rule 5: All 6 mandatory architecture contracts 00-05 MUST exist in docs/architecture/',
      () {
        final requiredContracts = [
          'docs/architecture/00_PROJECT_CONSTITUTION.md',
          'docs/architecture/01_PACKAGE_CONTRACT.md',
          'docs/architecture/02_NAVIGATION_CONTRACT.md',
          'docs/architecture/03_UI_DESIGN_SYSTEM_CONTRACT.md',
          'docs/architecture/04_LOCALIZATION_CONTRACT.md',
          'docs/architecture/05_TESTING_AND_CHANGE_CONTRACT.md',
        ];

        for (final path in requiredContracts) {
          final contractFile = File(path);
          expect(
            contractFile.existsSync(),
            isTrue,
            reason: 'Mandatory architecture contract file $path MUST exist.',
          );
          expect(
            contractFile.readAsStringSync().trim().isNotEmpty,
            isTrue,
            reason: 'Architecture contract file $path MUST NOT be empty.',
          );
        }
      },
    );
  });
}
