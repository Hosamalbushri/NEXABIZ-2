import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  final administrationDirectory = Directory(
    'lib/core/authorization/administration',
  );

  List<File> administrationFiles() => administrationDirectory
      .listSync(recursive: true)
      .whereType<File>()
      .where((file) => file.path.endsWith('.dart'))
      .toList();

  group('Authorization administration architecture guardrails', () {
    test(
      'contracts remain pure Dart with no persistence, router, or UI imports',
      () {
        final forbiddenImports = [
          'package:flutter/',
          'package:drift/',
          'package:sqlite3/',
          'package:go_router/',
          'package:nexabiz_ui/',
          '/presentation/',
          '/app/persistence/',
        ];

        for (final file in administrationFiles()) {
          final source = file.readAsStringSync();
          for (final forbidden in forbiddenImports) {
            expect(
              source,
              isNot(contains(forbidden)),
              reason: '${file.path} must not depend on $forbidden',
            );
          }
        }
      },
    );

    test('contracts contain no raw SQL or exception-string classification', () {
      final forbiddenPatterns = [
        RegExp(r'\bcustomSelect\b'),
        RegExp(r'\bcustomStatement\b'),
        RegExp(r'\brawQuery\b'),
        RegExp(r'\bSELECT\s', caseSensitive: false),
        RegExp(r'\bINSERT\s', caseSensitive: false),
        RegExp(r'\bUPDATE\s', caseSensitive: false),
        RegExp(r'\bDELETE\s', caseSensitive: false),
        RegExp(r'e\.toString\(\)\.contains'),
      ];

      for (final file in administrationFiles()) {
        final source = file.readAsStringSync();
        for (final pattern in forbiddenPatterns) {
          expect(
            pattern.hasMatch(source),
            isFalse,
            reason: '${file.path} contains forbidden ${pattern.pattern}',
          );
        }
      }
    });

    test(
      'legacy membership role and role-name authorization are forbidden',
      () {
        final forbiddenPatterns = [
          RegExp(r'core_company_memberships\.role'),
          RegExp(r'membership\.role'),
          RegExp(r'\bisAdmin\b'),
          RegExp(r'\bisOwner\b'),
          RegExp(r'''role\s*(?:==|!=)\s*['"]'''),
        ];

        for (final file in administrationFiles()) {
          final source = file.readAsStringSync();
          for (final pattern in forbiddenPatterns) {
            expect(
              pattern.hasMatch(source),
              isFalse,
              reason: '${file.path} contains forbidden ${pattern.pattern}',
            );
          }
        }
      },
    );

    test('built-in owner identity is centralized in exactly one policy file', () {
      final filesContainingOwner = administrationFiles()
          .where((file) => file.readAsStringSync().contains("'company.owner'"))
          .map((file) => file.path.replaceAll('\\', '/'))
          .toList();

      expect(filesContainingOwner, [
        'lib/core/authorization/administration/nexabiz_authorization_administration_policy.dart',
      ]);
    });

    test('store API uses typed, tenant-explicit identities', () {
      final source = File(
        'lib/core/authorization/administration/nexabiz_authorization_administration_store.dart',
      ).readAsStringSync();

      expect(source, contains('required NexaBizCompanyId companyId'));
      expect(source, contains('required NexaBizRoleId roleId'));
      expect(source, contains('required NexaBizMembershipId membershipId'));
      expect(source, isNot(contains('required String companyId')));
      expect(source, isNot(contains('required String roleId')));
      expect(source, isNot(contains('required String membershipId')));
    });

    test('future mutation UseCases must use Guard and company context', () {
      final useCaseFiles = Directory('lib')
          .listSync(recursive: true)
          .whereType<File>()
          .where((file) {
            if (!file.path.endsWith('.dart') ||
                !(file.path.contains('/usecases/') ||
                    file.path.contains('/use_cases/'))) {
              return false;
            }
            final source = file.readAsStringSync();
            return source.contains(
                  'NexaBizAuthorizationAdministrationMutationStore',
                ) ||
                source.contains('NexaBizAuthorizationAdministrationStore');
          });

      for (final file in useCaseFiles) {
        final source = file.readAsStringSync();
        expect(
          source,
          contains('NexaBizPermissionGuard'),
          reason: '${file.path} must enforce PermissionGuard before mutation.',
        );
        expect(
          source,
          contains('NexaBizCompanyAuthorizationContext'),
          reason: '${file.path} must require trusted company context.',
        );
        expect(
          source,
          isNot(contains('NexaBizPermissionEvaluator')),
          reason: '${file.path} must not bypass PermissionGuard.',
        );
      }
    });

    test(
      'presentation layer MUST NOT import Administration Store or Drift implementation',
      () {
        final libDir = Directory('lib');
        final presentationFiles = libDir
            .listSync(recursive: true)
            .whereType<File>()
            .where(
              (f) =>
                  f.path.contains('/presentation/') && f.path.endsWith('.dart'),
            )
            .toList();

        final forbiddenTypes = [
          'NexaBizAuthorizationAdministrationMutationStore',
          'NexaBizAuthorizationAdministrationQueryStore',
          'NexaBizAuthorizationAdministrationStore',
          'DriftAuthorizationAdministrationStore',
          'drift_authorization_administration_store.dart',
        ];

        for (final file in presentationFiles) {
          final content = file.readAsStringSync();
          for (final forbidden in forbiddenTypes) {
            expect(
              content.contains(forbidden),
              isFalse,
              reason:
                  '${file.path} in presentation layer must not reference $forbidden.',
            );
          }
        }
      },
    );

    test('all administration mutation UseCases require invalidation signal', () {
      final mutationUseCaseFiles = Directory('lib/app/authorization/use_cases')
          .listSync()
          .whereType<File>()
          .where(
            (f) =>
                f.path.endsWith('.dart') &&
                (f.path.contains('create_') ||
                    f.path.contains('update_') ||
                    f.path.contains('delete_') ||
                    f.path.contains('assign_') ||
                    f.path.contains('unassign_') ||
                    f.path.contains('grant_') ||
                    f.path.contains('revoke_')),
          )
          .toList();

      expect(mutationUseCaseFiles.length, 7);

      for (final file in mutationUseCaseFiles) {
        final content = file.readAsStringSync();
        expect(
          content,
          contains('NexaBizAuthorizationInvalidationSignal'),
          reason:
              '${file.path} must depend on NexaBizAuthorizationInvalidationSignal.',
        );
        expect(
          content,
          contains('notifyAuthorizationChanged()'),
          reason:
              '${file.path} must invoke notifyAuthorizationChanged() after commit.',
        );
      }
    });

    test('all administration query UseCases enforce PermissionGuard', () {
      final queryUseCaseFiles = Directory('lib/app/authorization/use_cases')
          .listSync()
          .whereType<File>()
          .where(
            (f) =>
                f.path.endsWith('.dart') &&
                (f.path.contains('get_') ||
                    f.path.contains('list_') ||
                    f.path.contains('inspect_')),
          )
          .toList();

      expect(queryUseCaseFiles.length, 8);

      for (final file in queryUseCaseFiles) {
        final content = file.readAsStringSync();
        expect(
          content,
          contains('NexaBizPermissionGuard'),
          reason: '${file.path} must depend on NexaBizPermissionGuard.',
        );
        expect(
          content,
          contains('requirePermission'),
          reason: '${file.path} must invoke requirePermission before query.',
        );
        expect(
          content,
          isNot(contains('NexaBizAuthorizationInvalidationSignal')),
          reason:
              '${file.path} query usecase must not emit invalidation signals.',
        );
      }
    });

    test(
      'administration architecture contract exists and records invariants',
      () {
        final contract = File(
          'docs/architecture/07_AUTHORIZATION_ADMINISTRATION_CONTRACT.md',
        );
        expect(contract.existsSync(), isTrue);
        final source = contract.readAsStringSync();

        for (final requiredText in [
          'trusted NexaBizCompanyAuthorizationContext',
          'successful commit',
          'authorization invalidation notification',
          'last-owner aggregate invariant',
          'System authorization remains deferred and fail-closed',
          'legacy `core_company_memberships.role`',
        ]) {
          expect(source, contains(requiredText));
        }
      },
    );
  });
}
