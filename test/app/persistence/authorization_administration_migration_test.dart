import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:nexabiz/app/persistence/drift_core_database.dart';
import 'package:nexabiz/app/persistence/drift_core_installation_store.dart';
import 'package:nexabiz/core/setup/initialize_nexabiz_core.dart';
import 'package:path/path.dart' as p;
import 'package:sqlite3/sqlite3.dart' as raw;

void main() {
  late Directory directory;
  late String databasePath;

  const v5OwnerPermissions = [
    'company.profile.view',
    'company.profile.manage',
    'company.membership.view',
    'identity.session.view',
    'identity.user.manage',
    'permissions.catalog.view',
    'permissions.policy.review',
  ];

  const setupInput = CoreInitializationInput(
    companyCode: 'FRESH',
    companyName: 'Fresh Company',
    adminName: 'Fresh Owner',
    adminEmail: 'fresh-owner@example.test',
    password: 'secure_password_123',
  );

  setUp(() {
    directory = Directory.systemTemp.createTempSync('nexabiz_authz_v6_');
    databasePath = p.join(directory.path, 'core.sqlite');
  });

  tearDown(() {
    if (directory.existsSync()) directory.deleteSync(recursive: true);
  });

  void createV5Fixture({bool collidingNames = false}) {
    final db = raw.sqlite3.open(databasePath);
    db.execute('PRAGMA foreign_keys = ON');
    db.execute('''
      CREATE TABLE core_companies (
        id TEXT NOT NULL PRIMARY KEY, code TEXT UNIQUE, name TEXT,
        status TEXT, created_at INTEGER, updated_at INTEGER
      )
    ''');
    db.execute('''
      CREATE TABLE core_users (
        id TEXT NOT NULL PRIMARY KEY, email TEXT UNIQUE, name TEXT,
        status TEXT, created_at INTEGER, updated_at INTEGER
      )
    ''');
    db.execute('''
      CREATE TABLE core_company_memberships (
        id TEXT NOT NULL PRIMARY KEY,
        user_id TEXT NOT NULL REFERENCES core_users(id),
        company_id TEXT NOT NULL REFERENCES core_companies(id),
        role TEXT NOT NULL, status TEXT NOT NULL,
        created_at INTEGER, updated_at INTEGER,
        UNIQUE(company_id, user_id)
      )
    ''');
    db.execute('''
      CREATE TABLE core_credentials (
        user_id TEXT NOT NULL REFERENCES core_users(id), kind TEXT NOT NULL,
        algorithm TEXT NOT NULL, parameters TEXT NOT NULL, salt TEXT NOT NULL,
        verifier TEXT NOT NULL, created_at INTEGER NOT NULL,
        updated_at INTEGER NOT NULL, PRIMARY KEY(user_id, kind)
      )
    ''');
    db.execute('''
      CREATE TABLE core_login_attempts (
        identifier_hash TEXT NOT NULL PRIMARY KEY, attempt_count INTEGER NOT NULL,
        locked_until INTEGER, last_attempt_at INTEGER NOT NULL
      )
    ''');
    db.execute('''
      CREATE TABLE core_roles (
        id TEXT NOT NULL PRIMARY KEY, scope TEXT NOT NULL,
        company_id TEXT REFERENCES core_companies(id), role_key TEXT NOT NULL,
        name TEXT, description TEXT, is_builtin INTEGER NOT NULL DEFAULT 0,
        created_at INTEGER NOT NULL, updated_at INTEGER NOT NULL
      )
    ''');
    db.execute('''
      CREATE TABLE core_membership_roles (
        membership_id TEXT NOT NULL REFERENCES core_company_memberships(id)
          ON DELETE CASCADE,
        role_id TEXT NOT NULL REFERENCES core_roles(id) ON DELETE CASCADE,
        created_at INTEGER NOT NULL, PRIMARY KEY(membership_id, role_id)
      )
    ''');
    db.execute('''
      CREATE TABLE core_role_permissions (
        role_id TEXT NOT NULL REFERENCES core_roles(id) ON DELETE CASCADE,
        permission_id TEXT NOT NULL, created_at INTEGER NOT NULL,
        PRIMARY KEY(role_id, permission_id)
      )
    ''');
    db.execute('''
      CREATE TABLE schema_migrations (
        owner TEXT NOT NULL, version INTEGER NOT NULL,
        PRIMARY KEY(owner, version)
      )
    ''');
    const now = 1767225600000;
    db.execute(
      "INSERT INTO core_companies VALUES ('company-a','A','Company A','active',$now,$now)",
    );
    db.execute(
      "INSERT INTO core_users VALUES ('user-a','owner-a@example.test','Owner A','active',$now,$now)",
    );
    db.execute(
      "INSERT INTO core_company_memberships VALUES ('membership-a','user-a','company-a','owner','active',$now,$now)",
    );
    db.execute(
      "INSERT INTO core_roles VALUES ('owner-role','company','company-a','company.owner','Owner','Built-in owner',1,$now,$now)",
    );
    db.execute(
      "INSERT INTO core_roles VALUES ('custom-role','company','company-a','company.auditor','مدقق','Custom role',0,$now,$now)",
    );
    if (collidingNames) {
      db.execute(
        "INSERT INTO core_roles VALUES ('collision-role','company','company-a','company.reviewer','  مدقق  ','Collision',0,$now,$now)",
      );
    }
    db.execute(
      "INSERT INTO core_membership_roles VALUES ('membership-a','owner-role',$now)",
    );
    for (final permissionId in v5OwnerPermissions) {
      db.execute('INSERT INTO core_role_permissions VALUES (?, ?, ?)', [
        'owner-role',
        permissionId,
        now,
      ]);
    }
    db.execute(
      "INSERT INTO core_role_permissions VALUES ('custom-role','reports.audit.view',$now)",
    );
    db.execute("INSERT INTO schema_migrations VALUES ('core',5)");
    db.execute('PRAGMA user_version = 5');
    db.close();
  }

  Set<String> ownerPermissions(raw.Database db) => db
      .select('''
        SELECT rp.permission_id
        FROM core_role_permissions rp
        JOIN core_roles r ON r.id = rp.role_id
        WHERE r.role_key = 'company.owner' AND r.is_builtin = 1
      ''')
      .map((row) => row['permission_id']! as String)
      .toSet();

  test('real v5 migrates atomically to v6 and preserves relational data', () async {
    createV5Fixture();
    final store = await DriftCoreInstallationStore.open(databasePath);
    await store.close();

    final db = raw.sqlite3.open(databasePath);
    expect(db.select('PRAGMA user_version').single['user_version'], 6);
    expect(ownerPermissions(db), kInitialCompanyOwnerPermissions.toSet());
    expect(
      ownerPermissions(db).difference(v5OwnerPermissions.toSet()),
      kCompanyOwnerAdministrationPermissionIds.toSet(),
    );
    expect(
      db
          .select(
            "SELECT permission_id FROM core_role_permissions WHERE role_id = 'custom-role'",
          )
          .single['permission_id'],
      'reports.audit.view',
    );
    expect(db.select('SELECT * FROM core_membership_roles'), hasLength(1));
    expect(
      db
          .select(
            "SELECT normalized_name FROM core_roles WHERE id = 'owner-role'",
          )
          .single['normalized_name'],
      'owner',
    );
    expect(
      db
          .select(
            "SELECT normalized_name FROM core_roles WHERE id = 'custom-role'",
          )
          .single['normalized_name'],
      'مدقق',
    );
    expect(
      db
          .select(
            "SELECT COUNT(*) AS count FROM core_role_permissions WHERE role_id = 'owner-role'",
          )
          .single['count'],
      kInitialCompanyOwnerPermissions.length,
    );
    final triggers = db
        .select("SELECT name FROM sqlite_master WHERE type = 'trigger'")
        .map((row) => row['name']! as String)
        .toSet();
    expect(
      triggers,
      containsAll({
        'trg_core_memberships_assignment_tenant_update',
        'trg_core_roles_assignment_tenant_update',
        'trg_core_memberships_last_owner_delete',
        'trg_core_roles_last_owner_delete',
        'trg_core_roles_last_owner_update',
        'trg_core_membership_roles_last_owner_delete',
        'trg_core_membership_roles_last_owner_update',
        'trg_core_memberships_last_owner_update',
        'trg_core_users_last_owner_update',
        'trg_core_companies_owner_activation_update',
      }),
    );
    db.close();
  });

  test('reopen is idempotent and does not duplicate grants', () async {
    createV5Fixture();
    final first = await DriftCoreInstallationStore.open(databasePath);
    await first.close();
    final second = await DriftCoreInstallationStore.open(databasePath);
    await second.close();

    final db = raw.sqlite3.open(databasePath);
    expect(ownerPermissions(db), kInitialCompanyOwnerPermissions.toSet());
    expect(
      db
          .select(
            "SELECT COUNT(*) AS count FROM schema_migrations WHERE owner = 'core' AND version = 6",
          )
          .single['count'],
      1,
    );
    db.close();
  });

  test(
    'fresh and migrated owner permission baselines are equivalent',
    () async {
      createV5Fixture();
      final migrated = await DriftCoreInstallationStore.open(databasePath);
      await migrated.close();
      final migratedDb = raw.sqlite3.open(databasePath);
      final migratedPermissions = ownerPermissions(migratedDb);
      migratedDb.close();

      final freshPath = p.join(directory.path, 'fresh.sqlite');
      final fresh = await DriftCoreInstallationStore.open(freshPath);
      await InitializeNexaBizCore(fresh)(setupInput);
      await fresh.close();
      final freshDb = raw.sqlite3.open(freshPath);
      expect(ownerPermissions(freshDb), migratedPermissions);
      expect(migratedPermissions, kInitialCompanyOwnerPermissions.toSet());
      freshDb.close();
    },
  );

  test(
    'name collision aborts column, grants, and schema-version change',
    () async {
      createV5Fixture(collidingNames: true);
      await expectLater(
        DriftCoreInstallationStore.open(databasePath),
        throwsA(
          isA<StateError>().having(
            (error) => error.message,
            'message',
            contains('duplicate normalized role names'),
          ),
        ),
      );

      final db = raw.sqlite3.open(databasePath);
      expect(db.select('PRAGMA user_version').single['user_version'], 5);
      expect(
        db
            .select('PRAGMA table_info(core_roles)')
            .map((row) => row['name'])
            .toSet(),
        isNot(contains('normalized_name')),
      );
      expect(ownerPermissions(db), v5OwnerPermissions.toSet());
      expect(
        db
            .select(
              "SELECT COUNT(*) AS count FROM schema_migrations WHERE version = 6",
            )
            .single['count'],
        0,
      );
      db.close();
    },
  );
}
