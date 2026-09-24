import 'dart:async';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:nexabiz/app/persistence/drift_core_installation_store.dart';
import 'package:nexabiz/core/identity/authenticate_local_user.dart';
import 'package:nexabiz/core/session/core_session_controller.dart';
import 'package:nexabiz/core/session/nexabiz_session.dart';
import 'package:nexabiz/core/setup/initialize_nexabiz_core.dart';
import 'package:path/path.dart' as p;

void main() {
  group('CoreSessionController Unit & Invariant Tests', () {
    late Directory tempDir;
    late DriftCoreInstallationStore store;
    late AuthenticateLocalUser authenticate;
    late CoreSessionController controller;

    setUp(() async {
      tempDir = Directory.systemTemp.createTempSync('nexabiz_session_test_');
      final dbPath = p.join(tempDir.path, 'nexabiz.sqlite');
      store = await DriftCoreInstallationStore.open(dbPath);
      authenticate = AuthenticateLocalUser(queryStore: store);
      controller = CoreSessionController(
        authenticateLocalUser: authenticate,
        queryStore: store,
      );
    });

    tearDown(() async {
      await controller.dispose();
      await store.close();
      if (tempDir.existsSync()) {
        tempDir.deleteSync(recursive: true);
      }
    });

    Future<void> loginEligibleUser() async {
      await InitializeNexaBizCore(store)(
        const CoreInitializationInput(
          companyCode: 'ALPHA',
          companyName: 'Alpha Corp',
          adminName: 'Alice Admin',
          adminEmail: 'alice@alpha.com',
          password: 'password12345',
        ),
      );
      expect(
        (await controller.login(
          const CoreAuthenticationInput(
            identifier: 'alice@alpha.com',
            password: 'password12345',
          ),
        )).isSuccess,
        isTrue,
      );
      expect(controller.currentSession.isActive, isTrue);
    }

    Future<void> addBackupOwner() async {
      final db = store.database;
      await db.customStatement('''
        INSERT INTO core_users (id, email, name, status)
        VALUES ('backup-owner-user', 'backup-owner@alpha.com', 'Backup Owner', 'active')
      ''');
      await db.customStatement('''
        INSERT INTO core_company_memberships
          (id, user_id, company_id, role, status)
        SELECT 'backup-owner-membership', 'backup-owner-user', id, 'owner', 'active'
        FROM core_companies WHERE code = 'ALPHA'
      ''');
      await db.customStatement('''
        INSERT INTO core_membership_roles (membership_id, role_id, created_at)
        SELECT 'backup-owner-membership', id, 0
        FROM core_roles
        WHERE company_id = (SELECT id FROM core_companies WHERE code = 'ALPHA')
          AND role_key = 'company.owner'
      ''');
    }

    for (final table in [
      'core_users',
      'core_company_memberships',
      'core_companies',
    ]) {
      test('validation invalidates session after disabling $table', () async {
        await loginEligibleUser();
        if (table != 'core_companies') {
          await addBackupOwner();
        }
        await store.database.customStatement(
          "UPDATE $table SET status = 'inactive' WHERE id NOT LIKE 'backup-owner-%'",
        );
        expect(await controller.validateSession(), isFalse);
        expect(controller.currentSession.state, NexaBizSessionState.noSession);
        expect(controller.currentSession.userId, isNull);
        expect(controller.currentSession.companyId, isNull);
      });

      test('Drift changes automatically invalidate session for $table', () async {
        await loginEligibleUser();
        if (table != 'core_companies') {
          await addBackupOwner();
        }
        final invalidated = controller.onSessionChanged.firstWhere(
          (session) => !session.isActive,
        );
        final db = store.database;
        await db.customUpdate(
          "UPDATE $table SET status = 'inactive' WHERE id NOT LIKE 'backup-owner-%'",
          updates: {
            if (table == 'core_users') db.coreUsers,
            if (table == 'core_company_memberships') db.coreCompanyMemberships,
            if (table == 'core_companies') db.coreCompanies,
          },
        );
        await invalidated.timeout(const Duration(seconds: 5));
        expect(controller.currentSession.state, NexaBizSessionState.noSession);
      });
    }

    test('eligible session survives validation without replacement', () async {
      await loginEligibleUser();
      final original = controller.currentSession;
      expect(await controller.validateSession(), isTrue);
      expect(controller.currentSession, same(original));
    });

    test(
      'another eligible company does not preserve a revoked scope',
      () async {
        await loginEligibleUser();
        await addBackupOwner();
        final current = controller.currentSession;
        final db = store.database;
        await db.customStatement(
          "INSERT INTO core_companies (id, code, name, status) "
          "VALUES ('other-company', 'OTHER', 'Other Corp', 'active')",
        );
        await db.customStatement(
          "INSERT INTO core_company_memberships "
          "(id, user_id, company_id, role, status) "
          "VALUES ('other-membership', ?, 'other-company', 'owner', 'active')",
          [current.userId!.value],
        );
        await db.customStatement(
          "UPDATE core_company_memberships SET status = 'inactive' "
          "WHERE company_id = ? AND user_id = ?",
          [current.companyId!.value, current.userId!.value],
        );
        expect(
          await store.isSessionEligible(current.userId!.value, null),
          isTrue,
        );
        expect(await controller.validateSession(), isFalse);
        expect(controller.currentSession.isActive, isFalse);
      },
    );

    test('eligibility read failure invalidates the current session', () async {
      await loginEligibleUser();
      await controller.dispose();
      final delayedStore = _DelayedSwitchStore(store, pauseValidation: true);
      controller = CoreSessionController(
        authenticateLocalUser: authenticate,
        queryStore: delayedStore,
      );
      await controller.login(
        const CoreAuthenticationInput(
          identifier: 'alice@alpha.com',
          password: 'password12345',
        ),
      );
      final validation = controller.validateSession();
      await delayedStore.started.future;
      delayedStore.validationResult.completeError(StateError('read failed'));
      expect(await validation, isFalse);
      expect(controller.currentSession.isActive, isFalse);
    });

    test('validation without a session returns false', () async {
      expect(await controller.validateSession(), isFalse);
      expect(controller.currentSession.isActive, isFalse);
    });

    test('stale validation cannot invalidate a newer session', () async {
      await loginEligibleUser();
      await controller.dispose();
      final delayedStore = _DelayedSwitchStore(store, pauseValidation: true);
      controller = CoreSessionController(
        authenticateLocalUser: authenticate,
        queryStore: delayedStore,
      );
      const input = CoreAuthenticationInput(
        identifier: 'alice@alpha.com',
        password: 'password12345',
      );
      await controller.login(input);
      final validation = controller.validateSession();
      await delayedStore.started.future;
      controller.logout();
      await controller.login(input);
      final newerSession = controller.currentSession;
      delayedStore.validationResult.complete(false);
      expect(await validation, isFalse);
      expect(controller.currentSession, same(newerSession));
      expect(controller.currentSession.isActive, isTrue);
    });

    test('initial state is noSession', () {
      expect(controller.currentSession.state, NexaBizSessionState.noSession);
      expect(controller.currentSession.isActive, isFalse);
    });

    test(
      'successful single-company login establishes active company session',
      () async {
        final init = InitializeNexaBizCore(store);
        await init(
          const CoreInitializationInput(
            companyCode: 'ALPHA',
            companyName: 'Alpha Corp',
            adminName: 'Alice Admin',
            adminEmail: 'alice@alpha.com',
            password: 'password12345',
          ),
        );

        final result = await controller.login(
          const CoreAuthenticationInput(
            identifier: 'alice@alpha.com',
            password: 'password12345',
          ),
        );

        expect(result.isSuccess, isTrue);
        expect(controller.currentSession.isActive, isTrue);
        expect(controller.currentSession.companyName, 'Alpha Corp');
        expect(controller.currentSession.companyCode, 'ALPHA');
        expect(controller.currentSession.role, 'owner');
        expect(controller.currentSession.sessionId, isNotNull);
      },
    );

    test(
      'logout invalidates active session and resets state to noSession',
      () async {
        final init = InitializeNexaBizCore(store);
        await init(
          const CoreInitializationInput(
            companyCode: 'ALPHA',
            companyName: 'Alpha Corp',
            adminName: 'Alice Admin',
            adminEmail: 'alice@alpha.com',
            password: 'password12345',
          ),
        );

        await controller.login(
          const CoreAuthenticationInput(
            identifier: 'alice@alpha.com',
            password: 'password12345',
          ),
        );

        expect(controller.currentSession.isActive, isTrue);

        controller.logout();

        expect(controller.currentSession.state, NexaBizSessionState.noSession);
        expect(controller.currentSession.isActive, isFalse);
        expect(controller.currentSession.userId, isNull);
        expect(controller.currentSession.companyId, isNull);
      },
    );

    test('active session A -> failed login -> session A unchanged', () async {
      await InitializeNexaBizCore(store)(
        const CoreInitializationInput(
          companyCode: 'ALPHA',
          companyName: 'Alpha Corp',
          adminName: 'Alice Admin',
          adminEmail: 'alice@alpha.com',
          password: 'password12345',
        ),
      );

      final loginA = await controller.login(
        const CoreAuthenticationInput(
          identifier: 'alice@alpha.com',
          password: 'password12345',
        ),
      );
      expect(loginA.isSuccess, isTrue);
      final sessionA = controller.currentSession;
      expect(sessionA.isActive, isTrue);

      final events = <NexaBizSession>[];
      final subscription = controller.onSessionChanged.listen(events.add);
      addTearDown(subscription.cancel);

      final failedLogin = await controller.login(
        const CoreAuthenticationInput(
          identifier: 'alice@alpha.com',
          password: 'wrong-password',
        ),
      );

      expect(failedLogin.isSuccess, isFalse);
      expect(controller.currentSession, same(sessionA));
      expect(controller.currentSession.isActive, isTrue);
      expect(controller.currentSession.sessionId, sessionA.sessionId);
      await Future<void>.value();
      expect(events, isEmpty);
    });

    test(
      'active session A -> login B pending -> logout -> B completes -> no session',
      () async {
        await InitializeNexaBizCore(store)(
          const CoreInitializationInput(
            companyCode: 'ALPHA',
            companyName: 'Alpha Corp',
            adminName: 'Alice Admin',
            adminEmail: 'alice@alpha.com',
            password: 'password12345',
          ),
        );
        final db = store.database;
        await db.customStatement(
          "INSERT INTO core_users (id, email, name, status) "
          "VALUES ('user-b', 'bob@beta.com', 'Bob', 'active')",
        );
        await db.customStatement(
          "INSERT INTO core_companies (id, code, name, status) "
          "VALUES ('company-b', 'BETA', 'Beta Corp', 'active')",
        );
        await db.customStatement(
          "INSERT INTO core_company_memberships "
          "(id, user_id, company_id, role, status) "
          "VALUES ('membership-b', 'user-b', 'company-b', 'owner', 'active')",
        );
        await db.customStatement(
          "INSERT INTO core_credentials "
          "SELECT 'user-b', kind, algorithm, parameters, salt, verifier, "
          "created_at, updated_at FROM core_credentials LIMIT 1",
        );

        final delayedStore = _DelayedSwitchStore(
          store,
          pauseLoginIdentifier: 'bob@beta.com',
        );
        await controller.dispose();
        controller = CoreSessionController(
          authenticateLocalUser: AuthenticateLocalUser(
            queryStore: delayedStore,
          ),
          queryStore: store,
        );

        final loginA = await controller.login(
          const CoreAuthenticationInput(
            identifier: 'alice@alpha.com',
            password: 'password12345',
          ),
        );
        expect(loginA.isSuccess, isTrue);
        final sessionA = controller.currentSession;
        expect(sessionA.isActive, isTrue);

        final pendingLoginB = controller.login(
          const CoreAuthenticationInput(
            identifier: 'bob@beta.com',
            password: 'password12345',
          ),
        );
        await delayedStore.started.future;

        controller.logout();
        expect(controller.currentSession.isActive, isFalse);
        expect(controller.currentSession.state, NexaBizSessionState.noSession);

        final events = <NexaBizSession>[];
        final subscription = controller.onSessionChanged.listen(events.add);
        addTearDown(subscription.cancel);

        delayedStore.release.complete();
        final resultB = await pendingLoginB;
        expect(resultB.isSuccess, isTrue);

        await Future<void>.value();
        expect(controller.currentSession.isActive, isFalse);
        expect(controller.currentSession.state, NexaBizSessionState.noSession);
        expect(events, isEmpty);
      },
    );

    test(
      'active session A -> login B pending -> login C succeeds -> B completes -> C unchanged',
      () async {
        await InitializeNexaBizCore(store)(
          const CoreInitializationInput(
            companyCode: 'ALPHA',
            companyName: 'Alpha Corp',
            adminName: 'Alice Admin',
            adminEmail: 'alice@alpha.com',
            password: 'password12345',
          ),
        );
        final db = store.database;
        await db.customStatement(
          "INSERT INTO core_users (id, email, name, status) "
          "VALUES ('user-b', 'bob@beta.com', 'Bob', 'active')",
        );
        await db.customStatement(
          "INSERT INTO core_companies (id, code, name, status) "
          "VALUES ('company-b', 'BETA', 'Beta Corp', 'active')",
        );
        await db.customStatement(
          "INSERT INTO core_company_memberships "
          "(id, user_id, company_id, role, status) "
          "VALUES ('membership-b', 'user-b', 'company-b', 'owner', 'active')",
        );
        await db.customStatement(
          "INSERT INTO core_credentials "
          "SELECT 'user-b', kind, algorithm, parameters, salt, verifier, "
          "created_at, updated_at FROM core_credentials LIMIT 1",
        );

        await db.customStatement(
          "INSERT INTO core_users (id, email, name, status) "
          "VALUES ('user-c', 'charlie@gamma.com', 'Charlie', 'active')",
        );
        await db.customStatement(
          "INSERT INTO core_companies (id, code, name, status) "
          "VALUES ('company-c', 'GAMMA', 'Gamma Corp', 'active')",
        );
        await db.customStatement(
          "INSERT INTO core_company_memberships "
          "(id, user_id, company_id, role, status) "
          "VALUES ('membership-c', 'user-c', 'company-c', 'owner', 'active')",
        );
        await db.customStatement(
          "INSERT INTO core_credentials "
          "SELECT 'user-c', kind, algorithm, parameters, salt, verifier, "
          "created_at, updated_at FROM core_credentials LIMIT 1",
        );

        final delayedStore = _DelayedSwitchStore(
          store,
          pauseLoginIdentifier: 'bob@beta.com',
        );
        await controller.dispose();
        controller = CoreSessionController(
          authenticateLocalUser: AuthenticateLocalUser(
            queryStore: delayedStore,
          ),
          queryStore: store,
        );

        final loginA = await controller.login(
          const CoreAuthenticationInput(
            identifier: 'alice@alpha.com',
            password: 'password12345',
          ),
        );
        expect(loginA.isSuccess, isTrue);

        final pendingLoginB = controller.login(
          const CoreAuthenticationInput(
            identifier: 'bob@beta.com',
            password: 'password12345',
          ),
        );
        await delayedStore.started.future;

        final loginC = await controller.login(
          const CoreAuthenticationInput(
            identifier: 'charlie@gamma.com',
            password: 'password12345',
          ),
        );
        expect(loginC.isSuccess, isTrue);
        final sessionC = controller.currentSession;
        expect(sessionC.userId!.value, 'user-c');
        expect(sessionC.companyId!.value, 'company-c');

        final events = <NexaBizSession>[];
        final subscription = controller.onSessionChanged.listen(events.add);
        addTearDown(subscription.cancel);

        delayedStore.release.complete();
        final resultB = await pendingLoginB;
        expect(resultB.isSuccess, isTrue);

        await Future<void>.value();
        expect(controller.currentSession, same(sessionC));
        expect(controller.currentSession.userId!.value, 'user-c');
        expect(controller.currentSession.companyId!.value, 'company-c');
        expect(events, isEmpty);
      },
    );

    test('no session -> failed login -> remains noSession', () async {
      await InitializeNexaBizCore(store)(
        const CoreInitializationInput(
          companyCode: 'ALPHA',
          companyName: 'Alpha Corp',
          adminName: 'Alice Admin',
          adminEmail: 'alice@alpha.com',
          password: 'password12345',
        ),
      );

      expect(controller.currentSession.state, NexaBizSessionState.noSession);
      expect(controller.currentSession.isActive, isFalse);

      final events = <NexaBizSession>[];
      final subscription = controller.onSessionChanged.listen(events.add);
      addTearDown(subscription.cancel);

      final failedLogin = await controller.login(
        const CoreAuthenticationInput(
          identifier: 'alice@alpha.com',
          password: 'wrong-password',
        ),
      );

      expect(failedLogin.isSuccess, isFalse);
      expect(controller.currentSession.state, NexaBizSessionState.noSession);
      expect(controller.currentSession.isActive, isFalse);
      await Future<void>.value();
      expect(events, isEmpty);
    });

    test(
      'company switch terminates old session context and establishes new context',
      () async {
        final init = InitializeNexaBizCore(store);
        await init(
          const CoreInitializationInput(
            companyCode: 'ALPHA',
            companyName: 'Alpha Corp',
            adminName: 'Alice Admin',
            adminEmail: 'alice@alpha.com',
            password: 'password12345',
          ),
        );

        final db = store.database;
        final alphaRow = await db
            .customSelect("SELECT id FROM core_companies WHERE code = 'ALPHA'")
            .getSingle();
        final alphaCompanyId = alphaRow.read<String>('id');

        const secondCompanyId = 'comp-beta-777';
        const secondMembershipId = 'mem-beta-888';
        final now = DateTime.now().toUtc();

        await db.customStatement(
          "INSERT INTO core_companies (id, code, name, status, created_at, updated_at) VALUES ('$secondCompanyId', 'BETA', 'Beta LLC', 'active', '${now.toIso8601String()}', '${now.toIso8601String()}')",
        );

        final userRow = await db
            .customSelect(
              "SELECT id FROM core_users WHERE email = 'alice@alpha.com'",
            )
            .getSingle();
        final userId = userRow.read<String>('id');

        await db.customStatement(
          "INSERT INTO core_company_memberships (id, user_id, company_id, role, status, created_at, updated_at) VALUES ('$secondMembershipId', '$userId', '$secondCompanyId', 'admin', 'active', '${now.toIso8601String()}', '${now.toIso8601String()}')",
        );

        // Login specifically with ALPHA company selected initially
        await controller.login(
          CoreAuthenticationInput(
            identifier: 'alice@alpha.com',
            password: 'password12345',
            companyId: alphaCompanyId,
          ),
        );

        final oldSessionId = controller.currentSession.sessionId;
        expect(controller.currentSession.companyCode, 'ALPHA');

        // Switch to Beta
        final switched = await controller.selectOrSwitchCompany(
          secondCompanyId,
        );

        expect(switched, isTrue);
        expect(controller.currentSession.companyCode, 'BETA');
        expect(controller.currentSession.companyName, 'Beta LLC');
        expect(controller.currentSession.role, 'admin');
        expect(controller.currentSession.sessionId, isNot(oldSessionId));
      },
    );

    for (final loginB in [false, true]) {
      for (final validPassword in [true, false]) {
        test(
          'pending login ${validPassword ? 'success' : 'failure'} after logout '
          '${loginB ? 'preserves session B' : 'keeps no session'}',
          () async {
            await InitializeNexaBizCore(store)(
              const CoreInitializationInput(
                companyCode: 'ALPHA',
                companyName: 'Alpha Corp',
                adminName: 'Alice Admin',
                adminEmail: 'alice@alpha.com',
                password: 'password12345',
              ),
            );
            final db = store.database;
            await db.customStatement(
              "INSERT INTO core_users (id, email, name, status) "
              "VALUES ('user-b', 'bob@beta.com', 'Bob', 'active')",
            );
            await db.customStatement(
              "INSERT INTO core_companies (id, code, name, status) "
              "VALUES ('company-b', 'BETA', 'Beta Corp', 'active')",
            );
            await db.customStatement(
              "INSERT INTO core_company_memberships "
              "(id, user_id, company_id, role, status) "
              "VALUES ('membership-b', 'user-b', 'company-b', 'owner', 'active')",
            );
            await db.customStatement(
              "INSERT INTO core_credentials "
              "SELECT 'user-b', kind, algorithm, parameters, salt, verifier, "
              "created_at, updated_at FROM core_credentials LIMIT 1",
            );
            final delayedStore = _DelayedSwitchStore(
              store,
              pauseLoginIdentifier: 'alice@alpha.com',
            );
            await controller.dispose();
            controller = CoreSessionController(
              authenticateLocalUser: AuthenticateLocalUser(
                queryStore: delayedStore,
              ),
              queryStore: store,
            );
            final pendingLogin = controller.login(
              CoreAuthenticationInput(
                identifier: 'alice@alpha.com',
                password: validPassword ? 'password12345' : 'wrong-password',
              ),
            );
            await delayedStore.started.future;
            controller.logout();
            expect(controller.currentSession.isActive, isFalse);
            if (loginB) {
              final resultB = await controller.login(
                const CoreAuthenticationInput(
                  identifier: 'bob@beta.com',
                  password: 'password12345',
                ),
              );
              expect(resultB.isSuccess, isTrue);
              expect(controller.currentSession.userId!.value, 'user-b');
              expect(controller.currentSession.companyId!.value, 'company-b');
            }
            final expectedSession = controller.currentSession;
            final events = <NexaBizSession>[];
            final subscription = controller.onSessionChanged.listen(events.add);
            addTearDown(subscription.cancel);
            // Drain any notification from B before releasing A.
            await Future<void>.value();
            events.clear();
            delayedStore.release.complete();
            final oldResult = await pendingLogin;
            expect(oldResult.isSuccess, validPassword);
            await Future<void>.value();
            expect(controller.currentSession, same(expectedSession));
            expect(controller.currentSession.isActive, loginB);
            expect(events, isEmpty);
          },
        );
      }
    }

    test(
      'company selection pending -> user becomes inactive -> selection fails -> no active session',
      () async {
        await InitializeNexaBizCore(store)(
          const CoreInitializationInput(
            companyCode: 'ALPHA',
            companyName: 'Alpha Corp',
            adminName: 'Alice Admin',
            adminEmail: 'alice@alpha.com',
            password: 'password12345',
          ),
        );
        final db = store.database;
        await db.customStatement(
          "INSERT INTO core_companies (id, code, name, status) "
          "VALUES ('company-2', 'BETA', 'Beta Corp', 'active')",
        );
        final alice = await store.findUserByIdentifier('alice@alpha.com');
        await db.customStatement(
          "INSERT INTO core_company_memberships "
          "(id, user_id, company_id, role, status) "
          "VALUES ('membership-2', '${alice!.id}', 'company-2', 'member', 'active')",
        );

        final delayedStore = _DelayedSwitchStore(
          store,
          pauseAuthenticationSnapshot: true,
        );
        await controller.dispose();
        controller = CoreSessionController(
          authenticateLocalUser: AuthenticateLocalUser(queryStore: store),
          queryStore: delayedStore,
        );

        final loginResult = await controller.login(
          const CoreAuthenticationInput(
            identifier: 'alice@alpha.com',
            password: 'password12345',
          ),
        );
        expect(loginResult.isSuccess, isTrue);
        expect(loginResult.requiresCompanySelection, isTrue);
        expect(controller.currentSession.isActive, isTrue);
        expect(controller.currentSession.companyId, isNull);

        final pendingSelection = controller.selectOrSwitchCompany('company-2');
        await delayedStore.started.future;

        await addBackupOwner();
        await db.customStatement(
          "UPDATE core_users SET status = 'inactive' WHERE id = '${alice.id}'",
        );

        delayedStore.release.complete();
        final success = await pendingSelection;

        expect(success, isFalse);
        expect(controller.currentSession.isActive, isFalse);
        expect(controller.currentSession.state, NexaBizSessionState.noSession);
      },
    );

    for (final change in ['inactive', 'deleted']) {
      test(
        'company switch pending -> membership becomes $change -> switch fails',
        () async {
          await InitializeNexaBizCore(store)(
            const CoreInitializationInput(
              companyCode: 'ALPHA',
              companyName: 'Alpha Corp',
              adminName: 'Alice Admin',
              adminEmail: 'alice@alpha.com',
              password: 'password12345',
            ),
          );
          final db = store.database;
          await db.customStatement(
            "INSERT INTO core_companies (id, code, name, status) "
            "VALUES ('company-2', 'BETA', 'Beta Corp', 'active')",
          );
          final alice = await store.findUserByIdentifier('alice@alpha.com');
          await db.customStatement(
            "INSERT INTO core_company_memberships "
            "(id, user_id, company_id, role, status) "
            "VALUES ('membership-2', '${alice!.id}', 'company-2', 'member', 'active')",
          );

          final delayedStore = _DelayedSwitchStore(
            store,
            pauseAuthenticationSnapshot: true,
          );
          await controller.dispose();
          controller = CoreSessionController(
            authenticateLocalUser: AuthenticateLocalUser(queryStore: store),
            queryStore: delayedStore,
          );

          final snapshot = await store.readAuthenticationSnapshot(alice.id);
          final alphaCompany = snapshot!.companies.firstWhere(
            (c) => c.code == 'ALPHA',
          );
          final loginResult = await controller.login(
            CoreAuthenticationInput(
              identifier: 'alice@alpha.com',
              password: 'password12345',
              companyId: alphaCompany.id,
            ),
          );
          expect(loginResult.isSuccess, isTrue);
          expect(controller.currentSession.companyCode, 'ALPHA');
          final oldSessionId = controller.currentSession.sessionId;

          final pendingSwitch = controller.selectOrSwitchCompany('company-2');
          await delayedStore.started.future;

          if (change == 'inactive') {
            await db.customStatement(
              "UPDATE core_company_memberships SET status = 'inactive' "
              "WHERE id = 'membership-2'",
            );
          } else {
            await db.customStatement(
              "DELETE FROM core_company_memberships WHERE id = 'membership-2'",
            );
          }

          delayedStore.release.complete();
          final success = await pendingSwitch;

          expect(success, isFalse);
          expect(controller.currentSession.companyCode, 'ALPHA');
          expect(controller.currentSession.sessionId, oldSessionId);
        },
      );
    }

    test(
      'company switch pending -> company becomes inactive -> switch fails',
      () async {
        await InitializeNexaBizCore(store)(
          const CoreInitializationInput(
            companyCode: 'ALPHA',
            companyName: 'Alpha Corp',
            adminName: 'Alice Admin',
            adminEmail: 'alice@alpha.com',
            password: 'password12345',
          ),
        );
        final db = store.database;
        await db.customStatement(
          "INSERT INTO core_companies (id, code, name, status) "
          "VALUES ('company-2', 'BETA', 'Beta Corp', 'active')",
        );
        final alice = await store.findUserByIdentifier('alice@alpha.com');
        await db.customStatement(
          "INSERT INTO core_company_memberships "
          "(id, user_id, company_id, role, status) "
          "VALUES ('membership-2', '${alice!.id}', 'company-2', 'member', 'active')",
        );

        final delayedStore = _DelayedSwitchStore(
          store,
          pauseAuthenticationSnapshot: true,
        );
        await controller.dispose();
        controller = CoreSessionController(
          authenticateLocalUser: AuthenticateLocalUser(queryStore: store),
          queryStore: delayedStore,
        );

        final snapshot = await store.readAuthenticationSnapshot(alice.id);
        final alphaCompany = snapshot!.companies.firstWhere(
          (c) => c.code == 'ALPHA',
        );
        final loginResult = await controller.login(
          CoreAuthenticationInput(
            identifier: 'alice@alpha.com',
            password: 'password12345',
            companyId: alphaCompany.id,
          ),
        );
        expect(loginResult.isSuccess, isTrue);
        expect(controller.currentSession.companyCode, 'ALPHA');
        final oldSessionId = controller.currentSession.sessionId;

        final pendingSwitch = controller.selectOrSwitchCompany('company-2');
        await delayedStore.started.future;

        await db.customStatement(
          "UPDATE core_companies SET status = 'inactive' WHERE id = 'company-2'",
        );

        delayedStore.release.complete();
        final success = await pendingSwitch;

        expect(success, isFalse);
        expect(controller.currentSession.companyCode, 'ALPHA');
        expect(controller.currentSession.sessionId, oldSessionId);
      },
    );

    test(
      'switch A pending -> logout/login B -> old switch completes -> B session unchanged',
      () async {
        await InitializeNexaBizCore(store)(
          const CoreInitializationInput(
            companyCode: 'ALPHA',
            companyName: 'Alpha Corp',
            adminName: 'Alice Admin',
            adminEmail: 'alice@alpha.com',
            password: 'password12345',
          ),
        );
        final db = store.database;
        await db.customStatement(
          "INSERT INTO core_companies (id, code, name, status) "
          "VALUES ('company-2', 'BETA', 'Beta Corp', 'active')",
        );
        final alice = await store.findUserByIdentifier('alice@alpha.com');
        await db.customStatement(
          "INSERT INTO core_company_memberships "
          "(id, user_id, company_id, role, status) "
          "VALUES ('membership-2', '${alice!.id}', 'company-2', 'member', 'active')",
        );

        await db.customStatement(
          "INSERT INTO core_users (id, email, name, status) "
          "VALUES ('user-b', 'bob@beta.com', 'Bob', 'active')",
        );
        await db.customStatement(
          "INSERT INTO core_company_memberships "
          "(id, user_id, company_id, role, status) "
          "VALUES ('membership-b', 'user-b', 'company-2', 'owner', 'active')",
        );
        await db.customStatement(
          "INSERT INTO core_credentials "
          "SELECT 'user-b', kind, algorithm, parameters, salt, verifier, "
          "created_at, updated_at FROM core_credentials LIMIT 1",
        );

        final delayedStore = _DelayedSwitchStore(
          store,
          pauseAuthenticationSnapshot: true,
        );
        await controller.dispose();
        controller = CoreSessionController(
          authenticateLocalUser: AuthenticateLocalUser(queryStore: store),
          queryStore: delayedStore,
        );

        final snapshot = await store.readAuthenticationSnapshot(alice.id);
        final alphaCompany = snapshot!.companies.firstWhere(
          (c) => c.code == 'ALPHA',
        );
        final loginA = await controller.login(
          CoreAuthenticationInput(
            identifier: 'alice@alpha.com',
            password: 'password12345',
            companyId: alphaCompany.id,
          ),
        );
        expect(loginA.isSuccess, isTrue);
        final sessionA = controller.currentSession;

        final pendingSwitchA = controller.selectOrSwitchCompany('company-2');
        await delayedStore.started.future;

        controller.logout();
        final loginB = await controller.login(
          const CoreAuthenticationInput(
            identifier: 'bob@beta.com',
            password: 'password12345',
          ),
        );
        expect(loginB.isSuccess, isTrue);
        final sessionB = controller.currentSession;
        expect(sessionB.userId!.value, 'user-b');
        expect(sessionB.companyId!.value, 'company-2');
        expect(sessionB.sessionId, isNot(sessionA.sessionId));

        delayedStore.release.complete();
        final switchResult = await pendingSwitchA;

        expect(switchResult, isFalse);
        expect(controller.currentSession, same(sessionB));
        expect(controller.currentSession.userId!.value, 'user-b');
        expect(controller.currentSession.companyId!.value, 'company-2');
      },
    );

    test('rejects switching to unauthorized company ID', () async {
      final init = InitializeNexaBizCore(store);
      await init(
        const CoreInitializationInput(
          companyCode: 'ALPHA',
          companyName: 'Alpha Corp',
          adminName: 'Alice Admin',
          adminEmail: 'alice@alpha.com',
          password: 'password12345',
        ),
      );

      await controller.login(
        const CoreAuthenticationInput(
          identifier: 'alice@alpha.com',
          password: 'password12345',
        ),
      );

      final oldSessionId = controller.currentSession.sessionId;

      final switched = await controller.selectOrSwitchCompany(
        'unauthorized-company-xyz',
      );

      expect(switched, isFalse);
      expect(controller.currentSession.companyCode, 'ALPHA');
      expect(controller.currentSession.sessionId, oldSessionId);
    });

    test(
      'login pending -> membership becomes invalid -> login fails -> no active session',
      () async {
        await InitializeNexaBizCore(store)(
          const CoreInitializationInput(
            companyCode: 'ALPHA',
            companyName: 'Alpha Corp',
            adminName: 'Alice Admin',
            adminEmail: 'alice@alpha.com',
            password: 'password12345',
          ),
        );

        final delayedStore = _DelayedSwitchStore(
          store,
          pauseAuthenticationSnapshot: true,
        );
        await controller.dispose();
        controller = CoreSessionController(
          authenticateLocalUser: AuthenticateLocalUser(
            queryStore: delayedStore,
          ),
          queryStore: store,
        );

        final sessions = <NexaBizSession>[];
        final subscription = controller.onSessionChanged.listen(sessions.add);
        addTearDown(subscription.cancel);

        final pendingLogin = controller.login(
          const CoreAuthenticationInput(
            identifier: 'alice@alpha.com',
            password: 'password12345',
          ),
        );

        await delayedStore.started.future;

        await addBackupOwner();
        await store.database.customStatement(
          "UPDATE core_company_memberships SET status = 'inactive' "
          "WHERE id NOT LIKE 'backup-owner-%'",
        );

        delayedStore.release.complete();

        final result = await pendingLogin;

        expect(result.isSuccess, isFalse);
        expect(result.status, CoreAuthenticationStatus.noActiveMemberships);
        expect(result.activeCompany, isNull);
        expect(result.activeMembership, isNull);
        expect(controller.currentSession.isActive, isFalse);
        expect(controller.currentSession.state, NexaBizSessionState.noSession);
        await Future<void>.value();
        expect(sessions.where((session) => session.isActive), isEmpty);
      },
    );

    test(
      'Architecture Contract: login, company selection, and company switching depend strictly on readAuthenticationSnapshot',
      () async {
        await InitializeNexaBizCore(store)(
          const CoreInitializationInput(
            companyCode: 'ALPHA',
            companyName: 'Alpha Corp',
            adminName: 'Alice Admin',
            adminEmail: 'alice@alpha.com',
            password: 'password12345',
          ),
        );
        final db = store.database;
        await db.customStatement(
          "INSERT INTO core_companies (id, code, name, status) "
          "VALUES ('company-2', 'BETA', 'Beta Corp', 'active')",
        );
        final alice = await store.findUserByIdentifier('alice@alpha.com');
        await db.customStatement(
          "INSERT INTO core_company_memberships "
          "(id, user_id, company_id, role, status) "
          "VALUES ('membership-2', '${alice!.id}', 'company-2', 'member', 'active')",
        );

        final trackingStore = _SnapshotOnlyTrackingStore(store);
        final ctrl = CoreSessionController(
          authenticateLocalUser: AuthenticateLocalUser(
            queryStore: trackingStore,
          ),
          queryStore: trackingStore,
        );
        addTearDown(ctrl.dispose);

        final initialSnapshot = await trackingStore.readAuthenticationSnapshot(
          alice.id,
        );
        final alphaCompany = initialSnapshot!.companies.firstWhere(
          (c) => c.code == 'ALPHA',
        );

        // 1. Login with explicit company selection
        final loginResult = await ctrl.login(
          CoreAuthenticationInput(
            identifier: 'alice@alpha.com',
            password: 'password12345',
            companyId: alphaCompany.id,
          ),
        );
        expect(loginResult.isSuccess, isTrue);
        expect(ctrl.currentSession.companyCode, 'ALPHA');
        final readsAfterLogin = trackingStore.snapshotReadCount;
        expect(readsAfterLogin, greaterThanOrEqualTo(1));

        // 2. Company switching
        final switched = await ctrl.selectOrSwitchCompany('company-2');
        expect(switched, isTrue);
        expect(ctrl.currentSession.companyCode, 'BETA');
        expect(trackingStore.snapshotReadCount, greaterThan(readsAfterLogin));
      },
    );
  });
}

/// Pauses real store responses for deterministic login and switch races.
class _DelayedSwitchStore implements CoreIdentityQueryStore {
  _DelayedSwitchStore(
    this.delegate, {
    this.pauseLoginIdentifier,
    this.pauseValidation = false,
    this.pauseAuthenticationSnapshot = false,
  });

  final CoreIdentityQueryStore delegate;
  final String? pauseLoginIdentifier;
  final bool pauseValidation;
  final bool pauseAuthenticationSnapshot;
  final validationResult = Completer<bool>();
  final started = Completer<void>();
  final release = Completer<void>();

  @override
  Future<CoreAuthIdentitySnapshot?> readAuthenticationSnapshot(
    String userId,
  ) async {
    if (pauseAuthenticationSnapshot) {
      if (!started.isCompleted) started.complete();
      await release.future;
    }
    return delegate.readAuthenticationSnapshot(userId);
  }

  @override
  Future<bool> isSessionEligible(String userId, String? companyId) {
    if (pauseValidation) {
      started.complete();
      return validationResult.future;
    }
    return delegate.isSessionEligible(userId, companyId);
  }

  @override
  Stream<bool> watchSessionEligibility(String userId, String? companyId) =>
      delegate.watchSessionEligibility(userId, companyId);

  @override
  Future<CoreAuthUserRef?> findUserByIdentifier(String identifier) async {
    final user = await delegate.findUserByIdentifier(identifier);
    if (identifier == pauseLoginIdentifier) {
      started.complete();
      await release.future;
    }
    return user;
  }

  @override
  Future<CorePreparedCredential?> readUserCredential(String userId) =>
      delegate.readUserCredential(userId);

  @override
  Future<CoreLoginLockout?> checkLockout(
    String normalizedIdentifier,
    DateTime nowUtc,
  ) => delegate.checkLockout(normalizedIdentifier, nowUtc);

  @override
  Future<CoreLoginLockout?> recordFailedAttempt(
    String normalizedIdentifier,
    DateTime nowUtc,
  ) => delegate.recordFailedAttempt(normalizedIdentifier, nowUtc);

  @override
  Future<void> clearFailedAttempts(String normalizedIdentifier) =>
      delegate.clearFailedAttempts(normalizedIdentifier);
}

class _SnapshotOnlyTrackingStore implements CoreIdentityQueryStore {
  _SnapshotOnlyTrackingStore(this.delegate);

  final CoreIdentityQueryStore delegate;
  int snapshotReadCount = 0;

  @override
  Future<CoreAuthIdentitySnapshot?> readAuthenticationSnapshot(String userId) {
    snapshotReadCount++;
    return delegate.readAuthenticationSnapshot(userId);
  }

  @override
  Future<CoreAuthUserRef?> findUserByIdentifier(String identifier) =>
      delegate.findUserByIdentifier(identifier);

  @override
  Future<CorePreparedCredential?> readUserCredential(String userId) =>
      delegate.readUserCredential(userId);

  @override
  Future<CoreLoginLockout?> checkLockout(
    String normalizedIdentifier,
    DateTime nowUtc,
  ) => delegate.checkLockout(normalizedIdentifier, nowUtc);

  @override
  Future<CoreLoginLockout?> recordFailedAttempt(
    String normalizedIdentifier,
    DateTime nowUtc,
  ) => delegate.recordFailedAttempt(normalizedIdentifier, nowUtc);

  @override
  Future<void> clearFailedAttempts(String normalizedIdentifier) =>
      delegate.clearFailedAttempts(normalizedIdentifier);

  @override
  Future<bool> isSessionEligible(String userId, String? companyId) =>
      delegate.isSessionEligible(userId, companyId);

  @override
  Stream<bool> watchSessionEligibility(String userId, String? companyId) =>
      delegate.watchSessionEligibility(userId, companyId);
}
