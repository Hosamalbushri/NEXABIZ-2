import 'package:drift/drift.dart';

import '../../core/authorization/administration/nexabiz_authorization_administration_errors.dart';
import '../../core/authorization/administration/nexabiz_authorization_administration_models.dart';
import '../../core/authorization/administration/nexabiz_authorization_administration_policy.dart';
import '../../core/authorization/administration/nexabiz_authorization_administration_store.dart';
import '../../core/authorization/nexabiz_membership_id.dart';
import '../../core/authorization/nexabiz_permission_catalog.dart';
import '../../core/company/nexabiz_company_scope.dart';
import '../../core/identity/core_uuid.dart';
import '../../core/permissions/nexabiz_permission_intent.dart';
import '../../core/roles/nexabiz_role_id.dart';
import '../../core/session/nexabiz_session.dart';
import 'drift_core_database.dart';

/// Drift-backed, company-scoped implementation of the authorization
/// administration contracts.
///
/// It owns persistence mapping and relational invariants only. Actor
/// authorization and post-commit invalidation belong to the application layer.
final class DriftAuthorizationAdministrationStore
    implements NexaBizAuthorizationAdministrationStore {
  DriftAuthorizationAdministrationStore(
    this._database, {
    required NexaBizPermissionCatalog permissionCatalog,
  }) : _permissionPolicy = NexaBizAuthorizationAdministrationPermissionPolicy(
         permissionCatalog,
       );

  final DriftCoreDatabase _database;
  final NexaBizAuthorizationAdministrationPermissionPolicy _permissionPolicy;
  static const _rolePolicy = NexaBizCompanyRoleAdministrationPolicy();

  @override
  Future<NexaBizCompanyRoleDetails> readCompanyRole({
    required NexaBizCompanyId companyId,
    required NexaBizRoleId roleId,
  }) async => _toRoleDetails(await _requireRole(companyId, roleId));

  @override
  Future<NexaBizAuthorizationAdministrationPage<NexaBizCompanyRoleSummary>>
  listCompanyRoles({
    required NexaBizCompanyId companyId,
    required NexaBizAuthorizationAdministrationPageRequest page,
    NexaBizCompanyRoleFilter? filter,
  }) async {
    final where = <String>['r.company_id = ?', "r.scope = 'company'"];
    final variables = <Variable<Object>>[Variable.withString(companyId.value)];
    if (page.cursor != null) {
      where.add('r.role_key > ?');
      variables.add(Variable.withString(page.cursor!));
    }
    if (filter?.search != null) {
      where.add(
        '(instr(r.normalized_name, ?) > 0 OR instr(r.role_key, ?) > 0)',
      );
      final searchKey = filter!.search!.toLowerCase();
      variables
        ..add(Variable.withString(searchKey))
        ..add(Variable.withString(searchKey));
    }
    if (filter?.kind != null) {
      where.add('r.is_builtin = ?');
      variables.add(
        Variable.withInt(
          filter!.kind == NexaBizCompanyRoleKind.builtIn ? 1 : 0,
        ),
      );
    }
    variables.add(Variable.withInt(page.limit + 1));

    final rows = await _database
        .customSelect(
          '''
      SELECT r.id, r.company_id, r.role_key, r.name, r.description,
             r.is_builtin, r.created_at, r.updated_at,
             COUNT(mr.membership_id) AS membership_count,
             (SELECT COUNT(*) FROM core_role_permissions rp
              WHERE rp.role_id = r.id) AS permission_count
      FROM core_roles r
      LEFT JOIN core_membership_roles mr ON mr.role_id = r.id
      WHERE ${where.join(' AND ')}
      GROUP BY r.id
      ORDER BY r.role_key
      LIMIT ?
      ''',
          variables: variables,
          readsFrom: {
            _database.coreRoles,
            _database.coreMembershipRoles,
            _database.coreRolePermissions,
          },
        )
        .get();

    final records = rows.map(_roleRecordFromRow).toList();
    final hasMore = records.length > page.limit;
    if (hasMore) records.removeLast();
    final items = records.map(_toRoleSummary).toList();
    return NexaBizAuthorizationAdministrationPage(
      items: items,
      nextCursor: hasMore ? records.last.roleId.value : null,
    );
  }

  @override
  Future<
    NexaBizAuthorizationAdministrationPage<NexaBizRolePermissionAssignment>
  >
  listRolePermissions({
    required NexaBizCompanyId companyId,
    required NexaBizRoleId roleId,
    required NexaBizAuthorizationAdministrationPageRequest page,
  }) async {
    final role = await _requireRole(companyId, roleId);
    final rows = await _database
        .customSelect(
          '''
      SELECT permission_id, created_at
      FROM core_role_permissions
      WHERE role_id = ? ${page.cursor == null ? '' : 'AND permission_id > ?'}
      ORDER BY permission_id
      LIMIT ?
      ''',
          variables: [
            Variable.withString(role.internalId),
            if (page.cursor != null) Variable.withString(page.cursor!),
            Variable.withInt(page.limit + 1),
          ],
          readsFrom: {_database.coreRolePermissions},
        )
        .get();
    final hasMore = rows.length > page.limit;
    if (hasMore) rows.removeLast();
    final items = [
      for (final row in rows)
        NexaBizRolePermissionAssignment(
          companyId: companyId,
          roleId: roleId,
          permissionId: NexaBizPermissionId(row.read<String>('permission_id')),
          assignedAt: _readDateTime(row, 'created_at'),
        ),
    ];
    return NexaBizAuthorizationAdministrationPage(
      items: items,
      nextCursor: hasMore ? items.last.permissionId.value : null,
    );
  }

  @override
  Future<
    NexaBizAuthorizationAdministrationPage<NexaBizMembershipRoleAssignment>
  >
  listMembershipRoles({
    required NexaBizCompanyId companyId,
    required NexaBizMembershipId membershipId,
    required NexaBizAuthorizationAdministrationPageRequest page,
  }) async {
    final membership = await _requireMembership(companyId, membershipId);
    final rows = await _database
        .customSelect(
          '''
      SELECT r.role_key, mr.created_at
      FROM core_membership_roles mr
      JOIN core_roles r ON r.id = mr.role_id
      WHERE mr.membership_id = ?
        ${page.cursor == null ? '' : 'AND r.role_key > ?'}
      ORDER BY r.role_key
      LIMIT ?
      ''',
          variables: [
            Variable.withString(membership.internalId),
            if (page.cursor != null) Variable.withString(page.cursor!),
            Variable.withInt(page.limit + 1),
          ],
          readsFrom: {_database.coreMembershipRoles, _database.coreRoles},
        )
        .get();
    final hasMore = rows.length > page.limit;
    if (hasMore) rows.removeLast();
    final items = [
      for (final row in rows)
        _toMembershipRoleAssignment(
          membership,
          NexaBizRoleId(row.read<String>('role_key')),
          _readDateTime(row, 'created_at'),
        ),
    ];
    return NexaBizAuthorizationAdministrationPage(
      items: items,
      nextCursor: hasMore ? items.last.roleId.value : null,
    );
  }

  @override
  Future<
    NexaBizAuthorizationAdministrationPage<NexaBizMembershipRoleAssignment>
  >
  listRoleMemberships({
    required NexaBizCompanyId companyId,
    required NexaBizRoleId roleId,
    required NexaBizAuthorizationAdministrationPageRequest page,
  }) async {
    final role = await _requireRole(companyId, roleId);
    final rows = await _database
        .customSelect(
          '''
      SELECT m.id AS membership_id, m.user_id, m.status AS membership_status,
             u.status AS user_status, u.name AS user_name, u.email AS user_email,
             mr.created_at
      FROM core_membership_roles mr
      JOIN core_company_memberships m ON m.id = mr.membership_id
      JOIN core_users u ON u.id = m.user_id
      WHERE mr.role_id = ? AND m.company_id = ?
        ${page.cursor == null ? '' : 'AND m.id > ?'}
      ORDER BY m.id
      LIMIT ?
      ''',
          variables: [
            Variable.withString(role.internalId),
            Variable.withString(companyId.value),
            if (page.cursor != null) Variable.withString(page.cursor!),
            Variable.withInt(page.limit + 1),
          ],
          readsFrom: {
            _database.coreMembershipRoles,
            _database.coreCompanyMemberships,
            _database.coreUsers,
          },
        )
        .get();
    final hasMore = rows.length > page.limit;
    if (hasMore) rows.removeLast();
    final items = [
      for (final row in rows)
        NexaBizMembershipRoleAssignment(
          companyId: companyId,
          membershipId: NexaBizMembershipId(row.read<String>('membership_id')),
          userId: NexaBizUserId(row.read<String>('user_id')),
          roleId: roleId,
          membershipIsActive: row.read<String>('membership_status') == 'active',
          userIsActive: row.read<String?>('user_status') == 'active',
          assignedAt: _readDateTime(row, 'created_at'),
          userName: row.read<String?>('user_name'),
          userEmail: row.read<String?>('user_email'),
        ),
    ];
    return NexaBizAuthorizationAdministrationPage(
      items: items,
      nextCursor: hasMore ? items.last.membershipId.value : null,
    );
  }

  @override
  Future<NexaBizAuthorizationAdministrationPage<NexaBizAssignableMembership>>
  listAssignableMembershipsForRole({
    required NexaBizCompanyId companyId,
    required NexaBizRoleId roleId,
    required NexaBizAuthorizationAdministrationPageRequest page,
    String? search,
  }) async {
    final role = await _requireRole(companyId, roleId);
    final where = <String>[
      'm.company_id = ?',
      'c.status = ?',
      'm.status = ?',
      'u.status = ?',
      'm.id NOT IN (SELECT mr.membership_id FROM core_membership_roles mr WHERE mr.role_id = ?)',
    ];
    final variables = <Variable>[
      Variable.withString(companyId.value),
      Variable.withString('active'),
      Variable.withString('active'),
      Variable.withString('active'),
      Variable.withString(role.internalId),
    ];
    if (page.cursor != null) {
      where.add('m.id > ?');
      variables.add(Variable.withString(page.cursor!));
    }
    if (search != null && search.trim().isNotEmpty) {
      where.add(
        '(instr(lower(coalesce(u.name, \'\')), ?) > 0 OR instr(lower(coalesce(u.email, \'\')), ?) > 0)',
      );
      final searchKey = search.trim().toLowerCase();
      variables
        ..add(Variable.withString(searchKey))
        ..add(Variable.withString(searchKey));
    }
    variables.add(Variable.withInt(page.limit + 1));

    final rows = await _database
        .customSelect(
          '''
      SELECT m.id AS membership_id, m.user_id, u.name AS user_name,
             u.email AS user_email, m.created_at
      FROM core_company_memberships m
      JOIN core_companies c ON c.id = m.company_id
      JOIN core_users u ON u.id = m.user_id
      WHERE ${where.join(' AND ')}
      ORDER BY m.id
      LIMIT ?
      ''',
          variables: variables,
          readsFrom: {
            _database.coreCompanyMemberships,
            _database.coreCompanies,
            _database.coreUsers,
            _database.coreMembershipRoles,
          },
        )
        .get();

    final hasMore = rows.length > page.limit;
    if (hasMore) rows.removeLast();
    final items = [
      for (final row in rows)
        NexaBizAssignableMembership(
          companyId: companyId,
          membershipId: NexaBizMembershipId(row.read<String>('membership_id')),
          userId: NexaBizUserId(row.read<String>('user_id')),
          userName: row.read<String?>('user_name'),
          userEmail: row.read<String?>('user_email'),
          membershipIsActive: true,
          userIsActive: true,
          joinedAt: row.data['created_at'] != null
              ? _readDateTime(row, 'created_at')
              : null,
        ),
    ];
    return NexaBizAuthorizationAdministrationPage(
      items: items,
      nextCursor: hasMore ? items.last.membershipId.value : null,
    );
  }

  @override
  Future<NexaBizMembershipEffectivePermissionInfo>
  inspectMembershipEffectivePermissions({
    required NexaBizCompanyId companyId,
    required NexaBizMembershipId membershipId,
  }) async {
    final membership = await _requireMembership(companyId, membershipId);
    final rows = await _database
        .customSelect(
          '''
      SELECT r.role_key, rp.permission_id
      FROM core_membership_roles mr
      JOIN core_roles r ON r.id = mr.role_id
      LEFT JOIN core_role_permissions rp ON rp.role_id = r.id
      WHERE mr.membership_id = ? AND r.company_id = ?
      ORDER BY r.role_key, rp.permission_id
      ''',
          variables: [
            Variable.withString(membership.internalId),
            Variable.withString(companyId.value),
          ],
          readsFrom: {
            _database.coreMembershipRoles,
            _database.coreRoles,
            _database.coreRolePermissions,
          },
        )
        .get();
    final roleIds = <NexaBizRoleId>{};
    final permissionIds = <NexaBizPermissionId>{};
    for (final row in rows) {
      roleIds.add(NexaBizRoleId(row.read<String>('role_key')));
      final permissionId = row.read<String?>('permission_id');
      if (membership.isEligible && permissionId != null) {
        permissionIds.add(NexaBizPermissionId(permissionId));
      }
    }
    return NexaBizMembershipEffectivePermissionInfo(
      companyId: companyId,
      membershipId: membershipId,
      userId: membership.userId,
      roleIds: roleIds,
      permissionIds: permissionIds,
      isEligible: membership.isEligible,
    );
  }

  @override
  Future<
    NexaBizAuthorizationAdministrationMutationResult<NexaBizCompanyRoleDetails>
  >
  createCompanyRole({
    required NexaBizCompanyId companyId,
    required NexaBizRoleId roleId,
    required NexaBizRoleMetadata metadata,
  }) => _database.transaction(() async {
    _rolePolicy.ensureCreatableCustomRole(roleId);
    await _ensureCompanyActive(companyId);
    if (await _roleKeyExists(companyId, roleId)) {
      throw NexaBizAuthorizationAdministrationConflictException(
        type: NexaBizAuthorizationAdministrationConflictType.duplicateRoleKey,
        roleId: roleId,
      );
    }
    if (await _roleNameExists(companyId, metadata.displayName.comparisonKey)) {
      throw NexaBizAuthorizationAdministrationConflictException(
        type: NexaBizAuthorizationAdministrationConflictType
            .duplicateRoleDisplayName,
        roleId: roleId,
      );
    }

    final now = DateTime.now().toUtc();
    await _database
        .into(_database.coreRoles)
        .insert(
          CoreRolesCompanion.insert(
            id: generateCoreUuidV7(),
            scope: 'company',
            companyId: Value(companyId.value),
            roleKey: roleId.value,
            name: Value(metadata.displayName.value),
            normalizedName: Value(metadata.displayName.comparisonKey),
            description: Value(metadata.description),
            isBuiltin: const Value(false),
            createdAt: now,
            updatedAt: now,
          ),
        );
    final after = _toRoleDetails(await _requireRole(companyId, roleId));
    return NexaBizAuthorizationAdministrationMutationResult(
      outcome: NexaBizAuthorizationAdministrationMutationOutcome.changed,
      before: null,
      after: after,
    );
  });

  @override
  Future<
    NexaBizAuthorizationAdministrationMutationResult<NexaBizCompanyRoleDetails>
  >
  updateCompanyRoleMetadata({
    required NexaBizCompanyId companyId,
    required NexaBizRoleId roleId,
    required NexaBizRoleMetadata metadata,
  }) => _database.transaction(() async {
    final role = await _requireRole(companyId, roleId);
    _rolePolicy.ensureMetadataMutable(
      roleId: role.roleId,
      persistedIsBuiltIn: role.isBuiltIn,
    );
    final before = _toRoleDetails(role);
    if (role.displayName.value == metadata.displayName.value &&
        role.description == metadata.description) {
      return NexaBizAuthorizationAdministrationMutationResult(
        outcome: NexaBizAuthorizationAdministrationMutationOutcome.unchanged,
        before: before,
        after: before,
      );
    }
    if (await _roleNameExists(
      companyId,
      metadata.displayName.comparisonKey,
      excludingInternalRoleId: role.internalId,
    )) {
      throw NexaBizAuthorizationAdministrationConflictException(
        type: NexaBizAuthorizationAdministrationConflictType
            .duplicateRoleDisplayName,
        roleId: roleId,
      );
    }
    await (_database.update(
      _database.coreRoles,
    )..where((table) => table.id.equals(role.internalId))).write(
      CoreRolesCompanion(
        name: Value(metadata.displayName.value),
        normalizedName: Value(metadata.displayName.comparisonKey),
        description: Value(metadata.description),
        updatedAt: Value(DateTime.now().toUtc()),
      ),
    );
    final after = _toRoleDetails(await _requireRole(companyId, roleId));
    return NexaBizAuthorizationAdministrationMutationResult(
      outcome: NexaBizAuthorizationAdministrationMutationOutcome.changed,
      before: before,
      after: after,
    );
  });

  @override
  Future<
    NexaBizAuthorizationAdministrationMutationResult<NexaBizCompanyRoleDetails>
  >
  deleteCompanyRole({
    required NexaBizCompanyId companyId,
    required NexaBizRoleId roleId,
  }) => _database.transaction(() async {
    final role = await _requireRole(companyId, roleId);
    _rolePolicy.ensureDeletable(
      roleId: role.roleId,
      persistedIsBuiltIn: role.isBuiltIn,
      membershipAssignmentCount: role.membershipAssignmentCount,
    );
    final before = _toRoleDetails(role);
    await (_database.delete(
      _database.coreRolePermissions,
    )..where((table) => table.roleId.equals(role.internalId))).go();
    await (_database.delete(
      _database.coreRoles,
    )..where((table) => table.id.equals(role.internalId))).go();
    return NexaBizAuthorizationAdministrationMutationResult(
      outcome: NexaBizAuthorizationAdministrationMutationOutcome.changed,
      before: before,
      after: null,
    );
  });

  @override
  Future<
    NexaBizAuthorizationAdministrationMutationResult<
      NexaBizRolePermissionAssignment
    >
  >
  grantPermissionToRole({
    required NexaBizCompanyId companyId,
    required NexaBizRoleId roleId,
    required NexaBizPermissionId permissionId,
  }) => _database.transaction(() async {
    _permissionPolicy.ensureDeclared(permissionId);
    final role = await _requireRole(companyId, roleId);
    _rolePolicy.ensurePermissionGrantable(
      roleId: role.roleId,
      persistedIsBuiltIn: role.isBuiltIn,
    );
    final existing = await _readPermissionAssignment(role, permissionId);
    if (existing != null) {
      return NexaBizAuthorizationAdministrationMutationResult(
        outcome: NexaBizAuthorizationAdministrationMutationOutcome.unchanged,
        before: existing,
        after: existing,
      );
    }
    final assignedAt = DateTime.now().toUtc();
    await _database
        .into(_database.coreRolePermissions)
        .insert(
          CoreRolePermissionsCompanion.insert(
            roleId: role.internalId,
            permissionId: permissionId.value,
            createdAt: assignedAt,
          ),
        );
    final after = NexaBizRolePermissionAssignment(
      companyId: companyId,
      roleId: roleId,
      permissionId: permissionId,
      assignedAt: assignedAt,
    );
    return NexaBizAuthorizationAdministrationMutationResult(
      outcome: NexaBizAuthorizationAdministrationMutationOutcome.changed,
      before: null,
      after: after,
    );
  });

  @override
  Future<
    NexaBizAuthorizationAdministrationMutationResult<
      NexaBizRolePermissionAssignment
    >
  >
  revokePermissionFromRole({
    required NexaBizCompanyId companyId,
    required NexaBizRoleId roleId,
    required NexaBizPermissionId permissionId,
  }) => _database.transaction(() async {
    _permissionPolicy.ensureDeclared(permissionId);
    final role = await _requireRole(companyId, roleId);
    _rolePolicy.ensurePermissionRevocable(
      roleId: role.roleId,
      persistedIsBuiltIn: role.isBuiltIn,
    );
    final before = await _readPermissionAssignment(role, permissionId);
    if (before == null) {
      return const NexaBizAuthorizationAdministrationMutationResult(
        outcome: NexaBizAuthorizationAdministrationMutationOutcome.unchanged,
        before: null,
        after: null,
      );
    }
    await (_database.delete(_database.coreRolePermissions)..where(
          (table) =>
              table.roleId.equals(role.internalId) &
              table.permissionId.equals(permissionId.value),
        ))
        .go();
    return NexaBizAuthorizationAdministrationMutationResult(
      outcome: NexaBizAuthorizationAdministrationMutationOutcome.changed,
      before: before,
      after: null,
    );
  });

  @override
  Future<
    NexaBizAuthorizationAdministrationMutationResult<
      NexaBizMembershipRoleAssignment
    >
  >
  assignRoleToMembership({
    required NexaBizCompanyId companyId,
    required NexaBizMembershipId membershipId,
    required NexaBizRoleId roleId,
  }) => _database.transaction(() async {
    final membership = await _requireMembership(companyId, membershipId);
    final role = await _requireRole(companyId, roleId);
    _rolePolicy.ensureAssignmentEligibility(
      companyId: companyId,
      membershipId: membershipId,
      companyIsActive: membership.companyIsActive,
      membershipIsActive: membership.membershipIsActive,
      userIsActive: membership.userIsActive,
    );
    final existing = await _readMembershipRoleAssignment(membership, role);
    if (existing != null) {
      return NexaBizAuthorizationAdministrationMutationResult(
        outcome: NexaBizAuthorizationAdministrationMutationOutcome.unchanged,
        before: existing,
        after: existing,
      );
    }
    final assignedAt = DateTime.now().toUtc();
    await _database
        .into(_database.coreMembershipRoles)
        .insert(
          CoreMembershipRolesCompanion.insert(
            membershipId: membership.internalId,
            roleId: role.internalId,
            createdAt: assignedAt,
          ),
        );
    final after = _toMembershipRoleAssignment(membership, roleId, assignedAt);
    return NexaBizAuthorizationAdministrationMutationResult(
      outcome: NexaBizAuthorizationAdministrationMutationOutcome.changed,
      before: null,
      after: after,
    );
  });

  @override
  Future<
    NexaBizAuthorizationAdministrationMutationResult<
      NexaBizMembershipRoleAssignment
    >
  >
  unassignRoleFromMembership({
    required NexaBizCompanyId companyId,
    required NexaBizMembershipId membershipId,
    required NexaBizRoleId roleId,
  }) => _database.transaction(() async {
    final membership = await _requireMembership(companyId, membershipId);
    final role = await _requireRole(companyId, roleId);
    final before = await _readMembershipRoleAssignment(membership, role);
    if (before == null) {
      return const NexaBizAuthorizationAdministrationMutationResult(
        outcome: NexaBizAuthorizationAdministrationMutationOutcome.unchanged,
        before: null,
        after: null,
      );
    }
    if (roleId == NexaBizBuiltInCompanyRoles.companyOwner &&
        membership.isEligible) {
      final ownerCount = await _activeOwnerCount(companyId);
      _rolePolicy.ensureOwnerUnassignmentLeavesActiveOwner(
        companyId: companyId,
        roleId: roleId,
        activeOwnerCountAfter: ownerCount - 1,
      );
    }
    await (_database.delete(_database.coreMembershipRoles)..where(
          (table) =>
              table.membershipId.equals(membership.internalId) &
              table.roleId.equals(role.internalId),
        ))
        .go();
    return NexaBizAuthorizationAdministrationMutationResult(
      outcome: NexaBizAuthorizationAdministrationMutationOutcome.changed,
      before: before,
      after: null,
    );
  });

  Future<_RoleRecord> _requireRole(
    NexaBizCompanyId companyId,
    NexaBizRoleId roleId,
  ) async {
    _rolePolicy.ensureCompanyRoleId(roleId);
    final rows = await _database
        .customSelect(
          '''
      SELECT r.id, r.company_id, r.role_key, r.name, r.description,
             r.is_builtin, r.created_at, r.updated_at,
             (SELECT COUNT(*) FROM core_membership_roles mr
              WHERE mr.role_id = r.id) AS membership_count,
             (SELECT COUNT(*) FROM core_role_permissions rp
              WHERE rp.role_id = r.id) AS permission_count
      FROM core_roles r
      WHERE r.company_id = ? AND r.scope = 'company' AND r.role_key = ?
      LIMIT 1
      ''',
          variables: [
            Variable.withString(companyId.value),
            Variable.withString(roleId.value),
          ],
          readsFrom: {
            _database.coreRoles,
            _database.coreMembershipRoles,
            _database.coreRolePermissions,
          },
        )
        .get();
    if (rows.isNotEmpty) return _roleRecordFromRow(rows.single);

    final other = await _database
        .customSelect(
          '''
      SELECT company_id FROM core_roles
      WHERE scope = 'company' AND role_key = ? AND company_id IS NOT NULL
      ORDER BY company_id LIMIT 1
      ''',
          variables: [Variable.withString(roleId.value)],
          readsFrom: {_database.coreRoles},
        )
        .getSingleOrNull();
    if (other != null) {
      throw NexaBizAuthorizationCrossCompanyException(
        expectedCompanyId: companyId,
        actualCompanyId: NexaBizCompanyId(other.read<String>('company_id')),
      );
    }
    throw NexaBizRoleNotFoundException(companyId: companyId, roleId: roleId);
  }

  Future<_MembershipRecord> _requireMembership(
    NexaBizCompanyId companyId,
    NexaBizMembershipId membershipId,
  ) async {
    final rows = await _database
        .customSelect(
          '''
      SELECT m.id, m.company_id, m.user_id, m.status AS membership_status,
             c.status AS company_status, u.status AS user_status,
             u.name AS user_name, u.email AS user_email
      FROM core_company_memberships m
      JOIN core_companies c ON c.id = m.company_id
      JOIN core_users u ON u.id = m.user_id
      WHERE m.id = ?
      LIMIT 1
      ''',
          variables: [Variable.withString(membershipId.value)],
          readsFrom: {
            _database.coreCompanyMemberships,
            _database.coreCompanies,
            _database.coreUsers,
          },
        )
        .get();
    if (rows.isEmpty) {
      throw NexaBizMembershipNotFoundException(
        companyId: companyId,
        membershipId: membershipId,
      );
    }
    final row = rows.single;
    final actualCompanyId = NexaBizCompanyId(row.read<String>('company_id'));
    _rolePolicy.ensureSameCompany(
      expectedCompanyId: companyId,
      actualCompanyId: actualCompanyId,
    );
    return _MembershipRecord(
      internalId: row.read<String>('id'),
      companyId: actualCompanyId,
      membershipId: membershipId,
      userId: NexaBizUserId(row.read<String>('user_id')),
      userName: row.read<String?>('user_name'),
      userEmail: row.read<String?>('user_email'),
      companyIsActive: row.read<String?>('company_status') == 'active',
      membershipIsActive: row.read<String>('membership_status') == 'active',
      userIsActive: row.read<String?>('user_status') == 'active',
    );
  }

  Future<void> _ensureCompanyActive(NexaBizCompanyId companyId) async {
    final row = await (_database.select(
      _database.coreCompanies,
    )..where((table) => table.id.equals(companyId.value))).getSingleOrNull();
    if (row?.status != 'active') {
      throw NexaBizCompanyIneligibleException(companyId);
    }
  }

  Future<bool> _roleKeyExists(
    NexaBizCompanyId companyId,
    NexaBizRoleId roleId,
  ) async =>
      await (_database.select(_database.coreRoles)..where(
            (table) =>
                table.companyId.equals(companyId.value) &
                table.roleKey.equals(roleId.value),
          ))
          .getSingleOrNull() !=
      null;

  Future<bool> _roleNameExists(
    NexaBizCompanyId companyId,
    String normalizedName, {
    String? excludingInternalRoleId,
  }) async {
    final query = _database.select(_database.coreRoles)
      ..where(
        (table) =>
            table.companyId.equals(companyId.value) &
            table.normalizedName.equals(normalizedName),
      );
    if (excludingInternalRoleId != null) {
      query.where((table) => table.id.isNotValue(excludingInternalRoleId));
    }
    return await query.getSingleOrNull() != null;
  }

  Future<NexaBizRolePermissionAssignment?> _readPermissionAssignment(
    _RoleRecord role,
    NexaBizPermissionId permissionId,
  ) async {
    final row =
        await (_database.select(_database.coreRolePermissions)..where(
              (table) =>
                  table.roleId.equals(role.internalId) &
                  table.permissionId.equals(permissionId.value),
            ))
            .getSingleOrNull();
    if (row == null) return null;
    return NexaBizRolePermissionAssignment(
      companyId: role.companyId,
      roleId: role.roleId,
      permissionId: permissionId,
      assignedAt: row.createdAt,
    );
  }

  Future<NexaBizMembershipRoleAssignment?> _readMembershipRoleAssignment(
    _MembershipRecord membership,
    _RoleRecord role,
  ) async {
    final row =
        await (_database.select(_database.coreMembershipRoles)..where(
              (table) =>
                  table.membershipId.equals(membership.internalId) &
                  table.roleId.equals(role.internalId),
            ))
            .getSingleOrNull();
    if (row == null) return null;
    return _toMembershipRoleAssignment(membership, role.roleId, row.createdAt);
  }

  Future<int> _activeOwnerCount(NexaBizCompanyId companyId) async {
    final row = await _database
        .customSelect(
          '''
      SELECT COUNT(*) AS owner_count
      FROM core_membership_roles mr
      JOIN core_roles r ON r.id = mr.role_id
      JOIN core_company_memberships m ON m.id = mr.membership_id
      JOIN core_users u ON u.id = m.user_id
      JOIN core_companies c ON c.id = m.company_id
      WHERE r.company_id = ? AND r.scope = 'company' AND r.role_key = ?
        AND c.status = 'active' AND m.status = 'active' AND u.status = 'active'
      ''',
          variables: [
            Variable.withString(companyId.value),
            Variable.withString(NexaBizBuiltInCompanyRoles.companyOwner.value),
          ],
          readsFrom: {
            _database.coreMembershipRoles,
            _database.coreRoles,
            _database.coreCompanyMemberships,
            _database.coreUsers,
            _database.coreCompanies,
          },
        )
        .getSingle();
    return row.read<int>('owner_count');
  }

  _RoleRecord _roleRecordFromRow(QueryRow row) {
    final roleId = NexaBizRoleId(row.read<String>('role_key'));
    final displayName = NexaBizRoleDisplayName(row.read<String>('name'));
    final isBuiltIn = row.read<int>('is_builtin') == 1;
    final kind = _rolePolicy.classifyRole(
      roleId: roleId,
      persistedIsBuiltIn: isBuiltIn,
    );
    return _RoleRecord(
      internalId: row.read<String>('id'),
      companyId: NexaBizCompanyId(row.read<String>('company_id')),
      roleId: roleId,
      displayName: displayName,
      description: row.read<String?>('description'),
      kind: kind,
      membershipAssignmentCount: row.read<int>('membership_count'),
      permissionAssignmentCount: row.read<int>('permission_count'),
      createdAt: _readDateTime(row, 'created_at'),
      updatedAt: _readDateTime(row, 'updated_at'),
    );
  }

  static NexaBizCompanyRoleSummary _toRoleSummary(_RoleRecord role) =>
      NexaBizCompanyRoleSummary(
        companyId: role.companyId,
        roleId: role.roleId,
        metadata: role.metadata,
        kind: role.kind,
        membershipAssignmentCount: role.membershipAssignmentCount,
      );

  static NexaBizCompanyRoleDetails _toRoleDetails(_RoleRecord role) =>
      NexaBizCompanyRoleDetails(
        companyId: role.companyId,
        roleId: role.roleId,
        metadata: role.metadata,
        kind: role.kind,
        membershipAssignmentCount: role.membershipAssignmentCount,
        permissionAssignmentCount: role.permissionAssignmentCount,
        createdAt: role.createdAt,
        updatedAt: role.updatedAt,
      );

  static NexaBizMembershipRoleAssignment _toMembershipRoleAssignment(
    _MembershipRecord membership,
    NexaBizRoleId roleId,
    DateTime assignedAt,
  ) => NexaBizMembershipRoleAssignment(
    companyId: membership.companyId,
    membershipId: membership.membershipId,
    userId: membership.userId,
    roleId: roleId,
    userName: membership.userName,
    userEmail: membership.userEmail,
    membershipIsActive: membership.membershipIsActive,
    userIsActive: membership.userIsActive,
    assignedAt: assignedAt,
  );

  static DateTime _readDateTime(QueryRow row, String column) {
    final value = row.data[column];
    return switch (value) {
      final DateTime dateTime => dateTime.toUtc(),
      final int milliseconds => DateTime.fromMillisecondsSinceEpoch(
        milliseconds,
        isUtc: true,
      ),
      final String text => DateTime.parse(text).toUtc(),
      _ => throw StateError('Invalid persisted timestamp in $column.'),
    };
  }
}

final class _RoleRecord {
  const _RoleRecord({
    required this.internalId,
    required this.companyId,
    required this.roleId,
    required this.displayName,
    required this.description,
    required this.kind,
    required this.membershipAssignmentCount,
    required this.permissionAssignmentCount,
    required this.createdAt,
    required this.updatedAt,
  });

  final String internalId;
  final NexaBizCompanyId companyId;
  final NexaBizRoleId roleId;
  final NexaBizRoleDisplayName displayName;
  final String? description;
  final NexaBizCompanyRoleKind kind;
  final int membershipAssignmentCount;
  final int permissionAssignmentCount;
  final DateTime createdAt;
  final DateTime updatedAt;

  bool get isBuiltIn => kind == NexaBizCompanyRoleKind.builtIn;
  NexaBizRoleMetadata get metadata =>
      NexaBizRoleMetadata(displayName: displayName, description: description);
}

final class _MembershipRecord {
  const _MembershipRecord({
    required this.internalId,
    required this.companyId,
    required this.membershipId,
    required this.userId,
    this.userName,
    this.userEmail,
    required this.companyIsActive,
    required this.membershipIsActive,
    required this.userIsActive,
  });

  final String internalId;
  final NexaBizCompanyId companyId;
  final NexaBizMembershipId membershipId;
  final NexaBizUserId userId;
  final String? userName;
  final String? userEmail;
  final bool companyIsActive;
  final bool membershipIsActive;
  final bool userIsActive;

  bool get isEligible => companyIsActive && membershipIsActive && userIsActive;
}
