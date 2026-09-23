import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  final controllerDirectory = Directory(
    'lib/packages/permissions/presentation/controllers',
  );

  List<File> controllerFiles() => controllerDirectory
      .listSync(recursive: true)
      .whereType<File>()
      .where((f) => f.path.endsWith('.dart'))
      .toList();

  group('Roles administration controller architecture guardrails', () {
    test(
      'controllers must NEVER import Drift, SQLite, or persistence stores directly',
      () {
        final forbiddenImports = [
          'package:drift/',
          'package:sqlite3/',
          'drift_core_database.dart',
          'drift_authorization_administration_store.dart',
          'nexabiz_authorization_administration_store.dart',
          '/app/persistence/',
        ];

        for (final file in controllerFiles()) {
          final source = file.readAsStringSync();
          for (final forbidden in forbiddenImports) {
            expect(
              source,
              isNot(contains(forbidden)),
              reason:
                  '${file.path} must not import persistence primitive: $forbidden',
            );
          }
        }
      },
    );

    test(
      'controllers must NOT cache effective permissions for security evaluation',
      () {
        final forbiddenTerms = [
          'effectivePermissions',
          'canManage',
          'hasPermission',
          'isAuthorized',
        ];

        for (final file in controllerFiles()) {
          final source = file.readAsStringSync();
          for (final term in forbiddenTerms) {
            expect(
              source,
              isNot(contains(term)),
              reason:
                  '${file.path} must not contain security authority cache: $term',
            );
          }
        }
      },
    );

    test('controllers must NOT declare Flutter UI widgets or screens', () {
      final forbiddenTerms = [
        'StatelessWidget',
        'StatefulWidget',
        'ConsumerWidget',
        'AppPage',
        'AppListPage',
        'AppFormPage',
        'showDialog',
        'showModalBottomSheet',
      ];

      for (final file in controllerFiles()) {
        final source = file.readAsStringSync();
        for (final term in forbiddenTerms) {
          expect(
            source,
            isNot(contains(term)),
            reason: '${file.path} must not declare UI primitives: $term',
          );
        }
      }
    });

    test('controllers must NOT register navigation routes', () {
      final forbiddenTerms = [
        'GoRoute',
        'NexaBizRouteDefinition',
        'NexaBizFlutterRouteDefinition',
        'context.go',
        'context.push',
      ];

      for (final file in controllerFiles()) {
        final source = file.readAsStringSync();
        for (final term in forbiddenTerms) {
          expect(
            source,
            isNot(contains(term)),
            reason: '${file.path} must not contain route declarations: $term',
          );
        }
      }
    });

    test(
      'controller assignment APIs must use strongly-typed NexaBizMembershipId (Source-Level Guardrail)',
      () {
        final controllerFile = File(
          'lib/packages/permissions/presentation/controllers/roles_administration_controller.dart',
        );
        final stateFile = File(
          'lib/packages/permissions/presentation/controllers/roles_administration_state.dart',
        );

        final controllerSource = controllerFile.readAsStringSync();
        final stateSource = stateFile.readAsStringSync();

        expect(
          controllerSource,
          contains(
            'Future<bool> assignMember(NexaBizMembershipId membershipId)',
          ),
        );
        expect(
          controllerSource,
          contains(
            'Future<bool> unassignMember(NexaBizMembershipId membershipId)',
          ),
        );
        expect(
          controllerSource,
          isNot(contains('Future<bool> assignMember(String membershipId)')),
        );
        expect(
          controllerSource,
          isNot(contains('Future<bool> unassignMember(String membershipId)')),
        );

        expect(
          stateSource,
          contains('final Set<NexaBizMembershipId> pendingMembershipIds;'),
        );
        expect(
          stateSource,
          isNot(contains('final Set<String> pendingMembershipIds;')),
        );
      },
    );
  });
}
