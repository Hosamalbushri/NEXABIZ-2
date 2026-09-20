import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:nexabiz/core/company/nexabiz_company_scope.dart';
import 'package:nexabiz/core/navigation/nexabiz_route_access_requirement.dart';
import 'package:nexabiz/core/navigation/nexabiz_route_definition.dart';
import 'package:nexabiz/core/navigation/nexabiz_route_id.dart';
import 'package:nexabiz/core/permissions/nexabiz_permission_intent.dart';
import 'package:nexabiz/core/session/nexabiz_session.dart';
import 'package:nexabiz/core/setup/nexabiz_setup_readiness.dart';

void main() {
  group('company scope', () {
    test('rejects empty or padded company IDs', () {
      for (final value in ['', ' ', ' company', 'company ']) {
        expect(() => NexaBizCompanyId(value), throwsArgumentError);
      }
    });

    test('separates system setup from a validated company scope', () {
      const system = NexaBizCompanyScope.systemSetup();
      final company = NexaBizCompanyScope.company(
        NexaBizCompanyId('company-1'),
      );
      expect(system.isSystemSetup, isTrue);
      expect(system.companyId, isNull);
      expect(system.requireCompany, throwsStateError);
      expect(company.isCompany, isTrue);
      expect(company.requireCompany(), NexaBizCompanyId('company-1'));
      expect(company.companyId, NexaBizCompanyId('company-1'));
      expect(
        company,
        NexaBizCompanyScope.company(NexaBizCompanyId('company-1')),
      );
      expect(
        company.hashCode,
        NexaBizCompanyScope.company(NexaBizCompanyId('company-1')).hashCode,
      );
      expect(company.toString(), isNot(contains('company-1')));
      expect(company, isNot(system));
    });
  });

  group('session', () {
    test('no session has no company; active and locked have exactly one', () {
      const absent = NexaBizSession.noSession();
      final user = NexaBizUserId('user-1');
      final company = NexaBizCompanyId('company-1');
      final active = NexaBizSession.active(userId: user, companyId: company);
      final locked = NexaBizSession.locked(userId: user, companyId: company);
      expect(absent.state, NexaBizSessionState.noSession);
      expect(absent.companyId, isNull);
      expect(active.state, NexaBizSessionState.activeSession);
      expect(active.companyId, company);
      expect(locked.state, NexaBizSessionState.lockedSession);
      expect(locked.companyId, company);
      expect(locked.isActive, isFalse);
      expect(active, NexaBizSession.active(userId: user, companyId: company));
      expect(active, isNot(locked));
      expect(active.toString(), isNot(contains('company-1')));
    });

    test('rejects invalid user identity', () {
      expect(() => NexaBizUserId(''), throwsArgumentError);
      expect(() => NexaBizUserId(' user'), throwsArgumentError);
    });
  });

  group('setup readiness', () {
    test('cannot claim ready without the company', () {
      expect(
        () => NexaBizSetupReadiness(
          state: NexaBizSetupState.ready,
          completed: const [NexaBizSetupRequirement.adminUser],
        ),
        throwsStateError,
      );
    });

    test('cannot claim ready without the administrator', () {
      expect(
        () => NexaBizSetupReadiness(
          state: NexaBizSetupState.ready,
          completed: const [NexaBizSetupRequirement.company],
        ),
        throwsStateError,
      );
    });

    test('company and administrator suffice without business setup', () {
      final ready = NexaBizSetupReadiness(
        state: NexaBizSetupState.ready,
        completed: const [
          NexaBizSetupRequirement.company,
          NexaBizSetupRequirement.adminUser,
        ],
      );
      expect(ready.isReady, isTrue);
      expect(ready.missing, isEmpty);
    });

    test(
      'distinguishes all states and exposes immutable missing requirements',
      () {
        for (final state in [
          NexaBizSetupState.uninitialized,
          NexaBizSetupState.inProgress,
          NexaBizSetupState.blocked,
        ]) {
          final readiness = NexaBizSetupReadiness(
            state: state,
            completed: const [],
          );
          expect(readiness.isReady, isFalse);
          expect(
            readiness.missing,
            NexaBizSetupReadiness.requiredCoreRequirements,
          );
          expect(
            () => readiness.completed.add(NexaBizSetupRequirement.company),
            throwsUnsupportedError,
          );
        }
        final ready = NexaBizSetupReadiness(
          state: NexaBizSetupState.ready,
          completed: NexaBizSetupReadiness.requiredCoreRequirements,
        );
        expect(ready.isReady, isTrue);
        expect(ready.missing, isEmpty);
      },
    );
  });

  group('permission intent', () {
    test('accepts canonical IDs and rejects noncanonical IDs', () {
      expect(
        NexaBizPermissionId('platform.users.view'),
        NexaBizPermissionId('platform.users.view'),
      );
      for (final value in [
        '',
        'users.view',
        'platform.users',
        'Platform.users.view',
        'platform.users.view.more',
        'platform..view',
        'platform.users.view ',
        'platform.users.view-read',
      ]) {
        expect(() => NexaBizPermissionId(value), throwsArgumentError);
      }
    });

    test('explicit denial differs from unknown and allowance', () {
      expect(
        NexaBizPermissionDecision.deny,
        isNot(NexaBizPermissionDecision.unknown),
      );
      expect(
        NexaBizPermissionDecision.allow,
        isNot(NexaBizPermissionDecision.unknown),
      );
      final requirement = NexaBizPermissionRequirement(
        NexaBizPermissionId('platform.users.view'),
      );
      expect(requirement.permissionId.value, 'platform.users.view');
    });
  });

  test(
    'route access intent is optional and preserves existing route identity',
    () {
      const id = NexaBizRouteId(namespace: 'example', routeName: 'root');
      const existing = NexaBizRouteDefinition(routeId: id, path: '/example');
      expect(existing.accessRequirement, isNull);
      const intent = NexaBizRouteAccessRequirement(
        requiresActiveSession: true,
        requiresCompanyScope: true,
        requiresReadySetup: true,
      );
      final permissionIntent = NexaBizRouteAccessRequirement(
        requiresActiveSession: true,
        permission: NexaBizPermissionRequirement(
          NexaBizPermissionId('platform.users.view'),
        ),
      );
      expect(
        permissionIntent.permission!.permissionId.value,
        'platform.users.view',
      );
      const described = NexaBizRouteDefinition(
        routeId: id,
        path: '/example',
        accessRequirement: intent,
      );
      expect(described.routeId, existing.routeId);
      expect(described.path, existing.path);
      expect(described.accessRequirement, intent);
      expect(described, isNot(existing));
    },
  );

  test('new core contracts remain framework-neutral', () {
    final files = [
      ...Directory('lib/core/company').listSync().whereType<File>(),
      ...Directory('lib/core/session').listSync().whereType<File>(),
      ...Directory('lib/core/setup').listSync().whereType<File>(),
      ...Directory('lib/core/permissions').listSync().whereType<File>(),
      File('lib/core/navigation/nexabiz_route_access_requirement.dart'),
      File('lib/core/navigation/nexabiz_route_definition.dart'),
    ];
    final imports = RegExp(
      r'''^\s*(?:import|export)\s+['"]([^'"]+)['"]''',
      multiLine: true,
    );
    for (final file in files) {
      for (final match in imports.allMatches(file.readAsStringSync())) {
        final dependency = match.group(1)!;
        expect(
          dependency.startsWith('package:flutter/'),
          isFalse,
          reason: file.path,
        );
        expect(dependency, isNot('dart:ui'), reason: file.path);
        expect(dependency.contains('/app/'), isFalse, reason: file.path);
        expect(
          dependency.contains('/presentation/'),
          isFalse,
          reason: file.path,
        );
      }
    }
  });
}
