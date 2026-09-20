import 'package:drift/drift.dart';

import '../../core/identity/authenticate_local_user.dart';
import '../../core/setup/initialize_nexabiz_core.dart';
import '../../core/setup/nexabiz_core_installation_store.dart';
import '../../core/setup/nexabiz_setup_readiness.dart';
import 'drift_core_database.dart';

/// Readiness projection and identity authority from the Drift Core database.
final class DriftCoreInstallationStore
    implements NexaBizCoreInstallationStore, CoreIdentityQueryStore {
  DriftCoreInstallationStore._(this.database);

  final DriftCoreDatabase database;

  static Future<DriftCoreInstallationStore> open(String databasePath) async {
    final database = DriftCoreDatabase.open(databasePath);
    try {
      await database.customSelect('SELECT 1').get();
      final store = DriftCoreInstallationStore._(database);
      await store.readReadiness();
      return store;
    } catch (_) {
      await database.close();
      rethrow;
    }
  }

  static Future<DriftCoreInstallationStore> openDatabaseForTest(
    DriftCoreDatabase database,
  ) async {
    final store = DriftCoreInstallationStore._(database);
    await store.readReadiness();
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
            AND cr.parameters = 'v=19,m=19456,t=2,p=1,l=32'
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
      return await database.transaction(() async {
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
        final after = await readReadiness();
        if (!after.isReady) {
          throw const CoreInitializationException(
            CoreInitializationFailure.storageFailure,
          );
        }
        return after;
      });
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
    final rows = await database.customSelect(
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
    ).get();

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
    final rows = await database.customSelect(
      '''
      SELECT algorithm, parameters, salt, verifier
      FROM core_credentials
      WHERE user_id = ? AND kind = 'password'
      LIMIT 1
      ''',
      variables: [Variable.withString(userId)],
    ).get();

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
  Future<List<CoreAuthCompanyRef>> readActiveUserCompanies(
    String userId,
  ) async {
    final rows = await database.customSelect(
      '''
      SELECT c.id, c.name, c.code, m.role
      FROM core_company_memberships m
      JOIN core_companies c ON c.id = m.company_id
      WHERE m.user_id = ? AND m.status = 'active' AND c.status = 'active'
      ORDER BY c.name ASC
      ''',
      variables: [Variable.withString(userId)],
    ).get();

    return [
      for (final row in rows)
        CoreAuthCompanyRef(
          id: row.read<String>('id'),
          name: row.read<String?>('name') ?? '',
          code: row.read<String?>('code') ?? '',
          role: row.read<String>('role'),
        ),
    ];
  }

  @override
  Future<CoreAuthMembershipRef?> readMembership(
    String userId,
    String companyId,
  ) async {
    final rows = await database.customSelect(
      '''
      SELECT user_id, company_id, role, status
      FROM core_company_memberships
      WHERE user_id = ? AND company_id = ? AND status = 'active'
      LIMIT 1
      ''',
      variables: [
        Variable.withString(userId),
        Variable.withString(companyId),
      ],
    ).get();

    if (rows.isEmpty) return null;
    final row = rows.single;
    return CoreAuthMembershipRef(
      userId: row.read<String>('user_id'),
      companyId: row.read<String>('company_id'),
      role: row.read<String>('role'),
      status: row.read<String>('status'),
    );
  }

  @override
  Future<void> close() => database.close();
}
