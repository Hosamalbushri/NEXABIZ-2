import 'dart:convert';
import 'dart:io';

import 'package:cryptography/cryptography.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nexabiz/app/persistence/drift_core_database.dart';
import 'package:nexabiz/app/persistence/drift_core_installation_store.dart';
import 'package:nexabiz/core/identity/authenticate_local_user.dart';
import 'package:nexabiz/core/permissions/nexabiz_permission_intent.dart';
import 'package:nexabiz/core/roles/nexabiz_role_id.dart';
import 'package:path/path.dart' as p;
import 'package:sqlite3/sqlite3.dart' as raw;

void main() {
  late Directory directory;
  late String databasePath;

  setUp(() {
    directory = Directory.systemTemp.createTempSync(
      'nexabiz_rbac_migration_test_',
    );
    databasePath = p.join(directory.path, 'core.sqlite');
  });

  tearDown(() {
    if (directory.existsSync()) {
      directory.deleteSync(recursive: true);
    }
  });

  const sampleTimestamp = 1767225600; // 2026-01-01T00:00:00Z in epoch seconds

  Future<void> createV4Database(
    String path, {
    String password = 'correct horse battery staple',
  }) async {
    final db = raw.sqlite3.open(path);
    db.execute('''
      CREATE TABLE schema_migrations (
        owner TEXT NOT NULL,
        version INTEGER NOT NULL,
        PRIMARY KEY (owner, version)
      );
      CREATE TABLE core_companies (
        id TEXT NOT NULL PRIMARY KEY,
        code TEXT UNIQUE,
        name TEXT,
        status TEXT NOT NULL DEFAULT 'active',
        created_at INTEGER,
        updated_at INTEGER
      );
      CREATE TABLE core_users (
        id TEXT NOT NULL PRIMARY KEY,
        email TEXT UNIQUE,
        name TEXT,
        is_initial_administrator INTEGER NOT NULL DEFAULT 0,
        status TEXT NOT NULL DEFAULT 'active',
        created_at INTEGER,
        updated_at INTEGER
      );
      CREATE TABLE core_company_memberships (
        id TEXT NOT NULL PRIMARY KEY,
        user_id TEXT NOT NULL,
        company_id TEXT NOT NULL,
        role TEXT NOT NULL,
        status TEXT NOT NULL DEFAULT 'active',
        created_at INTEGER,
        updated_at INTEGER,
        FOREIGN KEY (user_id) REFERENCES core_users(id),
        FOREIGN KEY (company_id) REFERENCES core_companies(id),
        UNIQUE (company_id, user_id)
      );
      CREATE TABLE core_credentials (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id TEXT NOT NULL UNIQUE,
        kind TEXT NOT NULL,
        algorithm TEXT NOT NULL,
        parameters TEXT NOT NULL,
        salt TEXT NOT NULL,
        verifier TEXT NOT NULL,
        created_at INTEGER,
        updated_at INTEGER,
        FOREIGN KEY (user_id) REFERENCES core_users(id)
      );
      CREATE TABLE core_login_attempts (
        identifier_hash TEXT NOT NULL PRIMARY KEY,
        attempt_count INTEGER NOT NULL DEFAULT 0,
        locked_until INTEGER,
        last_attempt_at INTEGER NOT NULL
      );

      INSERT INTO schema_migrations (owner, version) VALUES ('core', 1);
      INSERT INTO schema_migrations (owner, version) VALUES ('core', 2);
      INSERT INTO schema_migrations (owner, version) VALUES ('core', 3);
      INSERT INTO schema_migrations (owner, version) VALUES ('core', 4);
      PRAGMA user_version = 4;
    ''');

    // Hash password with Argon2id matching production parameters
    final salt = List<int>.filled(16, 9);
    final key = await Argon2id(
      memory: 19456,
      parallelism: 1,
      iterations: 2,
      hashLength: 32,
    ).deriveKeyFromPassword(password: password, nonce: salt);
    final verifierBytes = await key.extractBytes();
    final saltB64 = base64.encode(salt);
    final verifierB64 = base64.encode(verifierBytes);

    db.execute('''
      INSERT INTO core_companies (id, code, name, status, created_at, updated_at)
      VALUES ('c1', 'ACME', 'Acme Corporation', 'active', $sampleTimestamp, $sampleTimestamp);

      INSERT INTO core_users (id, email, name, is_initial_administrator, status, created_at, updated_at)
      VALUES ('u1', 'admin@acme.test', 'Alice Owner', 1, 'active', $sampleTimestamp, $sampleTimestamp);

      INSERT INTO core_company_memberships (id, user_id, company_id, role, status, created_at, updated_at)
      VALUES ('m1', 'u1', 'c1', 'owner', 'active', $sampleTimestamp, $sampleTimestamp);

      INSERT INTO core_credentials (user_id, kind, algorithm, parameters, salt, verifier, created_at, updated_at)
      VALUES ('u1', 'password', 'argon2id', 'v=19,m=19456,t=2,p=1,l=32', '$saltB64', '$verifierB64', $sampleTimestamp, $sampleTimestamp);

      INSERT INTO core_login_attempts (identifier_hash, attempt_count, locked_until, last_attempt_at)
      VALUES ('some_dummy_hash', 3, ${sampleTimestamp + 3600}, $sampleTimestamp);
    ''');

    db.close();
  }

  group('RBAC Schema Migration (v4 -> v6)', () {
    test(
      '1. Migrating v4 database upgrades schemaVersion to 6 and creates RBAC artifacts',
      () async {
        await createV4Database(databasePath);

        final store = await DriftCoreInstallationStore.open(databasePath);
        final readiness = await store.readReadiness();
        expect(readiness.isReady, isTrue);

        final snapshot = await store.readMembershipAuthorizationSnapshot('m1');
        expect(snapshot, isNotNull);
        expect(snapshot!.isEligibleForAuthorization, isTrue);
        expect(snapshot.roleIds, {NexaBizRoleId('company.owner')});
        expect(
          snapshot.permissionIds,
          kInitialCompanyOwnerPermissions.map(NexaBizPermissionId.new).toSet(),
        );

        await store.close();

        // Inspect SQLite raw level
        final rawDb = raw.sqlite3.open(databasePath);
        expect(rawDb.select('PRAGMA user_version').single['user_version'], 6);

        final migrations = rawDb
            .select('SELECT version FROM schema_migrations ORDER BY version')
            .map((r) => r['version'] as int)
            .toList();
        expect(migrations, [1, 2, 3, 4, 5, 6]);

        // Verify legacy membership role column remains 'owner'
        final memRow = rawDb
            .select("SELECT role FROM core_company_memberships WHERE id = 'm1'")
            .single;
        expect(memRow['role'], 'owner');

        // Verify login attempt was preserved
        final attemptRow = rawDb
            .select(
              "SELECT attempt_count FROM core_login_attempts WHERE identifier_hash = 'some_dummy_hash'",
            )
            .single;
        expect(attemptRow['attempt_count'], 3);

        rawDb.close();
      },
    );

    test(
      '2. Authentication works seamlessly after v4 to v6 migration',
      () async {
        const password = 'my_super_secure_password';
        await createV4Database(databasePath, password: password);

        final store = await DriftCoreInstallationStore.open(databasePath);
        final auth = AuthenticateLocalUser(queryStore: store);

        // Wrong password fails
        final failedResult = await auth(
          const CoreAuthenticationInput(
            identifier: 'admin@acme.test',
            password: 'wrong_password',
          ),
        );
        expect(failedResult.isSuccess, isFalse);
        expect(
          failedResult.status,
          CoreAuthenticationStatus.invalidCredentials,
        );
        expect(failedResult.user, isNull);

        // Correct password succeeds
        final successResult = await auth(
          const CoreAuthenticationInput(
            identifier: 'admin@acme.test',
            password: password,
          ),
        );
        expect(successResult.isSuccess, isTrue);
        expect(successResult.status, CoreAuthenticationStatus.success);
        expect(successResult.user, isNotNull);
        expect(successResult.user!.id, 'u1');
        expect(successResult.user!.email, 'admin@acme.test');
        expect(successResult.activeCompany?.id, 'c1');

        await store.close();
      },
    );

    test('3. Migration is idempotent across multiple store opens', () async {
      await createV4Database(databasePath);

      // First open: migrates v4 -> v6
      final store1 = await DriftCoreInstallationStore.open(databasePath);
      expect((await store1.readReadiness()).isReady, isTrue);
      await store1.close();

      // Second open: should not fail or duplicate
      final store2 = await DriftCoreInstallationStore.open(databasePath);
      expect((await store2.readReadiness()).isReady, isTrue);

      final roles = await store2.database
          .select(store2.database.coreRoles)
          .get();
      expect(roles, hasLength(1));

      final membershipRoles = await store2.database
          .select(store2.database.coreMembershipRoles)
          .get();
      expect(membershipRoles, hasLength(1));

      final rolePermissions = await store2.database
          .select(store2.database.coreRolePermissions)
          .get();
      expect(
        rolePermissions,
        hasLength(kInitialCompanyOwnerPermissions.length),
      );

      await store2.close();
    });

    test(
      '4. Migration with multiple legacy companies and owner memberships',
      () async {
        final db = raw.sqlite3.open(databasePath);
        db.execute('''
        CREATE TABLE schema_migrations (
          owner TEXT NOT NULL,
          version INTEGER NOT NULL,
          PRIMARY KEY (owner, version)
        );
        CREATE TABLE core_companies (
          id TEXT NOT NULL PRIMARY KEY,
          code TEXT UNIQUE,
          name TEXT,
          status TEXT NOT NULL DEFAULT 'active',
          created_at INTEGER,
          updated_at INTEGER
        );
        CREATE TABLE core_users (
          id TEXT NOT NULL PRIMARY KEY,
          email TEXT UNIQUE,
          name TEXT,
          is_initial_administrator INTEGER NOT NULL DEFAULT 0,
          status TEXT NOT NULL DEFAULT 'active',
          created_at INTEGER,
          updated_at INTEGER
        );
        CREATE TABLE core_company_memberships (
          id TEXT NOT NULL PRIMARY KEY,
          user_id TEXT NOT NULL,
          company_id TEXT NOT NULL,
          role TEXT NOT NULL,
          status TEXT NOT NULL DEFAULT 'active',
          created_at INTEGER,
          updated_at INTEGER,
          FOREIGN KEY (user_id) REFERENCES core_users(id),
          FOREIGN KEY (company_id) REFERENCES core_companies(id),
          UNIQUE (company_id, user_id)
        );
        CREATE TABLE core_credentials (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          user_id TEXT NOT NULL UNIQUE,
          kind TEXT NOT NULL,
          algorithm TEXT NOT NULL,
          parameters TEXT NOT NULL,
          salt TEXT NOT NULL,
          verifier TEXT NOT NULL,
          created_at INTEGER,
          updated_at INTEGER,
          FOREIGN KEY (user_id) REFERENCES core_users(id)
        );
        CREATE TABLE core_login_attempts (
          identifier_hash TEXT NOT NULL PRIMARY KEY,
          attempt_count INTEGER NOT NULL DEFAULT 0,
          locked_until INTEGER,
          last_attempt_at INTEGER NOT NULL
        );

        INSERT INTO schema_migrations (owner, version) VALUES ('core', 4);
        PRAGMA user_version = 4;

        INSERT INTO core_companies VALUES ('c1', 'C1', 'Company 1', 'active', $sampleTimestamp, $sampleTimestamp);
        INSERT INTO core_companies VALUES ('c2', 'C2', 'Company 2', 'active', $sampleTimestamp, $sampleTimestamp);
        INSERT INTO core_users VALUES ('u1', 'u1@test.com', 'User 1', 1, 'active', $sampleTimestamp, $sampleTimestamp);
        INSERT INTO core_users VALUES ('u2', 'u2@test.com', 'User 2', 0, 'active', $sampleTimestamp, $sampleTimestamp);
        INSERT INTO core_company_memberships VALUES ('m1', 'u1', 'c1', 'owner', 'active', $sampleTimestamp, $sampleTimestamp);
        INSERT INTO core_company_memberships VALUES ('m2', 'u2', 'c2', 'owner', 'active', $sampleTimestamp, $sampleTimestamp);
      ''');
        db.close();

        final store = await DriftCoreInstallationStore.open(databasePath);

        // Both companies should each have a company.owner role
        final roles = await store.database
            .select(store.database.coreRoles)
            .get();
        expect(roles, hasLength(2));
        expect(roles.every((r) => r.roleKey == 'company.owner'), isTrue);

        final snap1 = await store.readMembershipAuthorizationSnapshot('m1');
        expect(snap1, isNotNull);
        expect(snap1!.companyId.value, 'c1');
        expect(snap1.roleIds, {NexaBizRoleId('company.owner')});
        expect(
          snap1.permissionIds,
          hasLength(kInitialCompanyOwnerPermissions.length),
        );

        final snap2 = await store.readMembershipAuthorizationSnapshot('m2');
        expect(snap2, isNotNull);
        expect(snap2!.companyId.value, 'c2');
        expect(snap2.roleIds, {NexaBizRoleId('company.owner')});
        expect(
          snap2.permissionIds,
          hasLength(kInitialCompanyOwnerPermissions.length),
        );

        await store.close();
      },
    );

    test(
      '5. Non-owner legacy membership does not receive owner role upon migration',
      () async {
        final db = raw.sqlite3.open(databasePath);
        db.execute('''
        CREATE TABLE schema_migrations (
          owner TEXT NOT NULL,
          version INTEGER NOT NULL,
          PRIMARY KEY (owner, version)
        );
        CREATE TABLE core_companies (
          id TEXT NOT NULL PRIMARY KEY,
          code TEXT UNIQUE,
          name TEXT,
          status TEXT NOT NULL DEFAULT 'active',
          created_at INTEGER,
          updated_at INTEGER
        );
        CREATE TABLE core_users (
          id TEXT NOT NULL PRIMARY KEY,
          email TEXT UNIQUE,
          name TEXT,
          is_initial_administrator INTEGER NOT NULL DEFAULT 0,
          status TEXT NOT NULL DEFAULT 'active',
          created_at INTEGER,
          updated_at INTEGER
        );
        CREATE TABLE core_company_memberships (
          id TEXT NOT NULL PRIMARY KEY,
          user_id TEXT NOT NULL,
          company_id TEXT NOT NULL,
          role TEXT NOT NULL,
          status TEXT NOT NULL DEFAULT 'active',
          created_at INTEGER,
          updated_at INTEGER,
          FOREIGN KEY (user_id) REFERENCES core_users(id),
          FOREIGN KEY (company_id) REFERENCES core_companies(id),
          UNIQUE (company_id, user_id)
        );
        CREATE TABLE core_credentials (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          user_id TEXT NOT NULL UNIQUE,
          kind TEXT NOT NULL,
          algorithm TEXT NOT NULL,
          parameters TEXT NOT NULL,
          salt TEXT NOT NULL,
          verifier TEXT NOT NULL,
          created_at INTEGER,
          updated_at INTEGER,
          FOREIGN KEY (user_id) REFERENCES core_users(id)
        );
        CREATE TABLE core_login_attempts (
          identifier_hash TEXT NOT NULL PRIMARY KEY,
          attempt_count INTEGER NOT NULL DEFAULT 0,
          locked_until INTEGER,
          last_attempt_at INTEGER NOT NULL
        );

        INSERT INTO schema_migrations (owner, version) VALUES ('core', 4);
        PRAGMA user_version = 4;

        INSERT INTO core_companies VALUES ('c1', 'C1', 'Company 1', 'active', $sampleTimestamp, $sampleTimestamp);
        INSERT INTO core_users VALUES ('u1', 'u1@test.com', 'User 1', 1, 'active', $sampleTimestamp, $sampleTimestamp);
        INSERT INTO core_users VALUES ('u2', 'u2@test.com', 'User 2', 0, 'active', $sampleTimestamp, $sampleTimestamp);
        INSERT INTO core_company_memberships VALUES ('m1', 'u1', 'c1', 'owner', 'active', $sampleTimestamp, $sampleTimestamp);
        INSERT INTO core_company_memberships VALUES ('m2', 'u2', 'c1', 'member', 'active', $sampleTimestamp, $sampleTimestamp);
      ''');
        db.close();

        final store = await DriftCoreInstallationStore.open(databasePath);

        // m1 (owner) has company.owner role
        final snap1 = await store.readMembershipAuthorizationSnapshot('m1');
        expect(snap1!.roleIds, {NexaBizRoleId('company.owner')});
        expect(
          snap1.permissionIds,
          hasLength(kInitialCompanyOwnerPermissions.length),
        );

        // m2 (member) has NO roles assigned, fails closed
        final snap2 = await store.readMembershipAuthorizationSnapshot('m2');
        expect(snap2!.roleIds, isEmpty);
        expect(snap2.permissionIds, isEmpty);
        expect(snap2.effectiveRoles, isEmpty);
        expect(snap2.effectivePermissions, isEmpty);

        await store.close();
      },
    );
  });
}
