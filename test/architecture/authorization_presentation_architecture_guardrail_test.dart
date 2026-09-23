import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  final metadataDirectory = Directory(
    'lib/packages/permissions/presentation/metadata',
  );
  final coreAuthorizationDirectory = Directory('lib/core/authorization');

  List<File> dartFiles(Directory dir) => dir
      .listSync(recursive: true)
      .whereType<File>()
      .where((file) => file.path.endsWith('.dart'))
      .toList();

  group('Authorization presentation architecture guardrails', () {
    test(
      'core/authorization must NEVER import Flutter UI, UI packages, or localization',
      () {
        final forbiddenImports = [
          'package:flutter/',
          'package:nexabiz_ui/',
          'app_localizations.dart',
          '/presentation/',
        ];

        for (final file in dartFiles(coreAuthorizationDirectory)) {
          final source = file.readAsStringSync();
          for (final forbidden in forbiddenImports) {
            expect(
              source,
              isNot(contains(forbidden)),
              reason:
                  '${file.path} must not depend on UI/localization primitive $forbidden',
            );
          }
        }
      },
    );

    test(
      'presentation metadata must NEVER import persistence or database stores',
      () {
        final forbiddenImports = [
          'package:drift/',
          'package:sqlite3/',
          'drift_authorization_administration_store.dart',
          'drift_core_database.dart',
          'nexabiz_authorization_administration_mutation_store.dart',
          'nexabiz_authorization_administration_query_store.dart',
          '/app/persistence/',
        ];

        for (final file in dartFiles(metadataDirectory)) {
          final source = file.readAsStringSync();
          for (final forbidden in forbiddenImports) {
            expect(
              source,
              isNot(contains(forbidden)),
              reason:
                  '${file.path} must not import persistence primitive $forbidden',
            );
          }
        }
      },
    );

    test(
      'presentation error mapper and resolver must NOT parse exception strings or use toString().contains',
      () {
        final forbiddenPatterns = [
          RegExp(r'\.toString\(\)\.contains'),
          RegExp(r'\.message\.contains'),
          RegExp(r'RegExp\('),
        ];

        for (final file in dartFiles(metadataDirectory)) {
          final source = file.readAsStringSync();
          for (final pattern in forbiddenPatterns) {
            expect(
              pattern.hasMatch(source),
              isFalse,
              reason:
                  '${file.path} contains string parsing forbidden pattern: ${pattern.pattern}',
            );
          }
        }
      },
    );

    test('presentation metadata does NOT declare routes or screens', () {
      final forbiddenTerms = [
        'StatelessWidget',
        'StatefulWidget',
        'ConsumerWidget',
        'NexaBizRouteDefinition',
        'NexaBizFlutterRouteDefinition',
        'GoRoute',
      ];

      for (final file in dartFiles(metadataDirectory)) {
        final source = file.readAsStringSync();
        for (final term in forbiddenTerms) {
          expect(
            source,
            isNot(contains(term)),
            reason:
                '${file.path} must not contain screen or route declarations: $term',
          );
        }
      }
    });

    test(
      'presentation UI must NEVER import Drift, SQLite, or administration stores',
      () {
        final presentationDir = Directory(
          'lib/packages/permissions/presentation',
        );
        final forbiddenImports = [
          'package:drift/',
          'package:sqlite3/',
          'drift_authorization_administration_store.dart',
          'drift_core_database.dart',
          'nexabiz_authorization_administration_mutation_store.dart',
          'nexabiz_authorization_administration_query_store.dart',
          '/app/persistence/',
        ];

        for (final file in dartFiles(presentationDir)) {
          final source = file.readAsStringSync();
          for (final forbidden in forbiddenImports) {
            expect(
              source,
              isNot(contains(forbidden)),
              reason:
                  '${file.path} must not import persistence primitive $forbidden',
            );
          }
        }
      },
    );

    test(
      'presentation UI must NOT import shadcn_flutter directly (must use nexabiz_ui)',
      () {
        final presentationDir = Directory(
          'lib/packages/permissions/presentation',
        );
        for (final file in dartFiles(presentationDir)) {
          final source = file.readAsStringSync();
          expect(
            source,
            isNot(contains('package:shadcn_flutter/')),
            reason:
                '${file.path} directly imports shadcn_flutter instead of using nexabiz_ui',
          );
        }
      },
    );

    test('presentation UI must NOT perform role-name string security checks', () {
      final presentationDir = Directory(
        'lib/packages/permissions/presentation',
      );
      final forbiddenPatterns = [
        RegExp(r'''['"]company\.owner['"]\s*=='''),
        RegExp(r'''==\s*['"]company\.owner['"]'''),
        RegExp(r'''['"]company\.admin['"]\s*=='''),
        RegExp(r'''==\s*['"]company\.admin['"]'''),
      ];

      for (final file in dartFiles(presentationDir)) {
        final source = file.readAsStringSync();
        for (final pattern in forbiddenPatterns) {
          expect(
            pattern.hasMatch(source),
            isFalse,
            reason:
                '${file.path} contains forbidden role-name string check: ${pattern.pattern}',
          );
        }
      }
    });
  });
}
