import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:nexabiz/app/persistence/drift_core_installation_store.dart';
import 'package:nexabiz/core/setup/initialize_nexabiz_core.dart';
import 'package:nexabiz/core/setup/nexabiz_setup_readiness.dart';
import 'package:path/path.dart' as p;
import 'package:sqlite3/sqlite3.dart' as raw;

void main() {
  late Directory directory;
  late String databasePath;
  setUp(() {
    directory = Directory.systemTemp.createTempSync('nexabiz_core_init_');
    databasePath = p.join(directory.path, 'core.sqlite');
  });
  tearDown(() => directory.deleteSync(recursive: true));

  const input = CoreInitializationInput(
    companyCode: 'ACME',
    companyName: 'Acme Company',
    adminName: 'Owner Name',
    adminEmail: 'OWNER@EXAMPLE.COM',
    password: 'correct horse battery staple',
  );

  test('legacy tenant/admin transaction becomes four linked Core rows', () async {
    final store = await DriftCoreInstallationStore.open(databasePath);
    expect(store.readiness.value.state, NexaBizSetupState.uninitialized);
    final notifications = <NexaBizSetupState>[];
    store.readiness.addListener(
      () => notifications.add(store.readiness.value.state),
    );
    expect((await InitializeNexaBizCore(store)(input)).isReady, isTrue);
    expect(store.readiness.value.isReady, isTrue);
    expect(notifications, [NexaBizSetupState.ready]);
    final db = store.database;
    final companies = await db.select(db.coreCompanies).get();
    final users = await db.select(db.coreUsers).get();
    final memberships = await db.select(db.coreCompanyMemberships).get();
    final credentials = await db.select(db.coreCredentials).get();
    expect(companies, hasLength(1));
    expect(users, hasLength(1));
    expect(memberships, hasLength(1));
    expect(credentials, hasLength(1));
    expect(companies.single.code, 'ACME');
    expect(companies.single.status, 'active');
    expect(users.single.email, 'owner@example.com');
    expect(users.single.status, 'active');
    expect(memberships.single.companyId, companies.single.id);
    expect(memberships.single.userId, users.single.id);
    expect(memberships.single.role, 'owner');
    expect(memberships.single.status, 'active');
    expect(credentials.single.userId, users.single.id);
    expect(credentials.single.kind, 'password');
    expect(credentials.single.algorithm, 'argon2id');
    expect(credentials.single.parameters, 'v=19,m=19456,t=2,p=1,l=32');
    expect(credentials.single.salt, isNotEmpty);
    expect(credentials.single.verifier, isNotEmpty);
    expect(credentials.single.verifier, isNot(input.password));
    expect(credentials.single.toString(), isNot(contains(input.password)));
    for (final id in [
      companies.single.id,
      users.single.id,
      memberships.single.id,
    ]) {
      expect(
        id,
        matches(
          RegExp(
            r'^[0-9a-f]{8}-[0-9a-f]{4}-7[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$',
          ),
        ),
      );
    }
    expect(companies.single.createdAt, isNotNull);
    expect(users.single.createdAt, isNotNull);
    expect(memberships.single.createdAt, isNotNull);
    await store.close();
    final reopened = await DriftCoreInstallationStore.open(databasePath);
    expect((await reopened.readReadiness()).isReady, isTrue);
    expect(reopened.readiness.value.isReady, isTrue);
    expect(
      await reopened.database.select(reopened.database.coreCredentials).get(),
      hasLength(1),
    );
    await reopened.close();
    final physical = raw.sqlite3.open(databasePath);
    final credential = physical.select('SELECT * FROM core_credentials').single;
    expect(credential.values.join('|'), isNot(contains(input.password)));
    physical.close();
  });

  test('second initialization reports duplicate and adds no rows', () async {
    final store = await DriftCoreInstallationStore.open(databasePath);
    final initialize = InitializeNexaBizCore(store);
    await initialize(input);
    await expectLater(
      initialize(input),
      throwsA(
        isA<CoreInitializationException>().having(
          (e) => e.failure,
          'failure',
          CoreInitializationFailure.alreadyInitialized,
        ),
      ),
    );
    final db = store.database;
    expect(await db.select(db.coreCompanies).get(), hasLength(1));
    expect(await db.select(db.coreUsers).get(), hasLength(1));
    expect(await db.select(db.coreCompanyMemberships).get(), hasLength(1));
    expect(await db.select(db.coreCredentials).get(), hasLength(1));
    await store.close();
  });

  test('credential write failure rolls back company and user', () async {
    final store = await DriftCoreInstallationStore.open(databasePath);
    var notifications = 0;
    store.readiness.addListener(() => notifications++);
    await store.database.customStatement('''
      CREATE TRIGGER fail_credential BEFORE INSERT ON core_credentials
      BEGIN SELECT RAISE(FAIL, 'injected failure'); END
    ''');
    await expectLater(
      InitializeNexaBizCore(store)(input),
      throwsA(
        isA<CoreInitializationException>().having(
          (e) => e.failure,
          'failure',
          CoreInitializationFailure.storageFailure,
        ),
      ),
    );
    final db = store.database;
    expect(store.readiness.value.state, NexaBizSetupState.uninitialized);
    expect(notifications, 0);
    expect(await db.select(db.coreCompanies).get(), isEmpty);
    expect(await db.select(db.coreUsers).get(), isEmpty);
    expect(await db.select(db.coreCompanyMemberships).get(), isEmpty);
    expect(await db.select(db.coreCredentials).get(), isEmpty);
    expect(
      (await store.readReadiness()).state,
      NexaBizSetupState.uninitialized,
    );
    await store.close();
  });

  test(
    'partial migrated state requires recovery and is not attached to new records',
    () async {
      final store = await DriftCoreInstallationStore.open(databasePath);
      await store.database.customStatement(
        "INSERT INTO core_companies (id) VALUES ('historical-company')",
      );
      await expectLater(
        InitializeNexaBizCore(store)(input),
        throwsA(
          isA<CoreInitializationException>().having(
            (e) => e.failure,
            'failure',
            CoreInitializationFailure.recoveryRequired,
          ),
        ),
      );
      expect(
        await store.database.select(store.database.coreCompanies).get(),
        hasLength(1),
      );
      expect(
        await store.database.select(store.database.coreUsers).get(),
        isEmpty,
      );
      expect(
        await store.database.select(store.database.coreCredentials).get(),
        isEmpty,
      );
      await store.close();
    },
  );

  test('v2 data migrates to v3 without fabricating credentials', () async {
    final db = raw.sqlite3.open(databasePath);
    db.execute(
      'CREATE TABLE core_companies (id TEXT PRIMARY KEY, code TEXT UNIQUE, name TEXT, status TEXT, created_at INTEGER, updated_at INTEGER)',
    );
    db.execute(
      'CREATE TABLE core_users (id TEXT PRIMARY KEY, email TEXT UNIQUE, name TEXT, status TEXT, created_at INTEGER, updated_at INTEGER)',
    );
    db.execute(
      'CREATE TABLE core_company_memberships (id TEXT PRIMARY KEY, user_id TEXT NOT NULL REFERENCES core_users(id), company_id TEXT NOT NULL REFERENCES core_companies(id), role TEXT NOT NULL, status TEXT NOT NULL, created_at INTEGER, updated_at INTEGER, UNIQUE(company_id,user_id))',
    );
    db.execute(
      'CREATE TABLE schema_migrations (owner TEXT NOT NULL, version INTEGER NOT NULL, PRIMARY KEY(owner,version))',
    );
    db.execute("INSERT INTO schema_migrations VALUES ('core',2)");
    db.execute(
      "INSERT INTO core_companies (id,code,name,status) VALUES ('c','C','Company','active')",
    );
    db.execute(
      "INSERT INTO core_users (id,email,name,status) VALUES ('u','u@example.com','Owner','active')",
    );
    db.execute(
      "INSERT INTO core_company_memberships (id,user_id,company_id,role,status) VALUES ('m','u','c','owner','active')",
    );
    db.execute('PRAGMA user_version = 2');
    db.close();
    final store = await DriftCoreInstallationStore.open(databasePath);
    expect((await store.readReadiness()).state, NexaBizSetupState.inProgress);
    expect(
      await store.database.select(store.database.coreCompanies).get(),
      hasLength(1),
    );
    expect(
      await store.database.select(store.database.coreUsers).get(),
      hasLength(1),
    );
    expect(
      await store.database.select(store.database.coreCompanyMemberships).get(),
      hasLength(1),
    );
    expect(
      await store.database.select(store.database.coreCredentials).get(),
      isEmpty,
    );
    await store.close();
    final migrated = raw.sqlite3.open(databasePath);
    expect(migrated.select('PRAGMA user_version').single['user_version'], 6);
    migrated.close();
  });

  test('credential foreign key and unique password kind are enforced', () async {
    final store = await DriftCoreInstallationStore.open(databasePath);
    final db = store.database;
    await expectLater(
      db.customStatement(
        "INSERT INTO core_credentials (user_id,kind,algorithm,parameters,salt,verifier,created_at,updated_at) VALUES ('missing','password','argon2id','p','s','v',0,0)",
      ),
      throwsA(isA<Exception>()),
    );
    await InitializeNexaBizCore(store)(input);
    final user = (await db.select(db.coreUsers).get()).single;
    await expectLater(
      db.customStatement(
        "INSERT INTO core_credentials (user_id,kind,algorithm,parameters,salt,verifier,created_at,updated_at) VALUES (?, 'password','argon2id','p','s','v',0,0)",
        [user.id],
      ),
      throwsA(isA<Exception>()),
    );
    await store.close();
  });

  test(
    'different installations use different salts for the same password',
    () async {
      final first = await DriftCoreInstallationStore.open(databasePath);
      await InitializeNexaBizCore(first)(input);
      final salt1 =
          (await first.database.select(first.database.coreCredentials).get())
              .single
              .salt;
      await first.close();
      final secondPath = p.join(directory.path, 'second.sqlite');
      final second = await DriftCoreInstallationStore.open(secondPath);
      await InitializeNexaBizCore(second)(input);
      final salt2 =
          (await second.database.select(second.database.coreCredentials).get())
              .single
              .salt;
      expect(salt2, isNot(salt1));
      await second.close();
    },
  );

  test('invalid input is rejected before any write', () async {
    final store = await DriftCoreInstallationStore.open(databasePath);
    await expectLater(
      InitializeNexaBizCore(store)(
        const CoreInitializationInput(
          companyCode: '',
          companyName: 'Example',
          adminName: 'Owner',
          adminEmail: 'bad-email',
          password: 'short',
        ),
      ),
      throwsA(
        isA<CoreInitializationException>().having(
          (e) => e.failure,
          'failure',
          CoreInitializationFailure.invalidInput,
        ),
      ),
    );
    expect(
      (await store.readReadiness()).state,
      NexaBizSetupState.uninitialized,
    );
    await store.close();
  });
}
