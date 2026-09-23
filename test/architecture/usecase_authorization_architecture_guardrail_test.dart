import 'dart:io';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('UseCase Authorization Architecture Guardrails', () {
    test(
      'Mandatory Contract: docs/architecture/06_AUTHORIZATION_USECASE_CONTRACT.md MUST exist and define core invariants',
      () {
        final contractFile = File(
          'docs/architecture/06_AUTHORIZATION_USECASE_CONTRACT.md',
        );
        expect(
          contractFile.existsSync(),
          isTrue,
          reason: 'Contract 06_AUTHORIZATION_USECASE_CONTRACT.md MUST exist.',
        );

        final content = contractFile.readAsStringSync();
        expect(
          content.toLowerCase().contains('zero side effects'),
          isTrue,
          reason: 'Contract must declare that denial yields ZERO side effects.',
        );
        expect(
          content.contains(
            'UI -> UseCase -> PermissionGuard -> PermissionEvaluator -> Persistence',
          ),
          isTrue,
          reason: 'Contract must declare the canonical execution sequence.',
        );
        expect(
          content.contains('fromSession'),
          isTrue,
          reason: 'Contract must require context provenance via fromSession.',
        );
        expect(
          content.toLowerCase().contains('fail closed') ||
              content.toLowerCase().contains('fail-closed'),
          isTrue,
          reason: 'Contract must require Fail-Closed security semantics.',
        );
      },
    );

    test(
      'Presentation layer MUST NOT import or reference CoreAuthorizationQueryStore',
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

        for (final file in presentationFiles) {
          final content = file.readAsStringSync();
          expect(
            content.contains('CoreAuthorizationQueryStore'),
            isFalse,
            reason:
                '${file.path} in presentation layer must not reference CoreAuthorizationQueryStore.',
          );
          expect(
            content.contains('DriftCoreAuthorizationQueryStore'),
            isFalse,
            reason:
                '${file.path} in presentation layer must not reference DriftCoreAuthorizationQueryStore.',
          );
        }
      },
    );

    test(
      'Any UseCase or Domain files MUST NOT import Drift, SQLite, GoRouter, or UI packages',
      () {
        final libDir = Directory('lib');
        final domainAndUseCaseFiles = libDir
            .listSync(recursive: true)
            .whereType<File>()
            .where(
              (f) =>
                  (f.path.contains('/usecases/') ||
                      f.path.contains('/use_cases/') ||
                      f.path.contains('/domain/')) &&
                  f.path.endsWith('.dart'),
            )
            .toList();

        final forbiddenImports = [
          'package:drift/',
          'package:sqlite3/',
          'package:go_router/',
          'package:flutter/widgets.dart',
          'package:flutter/material.dart',
          'package:nexabiz_ui/',
        ];

        for (final file in domainAndUseCaseFiles) {
          final content = file.readAsStringSync();
          for (final forbidden in forbiddenImports) {
            expect(
              content.contains(forbidden),
              isFalse,
              reason: '${file.path} must not import $forbidden.',
            );
          }
        }
      },
    );

    test(
      'UseCases MUST NOT bypass PermissionGuard to depend directly on PermissionEvaluator',
      () {
        final libDir = Directory('lib');
        final useCaseFiles = libDir
            .listSync(recursive: true)
            .whereType<File>()
            .where(
              (f) =>
                  (f.path.contains('/usecases/') ||
                      f.path.contains('/use_cases/')) &&
                  f.path.endsWith('.dart'),
            )
            .toList();

        for (final file in useCaseFiles) {
          final content = file.readAsStringSync();
          expect(
            content.contains('nexabiz_permission_evaluator.dart'),
            isFalse,
            reason:
                '${file.path} must use NexaBizPermissionGuard, not NexaBizPermissionEvaluator directly.',
          );
        }
      },
    );

    test(
      'UseCases MUST NOT check hardcoded role names or flags (isAdmin, isOwner, role ==)',
      () {
        final libDir = Directory('lib');
        final useCaseFiles = libDir
            .listSync(recursive: true)
            .whereType<File>()
            .where(
              (f) =>
                  (f.path.contains('/usecases/') ||
                      f.path.contains('/use_cases/')) &&
                  f.path.endsWith('.dart'),
            )
            .toList();

        final antiPatterns = [
          'isAdmin',
          'isOwner',
          'isSuperuser',
          'systemAdmin',
        ];

        for (final file in useCaseFiles) {
          final content = file.readAsStringSync();
          for (final pattern in antiPatterns) {
            expect(
              content.contains(pattern),
              isFalse,
              reason:
                  '${file.path} contains forbidden role-check anti-pattern: $pattern',
            );
          }
        }
      },
    );

    test(
      'NexaBizPermissionGuard MUST enforce non-nullable required context and permissionId',
      () {
        final file = File(
          'lib/core/authorization/nexabiz_permission_guard.dart',
        );
        expect(file.existsSync(), isTrue);

        final content = file.readAsStringSync();
        expect(
          content.contains('required NexaBizAuthorizationContext context'),
          isTrue,
          reason:
              'PermissionGuard must require non-nullable context parameter.',
        );
        expect(
          content.contains('required NexaBizPermissionId permissionId'),
          isTrue,
          reason:
              'PermissionGuard must require non-nullable permissionId parameter.',
        );
        expect(
          content.contains('NexaBizPermissionDeniedException'),
          isTrue,
          reason:
              'PermissionGuard must throw NexaBizPermissionDeniedException on non-allowed decision.',
        );
      },
    );

    test(
      'NexaBizAuthorizationContext.fromSession enforces active session with user and company',
      () {
        final file = File(
          'lib/core/authorization/nexabiz_authorization_context.dart',
        );
        expect(file.existsSync(), isTrue);

        final content = file.readAsStringSync();
        expect(
          content.contains('factory NexaBizAuthorizationContext.fromSession'),
          isTrue,
          reason:
              'NexaBizAuthorizationContext must provide fromSession factory.',
        );
        expect(
          content.contains('session.isActive'),
          isTrue,
          reason: 'fromSession factory must validate session is active.',
        );
      },
    );
  });
}
