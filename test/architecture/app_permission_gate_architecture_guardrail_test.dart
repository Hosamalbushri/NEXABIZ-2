import 'dart:io';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AppPermissionGate Architecture Guardrails (Section 28)', () {
    test(
      '1. AppPermissionGate and AppPermissionScope MUST NOT import Drift or SQLite',
      () {
        final targetFiles = [
          File('lib/app/authorization/app_permission_gate.dart'),
          File('lib/app/authorization/app_permission_scope.dart'),
        ];

        final forbiddenImports = ['package:drift/', 'package:sqlite3/'];

        for (final file in targetFiles) {
          expect(file.existsSync(), isTrue, reason: '${file.path} must exist.');
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
      '2. AppPermissionGate MUST NOT reference CoreAuthorizationQueryStore or raw database stores',
      () {
        final file = File('lib/app/authorization/app_permission_gate.dart');
        expect(file.existsSync(), isTrue);

        final content = file.readAsStringSync();
        final forbiddenStoreReferences = [
          'CoreAuthorizationQueryStore',
          'DriftCoreAuthorizationQueryStore',
          'AppDatabase',
          'rawQuery',
          'select(',
        ];

        for (final ref in forbiddenStoreReferences) {
          expect(
            content.contains(ref),
            isFalse,
            reason:
                'AppPermissionGate must not reference $ref directly. It must only depend on NexaBizPermissionEvaluator abstraction.',
          );
        }
      },
    );

    test('3. AppPermissionGate MUST NOT check hardcoded role names or flags', () {
      final file = File('lib/app/authorization/app_permission_gate.dart');
      final content = file.readAsStringSync();

      final forbiddenRolePatterns = [
        RegExp(
          r"role\s*==\s*['"
          "]owner['"
          "]",
          caseSensitive: false,
        ),
        RegExp(
          r"role\s*==\s*['"
          "]admin['"
          "]",
          caseSensitive: false,
        ),
        RegExp(
          r"role\s*==\s*['"
          "]member['"
          "]",
          caseSensitive: false,
        ),
        RegExp(r"isOwner", caseSensitive: false),
        RegExp(r"isAdmin", caseSensitive: false),
        RegExp(r"systemAdmin", caseSensitive: false),
      ];

      for (final pattern in forbiddenRolePatterns) {
        expect(
          pattern.hasMatch(content),
          isFalse,
          reason:
              'AppPermissionGate must NOT check roles (matched ${pattern.pattern}). Access is capability-permission evaluated only.',
        );
      }
    });

    test('4. NexaBizSession MUST NOT store permission sets', () {
      final sessionFile = File('lib/core/session/nexabiz_session.dart');
      expect(sessionFile.existsSync(), isTrue);

      final content = sessionFile.readAsStringSync();
      expect(
        content.contains('Set<NexaBizPermissionId>') ||
            content.contains('permissions'),
        isFalse,
        reason:
            'Session must NOT become a permission cache or store permissions.',
      );
    });

    test(
      '5. AppPermissionGate MUST NOT own a duplicated secondary permission registry',
      () {
        final file = File('lib/app/authorization/app_permission_gate.dart');
        final content = file.readAsStringSync();

        final forbiddenRegistryPatterns = [
          RegExp(r'Map<\s*String\s*,\s*NexaBizPermission'),
          RegExp(r'Map<\s*String\s*,\s*bool'),
          RegExp(r'_permissionRegistry'),
          RegExp(r'_declaredPermissions'),
        ];

        for (final pattern in forbiddenRegistryPatterns) {
          expect(
            pattern.hasMatch(content),
            isFalse,
            reason:
                'AppPermissionGate must NOT maintain a duplicate permission registry.',
          );
        }
      },
    );

    test(
      '6. AppPermissionGate MUST document that it is UX-only and NOT an authoritative security boundary',
      () {
        final file = File('lib/app/authorization/app_permission_gate.dart');
        final content = file.readAsStringSync();

        expect(
          content.contains(
            'MUST NOT be used as the sole authorization mechanism',
          ),
          isTrue,
          reason:
              'AppPermissionGate doc must explicitly declare it is not the sole authorization mechanism.',
        );
        expect(
          content.contains('NexaBizPermissionGuard'),
          isTrue,
          reason:
              'AppPermissionGate doc must reference NexaBizPermissionGuard as the authoritative boundary.',
        );
        expect(
          content.toLowerCase().contains('fail-closed'),
          isTrue,
          reason:
              'AppPermissionGate doc must document Fail-Closed UX semantics.',
        );
      },
    );

    test(
      '7. packages/nexabiz_ui MUST NOT depend on application core or authorization',
      () {
        final pubspecFile = File('packages/nexabiz_ui/pubspec.yaml');
        expect(pubspecFile.existsSync(), isTrue);

        final content = pubspecFile.readAsStringSync();
        expect(
          content.contains('path: ../../lib') ||
              content.contains('path: ../lib'),
          isFalse,
          reason:
              'nexabiz_ui must remain independent and not depend on root app or core.',
        );
      },
    );
  });
}
