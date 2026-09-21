import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';

import '../../core/identity/core_uuid.dart';

part 'drift_core_database.g.dart';

/// Core identity only. Business capabilities must own their own schema.
@DataClassName('CoreCompanyRow')
class CoreCompanies extends Table {
  @override
  String get tableName => 'core_companies';

  TextColumn get id => text()();
  TextColumn get code => text().nullable().unique()();
  TextColumn get name => text().nullable()();
  TextColumn get status => text().nullable()();
  DateTimeColumn get createdAt => dateTime().nullable()();
  DateTimeColumn get updatedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('CoreUserRow')
class CoreUsers extends Table {
  @override
  String get tableName => 'core_users';

  TextColumn get id => text()();
  TextColumn get email => text().nullable().unique()();
  TextColumn get name => text().nullable()();
  TextColumn get status => text().nullable()();
  DateTimeColumn get createdAt => dateTime().nullable()();
  DateTimeColumn get updatedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('CoreCompanyMembershipRow')
class CoreCompanyMemberships extends Table {
  @override
  String get tableName => 'core_company_memberships';

  TextColumn get id => text()();
  TextColumn get userId => text().references(CoreUsers, #id)();
  TextColumn get companyId => text().references(CoreCompanies, #id)();
  TextColumn get role => text()();
  TextColumn get status => text()();
  DateTimeColumn get createdAt => dateTime().nullable()();
  DateTimeColumn get updatedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};

  @override
  List<Set<Column>> get uniqueKeys => [
    {companyId, userId},
  ];
}

@DataClassName('CoreCredentialRow')
class CoreCredentials extends Table {
  @override
  String get tableName => 'core_credentials';

  TextColumn get userId => text().references(CoreUsers, #id)();
  TextColumn get kind => text()();
  TextColumn get algorithm => text()();
  TextColumn get parameters => text()();
  TextColumn get salt => text()();
  TextColumn get verifier => text()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {userId, kind};
}

@DataClassName('CoreSchemaMigrationRow')
class SchemaMigrations extends Table {
  @override
  String get tableName => 'schema_migrations';

  TextColumn get owner => text()();
  IntColumn get version => integer()();

  @override
  Set<Column> get primaryKey => {owner, version};
}

@DataClassName('CoreLoginAttemptRow')
class CoreLoginAttempts extends Table {
  @override
  String get tableName => 'core_login_attempts';

  TextColumn get identifierHash => text()();
  IntColumn get attemptCount => integer()();
  DateTimeColumn get lockedUntil => dateTime().nullable()();
  DateTimeColumn get lastAttemptAt => dateTime()();

  @override
  Set<Column> get primaryKey => {identifierHash};
}

const List<String> kInitialCompanyOwnerPermissions = [
  'company.profile.view',
  'company.profile.manage',
  'company.membership.view',
  'identity.session.view',
  'identity.user.manage',
  'permissions.catalog.view',
  'permissions.policy.review',
];

@DataClassName('CoreRoleRow')
class CoreRoles extends Table {
  @override
  String get tableName => 'core_roles';

  TextColumn get id => text()();
  TextColumn get scope => text()(); // 'system' or 'company'
  TextColumn get companyId =>
      text().nullable().references(CoreCompanies, #id)();
  TextColumn get roleKey => text()(); // e.g. 'company.owner', 'company.admin'
  TextColumn get name => text().nullable()();
  TextColumn get description => text().nullable()();
  BoolColumn get isBuiltin =>
      boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('CoreMembershipRoleRow')
class CoreMembershipRoles extends Table {
  @override
  String get tableName => 'core_membership_roles';

  TextColumn get membershipId =>
      text().references(CoreCompanyMemberships, #id, onDelete: KeyAction.cascade)();
  TextColumn get roleId =>
      text().references(CoreRoles, #id, onDelete: KeyAction.cascade)();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {membershipId, roleId};
}

@DataClassName('CoreRolePermissionRow')
class CoreRolePermissions extends Table {
  @override
  String get tableName => 'core_role_permissions';

  TextColumn get roleId =>
      text().references(CoreRoles, #id, onDelete: KeyAction.cascade)();
  TextColumn get permissionId => text()();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {roleId, permissionId};
}

@DriftDatabase(
  tables: [
    CoreCompanies,
    CoreUsers,
    CoreCompanyMemberships,
    CoreCredentials,
    CoreLoginAttempts,
    CoreRoles,
    CoreMembershipRoles,
    CoreRolePermissions,
    SchemaMigrations,
  ],
)
class DriftCoreDatabase extends _$DriftCoreDatabase {
  DriftCoreDatabase(super.executor);

  factory DriftCoreDatabase.open(String databasePath) {
    if (databasePath.isEmpty || databasePath == ':memory:') {
      throw ArgumentError.value(databasePath, 'databasePath');
    }
    final file = File(databasePath);
    file.parent.createSync(recursive: true);
    return DriftCoreDatabase(
      NativeDatabase(
        file,
        setup: (db) {
          db.execute('PRAGMA foreign_keys = ON');
          db.execute('PRAGMA journal_mode = WAL');
          db.execute('PRAGMA busy_timeout = 5000');
        },
      ),
    );
  }

  factory DriftCoreDatabase.memory() => DriftCoreDatabase(
    NativeDatabase.memory(
      setup: (db) => db.execute('PRAGMA foreign_keys = ON'),
    ),
  );

  @override
  int get schemaVersion => 5;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) async {
      await m.createAll();
      await _createAuthorizationTriggersAndIndexes();
      await into(schemaMigrations).insert(
        const SchemaMigrationsCompanion(
          owner: Value('core'),
          version: Value(5),
        ),
      );
    },
    onUpgrade: (m, from, to) async {
      if (from < 1 || from > 4 || to != 5) {
        throw StateError('Unsupported Core schema migration: $from to $to');
      }
      if (from == 1) {
        // V1 contains only IDs and a user marker. Preserve those rows, but never
        // infer names, email, membership, or administrator authority from them.
        await customStatement(
          'ALTER TABLE core_companies ADD COLUMN code TEXT',
        );
        await customStatement(
          'ALTER TABLE core_companies ADD COLUMN name TEXT',
        );
        await customStatement(
          'ALTER TABLE core_companies ADD COLUMN status TEXT',
        );
        await customStatement(
          'ALTER TABLE core_companies ADD COLUMN created_at INTEGER',
        );
        await customStatement(
          'ALTER TABLE core_companies ADD COLUMN updated_at INTEGER',
        );
        await customStatement(
          'CREATE UNIQUE INDEX core_companies_code_unique ON core_companies (code)',
        );
        await customStatement('ALTER TABLE core_users ADD COLUMN email TEXT');
        await customStatement('ALTER TABLE core_users ADD COLUMN name TEXT');
        await customStatement('ALTER TABLE core_users ADD COLUMN status TEXT');
        await customStatement(
          'ALTER TABLE core_users ADD COLUMN created_at INTEGER',
        );
        await customStatement(
          'ALTER TABLE core_users ADD COLUMN updated_at INTEGER',
        );
        await customStatement(
          'CREATE UNIQUE INDEX core_users_email_unique ON core_users (email)',
        );
        await m.createTable(coreCompanyMemberships);
        await into(schemaMigrations).insert(
          const SchemaMigrationsCompanion(
            owner: Value('core'),
            version: Value(2),
          ),
        );
      }
      if (from <= 2) {
        await m.createTable(coreCredentials);
        await into(schemaMigrations).insert(
          const SchemaMigrationsCompanion(
            owner: Value('core'),
            version: Value(3),
          ),
        );
      }
      if (from <= 3) {
        await m.createTable(coreLoginAttempts);
        await into(schemaMigrations).insert(
          const SchemaMigrationsCompanion(
            owner: Value('core'),
            version: Value(4),
          ),
        );
      }
      if (from <= 4) {
        await m.createTable(coreRoles);
        await m.createTable(coreMembershipRoles);
        await m.createTable(coreRolePermissions);
        await _createAuthorizationTriggersAndIndexes();
        await _migrateExistingOwnerMemberships();
        await into(schemaMigrations).insert(
          const SchemaMigrationsCompanion(
            owner: Value('core'),
            version: Value(5),
          ),
        );
      }
    },
    beforeOpen: (_) async {
      await customStatement('PRAGMA foreign_keys = ON');
      await _createAuthorizationTriggersAndIndexes();
    },
  );

  Future<void> _createAuthorizationTriggersAndIndexes() async {
    // Unique index for company roles
    await customStatement('''
      CREATE UNIQUE INDEX IF NOT EXISTS idx_core_roles_company_key
      ON core_roles (company_id, role_key)
      WHERE company_id IS NOT NULL
    ''');

    // Unique index for system roles
    await customStatement('''
      CREATE UNIQUE INDEX IF NOT EXISTS idx_core_roles_system_key
      ON core_roles (role_key)
      WHERE company_id IS NULL
    ''');

    // Role scope & company_id invariants triggers
    await customStatement('''
      CREATE TRIGGER IF NOT EXISTS trg_core_roles_scope_check_insert
      BEFORE INSERT ON core_roles
      BEGIN
        SELECT CASE
          WHEN NEW.scope = 'company' AND (NEW.company_id IS NULL OR trim(NEW.company_id) = '')
          THEN RAISE(ABORT, 'Company-scoped role requires non-null company_id')
          WHEN NEW.scope = 'system' AND NEW.company_id IS NOT NULL
          THEN RAISE(ABORT, 'System-scoped role must have null company_id')
          WHEN NEW.scope NOT IN ('system', 'company')
          THEN RAISE(ABORT, 'Invalid role scope')
        END;
      END;
    ''');

    await customStatement('''
      CREATE TRIGGER IF NOT EXISTS trg_core_roles_scope_check_update
      BEFORE UPDATE ON core_roles
      BEGIN
        SELECT CASE
          WHEN NEW.scope = 'company' AND (NEW.company_id IS NULL OR trim(NEW.company_id) = '')
          THEN RAISE(ABORT, 'Company-scoped role requires non-null company_id')
          WHEN NEW.scope = 'system' AND NEW.company_id IS NOT NULL
          THEN RAISE(ABORT, 'System-scoped role must have null company_id')
          WHEN NEW.scope NOT IN ('system', 'company')
          THEN RAISE(ABORT, 'Invalid role scope')
        END;
      END;
    ''');

    // Cross-tenant protection & role-membership invariants triggers
    await customStatement('''
      CREATE TRIGGER IF NOT EXISTS trg_core_membership_roles_cross_tenant_insert
      BEFORE INSERT ON core_membership_roles
      BEGIN
        SELECT CASE
          WHEN (SELECT m.id FROM core_company_memberships m WHERE m.id = NEW.membership_id) IS NULL
          THEN RAISE(ABORT, 'Unknown membership_id in core_membership_roles')
          WHEN (SELECT r.id FROM core_roles r WHERE r.id = NEW.role_id) IS NULL
          THEN RAISE(ABORT, 'Unknown role_id in core_membership_roles')
          WHEN (SELECT r.scope FROM core_roles r WHERE r.id = NEW.role_id) <> 'company'
          THEN RAISE(ABORT, 'Company membership can only be assigned company-scoped roles')
          WHEN (SELECT m.company_id FROM core_company_memberships m WHERE m.id = NEW.membership_id) <>
               (SELECT r.company_id FROM core_roles r WHERE r.id = NEW.role_id)
          THEN RAISE(ABORT, 'Cross-tenant role assignment: membership and role belong to different companies')
        END;
      END;
    ''');

    await customStatement('''
      CREATE TRIGGER IF NOT EXISTS trg_core_membership_roles_cross_tenant_update
      BEFORE UPDATE ON core_membership_roles
      BEGIN
        SELECT CASE
          WHEN (SELECT m.id FROM core_company_memberships m WHERE m.id = NEW.membership_id) IS NULL
          THEN RAISE(ABORT, 'Unknown membership_id in core_membership_roles')
          WHEN (SELECT r.id FROM core_roles r WHERE r.id = NEW.role_id) IS NULL
          THEN RAISE(ABORT, 'Unknown role_id in core_membership_roles')
          WHEN (SELECT r.scope FROM core_roles r WHERE r.id = NEW.role_id) <> 'company'
          THEN RAISE(ABORT, 'Company membership can only be assigned company-scoped roles')
          WHEN (SELECT m.company_id FROM core_company_memberships m WHERE m.id = NEW.membership_id) <>
               (SELECT r.company_id FROM core_roles r WHERE r.id = NEW.role_id)
          THEN RAISE(ABORT, 'Cross-tenant role assignment: membership and role belong to different companies')
        END;
      END;
    ''');
  }

  Future<void> _migrateExistingOwnerMemberships() async {
    final companies = await select(coreCompanies).get();
    final now = DateTime.now().toUtc();
    for (final company in companies) {
      final existingRole = await (select(coreRoles)
            ..where((r) =>
                r.companyId.equals(company.id) &
                r.roleKey.equals('company.owner')))
          .getSingleOrNull();

      final String roleId;
      if (existingRole == null) {
        roleId = generateCoreUuidV7();
        await into(coreRoles).insert(
          CoreRolesCompanion.insert(
            id: roleId,
            scope: 'company',
            companyId: Value(company.id),
            roleKey: 'company.owner',
            name: const Value('owner'),
            description: const Value('Built-in company owner role'),
            isBuiltin: const Value(true),
            createdAt: company.createdAt ?? now,
            updatedAt: company.updatedAt ?? now,
          ),
        );

        for (final permId in kInitialCompanyOwnerPermissions) {
          await into(coreRolePermissions).insert(
            CoreRolePermissionsCompanion.insert(
              roleId: roleId,
              permissionId: permId,
              createdAt: company.createdAt ?? now,
            ),
          );
        }
      } else {
        roleId = existingRole.id;
      }

      final memberships = await (select(coreCompanyMemberships)
            ..where((m) =>
                m.companyId.equals(company.id) & m.role.equals('owner')))
          .get();

      for (final membership in memberships) {
        await into(coreMembershipRoles).insertOnConflictUpdate(
          CoreMembershipRolesCompanion.insert(
            membershipId: membership.id,
            roleId: roleId,
            createdAt: membership.createdAt ?? now,
          ),
        );
      }
    }
  }
}
