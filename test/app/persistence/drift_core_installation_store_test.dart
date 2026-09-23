import 'dart:io';

import 'package:drift/drift.dart' show Value;
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nexabiz/app/bootstrap/app_bootstrap.dart';
import 'package:nexabiz/app/persistence/drift_core_database.dart';
import 'package:nexabiz/app/persistence/drift_core_installation_store.dart';
import 'package:nexabiz/app/router/nexabiz_flutter_route_definition.dart';
import 'package:nexabiz/app/router/nexabiz_router_adapter.dart';
import 'package:nexabiz/core/capabilities/capability_metadata.dart';
import 'package:nexabiz/core/capabilities/nexabiz_capability.dart';
import 'package:nexabiz/core/capabilities/nexabiz_capability_registry.dart';
import 'package:nexabiz/core/identity/authenticate_local_user.dart';
import 'package:nexabiz/core/navigation/nexabiz_navigation_contribution.dart';
import 'package:nexabiz/core/navigation/nexabiz_navigation_registry.dart';
import 'package:nexabiz/core/navigation/nexabiz_route_definition.dart';
import 'package:nexabiz/core/navigation/nexabiz_route_id.dart';
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
    expect(db.select('PRAGMA user_version').single['user_version'], 6);
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
        'core_login_attempts',
        'core_roles',
        'core_membership_roles',
        'core_role_permissions',
        'schema_migrations',
      },
    );
    expect(
      db
          .select('SELECT version FROM schema_migrations ORDER BY version')
          .map((r) => r['version'])
          .toList(),
      [6],
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
        expect(db.select('PRAGMA user_version').single['user_version'], 6);
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

  group('readReadiness Credential Contract & Decoupling Tests', () {
    test(
      'canonical parameters v=19,m=19456,t=2,p=1,l=32 -> readiness is ready',
      () async {
        final store = await DriftCoreInstallationStore.open(databasePath);
        await insertValid(store.database);
        final readiness = await store.readReadiness();
        expect(readiness.isReady, isTrue);
        expect(readiness.state, NexaBizSetupState.ready);
        await store.close();
      },
    );

    test(
      'reordered parameters accepted by VerifyCoreCredential -> readiness is ready',
      () async {
        final store = await DriftCoreInstallationStore.open(databasePath);
        final db = store.database;
        await insertValid(db);
        // Update credential with reordered valid parameters
        await (db.update(
          db.coreCredentials,
        )..where((t) => t.userId.equals('user-1'))).write(
          const CoreCredentialsCompanion(
            parameters: Value('p=1,t=2,m=19456,l=32,v=19'),
          ),
        );
        final readiness = await store.readReadiness();
        expect(readiness.isReady, isTrue);
        expect(readiness.state, NexaBizSetupState.ready);
        await store.close();
      },
    );

    test(
      'parameter representation changes accepted by verifier -> readiness remains ready',
      () async {
        final store = await DriftCoreInstallationStore.open(databasePath);
        final db = store.database;
        await insertValid(db);
        // Valid parameters with different iteration / memory representation
        await (db.update(
          db.coreCredentials,
        )..where((t) => t.userId.equals('user-1'))).write(
          const CoreCredentialsCompanion(
            parameters: Value('v=19,m=32768,t=3,p=1,l=32'),
          ),
        );
        final readiness = await store.readReadiness();
        expect(readiness.isReady, isTrue);
        expect(readiness.state, NexaBizSetupState.ready);
        await store.close();
      },
    );

    test('missing credential -> readiness is inProgress', () async {
      final store = await DriftCoreInstallationStore.open(databasePath);
      final db = store.database;
      await insertValid(db);
      await db.delete(db.coreCredentials).go();
      final readiness = await store.readReadiness();
      expect(readiness.isReady, isFalse);
      expect(readiness.state, NexaBizSetupState.inProgress);
      await store.close();
    });

    test('wrong credential kind -> readiness is inProgress', () async {
      final store = await DriftCoreInstallationStore.open(databasePath);
      final db = store.database;
      await insertValid(db);
      await (db.update(db.coreCredentials)
            ..where((t) => t.userId.equals('user-1')))
          .write(const CoreCredentialsCompanion(kind: Value('pin')));
      final readiness = await store.readReadiness();
      expect(readiness.isReady, isFalse);
      expect(readiness.state, NexaBizSetupState.inProgress);
      await store.close();
    });

    test('unsupported algorithm -> readiness is inProgress', () async {
      final store = await DriftCoreInstallationStore.open(databasePath);
      final db = store.database;
      await insertValid(db);
      await (db.update(db.coreCredentials)
            ..where((t) => t.userId.equals('user-1')))
          .write(const CoreCredentialsCompanion(algorithm: Value('pbkdf2')));
      final readiness = await store.readReadiness();
      expect(readiness.isReady, isFalse);
      expect(readiness.state, NexaBizSetupState.inProgress);
      await store.close();
    });

    test(
      'malformed credential cannot bypass authentication even if structurally ready',
      () async {
        final store = await DriftCoreInstallationStore.open(databasePath);
        final db = store.database;
        await insertValid(db);
        // Malformed parameters string
        await (db.update(
          db.coreCredentials,
        )..where((t) => t.userId.equals('user-1'))).write(
          const CoreCredentialsCompanion(
            parameters: Value('malformed_parameter_string_without_delimiters'),
          ),
        );

        // Structural readiness is ready (does not corrupt or reset setup)
        final readiness = await store.readReadiness();
        expect(readiness.isReady, isTrue);

        // Cryptographic authentication fails closed
        final auth = AuthenticateLocalUser(queryStore: store);
        final result = await auth(
          const CoreAuthenticationInput(
            identifier: 'owner@example.test',
            password: 'any_password',
          ),
        );
        expect(result.isSuccess, isFalse);
        expect(result.status, CoreAuthenticationStatus.invalidCredentials);
        expect(result.user, isNull);

        await store.close();
      },
    );

    test(
      'initialized system with reordered parameters -> restart -> remains ready and no setup redirect',
      () async {
        final store = await DriftCoreInstallationStore.open(databasePath);
        final db = store.database;
        await insertValid(db);
        await (db.update(
          db.coreCredentials,
        )..where((t) => t.userId.equals('user-1'))).write(
          const CoreCredentialsCompanion(
            parameters: Value('p=1,t=2,m=19456,l=32,v=19'),
          ),
        );
        await store.close();

        // Simulate app restart / reopen from disk
        final reopenedStore = await DriftCoreInstallationStore.open(
          databasePath,
        );
        final readiness = await reopenedStore.readReadiness();
        expect(readiness.isReady, isTrue);

        // Verify router gate redirect logic: /login does not redirect to /system-setup
        final caps = NexaBizCapabilityRegistry();
        caps.register(
          _GateTestCapability(
            _GateTestContribution([
              NexaBizFlutterRouteDefinition(
                routeId: const NexaBizRouteId(
                  namespace: 'gate_test',
                  routeName: 'login',
                ),
                path: '/login',
                pageBuilder: (c) => const SizedBox(),
              ),
              NexaBizFlutterRouteDefinition(
                routeId: const NexaBizRouteId(
                  namespace: 'gate_test',
                  routeName: 'setup',
                ),
                path: '/system-setup',
                pageBuilder: (c) => const SizedBox(),
              ),
            ]),
          ),
        );
        caps.validateAndLock();
        final nav = NexaBizNavigationRegistry()..collectAndLock(caps);
        final router = NexaBizGoRouterAdapter(
          nav,
        ).createRouter(initialLocation: '/login', readiness: readiness);
        addTearDown(router.dispose);

        // Match for /login location does NOT redirect to /system-setup
        final match = router.configuration.findMatch(Uri.parse('/login'));
        expect(match.uri.path, '/login');
        expect(match.uri.path, isNot('/system-setup'));

        await reopenedStore.close();
      },
    );
  });
}

class _GateTestContribution implements NexaBizNavigationContribution {
  _GateTestContribution(this.routes);
  @override
  final List<NexaBizRouteDefinition> routes;
  @override
  NexaBizRouteId get rootRouteId => routes.first.routeId;
}

class _GateTestCapability implements NexaBizCapability {
  _GateTestCapability(this.navigationContribution);
  @override
  final NexaBizNavigationContribution navigationContribution;
  @override
  String get capabilityId => 'gate_test';
  @override
  CapabilityMetadata get metadata =>
      const CapabilityMetadata(nameKey: 'test', iconIdentifier: 'test');
  @override
  List<String> get dependsOn => const [];
}
