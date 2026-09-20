import 'dart:io';

import 'package:drift/drift.dart' show Value;
import 'package:flutter_test/flutter_test.dart';
import 'package:nexabiz/app/bootstrap/app_bootstrap.dart';
import 'package:nexabiz/app/persistence/drift_core_database.dart';
import 'package:nexabiz/app/persistence/drift_core_installation_store.dart';
import 'package:nexabiz/core/setup/nexabiz_setup_readiness.dart';
import 'package:path/path.dart' as p;
import 'package:sqlite3/sqlite3.dart' as raw;

void main() {
  late Directory directory;
  late String databasePath;
  setUp(() {
    directory = Directory.systemTemp.createTempSync('nexabiz_core_drift_');
    databasePath = p.join(directory.path, 'core.sqlite');
  });
  tearDown(() => directory.deleteSync(recursive: true));

  void createV1({bool company = false, bool user = false}) {
    final db = raw.sqlite3.open(databasePath);
    db.execute('''
      CREATE TABLE core_companies (
        id TEXT NOT NULL PRIMARY KEY CHECK (length(id) > 0 AND id = trim(id))
      )
    ''');
    db.execute('''
      CREATE TABLE core_users (
        id TEXT NOT NULL PRIMARY KEY CHECK (length(id) > 0 AND id = trim(id)),
        is_initial_administrator INTEGER NOT NULL DEFAULT 0
          CHECK (is_initial_administrator IN (0, 1))
      )
    ''');
    db.execute('''
      CREATE TABLE schema_migrations (
        owner TEXT NOT NULL, version INTEGER NOT NULL CHECK (version > 0),
        PRIMARY KEY (owner, version)
      )
    ''');
    db.execute("INSERT INTO schema_migrations VALUES ('core', 1)");
    if (company) {
      db.execute("INSERT INTO core_companies VALUES ('old-company')");
    }
    if (user) {
      db.execute("INSERT INTO core_users VALUES ('old-user', 1)");
    }
    db.execute('PRAGMA user_version = 1');
    db.close();
  }

  Future<void> insertValid(DriftCoreDatabase db) async {
    await db
        .into(db.coreCompanies)
        .insert(
          CoreCompaniesCompanion.insert(
            id: 'company-1',
            code: Value('C1'),
            name: Value('Example'),
            status: Value('active'),
          ),
        );
    await db
        .into(db.coreUsers)
        .insert(
          CoreUsersCompanion.insert(
            id: 'user-1',
            email: Value('owner@example.test'),
            name: Value('Owner'),
            status: Value('active'),
          ),
        );
    await db
        .into(db.coreCredentials)
        .insert(
          CoreCredentialsCompanion.insert(
            userId: 'user-1',
            kind: 'password',
            algorithm: 'argon2id',
            parameters: 'v=19,m=19456,t=2,p=1,l=32',
            salt: 'c2FsdA==',
            verifier: 'dmVyaWZpZXI=',
            createdAt: DateTime.utc(2026),
            updatedAt: DateTime.utc(2026),
          ),
        );
    await db
        .into(db.coreCompanyMemberships)
        .insert(
          CoreCompanyMembershipsCompanion.insert(
            id: 'membership-1',
            userId: 'user-1',
            companyId: 'company-1',
            role: 'owner',
            status: 'active',
          ),
        );
  }

  test('fresh database contains Core schema only', () async {
    final store = await DriftCoreInstallationStore.open(databasePath);
    expect(
      (await store.readReadiness()).state,
      NexaBizSetupState.uninitialized,
    );
    await store.close();
    final db = raw.sqlite3.open(databasePath);
    expect(db.select('PRAGMA user_version').single['user_version'], 3);
    expect(
      db
          .select(
            "SELECT name FROM sqlite_master WHERE type='table' AND name NOT LIKE 'sqlite_%'",
          )
          .map((r) => r['name'])
          .toSet(),
      {
        'core_companies',
        'core_users',
        'core_company_memberships',
        'core_credentials',
        'schema_migrations',
      },
    );
    expect(
      db
          .select('SELECT version FROM schema_migrations ORDER BY version')
          .map((r) => r['version'])
          .toList(),
      [3],
    );
    db.close();
  });

  for (final state in [
    (company: false, user: false),
    (company: true, user: false),
    (company: false, user: true),
    (company: true, user: true),
  ]) {
    test(
      'v1 migrates company=${state.company} user=${state.user} without fabricating facts',
      () async {
        createV1(company: state.company, user: state.user);
        final store = await DriftCoreInstallationStore.open(databasePath);
        final readiness = await store.readReadiness();
        expect(readiness.isReady, isFalse);
        expect(
          readiness.state,
          state.company || state.user
              ? NexaBizSetupState.inProgress
              : NexaBizSetupState.uninitialized,
        );
        expect(
          await store.database.select(store.database.coreCompanies).get(),
          hasLength(state.company ? 1 : 0),
        );
        expect(
          await store.database.select(store.database.coreUsers).get(),
          hasLength(state.user ? 1 : 0),
        );
        expect(
          await store.database
              .select(store.database.coreCompanyMemberships)
              .get(),
          isEmpty,
        );
        if (state.company) {
          final row =
              (await store.database.select(store.database.coreCompanies).get())
                  .single;
          expect(row.id, 'old-company');
          expect(row.name, isNull);
          expect(row.code, isNull);
        }
        if (state.user) {
          final row =
              (await store.database.select(store.database.coreUsers).get())
                  .single;
          expect(row.id, 'old-user');
          expect(row.email, isNull);
        }
        await store.close();
        final db = raw.sqlite3.open(databasePath);
        expect(db.select('PRAGMA user_version').single['user_version'], 3);
        if (state.user) {
          expect(
            db
                .select('SELECT is_initial_administrator FROM core_users')
                .single['is_initial_administrator'],
            1,
          );
        }
        db.close();
      },
    );
  }

  test(
    'migrated v1 database remains writable without changing old rows',
    () async {
      createV1(company: true, user: true);
      final store = await DriftCoreInstallationStore.open(databasePath);
      await store.database.transaction(() => insertValid(store.database));
      expect((await store.readReadiness()).isReady, isTrue);
      expect(
        await store.database.select(store.database.coreCompanies).get(),
        hasLength(2),
      );
      expect(
        await store.database.select(store.database.coreUsers).get(),
        hasLength(2),
      );
      await store.close();
    },
  );

  test('active owner relationship and credential survive restart', () async {
    final store = await DriftCoreInstallationStore.open(databasePath);
    await store.database.transaction(() => insertValid(store.database));
    expect((await store.readReadiness()).isReady, isTrue);
    await store.close();
    final reopened = await DriftCoreInstallationStore.open(databasePath);
    expect((await reopened.readReadiness()).isReady, isTrue);
    await reopened.close();
  });

  test('disconnected rows and inactive membership remain partial', () async {
    final store = await DriftCoreInstallationStore.open(databasePath);
    final db = store.database;
    await db
        .into(db.coreCompanies)
        .insert(
          CoreCompaniesCompanion.insert(
            id: 'company-1',
            code: Value('C1'),
            name: Value('Example'),
            status: Value('active'),
          ),
        );
    await db
        .into(db.coreUsers)
        .insert(
          CoreUsersCompanion.insert(
            id: 'user-1',
            email: Value('owner@example.test'),
            name: Value('Owner'),
            status: Value('active'),
          ),
        );
    expect((await store.readReadiness()).isReady, isFalse);
    await db
        .into(db.coreCompanyMemberships)
        .insert(
          CoreCompanyMembershipsCompanion.insert(
            id: 'membership-1',
            userId: 'user-1',
            companyId: 'company-1',
            role: 'owner',
            status: 'revoked',
          ),
        );
    expect((await store.readReadiness()).isReady, isFalse);
    await store.close();
  });

  test(
    'unique company code, user email, membership pair and foreign keys',
    () async {
      final store = await DriftCoreInstallationStore.open(databasePath);
      final db = store.database;
      await insertValid(db);
      await expectLater(
        db
            .into(db.coreCompanies)
            .insert(
              CoreCompaniesCompanion.insert(id: 'company-2', code: Value('C1')),
            ),
        throwsA(isA<Exception>()),
      );
      await expectLater(
        db
            .into(db.coreUsers)
            .insert(
              CoreUsersCompanion.insert(
                id: 'user-2',
                email: Value('owner@example.test'),
              ),
            ),
        throwsA(isA<Exception>()),
      );
      await expectLater(
        db
            .into(db.coreCompanyMemberships)
            .insert(
              CoreCompanyMembershipsCompanion.insert(
                id: 'membership-2',
                userId: 'user-1',
                companyId: 'company-1',
                role: 'owner',
                status: 'active',
              ),
            ),
        throwsA(isA<Exception>()),
      );
      await expectLater(
        db
            .into(db.coreCompanyMemberships)
            .insert(
              CoreCompanyMembershipsCompanion.insert(
                id: 'membership-3',
                userId: 'missing-user',
                companyId: 'company-1',
                role: 'owner',
                status: 'active',
              ),
            ),
        throwsA(isA<Exception>()),
      );
      await store.close();
    },
  );

  test('Drift transaction rolls back earlier Core writes', () async {
    final store = await DriftCoreInstallationStore.open(databasePath);
    final db = store.database;
    await expectLater(
      db.transaction(() async {
        await db
            .into(db.coreCompanies)
            .insert(CoreCompaniesCompanion.insert(id: 'company-1'));
        await db
            .into(db.coreUsers)
            .insert(CoreUsersCompanion.insert(id: 'user-1'));
        await db
            .into(db.coreCompanyMemberships)
            .insert(
              CoreCompanyMembershipsCompanion.insert(
                id: 'membership-1',
                userId: 'missing-user',
                companyId: 'company-1',
                role: 'owner',
                status: 'active',
              ),
            );
      }),
      throwsA(isA<Exception>()),
    );
    expect(await db.select(db.coreCompanies).get(), isEmpty);
    expect(await db.select(db.coreUsers).get(), isEmpty);
    expect(
      (await store.readReadiness()).state,
      NexaBizSetupState.uninitialized,
    );
    await store.close();
  });

  test('bootstrap reads migrated readiness', () async {
    createV1(company: true, user: true);
    final result = await AppBootstrap.initialize(databasePath: databasePath);
    expect(result.coreReadiness.isReady, isFalse);
    result.router.dispose();
    await result.coreInstallationStore.close();
  });

  test('newer schema and unreadable path fail, not fresh', () async {
    final db = raw.sqlite3.open(databasePath);
    db.execute('PRAGMA user_version = 999');
    db.close();
    await expectLater(
      DriftCoreInstallationStore.open(databasePath),
      throwsA(isA<StateError>()),
    );
    await expectLater(
      DriftCoreInstallationStore.open(directory.path),
      throwsA(isA<Exception>()),
    );
  });

  test('missing Core table is corruption, not fresh', () async {
    final store = await DriftCoreInstallationStore.open(databasePath);
    await store.close();
    final db = raw.sqlite3.open(databasePath);
    db.execute('DROP TABLE core_users');
    db.close();
    await expectLater(
      DriftCoreInstallationStore.open(databasePath),
      throwsA(isA<Exception>()),
    );
  });
}
