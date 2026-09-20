import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';

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

@DriftDatabase(
  tables: [
    CoreCompanies,
    CoreUsers,
    CoreCompanyMemberships,
    CoreCredentials,
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
  int get schemaVersion => 3;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) async {
      await m.createAll();
      await into(schemaMigrations).insert(
        const SchemaMigrationsCompanion(
          owner: Value('core'),
          version: Value(3),
        ),
      );
    },
    onUpgrade: (m, from, to) async {
      if (from < 1 || from > 2 || to != 3) {
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
      await m.createTable(coreCredentials);
      await into(schemaMigrations).insert(
        const SchemaMigrationsCompanion(
          owner: Value('core'),
          version: Value(3),
        ),
      );
    },
    beforeOpen: (_) async {
      await customStatement('PRAGMA foreign_keys = ON');
    },
  );
}
