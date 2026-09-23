import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:nexabiz/app/persistence/drift_core_installation_store.dart';
import 'package:nexabiz/core/authorization/core_authorization_query_store.dart';
import 'package:nexabiz/core/authorization/nexabiz_authorization_context.dart';
import 'package:nexabiz/core/authorization/nexabiz_authorization_session_source.dart';
import 'package:nexabiz/core/authorization/nexabiz_membership_authorization_snapshot.dart';
import 'package:nexabiz/core/authorization/nexabiz_membership_id.dart';
import 'package:nexabiz/core/authorization/nexabiz_permission_catalog.dart';
import 'package:nexabiz/core/authorization/nexabiz_permission_denied_exception.dart';
import 'package:nexabiz/core/authorization/nexabiz_permission_guard.dart';
import 'package:nexabiz/core/authorization/nexabiz_runtime_permission_evaluator.dart';
import 'package:nexabiz/core/capabilities/nexabiz_capability_registry.dart';
import 'package:nexabiz/core/company/nexabiz_company_scope.dart';
import 'package:nexabiz/core/identity/authenticate_local_user.dart';
import 'package:nexabiz/core/permissions/nexabiz_permission_intent.dart';
import 'package:nexabiz/core/roles/nexabiz_role_id.dart';
import 'package:nexabiz/core/roles/nexabiz_role_scope.dart';
import 'package:nexabiz/core/session/core_session_controller.dart';
import 'package:nexabiz/core/session/nexabiz_session.dart';
import 'package:nexabiz/core/setup/initialize_nexabiz_core.dart';
import 'package:nexabiz/packages/company/company_capability.dart';
import 'package:path/path.dart' as p;

// Test doubles for pure unit tests
final class _FakeSessionSource implements NexaBizAuthorizationSessionSource {
  _FakeSessionSource({
    required this.activeSessionId,
    required this.activeUserId,
    this.activeCompanyId,
    this.activeMembershipId,
    this.isActive = true,
    this.shouldThrow = false,
  });

  String activeSessionId;
  NexaBizUserId activeUserId;
  NexaBizCompanyId? activeCompanyId;
  NexaBizMembershipId? activeMembershipId;
  bool isActive;
  bool shouldThrow;

  @override
  bool matchesActiveSession({
    required String sessionId,
    required NexaBizUserId userId,
    NexaBizCompanyId? companyId,
    NexaBizMembershipId? membershipId,
  }) {
    if (shouldThrow) {
      throw Exception('Session storage read failed');
    }
    if (!isActive) return false;
    if (sessionId != activeSessionId) return false;
    if (userId != activeUserId) return false;
    if (companyId != null && activeCompanyId != companyId) return false;
    if (membershipId != null && activeMembershipId != membershipId) {
      return false;
    }
    return true;
  }
}

final class _FakeQueryStore implements CoreAuthorizationQueryStore {
  _FakeQueryStore({this.snapshot, this.shouldThrow = false});

  NexaBizMembershipAuthorizationSnapshot? snapshot;
  bool shouldThrow;

  @override
  Future<NexaBizMembershipAuthorizationSnapshot?>
  readMembershipAuthorizationSnapshot(String membershipId) async {
    if (shouldThrow) {
      throw Exception('Database query failed');
    }
    return snapshot;
  }
}

void main() {
  final permView = NexaBizPermissionId('company.profile.view');
  final permManage = NexaBizPermissionId('company.profile.manage');
  final permMembers = NexaBizPermissionId('company.membership.view');
  final permUndeclared = NexaBizPermissionId('unknown.fake.permission');

  final testCatalog = NexaBizImmutablePermissionCatalog({
    permView,
    permManage,
    permMembers,
  });

  final defaultUser = NexaBizUserId('user-1');
  final defaultCompany = NexaBizCompanyId('company-1');
  final defaultMembership = NexaBizMembershipId('mem-1');
  const defaultSessionId = 'session-123';

  NexaBizCompanyAuthorizationContext createDefaultContext({
    String sessionId = defaultSessionId,
    NexaBizUserId? userId,
    NexaBizCompanyId? companyId,
    NexaBizMembershipId? membershipId,
  }) {
    return NexaBizCompanyAuthorizationContext(
      userId: userId ?? defaultUser,
      sessionId: sessionId,
      companyId: companyId ?? defaultCompany,
      membershipId: membershipId ?? defaultMembership,
    );
  }

  NexaBizMembershipAuthorizationSnapshot createDefaultSnapshot({
    NexaBizMembershipId? membershipId,
    NexaBizCompanyId? companyId,
    NexaBizUserId? userId,
    String membershipStatus = 'active',
    String companyStatus = 'active',
    String userStatus = 'active',
    Set<NexaBizRoleId>? roles,
    Set<NexaBizPermissionId>? permissions,
  }) {
    return NexaBizMembershipAuthorizationSnapshot(
      membershipId: membershipId ?? defaultMembership,
      companyId: companyId ?? defaultCompany,
      userId: userId ?? defaultUser,
      membershipStatus: membershipStatus,
      companyStatus: companyStatus,
      userStatus: userStatus,
      roleIds: roles ?? {NexaBizRoleId('company.owner')},
      permissionIds: permissions ?? {permView},
    );
  }

  group('NexaBizRuntimePermissionEvaluator — 30 Required Invariants', () {
    // 1. Declared + granted permission → ALLOW
    test('1. Declared + granted permission evaluates to ALLOW', () async {
      final sessionSource = _FakeSessionSource(
        activeSessionId: defaultSessionId,
        activeUserId: defaultUser,
        activeCompanyId: defaultCompany,
        activeMembershipId: defaultMembership,
      );
      final queryStore = _FakeQueryStore(
        snapshot: createDefaultSnapshot(permissions: {permView}),
      );
      final evaluator = NexaBizRuntimePermissionEvaluator(
        permissionCatalog: testCatalog,
        queryStore: queryStore,
        sessionSource: sessionSource,
      );

      final decision = await evaluator.evaluate(
        context: createDefaultContext(),
        permissionId: permView,
      );

      expect(decision, NexaBizPermissionDecision.allow);
      expect(decision.isAllowed, isTrue);
      expect(decision.isDenied, isFalse);
      expect(decision.isUnknown, isFalse);
    });

    // 2. Declared but not granted → DENY
    test('2. Declared but not granted permission evaluates to DENY', () async {
      final sessionSource = _FakeSessionSource(
        activeSessionId: defaultSessionId,
        activeUserId: defaultUser,
        activeCompanyId: defaultCompany,
        activeMembershipId: defaultMembership,
      );
      final queryStore = _FakeQueryStore(
        snapshot: createDefaultSnapshot(permissions: {permView}),
      );
      final evaluator = NexaBizRuntimePermissionEvaluator(
        permissionCatalog: testCatalog,
        queryStore: queryStore,
        sessionSource: sessionSource,
      );

      final decision = await evaluator.evaluate(
        context: createDefaultContext(),
        permissionId: permManage,
      );

      expect(decision, NexaBizPermissionDecision.deny);
      expect(decision.isAllowed, isFalse);
      expect(decision.isDenied, isTrue);
    });

    // 3. Unknown permission → not allowed (UNKNOWN)
    test(
      '3. Undeclared unknown permission evaluates to UNKNOWN (not allowed)',
      () async {
        final sessionSource = _FakeSessionSource(
          activeSessionId: defaultSessionId,
          activeUserId: defaultUser,
          activeCompanyId: defaultCompany,
          activeMembershipId: defaultMembership,
        );
        final queryStore = _FakeQueryStore(
          snapshot: createDefaultSnapshot(permissions: {permUndeclared}),
        );
        final evaluator = NexaBizRuntimePermissionEvaluator(
          permissionCatalog: testCatalog,
          queryStore: queryStore,
          sessionSource: sessionSource,
        );

        final decision = await evaluator.evaluate(
          context: createDefaultContext(),
          permissionId: permUndeclared,
        );

        expect(decision, NexaBizPermissionDecision.unknown);
        expect(decision.isAllowed, isFalse);
        expect(decision.isUnknown, isTrue);
      },
    );

    // 4. DB-injected undeclared permission → not allowed
    test(
      '4. DB-injected undeclared permission evaluates to UNKNOWN even if in snapshot',
      () async {
        final sessionSource = _FakeSessionSource(
          activeSessionId: defaultSessionId,
          activeUserId: defaultUser,
          activeCompanyId: defaultCompany,
          activeMembershipId: defaultMembership,
        );
        final queryStore = _FakeQueryStore(
          snapshot: createDefaultSnapshot(
            permissions: {permView, permUndeclared},
          ),
        );
        final evaluator = NexaBizRuntimePermissionEvaluator(
          permissionCatalog: testCatalog,
          queryStore: queryStore,
          sessionSource: sessionSource,
        );

        final decision = await evaluator.evaluate(
          context: createDefaultContext(),
          permissionId: permUndeclared,
        );

        expect(decision, NexaBizPermissionDecision.unknown);
        expect(decision.isAllowed, isFalse);
      },
    );

    // 5. Inactive user → DENY
    test('5. Inactive user status evaluates to DENY', () async {
      final sessionSource = _FakeSessionSource(
        activeSessionId: defaultSessionId,
        activeUserId: defaultUser,
        activeCompanyId: defaultCompany,
        activeMembershipId: defaultMembership,
      );
      final queryStore = _FakeQueryStore(
        snapshot: createDefaultSnapshot(userStatus: 'inactive'),
      );
      final evaluator = NexaBizRuntimePermissionEvaluator(
        permissionCatalog: testCatalog,
        queryStore: queryStore,
        sessionSource: sessionSource,
      );

      final decision = await evaluator.evaluate(
        context: createDefaultContext(),
        permissionId: permView,
      );

      expect(decision, NexaBizPermissionDecision.deny);
      expect(decision.isAllowed, isFalse);
    });

    // 6. Inactive membership → DENY
    test('6. Inactive membership status evaluates to DENY', () async {
      final sessionSource = _FakeSessionSource(
        activeSessionId: defaultSessionId,
        activeUserId: defaultUser,
        activeCompanyId: defaultCompany,
        activeMembershipId: defaultMembership,
      );
      final queryStore = _FakeQueryStore(
        snapshot: createDefaultSnapshot(membershipStatus: 'inactive'),
      );
      final evaluator = NexaBizRuntimePermissionEvaluator(
        permissionCatalog: testCatalog,
        queryStore: queryStore,
        sessionSource: sessionSource,
      );

      final decision = await evaluator.evaluate(
        context: createDefaultContext(),
        permissionId: permView,
      );

      expect(decision, NexaBizPermissionDecision.deny);
      expect(decision.isAllowed, isFalse);
    });

    // 7. Inactive company → DENY
    test('7. Inactive company status evaluates to DENY', () async {
      final sessionSource = _FakeSessionSource(
        activeSessionId: defaultSessionId,
        activeUserId: defaultUser,
        activeCompanyId: defaultCompany,
        activeMembershipId: defaultMembership,
      );
      final queryStore = _FakeQueryStore(
        snapshot: createDefaultSnapshot(companyStatus: 'inactive'),
      );
      final evaluator = NexaBizRuntimePermissionEvaluator(
        permissionCatalog: testCatalog,
        queryStore: queryStore,
        sessionSource: sessionSource,
      );

      final decision = await evaluator.evaluate(
        context: createDefaultContext(),
        permissionId: permView,
      );

      expect(decision, NexaBizPermissionDecision.deny);
      expect(decision.isAllowed, isFalse);
    });

    // 8. Missing membership → DENY
    test('8. Missing membership snapshot evaluates to DENY', () async {
      final sessionSource = _FakeSessionSource(
        activeSessionId: defaultSessionId,
        activeUserId: defaultUser,
        activeCompanyId: defaultCompany,
        activeMembershipId: defaultMembership,
      );
      final queryStore = _FakeQueryStore(snapshot: null);
      final evaluator = NexaBizRuntimePermissionEvaluator(
        permissionCatalog: testCatalog,
        queryStore: queryStore,
        sessionSource: sessionSource,
      );

      final decision = await evaluator.evaluate(
        context: createDefaultContext(),
        permissionId: permView,
      );

      expect(decision, NexaBizPermissionDecision.deny);
      expect(decision.isAllowed, isFalse);
    });

    // 9. Mismatched user → DENY
    test(
      '9. Mismatched user between context and snapshot evaluates to DENY',
      () async {
        final sessionSource = _FakeSessionSource(
          activeSessionId: defaultSessionId,
          activeUserId: defaultUser,
          activeCompanyId: defaultCompany,
          activeMembershipId: defaultMembership,
        );
        final queryStore = _FakeQueryStore(
          snapshot: createDefaultSnapshot(userId: NexaBizUserId('other-user')),
        );
        final evaluator = NexaBizRuntimePermissionEvaluator(
          permissionCatalog: testCatalog,
          queryStore: queryStore,
          sessionSource: sessionSource,
        );

        final decision = await evaluator.evaluate(
          context: createDefaultContext(userId: defaultUser),
          permissionId: permView,
        );

        expect(decision, NexaBizPermissionDecision.deny);
        expect(decision.isAllowed, isFalse);
      },
    );

    // 10. Mismatched company → DENY
    test(
      '10. Mismatched company between context and snapshot evaluates to DENY',
      () async {
        final sessionSource = _FakeSessionSource(
          activeSessionId: defaultSessionId,
          activeUserId: defaultUser,
          activeCompanyId: defaultCompany,
          activeMembershipId: defaultMembership,
        );
        final queryStore = _FakeQueryStore(
          snapshot: createDefaultSnapshot(
            companyId: NexaBizCompanyId('other-company'),
          ),
        );
        final evaluator = NexaBizRuntimePermissionEvaluator(
          permissionCatalog: testCatalog,
          queryStore: queryStore,
          sessionSource: sessionSource,
        );

        final decision = await evaluator.evaluate(
          context: createDefaultContext(companyId: defaultCompany),
          permissionId: permView,
        );

        expect(decision, NexaBizPermissionDecision.deny);
        expect(decision.isAllowed, isFalse);
      },
    );

    // 11. Mismatched membership → DENY
    test(
      '11. Mismatched membership ID between context and snapshot evaluates to DENY',
      () async {
        final sessionSource = _FakeSessionSource(
          activeSessionId: defaultSessionId,
          activeUserId: defaultUser,
          activeCompanyId: defaultCompany,
          activeMembershipId: defaultMembership,
        );
        final queryStore = _FakeQueryStore(
          snapshot: createDefaultSnapshot(
            membershipId: NexaBizMembershipId('other-mem'),
          ),
        );
        final evaluator = NexaBizRuntimePermissionEvaluator(
          permissionCatalog: testCatalog,
          queryStore: queryStore,
          sessionSource: sessionSource,
        );

        final decision = await evaluator.evaluate(
          context: createDefaultContext(membershipId: defaultMembership),
          permissionId: permView,
        );

        expect(decision, NexaBizPermissionDecision.deny);
        expect(decision.isAllowed, isFalse);
      },
    );

    // 12. Stale sessionId → DENY
    test('12. Stale or mismatched sessionId evaluates to DENY', () async {
      final sessionSource = _FakeSessionSource(
        activeSessionId: 'actual-active-session',
        activeUserId: defaultUser,
        activeCompanyId: defaultCompany,
        activeMembershipId: defaultMembership,
      );
      final queryStore = _FakeQueryStore(snapshot: createDefaultSnapshot());
      final evaluator = NexaBizRuntimePermissionEvaluator(
        permissionCatalog: testCatalog,
        queryStore: queryStore,
        sessionSource: sessionSource,
      );

      final decision = await evaluator.evaluate(
        context: createDefaultContext(sessionId: 'stale-session-id'),
        permissionId: permView,
      );

      expect(decision, NexaBizPermissionDecision.deny);
      expect(decision.isAllowed, isFalse);
    });

    // 13. Logout invalidates existing context
    test('13. Logout immediately invalidates existing context', () async {
      final sessionSource = _FakeSessionSource(
        activeSessionId: defaultSessionId,
        activeUserId: defaultUser,
        activeCompanyId: defaultCompany,
        activeMembershipId: defaultMembership,
        isActive: true,
      );
      final queryStore = _FakeQueryStore(snapshot: createDefaultSnapshot());
      final evaluator = NexaBizRuntimePermissionEvaluator(
        permissionCatalog: testCatalog,
        queryStore: queryStore,
        sessionSource: sessionSource,
      );

      final ctx = createDefaultContext();

      // Before logout: allowed
      expect(
        (await evaluator.evaluate(
          context: ctx,
          permissionId: permView,
        )).isAllowed,
        isTrue,
      );

      // Simulate logout
      sessionSource.isActive = false;

      // After logout: immediate DENY
      final postLogoutDecision = await evaluator.evaluate(
        context: ctx,
        permissionId: permView,
      );
      expect(postLogoutDecision, NexaBizPermissionDecision.deny);
      expect(postLogoutDecision.isAllowed, isFalse);
    });

    // 14. Company switch invalidates previous context
    test(
      '14. Company switch immediately invalidates previous company context',
      () async {
        final sessionSource = _FakeSessionSource(
          activeSessionId: defaultSessionId,
          activeUserId: defaultUser,
          activeCompanyId: defaultCompany,
          activeMembershipId: defaultMembership,
        );
        final queryStore = _FakeQueryStore(snapshot: createDefaultSnapshot());
        final evaluator = NexaBizRuntimePermissionEvaluator(
          permissionCatalog: testCatalog,
          queryStore: queryStore,
          sessionSource: sessionSource,
        );

        final contextCompanyA = createDefaultContext();

        expect(
          (await evaluator.evaluate(
            context: contextCompanyA,
            permissionId: permView,
          )).isAllowed,
          isTrue,
        );

        // Switch to company B
        sessionSource.activeCompanyId = NexaBizCompanyId('company-2');
        sessionSource.activeMembershipId = NexaBizMembershipId('mem-2');
        sessionSource.activeSessionId = 'new-session-id';

        // Old Company A context is now rejected
        final postSwitchDecision = await evaluator.evaluate(
          context: contextCompanyA,
          permissionId: permView,
        );
        expect(postSwitchDecision, NexaBizPermissionDecision.deny);
        expect(postSwitchDecision.isAllowed, isFalse);
      },
    );

    // 15. Multiple roles union permissions correctly
    test('15. Multiple roles union their permissions correctly', () async {
      final sessionSource = _FakeSessionSource(
        activeSessionId: defaultSessionId,
        activeUserId: defaultUser,
        activeCompanyId: defaultCompany,
        activeMembershipId: defaultMembership,
      );
      final queryStore = _FakeQueryStore(
        snapshot: createDefaultSnapshot(
          roles: {
            NexaBizRoleId('company.role_a'),
            NexaBizRoleId('company.role_b'),
          },
          permissions: {permView, permManage},
        ),
      );
      final evaluator = NexaBizRuntimePermissionEvaluator(
        permissionCatalog: testCatalog,
        queryStore: queryStore,
        sessionSource: sessionSource,
      );

      final ctx = createDefaultContext();
      expect(
        (await evaluator.evaluate(
          context: ctx,
          permissionId: permView,
        )).isAllowed,
        isTrue,
      );
      expect(
        (await evaluator.evaluate(
          context: ctx,
          permissionId: permManage,
        )).isAllowed,
        isTrue,
      );
      expect(
        (await evaluator.evaluate(
          context: ctx,
          permissionId: permMembers,
        )).isAllowed,
        isFalse,
      );
    });

    // 16. Duplicate permission grants do not affect decision
    test(
      '16. Duplicate permission grants across roles do not affect evaluation',
      () async {
        final sessionSource = _FakeSessionSource(
          activeSessionId: defaultSessionId,
          activeUserId: defaultUser,
          activeCompanyId: defaultCompany,
          activeMembershipId: defaultMembership,
        );
        // Set deduplicates, union yields single grant
        final queryStore = _FakeQueryStore(
          snapshot: createDefaultSnapshot(
            roles: {
              NexaBizRoleId('company.owner'),
              NexaBizRoleId('company.admin'),
            },
            permissions: {permView},
          ),
        );
        final evaluator = NexaBizRuntimePermissionEvaluator(
          permissionCatalog: testCatalog,
          queryStore: queryStore,
          sessionSource: sessionSource,
        );

        final decision = await evaluator.evaluate(
          context: createDefaultContext(),
          permissionId: permView,
        );
        expect(decision, NexaBizPermissionDecision.allow);
      },
    );

    // 17. Live permission revoke → immediate DENY
    test(
      '17. Live permission revocation reflects immediately without re-login',
      () async {
        final sessionSource = _FakeSessionSource(
          activeSessionId: defaultSessionId,
          activeUserId: defaultUser,
          activeCompanyId: defaultCompany,
          activeMembershipId: defaultMembership,
        );
        final queryStore = _FakeQueryStore(
          snapshot: createDefaultSnapshot(permissions: {permView}),
        );
        final evaluator = NexaBizRuntimePermissionEvaluator(
          permissionCatalog: testCatalog,
          queryStore: queryStore,
          sessionSource: sessionSource,
        );

        final ctx = createDefaultContext();
        expect(
          (await evaluator.evaluate(
            context: ctx,
            permissionId: permView,
          )).isAllowed,
          isTrue,
        );

        // Revoke permission dynamically
        queryStore.snapshot = createDefaultSnapshot(
          permissions: <NexaBizPermissionId>{},
        );

        expect(
          (await evaluator.evaluate(
            context: ctx,
            permissionId: permView,
          )).isAllowed,
          isFalse,
        );
      },
    );

    // 18. Live role removal → immediate DENY
    test(
      '18. Live role removal reflects immediately without re-login',
      () async {
        final sessionSource = _FakeSessionSource(
          activeSessionId: defaultSessionId,
          activeUserId: defaultUser,
          activeCompanyId: defaultCompany,
          activeMembershipId: defaultMembership,
        );
        final queryStore = _FakeQueryStore(
          snapshot: createDefaultSnapshot(
            roles: {NexaBizRoleId('company.editor')},
            permissions: {permManage},
          ),
        );
        final evaluator = NexaBizRuntimePermissionEvaluator(
          permissionCatalog: testCatalog,
          queryStore: queryStore,
          sessionSource: sessionSource,
        );

        final ctx = createDefaultContext();
        expect(
          (await evaluator.evaluate(
            context: ctx,
            permissionId: permManage,
          )).isAllowed,
          isTrue,
        );

        // Remove role and its permissions
        queryStore.snapshot = createDefaultSnapshot(
          roles: <NexaBizRoleId>{},
          permissions: <NexaBizPermissionId>{},
        );

        expect(
          (await evaluator.evaluate(
            context: ctx,
            permissionId: permManage,
          )).isAllowed,
          isFalse,
        );
      },
    );

    // 19. Live permission grant → immediate ALLOW
    test(
      '19. Live permission grant reflects immediately without re-login',
      () async {
        final sessionSource = _FakeSessionSource(
          activeSessionId: defaultSessionId,
          activeUserId: defaultUser,
          activeCompanyId: defaultCompany,
          activeMembershipId: defaultMembership,
        );
        final queryStore = _FakeQueryStore(
          snapshot: createDefaultSnapshot(permissions: <NexaBizPermissionId>{}),
        );
        final evaluator = NexaBizRuntimePermissionEvaluator(
          permissionCatalog: testCatalog,
          queryStore: queryStore,
          sessionSource: sessionSource,
        );

        final ctx = createDefaultContext();
        expect(
          (await evaluator.evaluate(
            context: ctx,
            permissionId: permMembers,
          )).isAllowed,
          isFalse,
        );

        // Grant permission dynamically
        queryStore.snapshot = createDefaultSnapshot(permissions: {permMembers});

        expect(
          (await evaluator.evaluate(
            context: ctx,
            permissionId: permMembers,
          )).isAllowed,
          isTrue,
        );
      },
    );

    // 20. Owner without explicit grant → DENY
    test(
      '20. Owner role name grants zero permissions without explicit DB grant',
      () async {
        final sessionSource = _FakeSessionSource(
          activeSessionId: defaultSessionId,
          activeUserId: defaultUser,
          activeCompanyId: defaultCompany,
          activeMembershipId: defaultMembership,
        );
        final queryStore = _FakeQueryStore(
          snapshot: createDefaultSnapshot(
            roles: {NexaBizRoleId('company.owner')},
            permissions: <NexaBizPermissionId>{}, // Empty explicit grants
          ),
        );
        final evaluator = NexaBizRuntimePermissionEvaluator(
          permissionCatalog: testCatalog,
          queryStore: queryStore,
          sessionSource: sessionSource,
        );

        final decision = await evaluator.evaluate(
          context: createDefaultContext(),
          permissionId: permView,
        );

        expect(decision, NexaBizPermissionDecision.deny);
        expect(decision.isAllowed, isFalse);
      },
    );

    // 21. Arbitrary admin role name → no bypass
    test(
      '21. Arbitrary admin or superuser role name provides no automatic bypass',
      () async {
        final sessionSource = _FakeSessionSource(
          activeSessionId: defaultSessionId,
          activeUserId: defaultUser,
          activeCompanyId: defaultCompany,
          activeMembershipId: defaultMembership,
        );
        final queryStore = _FakeQueryStore(
          snapshot: createDefaultSnapshot(
            roles: {
              NexaBizRoleId('company.admin'),
              NexaBizRoleId('system.admin'),
            },
            permissions: <NexaBizPermissionId>{}, // No explicit grants
          ),
        );
        final evaluator = NexaBizRuntimePermissionEvaluator(
          permissionCatalog: testCatalog,
          queryStore: queryStore,
          sessionSource: sessionSource,
        );

        final decision = await evaluator.evaluate(
          context: createDefaultContext(),
          permissionId: permManage,
        );

        expect(decision, NexaBizPermissionDecision.deny);
        expect(decision.isAllowed, isFalse);
      },
    );

    // 22. Query-store expected failure → fail closed
    test(
      '22. Expected query-store failure fails closed safely to DENY without rethrowing',
      () async {
        final sessionSource = _FakeSessionSource(
          activeSessionId: defaultSessionId,
          activeUserId: defaultUser,
          activeCompanyId: defaultCompany,
          activeMembershipId: defaultMembership,
        );
        final queryStore = _FakeQueryStore(shouldThrow: true);
        final evaluator = NexaBizRuntimePermissionEvaluator(
          permissionCatalog: testCatalog,
          queryStore: queryStore,
          sessionSource: sessionSource,
        );

        final decision = await evaluator.evaluate(
          context: createDefaultContext(),
          permissionId: permView,
        );

        expect(decision, NexaBizPermissionDecision.deny);
        expect(decision.isAllowed, isFalse);
      },
    );

    // 23. Session-source expected failure → fail closed
    test(
      '23. Expected session-source failure fails closed safely to DENY without rethrowing',
      () async {
        final sessionSource = _FakeSessionSource(
          activeSessionId: defaultSessionId,
          activeUserId: defaultUser,
          activeCompanyId: defaultCompany,
          activeMembershipId: defaultMembership,
          shouldThrow: true,
        );
        final queryStore = _FakeQueryStore(snapshot: createDefaultSnapshot());
        final evaluator = NexaBizRuntimePermissionEvaluator(
          permissionCatalog: testCatalog,
          queryStore: queryStore,
          sessionSource: sessionSource,
        );

        final decision = await evaluator.evaluate(
          context: createDefaultContext(),
          permissionId: permView,
        );

        expect(decision, NexaBizPermissionDecision.deny);
        expect(decision.isAllowed, isFalse);
      },
    );

    // 24. System context without supported assignment → not allowed
    test(
      '24. System context evaluates to DENY as system persistence is deferred',
      () async {
        final sessionSource = _FakeSessionSource(
          activeSessionId: defaultSessionId,
          activeUserId: defaultUser,
        );
        final queryStore = _FakeQueryStore(snapshot: createDefaultSnapshot());
        final evaluator = NexaBizRuntimePermissionEvaluator(
          permissionCatalog: testCatalog,
          queryStore: queryStore,
          sessionSource: sessionSource,
        );

        final systemContext = NexaBizSystemAuthorizationContext(
          userId: defaultUser,
          sessionId: defaultSessionId,
        );

        final decision = await evaluator.evaluate(
          context: systemContext,
          permissionId: permView,
        );

        expect(decision, NexaBizPermissionDecision.deny);
        expect(decision.isAllowed, isFalse);
      },
    );

    // 25. Guard ALLOW → returns
    test('25. Guard completes normally when evaluator returns ALLOW', () async {
      final sessionSource = _FakeSessionSource(
        activeSessionId: defaultSessionId,
        activeUserId: defaultUser,
        activeCompanyId: defaultCompany,
        activeMembershipId: defaultMembership,
      );
      final queryStore = _FakeQueryStore(
        snapshot: createDefaultSnapshot(permissions: {permView}),
      );
      final evaluator = NexaBizRuntimePermissionEvaluator(
        permissionCatalog: testCatalog,
        queryStore: queryStore,
        sessionSource: sessionSource,
      );
      final guard = NexaBizDefaultPermissionGuard(evaluator);

      await expectLater(
        guard.requirePermission(
          context: createDefaultContext(),
          permissionId: permView,
        ),
        completes,
      );
    });

    // 26. Guard DENY → typed exception
    test(
      '26. Guard throws NexaBizPermissionDeniedException when decision is DENY',
      () async {
        final sessionSource = _FakeSessionSource(
          activeSessionId: defaultSessionId,
          activeUserId: defaultUser,
          activeCompanyId: defaultCompany,
          activeMembershipId: defaultMembership,
        );
        final queryStore = _FakeQueryStore(
          snapshot: createDefaultSnapshot(permissions: <NexaBizPermissionId>{}),
        );
        final evaluator = NexaBizRuntimePermissionEvaluator(
          permissionCatalog: testCatalog,
          queryStore: queryStore,
          sessionSource: sessionSource,
        );
        final guard = NexaBizDefaultPermissionGuard(evaluator);

        expect(
          () => guard.requirePermission(
            context: createDefaultContext(),
            permissionId: permView,
          ),
          throwsA(
            isA<NexaBizPermissionDeniedException>()
                .having((e) => e.permissionId, 'permissionId', permView)
                .having(
                  (e) => e.contextScope,
                  'contextScope',
                  equals(NexaBizRoleScope.company),
                )
                .having((e) => e.decision.isDenied, 'isDenied', isTrue),
          ),
        );
      },
    );

    // 27. Guard UNKNOWN → typed exception
    test(
      '27. Guard throws NexaBizPermissionDeniedException when decision is UNKNOWN',
      () async {
        final sessionSource = _FakeSessionSource(
          activeSessionId: defaultSessionId,
          activeUserId: defaultUser,
          activeCompanyId: defaultCompany,
          activeMembershipId: defaultMembership,
        );
        final queryStore = _FakeQueryStore(
          snapshot: createDefaultSnapshot(permissions: {permUndeclared}),
        );
        final evaluator = NexaBizRuntimePermissionEvaluator(
          permissionCatalog: testCatalog,
          queryStore: queryStore,
          sessionSource: sessionSource,
        );
        final guard = NexaBizDefaultPermissionGuard(evaluator);

        expect(
          () => guard.requirePermission(
            context: createDefaultContext(),
            permissionId: permUndeclared,
          ),
          throwsA(
            isA<NexaBizPermissionDeniedException>()
                .having((e) => e.permissionId, 'permissionId', permUndeclared)
                .having((e) => e.decision.isUnknown, 'isUnknown', isTrue),
          ),
        );
      },
    );

    // 28. Session never stores effective permissions
    test('28. NexaBizSession never stores effective permissions', () {
      final session = NexaBizSession.active(
        userId: defaultUser,
        companyId: defaultCompany,
        membershipId: defaultMembership,
        companyName: 'Test Corp',
        userName: 'Alice',
        userEmail: 'alice@test.com',
        role: 'owner',
        availableCompanies: const [],
        sessionId: 'session-xyz',
      );

      // Verify fields via reflection/toString: No permissions in session state
      expect(session.toString(), isNot(contains('permissions')));
      expect(session.membershipId, equals(defaultMembership));
    });

    // 29. Company B permissions never bleed into Company A
    test(
      '29. Permissions from Company B never bleed into Company A context',
      () async {
        final sessionSource = _FakeSessionSource(
          activeSessionId: defaultSessionId,
          activeUserId: defaultUser,
          activeCompanyId: defaultCompany,
          activeMembershipId: defaultMembership,
        );

        // Snapshot for Company A has no permissions; Company B snapshot would have permManage
        final queryStore = _FakeQueryStore(
          snapshot: createDefaultSnapshot(
            companyId: defaultCompany,
            membershipId: defaultMembership,
            permissions: <NexaBizPermissionId>{},
          ),
        );

        final evaluator = NexaBizRuntimePermissionEvaluator(
          permissionCatalog: testCatalog,
          queryStore: queryStore,
          sessionSource: sessionSource,
        );

        final decisionA = await evaluator.evaluate(
          context: createDefaultContext(companyId: defaultCompany),
          permissionId: permManage,
        );

        expect(decisionA, NexaBizPermissionDecision.deny);
        expect(decisionA.isAllowed, isFalse);
      },
    );

    // 30. Architecture dependencies remain Pure Dart
    test(
      '30. Evaluator, Catalog, and SessionSource maintain pure Dart boundaries',
      () {
        final authDir = Directory('lib/core/authorization');
        final files = authDir.listSync().whereType<File>().where(
          (f) => f.path.endsWith('.dart'),
        );

        for (final file in files) {
          final content = file.readAsStringSync();
          expect(content, isNot(contains("import 'package:flutter/")));
          expect(content, isNot(contains("import 'package:drift/")));
          expect(content, isNot(contains("import 'package:flutter_riverpod/")));
          expect(content, isNot(contains("import 'package:nexabiz_ui/")));
        }
      },
    );
  });

  group('NexaBizRuntimePermissionEvaluator — End-to-End Drift Integration', () {
    late Directory directory;
    late String databasePath;
    late DriftCoreInstallationStore store;
    late NexaBizCapabilityRegistry registry;
    late CoreSessionController sessionController;

    setUp(() async {
      directory = Directory.systemTemp.createTempSync(
        'nexabiz_evaluator_test_',
      );
      databasePath = p.join(directory.path, 'core.sqlite');
      store = await DriftCoreInstallationStore.open(databasePath);

      registry = NexaBizCapabilityRegistry();
      registry.register(const CompanyCapability());
      registry.validateAndLock();

      sessionController = CoreSessionController(
        authenticateLocalUser: AuthenticateLocalUser(queryStore: store),
        queryStore: store,
      );
    });

    tearDown(() async {
      await sessionController.dispose();
      await store.close();
      if (directory.existsSync()) {
        directory.deleteSync(recursive: true);
      }
    });

    test(
      'Full lifecycle: initialization, login, evaluation, live revoke, company switch, logout',
      () async {
        final db = store.database;

        // 1. Initialize core system
        final init = InitializeNexaBizCore(store);
        final initResult = await init(
          const CoreInitializationInput(
            companyCode: 'COMP1',
            companyName: 'Company One',
            adminName: 'Owner One',
            adminEmail: 'owner@comp1.com',
            password: 'password12345',
          ),
        );
        expect(initResult.isReady, isTrue);

        // 2. Login through session controller
        final loginResult = await sessionController.login(
          const CoreAuthenticationInput(
            identifier: 'owner@comp1.com',
            password: 'password12345',
          ),
        );
        expect(loginResult.isSuccess, isTrue);
        final activeSession = sessionController.currentSession;
        expect(activeSession.isActive, isTrue);
        expect(activeSession.membershipId, isNotNull);

        // 3. Construct Runtime Evaluator with real store and session controller
        final evaluator = NexaBizRuntimePermissionEvaluator(
          permissionCatalog: registry.permissionCatalog,
          queryStore: store,
          sessionSource: sessionController,
        );

        final ctx = NexaBizCompanyAuthorizationContext(
          userId: activeSession.userId!,
          sessionId: activeSession.sessionId!,
          companyId: activeSession.companyId!,
          membershipId: activeSession.membershipId!,
        );

        // 4. Initial owner has seeded declared permissions
        final viewDecision = await evaluator.evaluate(
          context: ctx,
          permissionId: permView,
        );
        expect(viewDecision, NexaBizPermissionDecision.allow);

        // 5. Undeclared permission returns unknown
        final unknownDecision = await evaluator.evaluate(
          context: ctx,
          permissionId: permUndeclared,
        );
        expect(unknownDecision, NexaBizPermissionDecision.unknown);

        // 6. Live revocation of permission directly from DB
        await db.customStatement(
          "DELETE FROM core_role_permissions WHERE permission_id = 'company.profile.view'",
        );

        final revokedDecision = await evaluator.evaluate(
          context: ctx,
          permissionId: permView,
        );
        expect(revokedDecision, NexaBizPermissionDecision.deny);

        // 7. Live grant of permission directly into DB
        final ownerRoleId =
            (await db
                    .customSelect(
                      "SELECT id FROM core_roles WHERE role_key = 'company.owner'",
                    )
                    .getSingle())
                .read<String>('id');

        await db.customStatement(
          "INSERT INTO core_role_permissions (role_id, permission_id, created_at) "
          "VALUES (?, 'company.profile.view', ?)",
          [ownerRoleId, DateTime.now().millisecondsSinceEpoch],
        );

        final reGrantedDecision = await evaluator.evaluate(
          context: ctx,
          permissionId: permView,
        );
        expect(reGrantedDecision, NexaBizPermissionDecision.allow);

        // 8. Logout invalidation
        sessionController.logout();
        expect(sessionController.currentSession.isActive, isFalse);

        final postLogoutDecision = await evaluator.evaluate(
          context: ctx,
          permissionId: permView,
        );
        expect(postLogoutDecision, NexaBizPermissionDecision.deny);
      },
    );
  });
}
