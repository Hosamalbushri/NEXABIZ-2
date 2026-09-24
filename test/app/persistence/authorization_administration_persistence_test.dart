import 'dart:io';

import 'package:drift/drift.dart' hide isNotNull, isNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nexabiz/app/persistence/drift_authorization_administration_store.dart';
import 'package:nexabiz/app/persistence/drift_core_database.dart';
import 'package:nexabiz/app/persistence/drift_core_installation_store.dart';
import 'package:nexabiz/core/authorization/administration/nexabiz_authorization_administration_errors.dart';
import 'package:nexabiz/core/authorization/administration/nexabiz_authorization_administration_models.dart';
import 'package:nexabiz/core/authorization/administration/nexabiz_authorization_administration_policy.dart';
import 'package:nexabiz/core/authorization/nexabiz_membership_id.dart';
import 'package:nexabiz/core/authorization/nexabiz_permission_catalog.dart';
import 'package:nexabiz/core/company/nexabiz_company_scope.dart';
import 'package:nexabiz/core/permissions/nexabiz_permission_intent.dart';
import 'package:nexabiz/core/roles/nexabiz_role_id.dart';
import 'package:nexabiz/core/setup/initialize_nexabiz_core.dart';
import 'package:path/path.dart' as p;

void main() {
  late Directory directory;
  late String databasePath;
  DriftCoreInstallationStore? installation;
  late DriftCoreDatabase database;
  late DriftAuthorizationAdministrationStore store;
  late NexaBizCompanyId companyA;
  late NexaBizMembershipId ownerMembershipA;

  final auditView = NexaBizPermissionId('reports.audit.view');
  final auditManage = NexaBizPermissionId('reports.audit.manage');
  final permissionCatalog = NexaBizImmutablePermissionCatalog({
    ...kInitialCompanyOwnerPermissions.map(NexaBizPermissionId.new),
    auditView,
    auditManage,
  });

  NexaBizRoleMetadata metadata(String name, [String? description]) =>
      NexaBizRoleMetadata(
        displayName: NexaBizRoleDisplayName(name),
        description: description,
      );

  setUp(() async {
    directory = Directory.systemTemp.createTempSync('nexabiz_authz_admin_');
    databasePath = p.join(directory.path, 'core.sqlite');
    installation = await DriftCoreInstallationStore.open(databasePath);
    await InitializeNexaBizCore(installation!)(
      const CoreInitializationInput(
        companyCode: 'A',
        companyName: 'Company A',
        adminName: 'Owner A',
        adminEmail: 'owner-a@example.test',
        password: 'secure_password_123',
      ),
    );
    database = installation!.database;
    store = DriftAuthorizationAdministrationStore(
      database,
      permissionCatalog: permissionCatalog,
    );
    companyA = NexaBizCompanyId(
      (await database.select(database.coreCompanies).get()).single.id,
    );
    ownerMembershipA = NexaBizMembershipId(
      (await database.select(database.coreCompanyMemberships).get()).single.id,
    );
  });

  tearDown(() async {
    await installation?.close();
    installation = null;
    if (directory.existsSync()) directory.deleteSync(recursive: true);
  });

  Future<NexaBizMembershipId> addMembership({
    required String suffix,
    NexaBizCompanyId? companyId,
    String membershipStatus = 'active',
    String userStatus = 'active',
  }) async {
    final targetCompany = companyId ?? companyA;
    final now = DateTime.now().toUtc();
    final userId = 'user-$suffix';
    final membershipId = 'membership-$suffix';
    await database
        .into(database.coreUsers)
        .insert(
          CoreUsersCompanion.insert(
            id: userId,
            email: Value('$suffix@example.test'),
            name: Value('User $suffix'),
            status: Value(userStatus),
            createdAt: Value(now),
            updatedAt: Value(now),
          ),
        );
    await database
        .into(database.coreCompanyMemberships)
        .insert(
          CoreCompanyMembershipsCompanion.insert(
            id: membershipId,
            userId: userId,
            companyId: targetCompany.value,
            role: 'member',
            status: membershipStatus,
            createdAt: Value(now),
            updatedAt: Value(now),
          ),
        );
    return NexaBizMembershipId(membershipId);
  }

  Future<NexaBizCompanyId> addCompany(String suffix) async {
    final id = NexaBizCompanyId('company-$suffix');
    final now = DateTime.now().toUtc();
    await database
        .into(database.coreCompanies)
        .insert(
          CoreCompaniesCompanion.insert(
            id: id.value,
            code: Value('C$suffix'),
            name: Value('Company $suffix'),
            status: const Value('active'),
            createdAt: Value(now),
            updatedAt: Value(now),
          ),
        );
    return id;
  }

  NexaBizRoleId role(String name) => NexaBizRoleId('company.$name');

  test(
    'role create, update, delete, conflicts, and before/after are typed',
    () async {
      final auditor = role('auditor');
      final created = await store.createCompanyRole(
        companyId: companyA,
        roleId: auditor,
        metadata: metadata(' Auditor ', ' Reviews records '),
      );
      expect(created.changed, isTrue);
      expect(created.before, isNull);
      expect(created.after!.roleId, auditor);
      expect(created.after!.metadata.displayName.value, 'Auditor');
      expect(created.after!.metadata.description, 'Reviews records');

      final unchanged = await store.updateCompanyRoleMetadata(
        companyId: companyA,
        roleId: auditor,
        metadata: metadata('Auditor', 'Reviews records'),
      );
      expect(unchanged.changed, isFalse);
      expect(unchanged.before!.updatedAt, unchanged.after!.updatedAt);

      final updated = await store.updateCompanyRoleMetadata(
        companyId: companyA,
        roleId: auditor,
        metadata: metadata('Senior Auditor'),
      );
      expect(updated.changed, isTrue);
      expect(updated.before!.metadata.displayName.value, 'Auditor');
      expect(updated.after!.metadata.displayName.value, 'Senior Auditor');

      await expectLater(
        store.createCompanyRole(
          companyId: companyA,
          roleId: auditor,
          metadata: metadata('Another Name'),
        ),
        throwsA(
          isA<NexaBizAuthorizationAdministrationConflictException>().having(
            (error) => error.type,
            'type',
            NexaBizAuthorizationAdministrationConflictType.duplicateRoleKey,
          ),
        ),
      );
      await expectLater(
        store.createCompanyRole(
          companyId: companyA,
          roleId: role('reviewer'),
          metadata: metadata(' senior auditor '),
        ),
        throwsA(
          isA<NexaBizAuthorizationAdministrationConflictException>().having(
            (error) => error.type,
            'type',
            NexaBizAuthorizationAdministrationConflictType
                .duplicateRoleDisplayName,
          ),
        ),
      );

      await store.grantPermissionToRole(
        companyId: companyA,
        roleId: auditor,
        permissionId: auditView,
      );
      final deleted = await store.deleteCompanyRole(
        companyId: companyA,
        roleId: auditor,
      );
      expect(deleted.before!.permissionAssignmentCount, 1);
      expect(deleted.after, isNull);
      expect(
        await database.select(database.coreRolePermissions).get(),
        hasLength(kInitialCompanyOwnerPermissions.length),
      );
    },
  );

  test(
    'normalized names match Dart for ASCII, Unicode, Arabic, and companies',
    () async {
      await store.createCompanyRole(
        companyId: companyA,
        roleId: role('latin'),
        metadata: metadata('ÄDMIN'),
      );
      await expectLater(
        store.createCompanyRole(
          companyId: companyA,
          roleId: role('latin_duplicate'),
          metadata: metadata('ädmin'),
        ),
        throwsA(isA<NexaBizAuthorizationAdministrationConflictException>()),
      );

      await store.createCompanyRole(
        companyId: companyA,
        roleId: role('composed'),
        metadata: metadata('Café'),
      );
      await store.createCompanyRole(
        companyId: companyA,
        roleId: role('decomposed'),
        metadata: metadata('Cafe\u0301'),
      );
      await store.createCompanyRole(
        companyId: companyA,
        roleId: role('arabic'),
        metadata: metadata('مدقق'),
      );
      await expectLater(
        store.createCompanyRole(
          companyId: companyA,
          roleId: role('arabic_duplicate'),
          metadata: metadata('  مدقق  '),
        ),
        throwsA(isA<NexaBizAuthorizationAdministrationConflictException>()),
      );

      final companyB = await addCompany('b');
      final sameNameOtherCompany = await store.createCompanyRole(
        companyId: companyB,
        roleId: role('arabic'),
        metadata: metadata('مدقق'),
      );
      expect(sameNameOtherCompany.changed, isTrue);

      final keys = await database
          .customSelect(
            '''
      SELECT role_key, normalized_name FROM core_roles
      WHERE company_id = ? AND role_key IN ('company.composed', 'company.decomposed')
      ORDER BY role_key
    ''',
            variables: [Variable.withString(companyA.value)],
          )
          .get();
      expect(keys[0].read<String>('normalized_name'), 'café');
      expect(keys[1].read<String>('normalized_name'), 'cafe\u0301');
    },
  );

  test('built-in owner metadata, deletion, and grants are protected', () async {
    final owner = NexaBizBuiltInCompanyRoles.companyOwner;
    for (final action in <Future<Object?> Function()>[
      () => store.updateCompanyRoleMetadata(
        companyId: companyA,
        roleId: owner,
        metadata: metadata('Renamed Owner'),
      ),
      () => store.deleteCompanyRole(companyId: companyA, roleId: owner),
      () => store.grantPermissionToRole(
        companyId: companyA,
        roleId: owner,
        permissionId: auditView,
      ),
      () => store.revokePermissionFromRole(
        companyId: companyA,
        roleId: owner,
        permissionId: NexaBizPermissionId('permissions.role.manage'),
      ),
    ]) {
      await expectLater(
        action(),
        throwsA(isA<NexaBizBuiltInRoleProtectedException>()),
      );
    }
  });

  test(
    'permission grants and revocations validate catalog and are idempotent',
    () async {
      final auditor = role('auditor');
      await store.createCompanyRole(
        companyId: companyA,
        roleId: auditor,
        metadata: metadata('Auditor'),
      );
      final granted = await store.grantPermissionToRole(
        companyId: companyA,
        roleId: auditor,
        permissionId: auditView,
      );
      expect(granted.changed, isTrue);
      expect(granted.before, isNull);
      expect(granted.after!.permissionId, auditView);

      final repeated = await store.grantPermissionToRole(
        companyId: companyA,
        roleId: auditor,
        permissionId: auditView,
      );
      expect(repeated.changed, isFalse);
      expect(repeated.before!.assignedAt, repeated.after!.assignedAt);

      final revoked = await store.revokePermissionFromRole(
        companyId: companyA,
        roleId: auditor,
        permissionId: auditView,
      );
      expect(revoked.changed, isTrue);
      expect(revoked.before!.permissionId, auditView);
      expect(revoked.after, isNull);

      final missing = await store.revokePermissionFromRole(
        companyId: companyA,
        roleId: auditor,
        permissionId: auditView,
      );
      expect(missing.changed, isFalse);
      expect(missing.before, isNull);
      expect(missing.after, isNull);

      await expectLater(
        store.grantPermissionToRole(
          companyId: companyA,
          roleId: auditor,
          permissionId: NexaBizPermissionId('unknown.resource.view'),
        ),
        throwsA(isA<NexaBizUndeclaredPermissionException>()),
      );
    },
  );

  test(
    'membership assignment, cleanup, and assigned-role delete policy',
    () async {
      final operator = role('operator');
      await store.createCompanyRole(
        companyId: companyA,
        roleId: operator,
        metadata: metadata('Operator'),
      );
      final active = await addMembership(suffix: 'active');
      final assigned = await store.assignRoleToMembership(
        companyId: companyA,
        membershipId: active,
        roleId: operator,
      );
      expect(assigned.changed, isTrue);
      final repeated = await store.assignRoleToMembership(
        companyId: companyA,
        membershipId: active,
        roleId: operator,
      );
      expect(repeated.changed, isFalse);

      await expectLater(
        store.deleteCompanyRole(companyId: companyA, roleId: operator),
        throwsA(
          isA<NexaBizAuthorizationAdministrationConflictException>().having(
            (error) => error.type,
            'type',
            NexaBizAuthorizationAdministrationConflictType
                .roleHasMembershipAssignments,
          ),
        ),
      );

      final inactive = await addMembership(
        suffix: 'inactive',
        membershipStatus: 'inactive',
      );
      await expectLater(
        store.assignRoleToMembership(
          companyId: companyA,
          membershipId: inactive,
          roleId: operator,
        ),
        throwsA(isA<NexaBizMembershipIneligibleException>()),
      );

      final inactiveUser = await addMembership(
        suffix: 'inactive-user-direct',
        userStatus: 'inactive',
      );
      await expectLater(
        store.assignRoleToMembership(
          companyId: companyA,
          membershipId: inactiveUser,
          roleId: operator,
        ),
        throwsA(isA<NexaBizMembershipIneligibleException>()),
      );

      final missingMembership = NexaBizMembershipId('membership-missing');
      await expectLater(
        store.assignRoleToMembership(
          companyId: companyA,
          membershipId: missingMembership,
          roleId: operator,
        ),
        throwsA(isA<NexaBizMembershipNotFoundException>()),
      );

      final roleRow = await (database.select(
        database.coreRoles,
      )..where((table) => table.roleKey.equals(operator.value))).getSingle();
      await database
          .into(database.coreMembershipRoles)
          .insert(
            CoreMembershipRolesCompanion.insert(
              membershipId: inactive.value,
              roleId: roleRow.id,
              createdAt: DateTime.now().toUtc(),
            ),
          );
      final cleaned = await store.unassignRoleFromMembership(
        companyId: companyA,
        membershipId: inactive,
        roleId: operator,
      );
      expect(cleaned.changed, isTrue);
      final missing = await store.unassignRoleFromMembership(
        companyId: companyA,
        membershipId: inactive,
        roleId: operator,
      );
      expect(missing.changed, isFalse);
    },
  );

  test(
    'last active owner is rejected and one of two owners can be removed',
    () async {
      await expectLater(
        store.unassignRoleFromMembership(
          companyId: companyA,
          membershipId: ownerMembershipA,
          roleId: NexaBizBuiltInCompanyRoles.companyOwner,
        ),
        throwsA(isA<NexaBizLastOwnerProtectedException>()),
      );

      final secondOwner = await addMembership(suffix: 'second-owner');
      await store.assignRoleToMembership(
        companyId: companyA,
        membershipId: secondOwner,
        roleId: NexaBizBuiltInCompanyRoles.companyOwner,
      );
      final removed = await store.unassignRoleFromMembership(
        companyId: companyA,
        membershipId: ownerMembershipA,
        roleId: NexaBizBuiltInCompanyRoles.companyOwner,
      );
      expect(removed.changed, isTrue);
      await expectLater(
        store.unassignRoleFromMembership(
          companyId: companyA,
          membershipId: secondOwner,
          roleId: NexaBizBuiltInCompanyRoles.companyOwner,
        ),
        throwsA(isA<NexaBizLastOwnerProtectedException>()),
      );
    },
  );

  test(
    'active company cannot lose its last active owner through Core identity writes',
    () async {
      final ownerMembership = await (database.select(
        database.coreCompanyMemberships,
      )..where((table) => table.id.equals(ownerMembershipA.value))).getSingle();

      await expectLater(
        (database.update(
          database.coreCompanyMemberships,
        )..where((table) => table.id.equals(ownerMembershipA.value))).write(
          const CoreCompanyMembershipsCompanion(status: Value('inactive')),
        ),
        throwsA(isA<Exception>()),
      );
      await expectLater(
        (database.update(database.coreUsers)
              ..where((table) => table.id.equals(ownerMembership.userId)))
            .write(const CoreUsersCompanion(status: Value('inactive'))),
        throwsA(isA<Exception>()),
      );
      await expectLater(
        (database.update(database.coreUsers)
              ..where((table) => table.id.equals(ownerMembership.userId)))
            .write(const CoreUsersCompanion(status: Value(null))),
        throwsA(isA<Exception>()),
      );
      await expectLater(
        (database.delete(
          database.coreCompanyMemberships,
        )..where((table) => table.id.equals(ownerMembershipA.value))).go(),
        throwsA(isA<Exception>()),
      );

      await (database.update(database.coreCompanies)
            ..where((table) => table.id.equals(companyA.value)))
          .write(const CoreCompaniesCompanion(status: Value('inactive')));
      await (database.update(
        database.coreCompanyMemberships,
      )..where((table) => table.id.equals(ownerMembershipA.value))).write(
        const CoreCompanyMembershipsCompanion(status: Value('inactive')),
      );
      await expectLater(
        (database.update(database.coreCompanies)
              ..where((table) => table.id.equals(companyA.value)))
            .write(const CoreCompaniesCompanion(status: Value('active'))),
        throwsA(isA<Exception>()),
      );
    },
  );

  test(
    'active company owner role cannot be renamed, reassigned, or cascade-deleted',
    () async {
      final replacement = role('owner_replacement');
      await store.createCompanyRole(
        companyId: companyA,
        roleId: replacement,
        metadata: metadata('Owner replacement'),
      );
      final replacementRow = await (database.select(
        database.coreRoles,
      )..where((table) => table.roleKey.equals(replacement.value))).getSingle();
      final ownerRole =
          await (database.select(database.coreRoles)..where(
                (table) =>
                    table.companyId.equals(companyA.value) &
                    table.roleKey.equals(
                      NexaBizBuiltInCompanyRoles.companyOwner.value,
                    ),
              ))
              .getSingle();

      await expectLater(
        (database.update(
          database.coreRoles,
        )..where((table) => table.id.equals(ownerRole.id))).write(
          const CoreRolesCompanion(roleKey: Value('company.former_owner')),
        ),
        throwsA(isA<Exception>()),
      );
      await expectLater(
        (database.update(database.coreMembershipRoles)..where(
              (table) =>
                  table.membershipId.equals(ownerMembershipA.value) &
                  table.roleId.equals(ownerRole.id),
            ))
            .write(
              CoreMembershipRolesCompanion(roleId: Value(replacementRow.id)),
            ),
        throwsA(isA<Exception>()),
      );
      await expectLater(
        (database.delete(
          database.coreRoles,
        )..where((table) => table.id.equals(ownerRole.id))).go(),
        throwsA(isA<Exception>()),
      );
    },
  );

  test(
    'cross-company role and membership attacks return typed errors',
    () async {
      final companyB = await addCompany('b');
      final memberB = await addMembership(suffix: 'b', companyId: companyB);
      final roleB = role('company_b_only');
      await store.createCompanyRole(
        companyId: companyB,
        roleId: roleB,
        metadata: metadata('Company B Role'),
      );
      final roleA = role('company_a_only');
      await store.createCompanyRole(
        companyId: companyA,
        roleId: roleA,
        metadata: metadata('Company A Role'),
      );

      final crossRoleActions = <Future<Object?> Function()>[
        () => store.readCompanyRole(companyId: companyA, roleId: roleB),
        () => store.updateCompanyRoleMetadata(
          companyId: companyA,
          roleId: roleB,
          metadata: metadata('Attack'),
        ),
        () => store.deleteCompanyRole(companyId: companyA, roleId: roleB),
        () => store.grantPermissionToRole(
          companyId: companyA,
          roleId: roleB,
          permissionId: auditView,
        ),
        () => store.revokePermissionFromRole(
          companyId: companyA,
          roleId: roleB,
          permissionId: auditView,
        ),
      ];
      for (final action in crossRoleActions) {
        await expectLater(
          action(),
          throwsA(isA<NexaBizAuthorizationCrossCompanyException>()),
        );
      }
      await expectLater(
        store.assignRoleToMembership(
          companyId: companyA,
          membershipId: ownerMembershipA,
          roleId: roleB,
        ),
        throwsA(isA<NexaBizAuthorizationCrossCompanyException>()),
      );
      await expectLater(
        store.assignRoleToMembership(
          companyId: companyA,
          membershipId: memberB,
          roleId: roleA,
        ),
        throwsA(isA<NexaBizAuthorizationCrossCompanyException>()),
      );
      await expectLater(
        store.unassignRoleFromMembership(
          companyId: companyA,
          membershipId: memberB,
          roleId: roleA,
        ),
        throwsA(isA<NexaBizAuthorizationCrossCompanyException>()),
      );

      final rolesA = await store.listCompanyRoles(
        companyId: companyA,
        page: NexaBizAuthorizationAdministrationPageRequest(limit: 100),
      );
      expect(rolesA.items.map((item) => item.roleId), isNot(contains(roleB)));
    },
  );

  test(
    'parent tenant updates cannot invalidate existing role assignments',
    () async {
      final companyB = await addCompany('parent-update-b');
      final member = await addMembership(suffix: 'parent-update');
      final assignedRole = role('parent_update');
      await store.createCompanyRole(
        companyId: companyA,
        roleId: assignedRole,
        metadata: metadata('Parent Update'),
      );
      await store.assignRoleToMembership(
        companyId: companyA,
        membershipId: member,
        roleId: assignedRole,
      );
      final roleRow =
          await (database.select(database.coreRoles)
                ..where((table) => table.roleKey.equals(assignedRole.value)))
              .getSingle();

      await expectLater(
        (database.update(
          database.coreCompanyMemberships,
        )..where((table) => table.id.equals(member.value))).write(
          CoreCompanyMembershipsCompanion(companyId: Value(companyB.value)),
        ),
        throwsA(isA<Exception>()),
      );
      await expectLater(
        (database.update(database.coreRoles)
              ..where((table) => table.id.equals(roleRow.id)))
            .write(CoreRolesCompanion(companyId: Value(companyB.value))),
        throwsA(isA<Exception>()),
      );
    },
  );

  test(
    'queries paginate stably and inspect current relational permissions',
    () async {
      for (final name in ['alpha', 'beta', 'gamma']) {
        await store.createCompanyRole(
          companyId: companyA,
          roleId: role(name),
          metadata: metadata(name.toUpperCase()),
        );
      }
      final first = await store.listCompanyRoles(
        companyId: companyA,
        page: NexaBizAuthorizationAdministrationPageRequest(limit: 2),
      );
      final second = await store.listCompanyRoles(
        companyId: companyA,
        page: NexaBizAuthorizationAdministrationPageRequest(
          limit: 2,
          cursor: first.nextCursor,
        ),
      );
      expect(first.hasMore, isTrue);
      expect(
        first.items
            .map((item) => item.roleId)
            .toSet()
            .intersection(second.items.map((item) => item.roleId).toSet()),
        isEmpty,
      );

      final member = await addMembership(suffix: 'inspection');
      for (final target in [role('alpha'), role('beta')]) {
        await store.grantPermissionToRole(
          companyId: companyA,
          roleId: target,
          permissionId: auditView,
        );
        await store.assignRoleToMembership(
          companyId: companyA,
          membershipId: member,
          roleId: target,
        );
      }
      final inspected = await store.inspectMembershipEffectivePermissions(
        companyId: companyA,
        membershipId: member,
      );
      expect(inspected.isEligible, isTrue);
      expect(inspected.roleIds, {role('alpha'), role('beta')});
      expect(inspected.permissionIds, {auditView});

      final assignments = await store.listMembershipRoles(
        companyId: companyA,
        membershipId: member,
        page: NexaBizAuthorizationAdministrationPageRequest(limit: 1),
      );
      expect(assignments.items, hasLength(1));
      expect(assignments.hasMore, isTrue);
      final memberships = await store.listRoleMemberships(
        companyId: companyA,
        roleId: role('alpha'),
        page: NexaBizAuthorizationAdministrationPageRequest(limit: 10),
      );
      expect(memberships.items.single.membershipId, member);
    },
  );

  test('custom role, grant, and assignment persist across restart', () async {
    final persistedRole = role('persisted');
    final member = await addMembership(suffix: 'persisted');
    await store.createCompanyRole(
      companyId: companyA,
      roleId: persistedRole,
      metadata: metadata('Persisted'),
    );
    await store.grantPermissionToRole(
      companyId: companyA,
      roleId: persistedRole,
      permissionId: auditManage,
    );
    await store.assignRoleToMembership(
      companyId: companyA,
      membershipId: member,
      roleId: persistedRole,
    );
    await installation!.close();
    installation = await DriftCoreInstallationStore.open(databasePath);
    database = installation!.database;
    store = DriftAuthorizationAdministrationStore(
      database,
      permissionCatalog: permissionCatalog,
    );

    final details = await store.readCompanyRole(
      companyId: companyA,
      roleId: persistedRole,
    );
    expect(details.permissionAssignmentCount, 1);
    expect(details.membershipAssignmentCount, 1);
    final inspected = await store.inspectMembershipEffectivePermissions(
      companyId: companyA,
      membershipId: member,
    );
    expect(inspected.permissionIds, {auditManage});
  });

  test(
    'forced role-delete failure rolls back explicit permission deletion',
    () async {
      final rollbackRole = role('rollback');
      await store.createCompanyRole(
        companyId: companyA,
        roleId: rollbackRole,
        metadata: metadata('Rollback'),
      );
      await store.grantPermissionToRole(
        companyId: companyA,
        roleId: rollbackRole,
        permissionId: auditView,
      );
      await database.customStatement('''
      CREATE TRIGGER test_force_role_delete_failure
      BEFORE DELETE ON core_roles
      WHEN OLD.role_key = 'company.rollback'
      BEGIN
        SELECT RAISE(ABORT, 'forced test failure');
      END
    ''');
      await expectLater(
        store.deleteCompanyRole(companyId: companyA, roleId: rollbackRole),
        throwsA(isA<Exception>()),
      );
      final details = await store.readCompanyRole(
        companyId: companyA,
        roleId: rollbackRole,
      );
      expect(details.permissionAssignmentCount, 1);
      final permissions = await store.listRolePermissions(
        companyId: companyA,
        roleId: rollbackRole,
        page: NexaBizAuthorizationAdministrationPageRequest(limit: 10),
      );
      expect(permissions.items.single.permissionId, auditView);
    },
  );

  test('foreign keys and query-supporting v6 indexes are active', () async {
    final foreignKeys = await database
        .customSelect('PRAGMA foreign_keys')
        .getSingle();
    expect(foreignKeys.read<int>('foreign_keys'), 1);
    final indexes =
        (await database
                .customSelect(
                  "SELECT name FROM sqlite_master WHERE type = 'index'",
                )
                .get())
            .map((row) => row.read<String>('name'))
            .toSet();
    expect(
      indexes,
      containsAll({
        'idx_core_roles_company_key',
        'idx_core_roles_company_normalized_name',
        'idx_core_membership_roles_role_membership',
      }),
    );
    await expectLater(
      database.customStatement('''
        INSERT INTO core_membership_roles (membership_id, role_id, created_at)
        VALUES ('missing-membership', 'missing-role', 0)
      '''),
      throwsA(isA<Exception>()),
    );
  });

  test(
    'two database connections cannot concurrently remove both owners',
    () async {
      final secondOwner = await addMembership(suffix: 'concurrent-owner');
      await store.assignRoleToMembership(
        companyId: companyA,
        membershipId: secondOwner,
        roleId: NexaBizBuiltInCompanyRoles.companyOwner,
      );
      await installation!.close();
      installation = null;

      QueryExecutor backgroundExecutor() => NativeDatabase.createInBackground(
        File(databasePath),
        setup: (rawDatabase) {
          rawDatabase.execute('PRAGMA busy_timeout = 5000');
          rawDatabase.execute('PRAGMA foreign_keys = ON');
          rawDatabase.execute('PRAGMA journal_mode = WAL');
        },
      );

      final databaseOne = DriftCoreDatabase(backgroundExecutor());
      await databaseOne.customSelect('SELECT 1').get();
      final databaseTwo = DriftCoreDatabase(backgroundExecutor());
      await databaseTwo.customSelect('SELECT 1').get();
      final storeOne = DriftAuthorizationAdministrationStore(
        databaseOne,
        permissionCatalog: permissionCatalog,
      );
      final storeTwo = DriftAuthorizationAdministrationStore(
        databaseTwo,
        permissionCatalog: permissionCatalog,
      );

      Future<Object> remove(
        DriftAuthorizationAdministrationStore target,
        NexaBizMembershipId membershipId,
      ) async {
        try {
          return await target.unassignRoleFromMembership(
            companyId: companyA,
            membershipId: membershipId,
            roleId: NexaBizBuiltInCompanyRoles.companyOwner,
          );
        } on Object catch (error) {
          return error;
        }
      }

      final results = await Future.wait([
        remove(storeOne, ownerMembershipA),
        remove(storeTwo, secondOwner),
      ]);
      expect(
        results.whereType<NexaBizLastOwnerProtectedException>(),
        hasLength(1),
        reason: '$results',
      );
      expect(
        results
            .whereType<
              NexaBizAuthorizationAdministrationMutationResult<
                NexaBizMembershipRoleAssignment
              >
            >()
            .where((result) => result.changed),
        hasLength(1),
      );
      final remaining = await databaseOne
          .customSelect(
            '''
      SELECT COUNT(*) AS count
      FROM core_membership_roles mr
      JOIN core_roles r ON r.id = mr.role_id
      JOIN core_company_memberships m ON m.id = mr.membership_id
      JOIN core_users u ON u.id = m.user_id
      WHERE r.role_key = ? AND r.company_id = ?
        AND m.status = 'active' AND u.status = 'active'
      ''',
            variables: [
              Variable.withString(
                NexaBizBuiltInCompanyRoles.companyOwner.value,
              ),
              Variable.withString(companyA.value),
            ],
          )
          .getSingle();
      expect(remaining.read<int>('count'), 1);
      await databaseOne.close();
      await databaseTwo.close();
    },
  );

  test(
    'two database connections cannot concurrently deactivate both owners',
    () async {
      final secondOwner = await addMembership(suffix: 'deactivation-owner');
      await store.assignRoleToMembership(
        companyId: companyA,
        membershipId: secondOwner,
        roleId: NexaBizBuiltInCompanyRoles.companyOwner,
      );
      await installation!.close();
      installation = null;

      QueryExecutor backgroundExecutor() => NativeDatabase.createInBackground(
        File(databasePath),
        setup: (rawDatabase) {
          rawDatabase.execute('PRAGMA busy_timeout = 5000');
          rawDatabase.execute('PRAGMA foreign_keys = ON');
          rawDatabase.execute('PRAGMA journal_mode = WAL');
        },
      );

      final databaseOne = DriftCoreDatabase(backgroundExecutor());
      await databaseOne.customSelect('SELECT 1').get();
      final databaseTwo = DriftCoreDatabase(backgroundExecutor());
      await databaseTwo.customSelect('SELECT 1').get();

      Future<Object> deactivate(
        DriftCoreDatabase target,
        NexaBizMembershipId membershipId,
      ) async {
        try {
          return await (target.update(
            target.coreCompanyMemberships,
          )..where((table) => table.id.equals(membershipId.value))).write(
            const CoreCompanyMembershipsCompanion(status: Value('inactive')),
          );
        } on Object catch (error) {
          return error;
        }
      }

      final results = await Future.wait([
        deactivate(databaseOne, ownerMembershipA),
        deactivate(databaseTwo, secondOwner),
      ]);
      expect(results.whereType<int>(), [1]);
      expect(results.whereType<Exception>(), hasLength(1));

      final remaining = await databaseOne
          .customSelect(
            '''
      SELECT COUNT(*) AS count
      FROM core_membership_roles mr
      JOIN core_roles r ON r.id = mr.role_id
      JOIN core_company_memberships m ON m.id = mr.membership_id
      JOIN core_users u ON u.id = m.user_id
      WHERE r.role_key = ? AND r.company_id = ?
        AND m.status = 'active' AND u.status = 'active'
      ''',
            variables: [
              Variable.withString(
                NexaBizBuiltInCompanyRoles.companyOwner.value,
              ),
              Variable.withString(companyA.value),
            ],
          )
          .getSingle();
      expect(remaining.read<int>('count'), 1);
      await databaseOne.close();
      await databaseTwo.close();
    },
  );

  test(
    'listRoleMemberships includes userName and userEmail via single join',
    () async {
      final customRole = NexaBizRoleId('company.developer');
      await store.createCompanyRole(
        companyId: companyA,
        roleId: customRole,
        metadata: metadata('Developer'),
      );

      final mem1 = await addMembership(suffix: 'alice');
      await store.assignRoleToMembership(
        companyId: companyA,
        membershipId: mem1,
        roleId: customRole,
      );

      final page = await store.listRoleMemberships(
        companyId: companyA,
        roleId: customRole,
        page: NexaBizAuthorizationAdministrationPageRequest(limit: 50),
      );

      expect(page.items, hasLength(1));
      final assignment = page.items.single;
      expect(assignment.membershipId, mem1);
      expect(assignment.userName, 'User alice');
      expect(assignment.userEmail, 'alice@example.test');
    },
  );

  group('listAssignableMembershipsForRole', () {
    test(
      'returns active company members not assigned to the target role',
      () async {
        final role = NexaBizRoleId('company.qa_lead');
        await store.createCompanyRole(
          companyId: companyA,
          roleId: role,
          metadata: metadata('QA Lead'),
        );

        final mem1 = await addMembership(suffix: 'bob');
        final mem2 = await addMembership(suffix: 'charlie');
        final inactiveMem = await addMembership(
          suffix: 'dave',
          membershipStatus: 'suspended',
        );
        final inactiveUser = await addMembership(
          suffix: 'eve',
          userStatus: 'suspended',
        );

        final companyB = await addCompany('b');
        final otherCompanyMem = await addMembership(
          suffix: 'frank',
          companyId: companyB,
        );

        // Assign bob to the role
        await store.assignRoleToMembership(
          companyId: companyA,
          membershipId: mem1,
          roleId: role,
        );

        // Initial list of assignable members
        final page = await store.listAssignableMembershipsForRole(
          companyId: companyA,
          roleId: role,
          page: NexaBizAuthorizationAdministrationPageRequest(limit: 50),
        );

        // Should contain ownerMembershipA and mem2 (charlie), but NOT bob (already assigned),
        // NOT inactiveMem (membership inactive), NOT inactiveUser (user inactive), NOT otherCompanyMem (wrong company)
        final assignableIds = page.items.map((m) => m.membershipId).toSet();
        expect(assignableIds.contains(mem2), isTrue);
        expect(assignableIds.contains(ownerMembershipA), isTrue);
        expect(assignableIds.contains(mem1), isFalse);
        expect(assignableIds.contains(inactiveMem), isFalse);
        expect(assignableIds.contains(inactiveUser), isFalse);
        expect(assignableIds.contains(otherCompanyMem), isFalse);

        final charlieItem = page.items.firstWhere(
          (m) => m.membershipId == mem2,
        );
        expect(charlieItem.userName, 'User charlie');
        expect(charlieItem.userEmail, 'charlie@example.test');
        expect(charlieItem.isEligible, isTrue);

        // Filter by search query on name
        final searchByName = await store.listAssignableMembershipsForRole(
          companyId: companyA,
          roleId: role,
          page: NexaBizAuthorizationAdministrationPageRequest(limit: 50),
          search: 'charlie',
        );
        expect(searchByName.items, hasLength(1));
        expect(searchByName.items.single.membershipId, mem2);

        // Filter by search query on email
        final searchByEmail = await store.listAssignableMembershipsForRole(
          companyId: companyA,
          roleId: role,
          page: NexaBizAuthorizationAdministrationPageRequest(limit: 50),
          search: 'charlie@example',
        );
        expect(searchByEmail.items, hasLength(1));
        expect(searchByEmail.items.single.membershipId, mem2);

        // Search with non-matching query returns empty
        final searchNoMatch = await store.listAssignableMembershipsForRole(
          companyId: companyA,
          roleId: role,
          page: NexaBizAuthorizationAdministrationPageRequest(limit: 50),
          search: 'nonexistent',
        );
        expect(searchNoMatch.items, isEmpty);
      },
    );
  });
}
