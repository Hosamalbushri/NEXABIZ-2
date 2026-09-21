import 'dart:convert';

import 'package:cryptography/cryptography.dart';
import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';

import '../../core/authorization/core_authorization_query_store.dart';
import '../../core/authorization/nexabiz_membership_authorization_snapshot.dart';
import '../../core/authorization/nexabiz_membership_id.dart';
import '../../core/company/nexabiz_company_scope.dart';
import '../../core/identity/authenticate_local_user.dart';
import '../../core/identity/core_uuid.dart';
import '../../core/permissions/nexabiz_permission_intent.dart';
import '../../core/roles/nexabiz_role_id.dart';
import '../../core/session/nexabiz_session.dart';
import '../../core/setup/initialize_nexabiz_core.dart';
import '../../core/setup/nexabiz_core_installation_store.dart';
import '../../core/setup/nexabiz_setup_readiness.dart';
import 'drift_core_database.dart';

/// Readiness projection and identity authority from the Drift Core database.
final class DriftCoreInstallationStore
    implements
        NexaBizCoreInstallationStore,
        CoreIdentityQueryStore,
        CoreAuthorizationQueryStore {
  /// Window of genuine inactivity required after either the last failed attempt
  /// (if no lockout was active) or after the lockout expiration time before
  /// the accumulated failure counter is reset.
  /// Merely waiting out a lockout duration does NOT reset the counter.
  static const Duration defaultInactivityResetWindow = Duration(hours: 1);

  DriftCoreInstallationStore._(
    this.database, {
    this.inactivityResetWindow = defaultInactivityResetWindow,
  });

  final DriftCoreDatabase database;
  final Duration inactivityResetWindow;
  late final ValueNotifier<NexaBizSetupReadiness> _readiness;

  /// Last committed setup readiness. The database remains authoritative.
  ValueListenable<NexaBizSetupReadiness> get readiness => _readiness;

  static Future<DriftCoreInstallationStore> open(
    String databasePath, {
    Duration inactivityResetWindow = defaultInactivityResetWindow,
  }) async {
    final database = DriftCoreDatabase.open(databasePath);
    try {
      await database.customSelect('SELECT 1').get();
      final store = DriftCoreInstallationStore._(
        database,
        inactivityResetWindow: inactivityResetWindow,
      );
      store._readiness = ValueNotifier(await store.readReadiness());
      return store;
    } catch (_) {
      await database.close();
      rethrow;
    }
  }

  static Future<DriftCoreInstallationStore> openDatabaseForTest(
    DriftCoreDatabase database, {
    Duration inactivityResetWindow = defaultInactivityResetWindow,
  }) async {
    final store = DriftCoreInstallationStore._(
      database,
      inactivityResetWindow: inactivityResetWindow,
    );
    store._readiness = ValueNotifier(await store.readReadiness());
    return store;
  }

  @override
  Future<NexaBizSetupReadiness> readReadiness() async {
    final rows = await database.customSelect('''
      SELECT
        EXISTS(SELECT 1 FROM core_companies) AS has_company,
        EXISTS(SELECT 1 FROM core_users) AS has_user,
        EXISTS(SELECT 1 FROM core_company_memberships) AS has_membership,
        EXISTS(SELECT 1 FROM core_credentials) AS has_credential,
        EXISTS(
          SELECT 1 FROM core_company_memberships m
          JOIN core_companies c ON c.id = m.company_id
          JOIN core_users u ON u.id = m.user_id
          JOIN core_credentials cr ON cr.user_id = u.id
          WHERE m.status = 'active' AND m.role IN ('owner', 'admin')
            AND c.name IS NOT NULL AND trim(c.name) <> ''
            AND c.code IS NOT NULL AND trim(c.code) <> ''
            AND c.status = 'active'
            AND u.email IS NOT NULL AND trim(u.email) <> ''
            AND u.name IS NOT NULL AND trim(u.name) <> ''
            AND u.status = 'active'
            AND cr.kind = 'password' AND cr.algorithm = 'argon2id'
            AND length(trim(cr.parameters)) > 0
            AND length(cr.salt) > 0 AND length(cr.verifier) > 0
        ) AS valid_relationship
    ''').get();
    final row = rows.single;
    final hasCompany = row.read<int>('has_company') == 1;
    final hasUser = row.read<int>('has_user') == 1;
    final hasMembership = row.read<int>('has_membership') == 1;
    final hasCredential = row.read<int>('has_credential') == 1;
    final valid = row.read<int>('valid_relationship') == 1;
    return NexaBizSetupReadiness(
      state: valid
          ? NexaBizSetupState.ready
          : hasCompany || hasUser || hasMembership || hasCredential
          ? NexaBizSetupState.inProgress
          : NexaBizSetupState.uninitialized,
      completed: {
        if (hasCompany) NexaBizSetupRequirement.company,
        if (valid) NexaBizSetupRequirement.adminUser,
      },
    );
  }

  @override
  Future<NexaBizSetupReadiness> initialize(
    CoreInitializationRecords records,
  ) async {
    try {
      final committedReadiness = await database.transaction(() async {
        final before = await readReadiness();
        if (before.isReady) {
          throw const CoreInitializationException(
            CoreInitializationFailure.alreadyInitialized,
          );
        }
        if (before.state != NexaBizSetupState.uninitialized) {
          throw const CoreInitializationException(
            CoreInitializationFailure.recoveryRequired,
          );
        }
        final db = database;
        final createdAt = records.createdAt;
        await db
            .into(db.coreCompanies)
            .insert(
              CoreCompaniesCompanion.insert(
                id: records.companyId,
                code: Value(records.companyCode),
                name: Value(records.companyName),
                status: const Value('active'),
                createdAt: Value(createdAt),
                updatedAt: Value(createdAt),
              ),
            );
        await db
            .into(db.coreUsers)
            .insert(
              CoreUsersCompanion.insert(
                id: records.userId,
                email: Value(records.adminEmail),
                name: Value(records.adminName),
                status: const Value('active'),
                createdAt: Value(createdAt),
                updatedAt: Value(createdAt),
              ),
            );
        await db
            .into(db.coreCredentials)
            .insert(
              CoreCredentialsCompanion.insert(
                userId: records.userId,
                kind: 'password',
                algorithm: records.credential.algorithm,
                parameters: records.credential.parameters,
                salt: records.credential.salt,
                verifier: records.credential.verifier,
                createdAt: createdAt,
                updatedAt: createdAt,
              ),
            );
        await db
            .into(db.coreCompanyMemberships)
            .insert(
              CoreCompanyMembershipsCompanion.insert(
                id: records.membershipId,
                userId: records.userId,
                companyId: records.companyId,
                role: 'owner',
                status: 'active',
                createdAt: Value(createdAt),
                updatedAt: Value(createdAt),
              ),
            );

        // Relational RBAC: Create built-in company.owner role and assign to initial membership
        final ownerRoleId = generateCoreUuidV7();
        await db
            .into(db.coreRoles)
            .insert(
              CoreRolesCompanion.insert(
                id: ownerRoleId,
                scope: 'company',
                companyId: Value(records.companyId),
                roleKey: 'company.owner',
                name: const Value('owner'),
                description: const Value('Built-in company owner role'),
                isBuiltin: const Value(true),
                createdAt: createdAt,
                updatedAt: createdAt,
              ),
            );

        for (final permId in kInitialCompanyOwnerPermissions) {
          await db
              .into(db.coreRolePermissions)
              .insert(
                CoreRolePermissionsCompanion.insert(
                  roleId: ownerRoleId,
                  permissionId: permId,
                  createdAt: createdAt,
                ),
              );
        }

        await db
            .into(db.coreMembershipRoles)
            .insert(
              CoreMembershipRolesCompanion.insert(
                membershipId: records.membershipId,
                roleId: ownerRoleId,
                createdAt: createdAt,
              ),
            );

        final after = await readReadiness();
        if (!after.isReady) {
          throw const CoreInitializationException(
            CoreInitializationFailure.storageFailure,
          );
        }
        return after;
      });
      // Never publish readiness from inside an uncommitted transaction.
      _readiness.value = committedReadiness;
      return committedReadiness;
    } on CoreInitializationException {
      rethrow;
    } catch (_) {
      throw const CoreInitializationException(
        CoreInitializationFailure.storageFailure,
      );
    }
  }

  @override
  Future<CoreAuthUserRef?> findUserByIdentifier(
    String normalizedIdentifier,
  ) async {
    final rows = await database
        .customSelect(
          '''
      SELECT id, name, email, status
      FROM core_users
      WHERE lower(trim(email)) = ? OR lower(trim(name)) = ?
      LIMIT 1
      ''',
          variables: [
            Variable.withString(normalizedIdentifier),
            Variable.withString(normalizedIdentifier),
          ],
        )
        .get();

    if (rows.isEmpty) return null;
    final row = rows.single;
    return CoreAuthUserRef(
      id: row.read<String>('id'),
      name: row.read<String?>('name') ?? '',
      email: row.read<String?>('email') ?? '',
      status: row.read<String?>('status') ?? 'active',
    );
  }

  @override
  Future<CorePreparedCredential?> readUserCredential(String userId) async {
    final rows = await database
        .customSelect(
          '''
      SELECT algorithm, parameters, salt, verifier
      FROM core_credentials
      WHERE user_id = ? AND kind = 'password'
      LIMIT 1
      ''',
          variables: [Variable.withString(userId)],
        )
        .get();

    if (rows.isEmpty) return null;
    final row = rows.single;
    return CorePreparedCredential(
      algorithm: row.read<String>('algorithm'),
      parameters: row.read<String>('parameters'),
      salt: row.read<String>('salt'),
      verifier: row.read<String>('verifier'),
    );
  }

  @override
  Future<CoreAuthIdentitySnapshot?> readAuthenticationSnapshot(
    String userId,
  ) async {
    // A single SELECT gives all identity facts the same SQLite snapshot.
    final rows = await database
        .customSelect(
          '''
      SELECT u.id AS user_id, u.name AS user_name, u.email, u.status,
             c.id AS company_id, c.name AS company_name, c.code,
             m.id AS membership_id, m.role
      FROM core_users u
      LEFT JOIN core_company_memberships m
        ON m.user_id = u.id AND m.status = 'active'
      LEFT JOIN core_companies c
        ON c.id = m.company_id AND c.status = 'active'
      WHERE u.id = ?
      ORDER BY c.name, c.id
      ''',
          variables: [Variable.withString(userId)],
        )
        .get();
    if (rows.isEmpty) return null;
    final user = rows.first;
    return CoreAuthIdentitySnapshot(
      user: CoreAuthUserRef(
        id: user.read<String>('user_id'),
        name: user.read<String?>('user_name') ?? '',
        email: user.read<String?>('email') ?? '',
        status: user.read<String?>('status') ?? '',
      ),
      companies: [
        for (final row in rows)
          if (row.read<String?>('company_id') != null)
            CoreAuthCompanyRef(
              id: row.read<String>('company_id'),
              name: row.read<String?>('company_name') ?? '',
              code: row.read<String?>('code') ?? '',
              role: row.read<String>('role'),
              membershipId: row.read<String?>('membership_id'),
            ),
      ],
    );
  }

  Selectable<QueryRow> _sessionEligibility(String userId, String? companyId) {
    return database.customSelect(
      '''
      SELECT EXISTS(
        SELECT 1 FROM core_users u
        JOIN core_company_memberships m ON m.user_id = u.id
        JOIN core_companies c ON c.id = m.company_id
        WHERE u.id = ? AND u.status = 'active'
          AND m.status = 'active' AND c.status = 'active'
          ${companyId == null ? '' : 'AND c.id = ?'}
      ) AS eligible
      ''',
      variables: [
        Variable.withString(userId),
        if (companyId != null) Variable.withString(companyId),
      ],
      readsFrom: {
        database.coreUsers,
        database.coreCompanyMemberships,
        database.coreCompanies,
      },
    );
  }

  @override
  Future<bool> isSessionEligible(String userId, String? companyId) async =>
      (await _sessionEligibility(
        userId,
        companyId,
      ).getSingle()).read<int>('eligible') ==
      1;

  @override
  Stream<bool> watchSessionEligibility(String userId, String? companyId) =>
      _sessionEligibility(
        userId,
        companyId,
      ).watchSingle().map((row) => row.read<int>('eligible') == 1).distinct();

  static final _sha256 = Sha256();

  static Future<String> _hashIdentifier(String normalizedIdentifier) async {
    final hash = await _sha256.hash(utf8.encode(normalizedIdentifier));
    return hash.bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
  }

  @override
  Future<CoreLoginLockout?> checkLockout(
    String normalizedIdentifier,
    DateTime nowUtc,
  ) async {
    final hash = await _hashIdentifier(normalizedIdentifier);
    final row = await (database.select(
      database.coreLoginAttempts,
    )..where((t) => t.identifierHash.equals(hash))).getSingleOrNull();

    if (row == null || row.lockedUntil == null) {
      return null;
    }

    final lockedUntilUtc = row.lockedUntil!.toUtc();
    if (nowUtc.toUtc().isBefore(lockedUntilUtc)) {
      return CoreLoginLockout(
        attemptCount: row.attemptCount,
        lockedUntil: lockedUntilUtc,
      );
    }

    return null;
  }

  @override
  Future<CoreLoginLockout?> recordFailedAttempt(
    String normalizedIdentifier,
    DateTime nowUtc,
  ) async {
    final hash = await _hashIdentifier(normalizedIdentifier);
    final now = nowUtc.toUtc();

    return database.transaction(() async {
      final existing = await (database.select(
        database.coreLoginAttempts,
      )..where((t) => t.identifierHash.equals(hash))).getSingleOrNull();

      int nextCount;
      DateTime? lockedUntil;

      if (existing == null) {
        nextCount = 1;
        lockedUntil = null;
      } else {
        final existingLockedUntil = existing.lockedUntil?.toUtc();
        if (existingLockedUntil != null && now.isBefore(existingLockedUntil)) {
          return CoreLoginLockout(
            attemptCount: existing.attemptCount,
            lockedUntil: existingLockedUntil,
          );
        }

        final existingLastAttemptAt = existing.lastAttemptAt.toUtc();
        // Policy: Genuine inactivity is measured from when the account was first eligible
        // to attempt logging in again.
        // If a lockout was in effect, cooloff begins only after lockedUntil has expired.
        // If no lockout was active, cooloff begins from lastAttemptAt.
        final cooloffBase =
            (existingLockedUntil != null &&
                existingLockedUntil.isAfter(existingLastAttemptAt))
            ? existingLockedUntil
            : existingLastAttemptAt;

        if (now.difference(cooloffBase) >= inactivityResetWindow) {
          nextCount = 1;
          lockedUntil = null;
        } else {
          nextCount = existing.attemptCount + 1;
          lockedUntil = _calculateLockout(nextCount, now);
        }
      }

      await database
          .into(database.coreLoginAttempts)
          .insertOnConflictUpdate(
            CoreLoginAttemptsCompanion(
              identifierHash: Value(hash),
              attemptCount: Value(nextCount),
              lockedUntil: Value(lockedUntil),
              lastAttemptAt: Value(now),
            ),
          );

      if (lockedUntil != null) {
        return CoreLoginLockout(
          attemptCount: nextCount,
          lockedUntil: lockedUntil,
        );
      }
      return null;
    });
  }

  static DateTime? _calculateLockout(int attemptCount, DateTime nowUtc) {
    if (attemptCount < 5) return null;
    if (attemptCount >= 10) {
      return nowUtc.add(const Duration(minutes: 15));
    }
    final multiplier = 1 << (attemptCount - 5);
    final seconds = 30 * multiplier;
    if (seconds >= 900) {
      return nowUtc.add(const Duration(minutes: 15));
    }
    return nowUtc.add(Duration(seconds: seconds));
  }

  @override
  Future<void> clearFailedAttempts(String normalizedIdentifier) async {
    final hash = await _hashIdentifier(normalizedIdentifier);
    await (database.delete(
      database.coreLoginAttempts,
    )..where((t) => t.identifierHash.equals(hash))).go();
  }

  @override
  Future<NexaBizMembershipAuthorizationSnapshot?>
      readMembershipAuthorizationSnapshot(String membershipId) async {
    final rows = await database.customSelect(
      '''
      SELECT
        m.id AS membership_id,
        m.company_id,
        m.user_id,
        m.status AS membership_status,
        c.status AS company_status,
        u.status AS user_status,
        r.id AS role_id,
        r.role_key,
        r.scope AS role_scope,
        rp.permission_id
      FROM core_company_memberships m
      JOIN core_companies c ON c.id = m.company_id
      JOIN core_users u ON u.id = m.user_id
      LEFT JOIN core_membership_roles mr ON mr.membership_id = m.id
      LEFT JOIN core_roles r ON r.id = mr.role_id
      LEFT JOIN core_role_permissions rp ON rp.role_id = r.id
      WHERE m.id = ?
      ''',
      variables: [Variable.withString(membershipId)],
    ).get();

    if (rows.isEmpty) return null;

    final first = rows.first;
    final roleIds = <NexaBizRoleId>{};
    final permissionIds = <NexaBizPermissionId>{};

    for (final row in rows) {
      final roleKey = row.read<String?>('role_key');
      if (roleKey != null) {
        roleIds.add(NexaBizRoleId(roleKey));
      }
      final permissionId = row.read<String?>('permission_id');
      if (permissionId != null) {
        permissionIds.add(NexaBizPermissionId(permissionId));
      }
    }

    return NexaBizMembershipAuthorizationSnapshot(
      membershipId: NexaBizMembershipId(first.read<String>('membership_id')),
      companyId: NexaBizCompanyId(first.read<String>('company_id')),
      userId: NexaBizUserId(first.read<String>('user_id')),
      membershipStatus: first.read<String>('membership_status'),
      companyStatus: first.read<String?>('company_status') ?? 'active',
      userStatus: first.read<String?>('user_status') ?? 'active',
      roleIds: Set.unmodifiable(roleIds),
      permissionIds: Set.unmodifiable(permissionIds),
    );
  }

  /// Creates a role record in `core_roles`.
  Future<String> createRole({
    required NexaBizRoleId roleId,
    String? companyId,
    String? name,
    String? description,
    bool isBuiltin = false,
  }) async {
    final scopeStr = roleId.scope.name;
    if (roleId.scope.isCompany &&
        (companyId == null || companyId.trim().isEmpty)) {
      throw ArgumentError.value(
        companyId,
        'companyId',
        'Company role requires companyId.',
      );
    }
    if (roleId.scope.isSystem && companyId != null) {
      throw ArgumentError.value(
        companyId,
        'companyId',
        'System role cannot have companyId.',
      );
    }

    final id = generateCoreUuidV7();
    final now = DateTime.now().toUtc();
    await database.into(database.coreRoles).insert(
      CoreRolesCompanion.insert(
        id: id,
        scope: scopeStr,
        companyId: Value(companyId),
        roleKey: roleId.value,
        name: Value(name),
        description: Value(description),
        isBuiltin: Value(isBuiltin),
        createdAt: now,
        updatedAt: now,
      ),
    );
    return id;
  }

  /// Assigns a role to a company membership in `core_membership_roles`.
  Future<void> assignRoleToMembership({
    required String membershipId,
    required String roleId,
  }) async {
    final now = DateTime.now().toUtc();
    await database.into(database.coreMembershipRoles).insert(
      CoreMembershipRolesCompanion.insert(
        membershipId: membershipId,
        roleId: roleId,
        createdAt: now,
      ),
    );
  }

  /// Removes a role from a membership in `core_membership_roles`.
  Future<int> removeRoleFromMembership({
    required String membershipId,
    required String roleId,
  }) async {
    return (database.delete(database.coreMembershipRoles)
          ..where((t) =>
              t.membershipId.equals(membershipId) & t.roleId.equals(roleId)))
        .go();
  }

  /// Grants a canonical permission to a role in `core_role_permissions`.
  Future<void> grantPermissionToRole({
    required String roleId,
    required NexaBizPermissionId permissionId,
  }) async {
    final now = DateTime.now().toUtc();
    await database.into(database.coreRolePermissions).insert(
      CoreRolePermissionsCompanion.insert(
        roleId: roleId,
        permissionId: permissionId.value,
        createdAt: now,
      ),
    );
  }

  /// Revokes a permission from a role in `core_role_permissions`.
  Future<int> revokePermissionFromRole({
    required String roleId,
    required NexaBizPermissionId permissionId,
  }) async {
    return (database.delete(database.coreRolePermissions)
          ..where((t) =>
              t.roleId.equals(roleId) &
              t.permissionId.equals(permissionId.value)))
        .go();
  }

  @override
  Future<void> close() async {
    _readiness.dispose();
    await database.close();
  }
}
