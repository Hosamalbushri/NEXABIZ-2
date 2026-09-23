import 'dart:io';

import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:flutter_test/flutter_test.dart';
import 'package:nexabiz/app/persistence/drift_core_database.dart';
import 'package:nexabiz/app/persistence/drift_core_installation_store.dart';
import 'package:nexabiz/core/permissions/nexabiz_permission_intent.dart';
import 'package:nexabiz/core/roles/nexabiz_role_id.dart';
import 'package:nexabiz/core/setup/initialize_nexabiz_core.dart';
import 'package:path/path.dart' as p;
import 'package:sqlite3/sqlite3.dart' as raw;

void main() {
  late Directory directory;
  late String databasePath;

  setUp(() {
    directory = Directory.systemTemp.createTempSync('nexabiz_rbac_test_');
    databasePath = p.join(directory.path, 'core.sqlite');
  });

  tearDown(() {
    if (directory.existsSync()) {
      directory.deleteSync(recursive: true);
    }
  });

  const setupInput = CoreInitializationInput(
    companyCode: 'COMP1',
    companyName: 'Company One',
    adminName: 'Owner One',
    adminEmail: 'owner1@example.test',
    password: 'secure_password_123',
  );

  Future<void> addSecondActiveOwner(DriftCoreInstallationStore store) async {
    final db = store.database;
    final company = (await db.select(db.coreCompanies).get()).single;
    final ownerRole = (await (db.select(
      db.coreRoles,
    )..where((table) => table.roleKey.equals('company.owner'))).getSingle());
    final now = DateTime.now().toUtc();
    await db
        .into(db.coreUsers)
        .insert(
          CoreUsersCompanion.insert(
            id: 'second-owner-user',
            email: const Value('second-owner@example.test'),
            name: const Value('Second Owner'),
            status: const Value('active'),
            createdAt: Value(now),
            updatedAt: Value(now),
          ),
        );
    await db
        .into(db.coreCompanyMemberships)
        .insert(
          CoreCompanyMembershipsCompanion.insert(
            id: 'second-owner-membership',
            userId: 'second-owner-user',
            companyId: company.id,
            role: 'member',
            status: 'active',
            createdAt: Value(now),
            updatedAt: Value(now),
          ),
        );
    await store.assignRoleToMembership(
      membershipId: 'second-owner-membership',
      roleId: ownerRole.id,
    );
  }

  group('Relational RBAC Persistence & Constraints', () {
    test('1. Fresh DB creates all RBAC tables and triggers', () async {
      final store = await DriftCoreInstallationStore.open(databasePath);
      await store.close();

      final db = raw.sqlite3.open(databasePath);
      final tables = db
          .select(
            "SELECT name FROM sqlite_master WHERE type='table' AND name NOT LIKE 'sqlite_%'",
          )
          .map((r) => r['name'] as String)
          .toSet();

      expect(
        tables,
        containsAll([
          'core_roles',
          'core_membership_roles',
          'core_role_permissions',
        ]),
      );

      final triggers = db
          .select("SELECT name FROM sqlite_master WHERE type='trigger'")
          .map((r) => r['name'] as String)
          .toSet();

      expect(
        triggers,
        containsAll([
          'trg_core_roles_scope_check_insert',
          'trg_core_roles_scope_check_update',
          'trg_core_membership_roles_cross_tenant_insert',
          'trg_core_membership_roles_cross_tenant_update',
        ]),
      );
      db.close();
    });

    test('2. Role creation with valid scope (company vs system)', () async {
      final store = await DriftCoreInstallationStore.open(databasePath);
      await InitializeNexaBizCore(store)(setupInput);

      final company =
          (await store.database.select(store.database.coreCompanies).get())
              .single;

      // Valid company role
      final companyRoleId = await store.createRole(
        roleId: NexaBizRoleId('company.manager'),
        companyId: company.id,
        name: 'Manager',
        description: 'Company manager role',
      );
      expect(companyRoleId, isNotEmpty);

      // Valid system role
      final systemRoleId = await store.createRole(
        roleId: NexaBizRoleId('system.support'),
        companyId: null,
        name: 'Support Agent',
        description: 'System support role',
      );
      expect(systemRoleId, isNotEmpty);

      final roles = await store.database.select(store.database.coreRoles).get();
      // built-in company.owner + company.manager + system.support = 3
      expect(roles, hasLength(3));
      await store.close();
    });

    test('3. Invariant: company role without company_id throws', () async {
      final store = await DriftCoreInstallationStore.open(databasePath);

      // Throws at Dart validation level
      expect(
        () => store.createRole(
          roleId: NexaBizRoleId('company.manager'),
          companyId: null,
        ),
        throwsArgumentError,
      );

      // Throws at SQLite trigger level if bypassed
      final rawDb = raw.sqlite3.open(databasePath);
      expect(
        () => rawDb.execute('''
          INSERT INTO core_roles (id, scope, company_id, role_key, created_at, updated_at)
          VALUES ('role-no-comp', 'company', NULL, 'company.invalid', '2026-01-01', '2026-01-01')
        '''),
        throwsA(isA<raw.SqliteException>()),
      );
      rawDb.close();
      await store.close();
    });

    test('4. Invariant: system role with company_id throws', () async {
      final store = await DriftCoreInstallationStore.open(databasePath);
      await InitializeNexaBizCore(store)(setupInput);
      final company =
          (await store.database.select(store.database.coreCompanies).get())
              .single;

      // Throws at Dart validation level
      expect(
        () => store.createRole(
          roleId: NexaBizRoleId('system.auditor'),
          companyId: company.id,
        ),
        throwsArgumentError,
      );

      // Throws at SQLite trigger level if bypassed
      final rawDb = raw.sqlite3.open(databasePath);
      expect(
        () => rawDb.execute('''
          INSERT INTO core_roles (id, scope, company_id, role_key, created_at, updated_at)
          VALUES ('role-sys-comp', 'system', '${company.id}', 'system.invalid', '2026-01-01', '2026-01-01')
        '''),
        throwsA(isA<raw.SqliteException>()),
      );
      rawDb.close();
      await store.close();
    });

    test('5. Membership can have multiple roles', () async {
      final store = await DriftCoreInstallationStore.open(databasePath);
      await InitializeNexaBizCore(store)(setupInput);
      final company =
          (await store.database.select(store.database.coreCompanies).get())
              .single;
      final membership =
          (await store.database
                  .select(store.database.coreCompanyMemberships)
                  .get())
              .single;

      final role2Id = await store.createRole(
        roleId: NexaBizRoleId('company.accountant'),
        companyId: company.id,
      );

      await store.assignRoleToMembership(
        membershipId: membership.id,
        roleId: role2Id,
      );

      final snapshot = await store.readMembershipAuthorizationSnapshot(
        membership.id,
      );
      expect(snapshot, isNotNull);
      expect(snapshot!.roleIds, {
        NexaBizRoleId('company.owner'),
        NexaBizRoleId('company.accountant'),
      });
      await store.close();
    });

    test('6. Duplicate membership-role mapping throws', () async {
      final store = await DriftCoreInstallationStore.open(databasePath);
      await InitializeNexaBizCore(store)(setupInput);
      final membership =
          (await store.database
                  .select(store.database.coreCompanyMemberships)
                  .get())
              .single;
      final ownerRole = (await (store.database.select(
        store.database.coreRoles,
      )..where((t) => t.roleKey.equals('company.owner'))).getSingle());

      // company.owner was already assigned to membership in initialize()
      expect(
        () => store.assignRoleToMembership(
          membershipId: membership.id,
          roleId: ownerRole.id,
        ),
        throwsA(isA<Exception>()),
      );
      await store.close();
    });

    test('7. Duplicate role-permission mapping throws', () async {
      final store = await DriftCoreInstallationStore.open(databasePath);
      await InitializeNexaBizCore(store)(setupInput);
      final ownerRole = (await (store.database.select(
        store.database.coreRoles,
      )..where((t) => t.roleKey.equals('company.owner'))).getSingle());

      // 'company.details.view' was already granted in initialize()
      // 'company.profile.view' was already granted in initialize()
      expect(
        () => store.grantPermissionToRole(
          roleId: ownerRole.id,
          permissionId: NexaBizPermissionId('company.profile.view'),
        ),
        throwsA(isA<Exception>()),
      );
      await store.close();
    });

    test('8. Unknown role assignment throws (FK)', () async {
      final store = await DriftCoreInstallationStore.open(databasePath);
      await InitializeNexaBizCore(store)(setupInput);
      final membership =
          (await store.database
                  .select(store.database.coreCompanyMemberships)
                  .get())
              .single;

      expect(
        () => store.assignRoleToMembership(
          membershipId: membership.id,
          roleId: 'non-existent-role-id',
        ),
        throwsA(isA<Exception>()),
      );
      await store.close();
    });

    test('9. Unknown membership assignment throws (FK)', () async {
      final store = await DriftCoreInstallationStore.open(databasePath);
      await InitializeNexaBizCore(store)(setupInput);
      final ownerRole = (await (store.database.select(
        store.database.coreRoles,
      )..where((t) => t.roleKey.equals('company.owner'))).getSingle());

      expect(
        () => store.assignRoleToMembership(
          membershipId: 'non-existent-membership-id',
          roleId: ownerRole.id,
        ),
        throwsA(isA<Exception>()),
      );
      await store.close();
    });

    test('10. Cross-tenant assignment throws', () async {
      final store = await DriftCoreInstallationStore.open(databasePath);
      await InitializeNexaBizCore(store)(setupInput);
      final db = store.database;

      final comp1 = (await db.select(db.coreCompanies).get()).single;
      final mem1 = (await db.select(db.coreCompanyMemberships).get()).single;
      final role1 = (await (db.select(
        db.coreRoles,
      )..where((t) => t.companyId.equals(comp1.id))).getSingle());

      // Create Company 2 and Membership 2
      final now = DateTime.now().toUtc();
      await db
          .into(db.coreCompanies)
          .insert(
            CoreCompaniesCompanion.insert(
              id: 'comp-2',
              code: const Value('COMP2'),
              name: const Value('Company Two'),
              status: const Value('active'),
              createdAt: Value(now),
              updatedAt: Value(now),
            ),
          );
      await db
          .into(db.coreUsers)
          .insert(
            CoreUsersCompanion.insert(
              id: 'user-2',
              email: const Value('user2@example.test'),
              name: const Value('User Two'),
              status: const Value('active'),
              createdAt: Value(now),
              updatedAt: Value(now),
            ),
          );
      await db
          .into(db.coreCompanyMemberships)
          .insert(
            CoreCompanyMembershipsCompanion.insert(
              id: 'mem-2',
              userId: 'user-2',
              companyId: 'comp-2',
              role: 'owner',
              status: 'active',
              createdAt: Value(now),
              updatedAt: Value(now),
            ),
          );

      final role2Id = await store.createRole(
        roleId: NexaBizRoleId('company.supervisor'),
        companyId: 'comp-2',
      );

      // Attempt 1: Assign Company 2 role to Company 1 membership -> MUST THROW
      expect(
        () => store.assignRoleToMembership(
          membershipId: mem1.id,
          roleId: role2Id,
        ),
        throwsA(isA<Exception>()),
      );

      // Attempt 2: Assign Company 1 role to Company 2 membership -> MUST THROW
      expect(
        () => store.assignRoleToMembership(
          membershipId: 'mem-2',
          roleId: role1.id,
        ),
        throwsA(isA<Exception>()),
      );

      await store.close();
    });

    test(
      '11. Scope isolation throws: Company membership cannot receive system role',
      () async {
        final store = await DriftCoreInstallationStore.open(databasePath);
        await InitializeNexaBizCore(store)(setupInput);
        final membership =
            (await store.database
                    .select(store.database.coreCompanyMemberships)
                    .get())
                .single;

        final sysRoleId = await store.createRole(
          roleId: NexaBizRoleId('system.admin'),
          companyId: null,
        );

        expect(
          () => store.assignRoleToMembership(
            membershipId: membership.id,
            roleId: sysRoleId,
          ),
          throwsA(isA<Exception>()),
        );
        await store.close();
      },
    );

    test(
      '12. Role permissions deduplication across multiple assigned roles',
      () async {
        final store = await DriftCoreInstallationStore.open(databasePath);
        await InitializeNexaBizCore(store)(setupInput);
        final db = store.database;
        final company = (await db.select(db.coreCompanies).get()).single;
        final membership =
            (await db.select(db.coreCompanyMemberships).get()).single;

        // Role 1 (roleA) has Perm A ('company.details.view') and Perm B ('company.details.edit')
        final roleA = await store.createRole(
          roleId: NexaBizRoleId('company.role_a'),
          companyId: company.id,
        );
        await store.grantPermissionToRole(
          roleId: roleA,
          permissionId: NexaBizPermissionId('company.details.view'),
        );
        await store.grantPermissionToRole(
          roleId: roleA,
          permissionId: NexaBizPermissionId('company.details.edit'),
        );

        // Role 2 (roleB) has Perm B ('company.details.edit') and Perm C ('identity.user.manage')
        final roleB = await store.createRole(
          roleId: NexaBizRoleId('company.role_b'),
          companyId: company.id,
        );
        await store.grantPermissionToRole(
          roleId: roleB,
          permissionId: NexaBizPermissionId('company.details.edit'),
        );
        await store.grantPermissionToRole(
          roleId: roleB,
          permissionId: NexaBizPermissionId('identity.user.manage'),
        );

        // Assign both roles
        await store.assignRoleToMembership(
          membershipId: membership.id,
          roleId: roleA,
        );
        await store.assignRoleToMembership(
          membershipId: membership.id,
          roleId: roleB,
        );

        final snapshot = await store.readMembershipAuthorizationSnapshot(
          membership.id,
        );
        expect(snapshot, isNotNull);

        // Contains both roles + built-in owner
        expect(
          snapshot!.roleIds,
          containsAll([
            NexaBizRoleId('company.role_a'),
            NexaBizRoleId('company.role_b'),
          ]),
        );

        // Verify Perm B is deduplicated in the set
        expect(
          snapshot.permissionIds,
          containsAll([
            NexaBizPermissionId('company.details.view'),
            NexaBizPermissionId('company.details.edit'),
            NexaBizPermissionId('identity.user.manage'),
          ]),
        );
        await store.close();
      },
    );

    test('13. Role removal updates effective permissions', () async {
      final store = await DriftCoreInstallationStore.open(databasePath);
      await InitializeNexaBizCore(store)(setupInput);
      await addSecondActiveOwner(store);
      final db = store.database;
      final company = (await db.select(db.coreCompanies).get()).single;
      final membership =
          (await db.select(db.coreCompanyMemberships).get()).first;

      // Remove the built-in owner role first to test with isolated roles
      final ownerRole = (await (db.select(
        db.coreRoles,
      )..where((t) => t.roleKey.equals('company.owner'))).getSingle());
      await store.removeRoleFromMembership(
        membershipId: membership.id,
        roleId: ownerRole.id,
      );

      final roleA = await store.createRole(
        roleId: NexaBizRoleId('company.a'),
        companyId: company.id,
      );
      final roleB = await store.createRole(
        roleId: NexaBizRoleId('company.b'),
        companyId: company.id,
      );

      await store.grantPermissionToRole(
        roleId: roleA,
        permissionId: NexaBizPermissionId('company.details.view'),
      );
      await store.grantPermissionToRole(
        roleId: roleB,
        permissionId: NexaBizPermissionId('identity.user.manage'),
      );

      await store.assignRoleToMembership(
        membershipId: membership.id,
        roleId: roleA,
      );
      await store.assignRoleToMembership(
        membershipId: membership.id,
        roleId: roleB,
      );

      var snapshot = await store.readMembershipAuthorizationSnapshot(
        membership.id,
      );
      expect(snapshot!.permissionIds, {
        NexaBizPermissionId('company.details.view'),
        NexaBizPermissionId('identity.user.manage'),
      });

      // Remove role B
      await store.removeRoleFromMembership(
        membershipId: membership.id,
        roleId: roleB,
      );

      snapshot = await store.readMembershipAuthorizationSnapshot(membership.id);
      expect(snapshot!.roleIds, {NexaBizRoleId('company.a')});
      expect(snapshot.permissionIds, {
        NexaBizPermissionId('company.details.view'),
      });

      await store.close();
    });

    test('14. Permission revocation updates effective permissions', () async {
      final store = await DriftCoreInstallationStore.open(databasePath);
      await InitializeNexaBizCore(store)(setupInput);
      await addSecondActiveOwner(store);
      final db = store.database;
      final company = (await db.select(db.coreCompanies).get()).single;
      final membership =
          (await db.select(db.coreCompanyMemberships).get()).first;

      final ownerRole = (await (db.select(
        db.coreRoles,
      )..where((t) => t.roleKey.equals('company.owner'))).getSingle());
      await store.removeRoleFromMembership(
        membershipId: membership.id,
        roleId: ownerRole.id,
      );

      final role = await store.createRole(
        roleId: NexaBizRoleId('company.editor'),
        companyId: company.id,
      );
      await store.grantPermissionToRole(
        roleId: role,
        permissionId: NexaBizPermissionId('company.details.view'),
      );
      await store.grantPermissionToRole(
        roleId: role,
        permissionId: NexaBizPermissionId('company.details.edit'),
      );
      await store.assignRoleToMembership(
        membershipId: membership.id,
        roleId: role,
      );

      var snapshot = await store.readMembershipAuthorizationSnapshot(
        membership.id,
      );
      expect(snapshot!.permissionIds, {
        NexaBizPermissionId('company.details.view'),
        NexaBizPermissionId('company.details.edit'),
      });

      // Revoke company.details.edit
      await store.revokePermissionFromRole(
        roleId: role,
        permissionId: NexaBizPermissionId('company.details.edit'),
      );

      snapshot = await store.readMembershipAuthorizationSnapshot(membership.id);
      expect(snapshot!.permissionIds, {
        NexaBizPermissionId('company.details.view'),
      });

      await store.close();
    });

    test('15. Inactive membership snapshot fails-closed', () async {
      final store = await DriftCoreInstallationStore.open(databasePath);
      await InitializeNexaBizCore(store)(setupInput);
      final db = store.database;
      final membership =
          (await db.select(db.coreCompanyMemberships).get()).single;

      // Deactivate membership
      await (db.update(
        db.coreCompanyMemberships,
      )..where((t) => t.id.equals(membership.id))).write(
        const CoreCompanyMembershipsCompanion(status: Value('revoked')),
      );

      final snapshot = await store.readMembershipAuthorizationSnapshot(
        membership.id,
      );
      expect(snapshot, isNotNull);
      expect(snapshot!.isEligibleForAuthorization, isFalse);
      expect(snapshot.isActive, isFalse);
      expect(snapshot.effectiveRoles, isEmpty);
      expect(snapshot.effectivePermissions, isEmpty);

      // Raw assigned roles/permissions still exist on snapshot for auditing
      expect(snapshot.roleIds, isNotEmpty);
      expect(snapshot.permissionIds, isNotEmpty);

      await store.close();
    });

    test('16. Inactive company snapshot fails-closed', () async {
      final store = await DriftCoreInstallationStore.open(databasePath);
      await InitializeNexaBizCore(store)(setupInput);
      final db = store.database;
      final company = (await db.select(db.coreCompanies).get()).single;
      final membership =
          (await db.select(db.coreCompanyMemberships).get()).single;

      // Suspend company
      await (db.update(db.coreCompanies)..where((t) => t.id.equals(company.id)))
          .write(const CoreCompaniesCompanion(status: Value('suspended')));

      final snapshot = await store.readMembershipAuthorizationSnapshot(
        membership.id,
      );
      expect(snapshot, isNotNull);
      expect(snapshot!.isEligibleForAuthorization, isFalse);
      expect(snapshot.isActive, isFalse);
      expect(snapshot.effectiveRoles, isEmpty);
      expect(snapshot.effectivePermissions, isEmpty);

      await store.close();
    });

    test('17. Inactive user snapshot fails-closed', () async {
      final store = await DriftCoreInstallationStore.open(databasePath);
      await InitializeNexaBizCore(store)(setupInput);
      final db = store.database;
      final user = (await db.select(db.coreUsers).get()).single;
      final membership =
          (await db.select(db.coreCompanyMemberships).get()).single;

      // Disable user
      await (db.update(db.coreUsers)..where((t) => t.id.equals(user.id))).write(
        const CoreUsersCompanion(status: Value('disabled')),
      );

      final snapshot = await store.readMembershipAuthorizationSnapshot(
        membership.id,
      );
      expect(snapshot, isNotNull);
      expect(snapshot!.isEligibleForAuthorization, isFalse);
      expect(snapshot.isActive, isFalse);
      expect(snapshot.effectiveRoles, isEmpty);
      expect(snapshot.effectivePermissions, isEmpty);

      await store.close();
    });

    test(
      '18. Atomic query returns consistent snapshot or null for unknown membership',
      () async {
        final store = await DriftCoreInstallationStore.open(databasePath);
        await InitializeNexaBizCore(store)(setupInput);

        final unknown = await store.readMembershipAuthorizationSnapshot(
          'unknown-id',
        );
        expect(unknown, isNull);

        final membership =
            (await store.database
                    .select(store.database.coreCompanyMemberships)
                    .get())
                .single;
        final snapshot = await store.readMembershipAuthorizationSnapshot(
          membership.id,
        );
        expect(snapshot, isNotNull);
        expect(snapshot!.membershipId.value, membership.id);
        expect(snapshot.companyId.value, membership.companyId);
        expect(snapshot.userId.value, membership.userId);

        await store.close();
      },
    );

    test(
      '19. Closed permissions: membership with no roles or role with no permissions',
      () async {
        final store = await DriftCoreInstallationStore.open(databasePath);
        await InitializeNexaBizCore(store)(setupInput);
        await addSecondActiveOwner(store);
        final db = store.database;
        final company = (await db.select(db.coreCompanies).get()).single;
        final membership =
            (await db.select(db.coreCompanyMemberships).get()).first;

        // 1. Remove all roles from membership
        final ownerRole = (await (db.select(
          db.coreRoles,
        )..where((t) => t.roleKey.equals('company.owner'))).getSingle());
        await store.removeRoleFromMembership(
          membershipId: membership.id,
          roleId: ownerRole.id,
        );

        var snapshot = await store.readMembershipAuthorizationSnapshot(
          membership.id,
        );
        expect(snapshot!.roleIds, isEmpty);
        expect(snapshot.permissionIds, isEmpty);
        expect(snapshot.effectiveRoles, isEmpty);
        expect(snapshot.effectivePermissions, isEmpty);

        // 2. Assign role with no permissions
        final emptyRole = await store.createRole(
          roleId: NexaBizRoleId('company.empty'),
          companyId: company.id,
        );
        await store.assignRoleToMembership(
          membershipId: membership.id,
          roleId: emptyRole,
        );

        snapshot = await store.readMembershipAuthorizationSnapshot(
          membership.id,
        );
        expect(snapshot!.roleIds, {NexaBizRoleId('company.empty')});
        expect(snapshot.permissionIds, isEmpty);
        expect(snapshot.effectivePermissions, isEmpty);

        await store.close();
      },
    );

    test(
      '20. Built-in roles: Initial setup creates company.owner role with declared permissions',
      () async {
        final store = await DriftCoreInstallationStore.open(databasePath);
        final readiness = await InitializeNexaBizCore(store)(setupInput);
        expect(readiness.isReady, isTrue);

        final db = store.database;
        final roles = await db.select(db.coreRoles).get();
        expect(roles, hasLength(1));
        expect(roles.single.roleKey, 'company.owner');
        expect(roles.single.scope, 'company');
        expect(roles.single.isBuiltin, isTrue);

        final membershipRoles = await db.select(db.coreMembershipRoles).get();
        expect(membershipRoles, hasLength(1));
        expect(membershipRoles.single.roleId, roles.single.id);

        final rolePermissions = await db.select(db.coreRolePermissions).get();
        expect(
          rolePermissions.map((rp) => rp.permissionId).toSet(),
          kInitialCompanyOwnerPermissions,
        );

        final membership =
            (await db.select(db.coreCompanyMemberships).get()).single;
        final snapshot = await store.readMembershipAuthorizationSnapshot(
          membership.id,
        );
        expect(snapshot, isNotNull);
        expect(snapshot!.isEligibleForAuthorization, isTrue);
        expect(snapshot.effectiveRoles, {NexaBizRoleId('company.owner')});
        expect(
          snapshot.effectivePermissions,
          kInitialCompanyOwnerPermissions.map(NexaBizPermissionId.new).toSet(),
        );

        await store.close();
      },
    );

    test('21. DB reopen / restart preserves all RBAC mappings', () async {
      final store = await DriftCoreInstallationStore.open(databasePath);
      await InitializeNexaBizCore(store)(setupInput);
      final company =
          (await store.database.select(store.database.coreCompanies).get())
              .single;
      final membership =
          (await store.database
                  .select(store.database.coreCompanyMemberships)
                  .get())
              .single;

      final roleId = await store.createRole(
        roleId: NexaBizRoleId('company.manager'),
        companyId: company.id,
      );
      await store.grantPermissionToRole(
        roleId: roleId,
        permissionId: NexaBizPermissionId('permissions.policy.review'),
      );
      await store.assignRoleToMembership(
        membershipId: membership.id,
        roleId: roleId,
      );
      await store.close();

      // Reopen from disk
      final reopenedStore = await DriftCoreInstallationStore.open(databasePath);
      final snapshot = await reopenedStore.readMembershipAuthorizationSnapshot(
        membership.id,
      );
      expect(snapshot, isNotNull);
      expect(snapshot!.isEligibleForAuthorization, isTrue);
      expect(snapshot.roleIds, {
        NexaBizRoleId('company.owner'),
        NexaBizRoleId('company.manager'),
      });
      expect(
        snapshot.permissionIds,
        contains(NexaBizPermissionId('permissions.policy.review')),
      );

      await reopenedStore.close();
    });
  });
}
