import 'package:flutter_test/flutter_test.dart';
import 'package:nexabiz/core/authorization/nexabiz_authorization_context.dart';
import 'package:nexabiz/core/authorization/nexabiz_authorization_subject.dart';
import 'package:nexabiz/core/authorization/nexabiz_membership_id.dart';
import 'package:nexabiz/core/authorization/nexabiz_permission_denied_exception.dart';
import 'package:nexabiz/core/authorization/nexabiz_permission_evaluator.dart';
import 'package:nexabiz/core/authorization/nexabiz_permission_guard.dart';
import 'package:nexabiz/core/capabilities/capability_metadata.dart';
import 'package:nexabiz/core/capabilities/contributions/nexabiz_capability_runtime_contributions.dart';
import 'package:nexabiz/core/capabilities/contributions/nexabiz_permission_contribution.dart';
import 'package:nexabiz/core/capabilities/contributions/nexabiz_setup_contribution.dart';
import 'package:nexabiz/core/capabilities/nexabiz_capability_registry.dart';
import 'package:nexabiz/core/company/nexabiz_company_scope.dart';
import 'package:nexabiz/core/navigation/nexabiz_navigation_contribution.dart';
import 'package:nexabiz/core/permissions/nexabiz_permission_intent.dart';
import 'package:nexabiz/core/roles/nexabiz_role_id.dart';
import 'package:nexabiz/core/roles/nexabiz_role_scope.dart';
import 'package:nexabiz/core/session/nexabiz_session.dart';

void main() {
  group('NexaBizRoleId Value Object', () {
    test('accepts canonical format namespace.name', () {
      final role1 = NexaBizRoleId('system.admin');
      expect(role1.value, 'system.admin');
      expect(role1.namespace, 'system');
      expect(role1.roleName, 'admin');
      expect(role1.scope, NexaBizRoleScope.system);

      final role2 = NexaBizRoleId('company.owner');
      expect(role2.value, 'company.owner');
      expect(role2.namespace, 'company');
      expect(role2.roleName, 'owner');
      expect(role2.scope, NexaBizRoleScope.company);

      final role3 = NexaBizRoleId('company.custom_accountant');
      expect(role3.value, 'company.custom_accountant');
      expect(role3.namespace, 'company');
      expect(role3.roleName, 'custom_accountant');
      expect(role3.scope, NexaBizRoleScope.company);
    });

    test('supports scoped factory constructor', () {
      final role = NexaBizRoleId.scoped(NexaBizRoleScope.company, 'cashier');
      expect(role, NexaBizRoleId('company.cashier'));
      expect(role.scope, NexaBizRoleScope.company);
      expect(role.roleName, 'cashier');
    });

    test('rejects noncanonical formats', () {
      const invalid = [
        '',
        ' ',
        'admin',
        'system.',
        '.admin',
        'system..admin',
        'system.Admin',
        'System.admin',
        'system admin',
        'system.admin.extra',
        'system-admin',
        'system.admin!',
      ];
      for (final candidate in invalid) {
        expect(
          () => NexaBizRoleId(candidate),
          throwsArgumentError,
          reason: 'Should reject "$candidate"',
        );
      }
    });

    test('implements value equality, hashCode, and toString', () {
      final a = NexaBizRoleId('company.admin');
      final b = NexaBizRoleId('company.admin');
      final c = NexaBizRoleId('company.owner');

      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
      expect(a, isNot(equals(c)));
      expect(a.toString(), 'company.admin');
    });
  });

  group('NexaBizRoleScope', () {
    test('distinguishes system vs company scope type-safely', () {
      expect(NexaBizRoleScope.system.isSystem, isTrue);
      expect(NexaBizRoleScope.system.isCompany, isFalse);

      expect(NexaBizRoleScope.company.isSystem, isFalse);
      expect(NexaBizRoleScope.company.isCompany, isTrue);
    });
  });

  group('NexaBizMembershipId Value Object', () {
    test('accepts valid unpadded string', () {
      final id = NexaBizMembershipId('mem-12345');
      expect(id.value, 'mem-12345');
    });

    test('rejects empty or whitespace-padded string', () {
      expect(() => NexaBizMembershipId(''), throwsArgumentError);
      expect(() => NexaBizMembershipId(' '), throwsArgumentError);
      expect(() => NexaBizMembershipId(' mem-123'), throwsArgumentError);
      expect(() => NexaBizMembershipId('mem-123 '), throwsArgumentError);
      expect(() => NexaBizMembershipId('  '), throwsArgumentError);
    });

    test('implements value equality, hashCode, and safe redacted toString', () {
      final a = NexaBizMembershipId('mem-1');
      final b = NexaBizMembershipId('mem-1');
      final c = NexaBizMembershipId('mem-2');

      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
      expect(a, isNot(equals(c)));
      expect(a.toString(), 'NexaBizMembershipId(<redacted>)');
      expect(a.toString(), isNot(contains('mem-1')));
    });
  });

  group('NexaBizAuthorizationSubject', () {
    test(
      'holds security identifiers and provides safe toString without secrets',
      () {
        final subject = NexaBizAuthorizationSubject(
          userId: NexaBizUserId('user-uuid-1'),
          companyId: NexaBizCompanyId('company-uuid-1'),
          membershipId: NexaBizMembershipId('membership-uuid-1'),
          sessionId: 'session-token-secret',
        );

        expect(subject.userId, NexaBizUserId('user-uuid-1'));
        expect(subject.companyId, NexaBizCompanyId('company-uuid-1'));
        expect(subject.membershipId, NexaBizMembershipId('membership-uuid-1'));
        expect(subject.sessionId, 'session-token-secret');

        final stringOutput = subject.toString();
        expect(stringOutput, isNot(contains('session-token-secret')));
        expect(stringOutput, contains('<redacted>'));
      },
    );

    test('supports value equality and hashCode', () {
      final s1 = NexaBizAuthorizationSubject(
        userId: NexaBizUserId('user-1'),
        companyId: NexaBizCompanyId('company-1'),
        membershipId: NexaBizMembershipId('mem-1'),
      );
      final s2 = NexaBizAuthorizationSubject(
        userId: NexaBizUserId('user-1'),
        companyId: NexaBizCompanyId('company-1'),
        membershipId: NexaBizMembershipId('mem-1'),
      );
      final s3 = NexaBizAuthorizationSubject(userId: NexaBizUserId('user-2'));

      expect(s1, equals(s2));
      expect(s1.hashCode, equals(s2.hashCode));
      expect(s1, isNot(equals(s3)));
    });
  });

  group('NexaBizAuthorizationContext', () {
    test('NexaBizSystemAuthorizationContext maintains pure system scope', () {
      final context = NexaBizSystemAuthorizationContext(
        userId: NexaBizUserId('sys-admin'),
        sessionId: 'session-id-1',
      );

      expect(context.scope, NexaBizRoleScope.system);
      expect(context.isSystem, isTrue);
      expect(context.isCompany, isFalse);
      expect(context.userId, NexaBizUserId('sys-admin'));
      expect(context.sessionId, 'session-id-1');
      expect(context.subject.companyId, isNull);
      expect(context.subject.membershipId, isNull);

      final subjectWithCompany = NexaBizAuthorizationSubject(
        userId: NexaBizUserId('sys-admin'),
        companyId: NexaBizCompanyId('comp-1'),
      );
      expect(
        () => NexaBizSystemAuthorizationContext.fromSubject(subjectWithCompany),
        throwsArgumentError,
      );
    });

    test(
      'NexaBizCompanyAuthorizationContext guarantees non-null company and membership',
      () {
        final context = NexaBizCompanyAuthorizationContext(
          userId: NexaBizUserId('user-1'),
          companyId: NexaBizCompanyId('comp-1'),
          membershipId: NexaBizMembershipId('mem-1'),
          sessionId: 'session-1',
        );

        expect(context.scope, NexaBizRoleScope.company);
        expect(context.isSystem, isFalse);
        expect(context.isCompany, isTrue);
        expect(context.companyId, NexaBizCompanyId('comp-1'));
        expect(context.membershipId, NexaBizMembershipId('mem-1'));
        expect(context.userId, NexaBizUserId('user-1'));
        expect(context.sessionId, 'session-1');

        final incompleteSubject = NexaBizAuthorizationSubject(
          userId: NexaBizUserId('user-1'),
          companyId: NexaBizCompanyId('comp-1'),
          // missing membershipId
        );
        expect(
          () =>
              NexaBizCompanyAuthorizationContext.fromSubject(incompleteSubject),
          throwsArgumentError,
        );
      },
    );

    test(
      'pattern matching over sealed NexaBizAuthorizationContext is exhaustive',
      () {
        NexaBizAuthorizationContext ctx = NexaBizSystemAuthorizationContext(
          userId: NexaBizUserId('user-1'),
        );

        String describe(NexaBizAuthorizationContext c) => switch (c) {
          NexaBizSystemAuthorizationContext() => 'system',
          NexaBizCompanyAuthorizationContext() => 'company',
        };

        expect(describe(ctx), 'system');

        ctx = NexaBizCompanyAuthorizationContext(
          userId: NexaBizUserId('user-1'),
          companyId: NexaBizCompanyId('comp-1'),
          membershipId: NexaBizMembershipId('mem-1'),
        );
        expect(describe(ctx), 'company');
      },
    );
  });

  group('NexaBizPermissionDecision Fail-Closed Semantics', () {
    test('isAllowed is true only for allow', () {
      expect(NexaBizPermissionDecision.allow.isAllowed, isTrue);
      expect(NexaBizPermissionDecision.allow.isDenied, isFalse);
      expect(NexaBizPermissionDecision.allow.isUnknown, isFalse);

      expect(NexaBizPermissionDecision.deny.isAllowed, isFalse);
      expect(NexaBizPermissionDecision.deny.isDenied, isTrue);
      expect(NexaBizPermissionDecision.deny.isUnknown, isFalse);

      expect(NexaBizPermissionDecision.unknown.isAllowed, isFalse);
      expect(NexaBizPermissionDecision.unknown.isDenied, isFalse);
      expect(NexaBizPermissionDecision.unknown.isUnknown, isTrue);
    });
  });

  group('NexaBizPermissionEvaluator and Guard', () {
    test('guard passes when evaluator returns allow', () async {
      final evaluator = _FakeEvaluator({
        'company.record.read': NexaBizPermissionDecision.allow,
      });
      final guard = NexaBizDefaultPermissionGuard(evaluator);
      final context = NexaBizCompanyAuthorizationContext(
        userId: NexaBizUserId('u-1'),
        companyId: NexaBizCompanyId('c-1'),
        membershipId: NexaBizMembershipId('m-1'),
      );

      await expectLater(
        guard.requirePermission(
          context: context,
          permissionId: NexaBizPermissionId('company.record.read'),
        ),
        completes,
      );
    });

    test(
      'guard throws NexaBizPermissionDeniedException when evaluator returns deny',
      () async {
        final evaluator = _FakeEvaluator({
          'company.record.delete': NexaBizPermissionDecision.deny,
        });
        final guard = NexaBizDefaultPermissionGuard(evaluator);
        final context = NexaBizCompanyAuthorizationContext(
          userId: NexaBizUserId('u-1'),
          companyId: NexaBizCompanyId('c-1'),
          membershipId: NexaBizMembershipId('m-1'),
        );

        final permId = NexaBizPermissionId('company.record.delete');
        try {
          await guard.requirePermission(context: context, permissionId: permId);
          fail('Should throw NexaBizPermissionDeniedException');
        } on NexaBizPermissionDeniedException catch (e) {
          expect(e.permissionId, permId);
          expect(e.contextScope, NexaBizRoleScope.company);
          expect(e.decision, NexaBizPermissionDecision.deny);
          expect(e.toString(), contains('company.record.delete'));
          expect(e.toString(), contains('company'));
          expect(e.toString(), contains('deny'));
        }
      },
    );

    test(
      'guard throws NexaBizPermissionDeniedException on unknown (Fail-Closed)',
      () async {
        final evaluator = _FakeEvaluator(
          {},
        ); // empty, so everything returns unknown
        final guard = NexaBizDefaultPermissionGuard(evaluator);
        final context = NexaBizSystemAuthorizationContext(
          userId: NexaBizUserId('admin-1'),
        );

        final permId = NexaBizPermissionId('system.backup.run');
        try {
          await guard.requirePermission(context: context, permissionId: permId);
          fail('Should throw NexaBizPermissionDeniedException on unknown');
        } on NexaBizPermissionDeniedException catch (e) {
          expect(e.permissionId, permId);
          expect(e.contextScope, NexaBizRoleScope.system);
          expect(e.decision, NexaBizPermissionDecision.unknown);
        }
      },
    );
  });

  group('Capability Registry Namespace Ownership Validation', () {
    test('allows capability to declare permissions in its own namespace', () {
      final registry = NexaBizCapabilityRegistry()
        ..register(
          _TestCapability(
            'sales',
            declared: [NexaBizPermissionId('sales.order.create')],
            required: [
              NexaBizPermissionRequirement(
                NexaBizPermissionId('inventory.item.read'),
              ),
            ],
          ),
        );

      registry.validateAndLock();
      expect(registry.isLocked, isTrue);
    });

    test('rejects capability declaring permissions outside its namespace', () {
      final registry = NexaBizCapabilityRegistry()
        ..register(
          _TestCapability(
            'sales',
            declared: [
              NexaBizPermissionId('inventory.item.create'), // wrong namespace!
            ],
          ),
        );

      expect(
        registry.validateAndLock,
        throwsA(
          isA<StateError>().having(
            (e) => e.message,
            'message',
            contains(
              'Capability "sales" cannot declare permission "inventory.item.create" outside its namespace.',
            ),
          ),
        ),
      );
    });
  });
}

final class _FakeEvaluator implements NexaBizPermissionEvaluator {
  final Map<String, NexaBizPermissionDecision> rules;

  _FakeEvaluator(this.rules);

  @override
  Future<NexaBizPermissionDecision> evaluate({
    required NexaBizAuthorizationContext context,
    required NexaBizPermissionId permissionId,
  }) async {
    return rules[permissionId.value] ?? NexaBizPermissionDecision.unknown;
  }
}

final class _TestCapability
    implements NexaBizCapabilityWithRuntimeContributions {
  _TestCapability(
    this.capabilityId, {
    this.declared = const [],
    this.required = const [],
  });

  @override
  final String capabilityId;

  final List<NexaBizPermissionId> declared;
  final List<NexaBizPermissionRequirement> required;

  @override
  List<String> get dependsOn => const [];

  @override
  CapabilityMetadata get metadata =>
      const CapabilityMetadata(nameKey: 'test', iconIdentifier: 'test');

  @override
  NexaBizNavigationContribution? get navigationContribution => null;

  @override
  NexaBizPermissionContribution? get permissionContribution =>
      _TestPermissions(declared, required);

  @override
  NexaBizSetupContribution? get setupContribution => null;
}

final class _TestPermissions implements NexaBizPermissionContribution {
  _TestPermissions(this.declaredPermissionIds, this.requiredPermissions);

  @override
  final List<NexaBizPermissionId> declaredPermissionIds;

  @override
  final List<NexaBizPermissionRequirement> requiredPermissions;
}
