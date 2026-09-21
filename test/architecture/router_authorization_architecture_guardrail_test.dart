import 'dart:io';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Router Authorization Defense-in-Depth Architecture Guardrails', () {
    test('Router and Navigation layers MUST NOT import Drift or SQLite', () {
      final targetDirs = [
        Directory('lib/app/router'),
        Directory('lib/core/navigation'),
      ];

      final forbiddenImports = [
        'package:drift/',
        'package:sqlite3/',
      ];

      for (final dir in targetDirs) {
        if (!dir.existsSync()) continue;
        final files = dir
            .listSync(recursive: true)
            .whereType<File>()
            .where((f) => f.path.endsWith('.dart'));

        for (final file in files) {
          final content = file.readAsStringSync();
          for (final forbidden in forbiddenImports) {
            expect(
              content.contains(forbidden),
              isFalse,
              reason: '${file.path} must not import $forbidden.',
            );
          }
        }
      }
    });

    test('Router MUST NOT directly reference CoreAuthorizationQueryStore or database query stores', () {
      final routerDir = Directory('lib/app/router');
      final files = routerDir
          .listSync(recursive: true)
          .whereType<File>()
          .where((f) => f.path.endsWith('.dart'));

      final forbiddenStoreReferences = [
        'CoreAuthorizationQueryStore',
        'DriftCoreAuthorizationQueryStore',
        'AppDatabase',
      ];

      for (final file in files) {
        final content = file.readAsStringSync();
        for (final ref in forbiddenStoreReferences) {
          expect(
            content.contains(ref),
            isFalse,
            reason: '${file.path} must not reference $ref directly. Router must only use NexaBizPermissionEvaluator abstraction.',
          );
        }
      }
    });

    test('Router MUST NOT inspect hardcoded role names or bypass permission evaluator via role checks', () {
      final routerFile = File('lib/app/router/nexabiz_router_adapter.dart');
      expect(routerFile.existsSync(), isTrue);

      final content = routerFile.readAsStringSync();
      final forbiddenRolePatterns = [
        RegExp(r"role\s*==\s*['""]owner['""]", caseSensitive: false),
        RegExp(r"role\s*==\s*['""]admin['""]", caseSensitive: false),
        RegExp(r"role\s*==\s*['""]member['""]", caseSensitive: false),
        RegExp(r"isOwner", caseSensitive: false),
        RegExp(r"isAdmin", caseSensitive: false),
        RegExp(r"systemAdmin", caseSensitive: false),
      ];

      for (final pattern in forbiddenRolePatterns) {
        expect(
          pattern.hasMatch(content),
          isFalse,
          reason: 'Router must NOT perform role-based bypasses (matched ${pattern.pattern}). Access decisions must be capability-permission based.',
        );
      }
    });

    test('Router MUST NOT contain secondary/hardcoded path-to-permission mapping table', () {
      final routerFile = File('lib/app/router/nexabiz_router_adapter.dart');
      expect(routerFile.existsSync(), isTrue);

      final content = routerFile.readAsStringSync();

      // Ensure no Map<String, NexaBizPermissionId> or path-to-permission hardcoded table exists
      final forbiddenMapPatterns = [
        RegExp(r'Map<\s*String\s*,\s*NexaBizPermission'),
        RegExp(r'Map<\s*String\s*,\s*PermissionRequirement'),
        RegExp(r'_pathToPermission'),
        RegExp(r'_routePermissions'),
      ];

      for (final pattern in forbiddenMapPatterns) {
        expect(
          pattern.hasMatch(content),
          isFalse,
          reason: 'Router must get permissions strictly from NexaBizRouteDefinition.accessRequirement.permission, not an ad-hoc map.',
        );
      }
    });

    test('Unauthorized route (/unauthorized) MUST exist in Permissions capability and be accessible without permissions', () {
      final capabilityFile = File('lib/packages/permissions/permissions_capability.dart');
      expect(capabilityFile.existsSync(), isTrue);

      final content = capabilityFile.readAsStringSync();
      expect(
        content.contains("path: '/unauthorized'"),
        isTrue,
        reason: 'Permissions capability must contribute the canonical /unauthorized route.',
      );
      expect(
        content.contains('requiresReadySetup: false') || !content.contains("path: '/unauthorized',\n          accessRequirement: NexaBizRouteAccessRequirement(permission:"),
        isTrue,
        reason: '/unauthorized must not require permission or cause redirect loops.',
      );
    });

    test('Router redirects access denials to canonical /unauthorized and never leaks to /login or /company-selection', () {
      final routerFile = File('lib/app/router/nexabiz_router_adapter.dart');
      final content = routerFile.readAsStringSync();

      expect(
        content.contains("return '/unauthorized';"),
        isTrue,
        reason: 'Router must redirect authorization failures to /unauthorized.',
      );
    });

    test('Router invalidation signal MUST decouple Router from persistence tables', () {
      final signalFile = File('lib/app/authorization/nexabiz_authorization_invalidation_signal.dart');
      expect(signalFile.existsSync(), isTrue);

      final content = signalFile.readAsStringSync();
      expect(
        content.contains('package:drift/'),
        isFalse,
        reason: 'Authorization invalidation signal must be persistence-agnostic.',
      );
      expect(
        content.contains('ChangeNotifier'),
        isTrue,
        reason: 'Signal must extend/implement ChangeNotifier/Listenable.',
      );
    });
  });
}
