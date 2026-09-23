import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:nexabiz/app/authorization/nexabiz_authorization_administration.dart';
import 'package:nexabiz/app/authorization/nexabiz_authorization_invalidation_signal.dart';
import 'package:nexabiz/app/persistence/drift_authorization_administration_store.dart';
import 'package:nexabiz/app/persistence/drift_core_installation_store.dart';
import 'package:nexabiz/core/authorization/administration/nexabiz_authorization_administration_errors.dart';
import 'package:nexabiz/core/authorization/administration/nexabiz_authorization_administration_models.dart';
import 'package:nexabiz/core/authorization/administration/nexabiz_authorization_administration_permissions.dart';
import 'package:nexabiz/core/authorization/administration/nexabiz_authorization_administration_policy.dart';
import 'package:nexabiz/core/authorization/nexabiz_authorization_context.dart';
import 'package:nexabiz/core/authorization/nexabiz_authorization_session_source.dart';
import 'package:nexabiz/core/authorization/nexabiz_membership_id.dart';
import 'package:nexabiz/core/authorization/nexabiz_permission_catalog.dart';
import 'package:nexabiz/core/authorization/nexabiz_permission_denied_exception.dart';
import 'package:nexabiz/core/authorization/nexabiz_permission_guard.dart';
import 'package:nexabiz/core/authorization/nexabiz_runtime_permission_evaluator.dart';
import 'package:nexabiz/core/company/nexabiz_company_scope.dart';
import 'package:nexabiz/core/permissions/nexabiz_permission_intent.dart';
import 'package:nexabiz/core/roles/nexabiz_role_id.dart';
import 'package:nexabiz/core/session/nexabiz_session.dart';
import 'package:nexabiz/core/setup/initialize_nexabiz_core.dart';
import 'package:path/path.dart' as p;

final class _LiveIntegrationSessionSource
    implements NexaBizAuthorizationSessionSource {
  _LiveIntegrationSessionSource({
    required this.activeSessionId,
    required this.activeUserId,
    required this.activeCompanyId,
    required this.activeMembershipId,
  });

  String activeSessionId;
  NexaBizUserId activeUserId;
  NexaBizCompanyId activeCompanyId;
  NexaBizMembershipId activeMembershipId;

  @override
  bool matchesActiveSession({
    required String sessionId,
    required NexaBizUserId userId,
    NexaBizCompanyId? companyId,
    NexaBizMembershipId? membershipId,
  }) {
    if (sessionId != activeSessionId || userId != activeUserId) return false;
    if (companyId != null && companyId != activeCompanyId) return false;
    if (membershipId != null && membershipId != activeMembershipId) {
      return false;
    }
    return true;
  }
}

void main() {
  late Directory directory;
  late String databasePath;
  late DriftCoreInstallationStore installationStore;
  late DriftAuthorizationAdministrationStore administrationStore;
  late NexaBizImmutablePermissionCatalog catalog;
  late NexaBizAuthorizationInvalidationSignal signal;
  late NexaBizRuntimePermissionEvaluator evaluator;
  late NexaBizDefaultPermissionGuard guard;
  late NexaBizAuthorizationAdministration facade;
  late _LiveIntegrationSessionSource sessionSource;
  late int invalidationEventCount;

  late NexaBizCompanyId companyId;
  late NexaBizUserId ownerUserId;
  late NexaBizMembershipId ownerMembershipId;
  late NexaBizCompanyAuthorizationContext ownerContext;

  late NexaBizUserId clerkUserId;
  late NexaBizMembershipId clerkMembershipId;
  late NexaBizCompanyAuthorizationContext clerkContext;

  setUp(() async {
    directory = Directory.systemTemp.createTempSync(
      'nexabiz_auth_admin_live_test_',
    );
    databasePath = p.join(directory.path, 'core.sqlite');

    installationStore = await DriftCoreInstallationStore.open(databasePath);

    // Initial Core Setup
    const setupInput = CoreInitializationInput(
      companyCode: 'NEXA',
      companyName: 'NexaBiz Corp',
      adminName: 'Owner Admin',
      adminEmail: 'owner@nexabiz.test',
      password: 'Strong_Password_123!',
    );
    final coreInit = InitializeNexaBizCore(installationStore);
    await coreInit(setupInput);

    final db = installationStore.database;
    final companyRow = (await db.select(db.coreCompanies).get()).single;
    final userRow = (await db.select(db.coreUsers).get()).single;
    final membershipRow =
        (await db.select(db.coreCompanyMemberships).get()).single;

    companyId = NexaBizCompanyId(companyRow.id);
    ownerUserId = NexaBizUserId(userRow.id);
    ownerMembershipId = NexaBizMembershipId(membershipRow.id);
    ownerContext = NexaBizCompanyAuthorizationContext(
      userId: ownerUserId,
      companyId: companyId,
      membershipId: ownerMembershipId,
      sessionId: 'session-owner-1',
    );

    // Create a second user (Clerk) in Company
    final now = DateTime.now().toUtc();
    await db.customStatement(
      '''
      INSERT INTO core_users (id, email, name, status, created_at, updated_at)
      VALUES (?, ?, ?, 'active', ?, ?)
      ''',
      [
        'usr-clerk-1',
        'clerk@nexabiz.test',
        'Clerk User',
        now.toIso8601String(),
        now.toIso8601String(),
      ],
    );
    await db.customStatement(
      '''
      INSERT INTO core_company_memberships (id, user_id, company_id, role, status, created_at, updated_at)
      VALUES (?, ?, ?, 'member', 'active', ?, ?)
      ''',
      [
        'mem-clerk-1',
        'usr-clerk-1',
        companyId.value,
        now.toIso8601String(),
        now.toIso8601String(),
      ],
    );

    clerkUserId = NexaBizUserId('usr-clerk-1');
    clerkMembershipId = NexaBizMembershipId('mem-clerk-1');
    clerkContext = NexaBizCompanyAuthorizationContext(
      userId: clerkUserId,
      companyId: companyId,
      membershipId: clerkMembershipId,
      sessionId: 'session-clerk-1',
    );

    // Build Catalog with administration and business permissions
    catalog = NexaBizImmutablePermissionCatalog({
      ...NexaBizAuthorizationAdministrationPermissions.declaredPermissionIds,
      NexaBizPermissionId('company.profile.manage'),
      NexaBizPermissionId('finance.ledger.post'),
    });

    administrationStore = DriftAuthorizationAdministrationStore(
      db,
      permissionCatalog: catalog,
    );

    signal = NexaBizAuthorizationInvalidationSignal();
    invalidationEventCount = 0;
    signal.addListener(() => invalidationEventCount++);

    sessionSource = _LiveIntegrationSessionSource(
      activeSessionId: 'session-owner-1',
      activeUserId: ownerUserId,
      activeCompanyId: companyId,
      activeMembershipId: ownerMembershipId,
    );

    evaluator = NexaBizRuntimePermissionEvaluator(
      permissionCatalog: catalog,
      queryStore: installationStore,
      sessionSource: sessionSource,
    );

    guard = NexaBizDefaultPermissionGuard(evaluator);

    facade = NexaBizAuthorizationAdministration.create(
      permissionGuard: guard,
      queryStore: administrationStore,
      mutationStore: administrationStore,
      invalidationSignal: signal,
      permissionCatalog: catalog,
    );
  });

  tearDown(() async {
    await installationStore.close();
    if (directory.existsSync()) {
      directory.deleteSync(recursive: true);
    }
  });

  void switchToClerkSession() {
    sessionSource.activeSessionId = 'session-clerk-1';
    sessionSource.activeUserId = clerkUserId;
    sessionSource.activeCompanyId = companyId;
    sessionSource.activeMembershipId = clerkMembershipId;
  }

  void switchToOwnerSession() {
    sessionSource.activeSessionId = 'session-owner-1';
    sessionSource.activeUserId = ownerUserId;
    sessionSource.activeCompanyId = companyId;
    sessionSource.activeMembershipId = ownerMembershipId;
  }

  group('Live Real-SQLite Authorization Administration End-to-End Tests', () {
    test(
      'Live Grant and Revoke: modifies permissions and reflects dynamically in Evaluator without restart',
      () async {
        final clerkRole = NexaBizRoleId('company.billing_clerk');
        final targetPermission = NexaBizPermissionId('company.profile.manage');

        // 1. Owner creates custom role
        switchToOwnerSession();
        final createResult = await facade.createCompanyRole.execute(
          context: ownerContext,
          roleId: clerkRole,
          metadata: NexaBizRoleMetadata(
            displayName: NexaBizRoleDisplayName('Billing Clerk'),
          ),
        );
        expect(createResult.changed, isTrue);
        expect(invalidationEventCount, 1);

        // 2. Owner assigns custom role to Clerk
        final assignResult = await facade.assignRoleToMembership.execute(
          context: ownerContext,
          membershipId: clerkMembershipId,
          roleId: clerkRole,
        );
        expect(assignResult.changed, isTrue);
        expect(invalidationEventCount, 2);

        // 3. Verify Clerk currently lacks targetPermission
        switchToClerkSession();
        var decision = await evaluator.evaluate(
          context: clerkContext,
          permissionId: targetPermission,
        );
        expect(decision.isAllowed, isFalse);

        // 4. Live Grant: Owner grants targetPermission to custom role
        switchToOwnerSession();
        final grantResult = await facade.grantPermissionToRole.execute(
          context: ownerContext,
          roleId: clerkRole,
          permissionId: targetPermission,
        );
        expect(grantResult.changed, isTrue);
        expect(invalidationEventCount, 3);

        // 5. Without logout/restart, Clerk evaluates immediately as ALLOW
        switchToClerkSession();
        decision = await evaluator.evaluate(
          context: clerkContext,
          permissionId: targetPermission,
        );
        expect(decision.isAllowed, isTrue);

        // 6. Live Revoke: Owner revokes targetPermission from custom role
        switchToOwnerSession();
        final revokeResult = await facade.revokePermissionFromRole.execute(
          context: ownerContext,
          roleId: clerkRole,
          permissionId: targetPermission,
        );
        expect(revokeResult.changed, isTrue);
        expect(invalidationEventCount, 4);

        // 7. Without logout/restart, Clerk evaluates immediately as DENY
        switchToClerkSession();
        decision = await evaluator.evaluate(
          context: clerkContext,
          permissionId: targetPermission,
        );
        expect(decision.isAllowed, isFalse);
      },
    );

    test(
      'Role Assign and Unassign live effect: toggles user access immediately',
      () async {
        final accountantRole = NexaBizRoleId('company.accountant');
        final targetPermission = NexaBizPermissionId('company.profile.manage');

        switchToOwnerSession();
        await facade.createCompanyRole.execute(
          context: ownerContext,
          roleId: accountantRole,
          metadata: NexaBizRoleMetadata(
            displayName: NexaBizRoleDisplayName('Accountant'),
          ),
        );
        await facade.grantPermissionToRole.execute(
          context: ownerContext,
          roleId: accountantRole,
          permissionId: targetPermission,
        );

        // Clerk currently has no roles
        switchToClerkSession();
        var decision = await evaluator.evaluate(
          context: clerkContext,
          permissionId: targetPermission,
        );
        expect(decision.isAllowed, isFalse);

        // Assign role to Clerk
        switchToOwnerSession();
        final assignResult = await facade.assignRoleToMembership.execute(
          context: ownerContext,
          membershipId: clerkMembershipId,
          roleId: accountantRole,
        );
        expect(assignResult.changed, isTrue);

        // Clerk immediately becomes ALLOW
        switchToClerkSession();
        decision = await evaluator.evaluate(
          context: clerkContext,
          permissionId: targetPermission,
        );
        expect(decision.isAllowed, isTrue);

        // Unassign role from Clerk
        switchToOwnerSession();
        final unassignResult = await facade.unassignRoleFromMembership.execute(
          context: ownerContext,
          membershipId: clerkMembershipId,
          roleId: accountantRole,
        );
        expect(unassignResult.changed, isTrue);

        // Clerk immediately becomes DENY
        switchToClerkSession();
        decision = await evaluator.evaluate(
          context: clerkContext,
          permissionId: targetPermission,
        );
        expect(decision.isAllowed, isFalse);
      },
    );

    test(
      'Idempotency test: duplicate assign, grant, unassign, revoke emit 0 invalidations',
      () async {
        final customRole = NexaBizRoleId('company.operator');
        final targetPermission = NexaBizPermissionId('company.profile.manage');

        switchToOwnerSession();
        await facade.createCompanyRole.execute(
          context: ownerContext,
          roleId: customRole,
          metadata: NexaBizRoleMetadata(
            displayName: NexaBizRoleDisplayName('Operator'),
          ),
        );
        await facade.assignRoleToMembership.execute(
          context: ownerContext,
          membershipId: clerkMembershipId,
          roleId: customRole,
        );
        await facade.grantPermissionToRole.execute(
          context: ownerContext,
          roleId: customRole,
          permissionId: targetPermission,
        );

        final countBefore = invalidationEventCount;

        // Idempotent assign (already assigned)
        final dupAssign = await facade.assignRoleToMembership.execute(
          context: ownerContext,
          membershipId: clerkMembershipId,
          roleId: customRole,
        );
        expect(dupAssign.changed, isFalse);
        expect(invalidationEventCount, countBefore);

        // Idempotent grant (already granted)
        final dupGrant = await facade.grantPermissionToRole.execute(
          context: ownerContext,
          roleId: customRole,
          permissionId: targetPermission,
        );
        expect(dupGrant.changed, isFalse);
        expect(invalidationEventCount, countBefore);

        // First revoke succeeds
        await facade.revokePermissionFromRole.execute(
          context: ownerContext,
          roleId: customRole,
          permissionId: targetPermission,
        );
        expect(invalidationEventCount, countBefore + 1);

        // Idempotent revoke (already revoked)
        final dupRevoke = await facade.revokePermissionFromRole.execute(
          context: ownerContext,
          roleId: customRole,
          permissionId: targetPermission,
        );
        expect(dupRevoke.changed, isFalse);
        expect(invalidationEventCount, countBefore + 1);

        // First unassign succeeds
        await facade.unassignRoleFromMembership.execute(
          context: ownerContext,
          membershipId: clerkMembershipId,
          roleId: customRole,
        );
        expect(invalidationEventCount, countBefore + 2);

        // Idempotent unassign (already unassigned)
        final dupUnassign = await facade.unassignRoleFromMembership.execute(
          context: ownerContext,
          membershipId: clerkMembershipId,
          roleId: customRole,
        );
        expect(dupUnassign.changed, isFalse);
        expect(invalidationEventCount, countBefore + 2);
      },
    );

    test('Built-in company.owner role is protected from mutations', () async {
      final ownerRole = NexaBizBuiltInCompanyRoles.companyOwner;
      switchToOwnerSession();

      final countBefore = invalidationEventCount;

      await expectLater(
        facade.grantPermissionToRole.execute(
          context: ownerContext,
          roleId: ownerRole,
          permissionId: NexaBizPermissionId('company.profile.manage'),
        ),
        throwsA(isA<NexaBizBuiltInRoleProtectedException>()),
      );

      await expectLater(
        facade.revokePermissionFromRole.execute(
          context: ownerContext,
          roleId: ownerRole,
          permissionId:
              NexaBizAuthorizationAdministrationPermissions.roleManage,
        ),
        throwsA(isA<NexaBizBuiltInRoleProtectedException>()),
      );

      await expectLater(
        facade.deleteCompanyRole.execute(
          context: ownerContext,
          roleId: ownerRole,
        ),
        throwsA(isA<NexaBizBuiltInRoleProtectedException>()),
      );

      expect(invalidationEventCount, countBefore);
    });

    test('Last active owner invariant prevents removing sole owner', () async {
      final ownerRole = NexaBizBuiltInCompanyRoles.companyOwner;
      switchToOwnerSession();

      final countBefore = invalidationEventCount;

      await expectLater(
        facade.unassignRoleFromMembership.execute(
          context: ownerContext,
          membershipId: ownerMembershipId,
          roleId: ownerRole,
        ),
        throwsA(isA<NexaBizLastOwnerProtectedException>()),
      );

      expect(invalidationEventCount, countBefore);
    });

    test(
      'Self-demotion and self-grant under policy.manage: immediately updates actor evaluation without logout',
      () async {
        final specializedRole = NexaBizRoleId('company.specialized');
        final targetPermission = NexaBizPermissionId('finance.ledger.post');

        switchToOwnerSession();

        // 1. Create a specialized role
        await facade.createCompanyRole.execute(
          context: ownerContext,
          roleId: specializedRole,
          metadata: NexaBizRoleMetadata(
            displayName: NexaBizRoleDisplayName('Specialized Role'),
          ),
        );

        // 2. Owner assigns specialized role to themselves
        await facade.assignRoleToMembership.execute(
          context: ownerContext,
          membershipId: ownerMembershipId,
          roleId: specializedRole,
        );

        // 3. Verify owner initially lacks targetPermission
        var decision = await evaluator.evaluate(
          context: ownerContext,
          permissionId: targetPermission,
        );
        expect(decision.isAllowed, isFalse);

        // 4. Owner grants targetPermission to their own specialized role (self-escalation under policy.manage authority)
        await facade.grantPermissionToRole.execute(
          context: ownerContext,
          roleId: specializedRole,
          permissionId: targetPermission,
        );

        // 5. Fresh snapshot immediately allows targetPermission
        decision = await evaluator.evaluate(
          context: ownerContext,
          permissionId: targetPermission,
        );
        expect(decision.isAllowed, isTrue);

        // 6. Owner revokes targetPermission from specialized role (self-demotion)
        await facade.revokePermissionFromRole.execute(
          context: ownerContext,
          roleId: specializedRole,
          permissionId: targetPermission,
        );

        // 7. Fresh snapshot immediately denies targetPermission without logout
        decision = await evaluator.evaluate(
          context: ownerContext,
          permissionId: targetPermission,
        );
        expect(decision.isAllowed, isFalse);
      },
    );

    test(
      'Live query pipeline: role assignments project human-readable user identity and assignable query enforces permissions and exclusion',
      () async {
        final pageRequest = NexaBizAuthorizationAdministrationPageRequest(
          limit: 50,
        );

        // 1. Owner assignments project human-readable identity
        final ownerAssignments = await facade.listMembershipsAssignedToRole
            .execute(
              context: ownerContext,
              roleId: NexaBizBuiltInCompanyRoles.companyOwner,
              page: pageRequest,
            );
        expect(ownerAssignments.items, isNotEmpty);
        final initialOwner = ownerAssignments.items.firstWhere(
          (a) => a.membershipId == ownerMembershipId,
        );
        expect(initialOwner.userName, 'Owner Admin');
        expect(initialOwner.userEmail, 'owner@nexabiz.test');

        // 2. Clerk lacks assignmentManage permission -> fails closed
        await expectLater(
          facade.listAssignableMembershipsForRole.execute(
            context: clerkContext,
            roleId: NexaBizBuiltInCompanyRoles.companyOwner,
            page: pageRequest,
          ),
          throwsA(isA<NexaBizPermissionDeniedException>()),
        );

        // 3. Owner queries assignable memberships -> Clerk is present as candidate
        final assignableBefore = await facade.listAssignableMembershipsForRole
            .execute(
              context: ownerContext,
              roleId: NexaBizBuiltInCompanyRoles.companyOwner,
              page: pageRequest,
            );
        final clerkCandidate = assignableBefore.items.firstWhere(
          (m) => m.membershipId == clerkMembershipId,
        );
        expect(clerkCandidate.userName, 'Clerk User');
        expect(clerkCandidate.userEmail, 'clerk@nexabiz.test');
        expect(clerkCandidate.isEligible, isTrue);

        // 4. Assign Clerk to company.owner
        await facade.assignRoleToMembership.execute(
          context: ownerContext,
          membershipId: clerkMembershipId,
          roleId: NexaBizBuiltInCompanyRoles.companyOwner,
        );

        // 5. Subsequent assignable query no longer includes Clerk
        final assignableAfter = await facade.listAssignableMembershipsForRole
            .execute(
              context: ownerContext,
              roleId: NexaBizBuiltInCompanyRoles.companyOwner,
              page: pageRequest,
            );
        expect(
          assignableAfter.items.any((m) => m.membershipId == clerkMembershipId),
          isFalse,
        );
      },
    );
  });
}
