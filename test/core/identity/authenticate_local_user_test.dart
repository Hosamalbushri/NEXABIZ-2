import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:cryptography/cryptography.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nexabiz/app/persistence/drift_core_installation_store.dart';
import 'package:nexabiz/core/identity/authenticate_local_user.dart';
import 'package:nexabiz/core/identity/verify_core_credential.dart';
import 'package:nexabiz/core/session/core_session_controller.dart';
import 'package:nexabiz/core/session/nexabiz_session.dart';
import 'package:nexabiz/core/setup/initialize_nexabiz_core.dart';
import 'package:nexabiz/core/setup/nexabiz_core_installation_store.dart';
import 'package:nexabiz/core/setup/nexabiz_setup_readiness.dart';
import 'package:path/path.dart' as p;

void main() {
  group('VerifyCoreCredential Unit Tests', () {
    const verifier = VerifyCoreCredential();

    CorePreparedCredential copyCredential(
      CorePreparedCredential base, {
      String? algorithm,
      String? parameters,
      String? salt,
      String? verifier,
    }) {
      return CorePreparedCredential(
        algorithm: algorithm ?? base.algorithm,
        parameters: parameters ?? base.parameters,
        salt: salt ?? base.salt,
        verifier: verifier ?? base.verifier,
      );
    }

    test('verifies correct password against prepared credential', () async {
      final records = await InitializeNexaBizCore(
        _DummyStore(),
      ).prepareForTest('secret_pass_123');

      final result = await verifier(
        candidatePassword: 'secret_pass_123',
        storedCredential: records.credential,
      );
      expect(result, isTrue);
    });

    test('rejects incorrect password against prepared credential', () async {
      final records = await InitializeNexaBizCore(
        _DummyStore(),
      ).prepareForTest('secret_pass_123');

      final result = await verifier(
        candidatePassword: 'wrong_password_99',
        storedCredential: records.credential,
      );
      expect(result, isFalse);
    });

    test('rejects unsupported algorithm', () async {
      final records = await InitializeNexaBizCore(
        _DummyStore(),
      ).prepareForTest('secret_pass_123');

      final result = await verifier(
        candidatePassword: 'secret_pass_123',
        storedCredential: copyCredential(
          records.credential,
          algorithm: 'pbkdf2-sha256',
        ),
      );
      expect(result, isFalse);
    });

    test('rejects unsupported version', () async {
      final records = await InitializeNexaBizCore(
        _DummyStore(),
      ).prepareForTest('secret_pass_123');

      for (final v in ['v=16', 'v=0', 'v=20']) {
        final result = await verifier(
          candidatePassword: 'secret_pass_123',
          storedCredential: copyCredential(
            records.credential,
            parameters: '$v,m=19456,t=2,p=1,l=32',
          ),
        );
        expect(result, isFalse);
      }
    });

    test(
      'rejects missing, duplicate, unknown, or malformed parameters',
      () async {
        final records = await InitializeNexaBizCore(
          _DummyStore(),
        ).prepareForTest('secret_pass_123');

        final badParameters = [
          'v=19,m=19456,t=2,p=1', // missing 'l'
          'm=19456,t=2,p=1,l=32', // missing 'v'
          'v=19,m=19456,t=2,p=1,l=32,v=19', // duplicate 'v'
          'v=19,m=19456,t=2,p=1,l=32,m=19456', // duplicate 'm'
          'v=19,m=19456,t=2,p=1,l=32,unknown=1', // unknown key
          'v=19,,m=19456,t=2,p=1,l=32', // empty segment
          'v=19,m=19456,t=2,p=1,l=32,', // trailing comma
          'not_a_valid_param_string', // malformed
          '', // empty
        ];

        for (final params in badParameters) {
          final result = await verifier(
            candidatePassword: 'secret_pass_123',
            storedCredential: copyCredential(
              records.credential,
              parameters: params,
            ),
          );
          expect(result, isFalse, reason: 'Should reject parameters: $params');
        }
      },
    );

    test('rejects zero, negative, or excessive resource parameters', () async {
      final records = await InitializeNexaBizCore(
        _DummyStore(),
      ).prepareForTest('secret_pass_123');

      final outOfBoundsParameters = [
        'v=19,m=0,t=2,p=1,l=32', // zero memory
        'v=19,m=100,t=2,p=1,l=32', // memory < minMemory (1024)
        'v=19,m=9999999,t=2,p=1,l=32', // memory > maxMemory
        'v=19,m=19456,t=0,p=1,l=32', // zero iterations
        'v=19,m=19456,t=-2,p=1,l=32', // negative iterations
        'v=19,m=19456,t=100,p=1,l=32', // excessive iterations
        'v=19,m=19456,t=2,p=0,l=32', // zero parallelism
        'v=19,m=19456,t=2,p=-1,l=32', // negative parallelism
        'v=19,m=19456,t=2,p=32,l=32', // excessive parallelism
        'v=19,m=19456,t=2,p=1,l=8', // hash length < minHashLength (16)
        'v=19,m=19456,t=2,p=1,l=256', // hash length > maxHashLength (64)
        'v=19,m=-19456,t=2,p=1,l=32', // negative memory
      ];

      for (final params in outOfBoundsParameters) {
        final result = await verifier(
          candidatePassword: 'secret_pass_123',
          storedCredential: copyCredential(
            records.credential,
            parameters: params,
          ),
        );
        expect(result, isFalse, reason: 'Should reject: $params');
      }
    });

    test('rejects invalid or mismatched salt and verifier', () async {
      final records = await InitializeNexaBizCore(
        _DummyStore(),
      ).prepareForTest('secret_pass_123');

      // Invalid base64 salt
      expect(
        await verifier(
          candidatePassword: 'secret_pass_123',
          storedCredential: copyCredential(
            records.credential,
            salt: 'not-valid-base64!',
          ),
        ),
        isFalse,
      );

      // Salt too short (< 16 bytes)
      expect(
        await verifier(
          candidatePassword: 'secret_pass_123',
          storedCredential: copyCredential(
            records.credential,
            salt: base64Encode(List<int>.filled(8, 1)),
          ),
        ),
        isFalse,
      );

      // Invalid base64 verifier
      expect(
        await verifier(
          candidatePassword: 'secret_pass_123',
          storedCredential: copyCredential(
            records.credential,
            verifier: 'not-valid-base64!',
          ),
        ),
        isFalse,
      );

      // Verifier length mismatch with declared hashLength 'l=32'
      expect(
        await verifier(
          candidatePassword: 'secret_pass_123',
          storedCredential: copyCredential(
            records.credential,
            verifier: base64Encode(List<int>.filled(16, 1)), // 16 != 32
          ),
        ),
        isFalse,
      );
    });
  });

  group('AuthenticateLocalUser Integration & Invariant Tests', () {
    late Directory tempDir;
    late DriftCoreInstallationStore store;
    late AuthenticateLocalUser authenticate;

    setUp(() async {
      tempDir = Directory.systemTemp.createTempSync('nexabiz_auth_test_');
      final dbPath = p.join(tempDir.path, 'nexabiz.sqlite');
      store = await DriftCoreInstallationStore.open(dbPath);
      authenticate = AuthenticateLocalUser(queryStore: store);
    });

    tearDown(() async {
      await store.close();
      if (tempDir.existsSync()) {
        tempDir.deleteSync(recursive: true);
      }
    });

    test(
      'valid setup administrator authenticates and resolves active company',
      () async {
        final init = InitializeNexaBizCore(store);
        await init(
          const CoreInitializationInput(
            companyCode: 'ACME',
            companyName: 'Acme Corp',
            adminName: 'Alice Admin',
            adminEmail: 'alice@acme.com',
            password: 'correct horse battery staple',
          ),
        );

        final result = await authenticate(
          const CoreAuthenticationInput(
            identifier: 'alice@acme.com',
            password: 'correct horse battery staple',
          ),
        );

        expect(result.status, CoreAuthenticationStatus.success);
        expect(result.user?.email, 'alice@acme.com');
        expect(result.activeCompany?.code, 'ACME');
        expect(result.activeMembership?.role, 'owner');
      },
    );

    for (final change in {
      'membership deleted': 'DELETE FROM core_company_memberships',
      'membership disabled':
          "UPDATE core_company_memberships SET status = 'inactive'",
      'user disabled': "UPDATE core_users SET status = 'inactive'",
      'company disabled': "UPDATE core_companies SET status = 'inactive'",
    }.entries) {
      test('login fails when ${change.key} before final decision', () async {
        await InitializeNexaBizCore(store)(
          const CoreInitializationInput(
            companyCode: 'ACME',
            companyName: 'Acme Corp',
            adminName: 'Alice Admin',
            adminEmail: 'alice@acme.com',
            password: 'correct horse battery staple',
          ),
        );
        final delayed = _PendingIdentitySnapshotStore(store);
        final controller = CoreSessionController(
          authenticateLocalUser: AuthenticateLocalUser(queryStore: delayed),
          queryStore: store,
        );
        addTearDown(controller.dispose);
        final sessions = <NexaBizSession>[];
        final subscription = controller.onSessionChanged.listen(sessions.add);
        addTearDown(subscription.cancel);
        final pending = controller.login(
          const CoreAuthenticationInput(
            identifier: 'alice@acme.com',
            password: 'correct horse battery staple',
          ),
        );
        await delayed.started.future;
        // The old flow has already obtained its list of eligible companies.
        await store.database.customStatement(change.value);
        delayed.release.complete();
        final result = await pending;
        expect(result.isSuccess, isFalse);
        expect(
          result.status,
          change.key == 'user disabled'
              ? CoreAuthenticationStatus.userInactive
              : CoreAuthenticationStatus.noActiveMemberships,
        );
        expect(result.activeCompany, isNull);
        expect(result.activeMembership, isNull);
        expect(controller.currentSession.isActive, isFalse);
        await Future<void>.value();
        expect(sessions.where((session) => session.isActive), isEmpty);
      });
    }

    test('rejects invalid password', () async {
      final init = InitializeNexaBizCore(store);
      await init(
        const CoreInitializationInput(
          companyCode: 'ACME',
          companyName: 'Acme Corp',
          adminName: 'Alice Admin',
          adminEmail: 'alice@acme.com',
          password: 'correct horse battery staple',
        ),
      );

      final result = await authenticate(
        const CoreAuthenticationInput(
          identifier: 'alice@acme.com',
          password: 'wrong password here',
        ),
      );

      expect(result.status, CoreAuthenticationStatus.invalidCredentials);
      expect(result.activeCompany, isNull);
    });

    test('rejects unknown user identifier', () async {
      final result = await authenticate(
        const CoreAuthenticationInput(
          identifier: 'nobody@acme.com',
          password: 'correct horse battery staple',
        ),
      );

      expect(result.status, CoreAuthenticationStatus.invalidCredentials);
    });

    test('rejects inactive user', () async {
      final init = InitializeNexaBizCore(store);
      await init(
        const CoreInitializationInput(
          companyCode: 'ACME',
          companyName: 'Acme Corp',
          adminName: 'Alice Admin',
          adminEmail: 'alice@acme.com',
          password: 'correct horse battery staple',
        ),
      );

      // Deactivate user directly in DB
      await store.database.customStatement(
        "UPDATE core_users SET status = 'inactive' WHERE email = 'alice@acme.com'",
      );

      final result = await authenticate(
        const CoreAuthenticationInput(
          identifier: 'alice@acme.com',
          password: 'correct horse battery staple',
        ),
      );

      expect(result.status, CoreAuthenticationStatus.userInactive);
    });

    test(
      'inactive user + wrong password -> invalidCredentials + user null + failed attempt recorded',
      () async {
        final init = InitializeNexaBizCore(store);
        await init(
          const CoreInitializationInput(
            companyCode: 'ACME',
            companyName: 'Acme Corp',
            adminName: 'Alice Admin',
            adminEmail: 'alice@acme.com',
            password: 'correct horse battery staple',
          ),
        );
        await store.database.customStatement(
          "UPDATE core_users SET status = 'inactive' WHERE email = 'alice@acme.com'",
        );

        final result = await authenticate(
          const CoreAuthenticationInput(
            identifier: 'alice@acme.com',
            password: 'wrong password',
          ),
        );

        expect(result.status, CoreAuthenticationStatus.invalidCredentials);
        expect(result.user, isNull);
        expect(result.activeCompany, isNull);
        expect(result.activeMembership, isNull);
        expect(result.isLockedOut, isFalse);

        final attempts = await store.database
            .select(store.database.coreLoginAttempts)
            .get();
        expect(attempts, hasLength(1));
        expect(attempts.single.attemptCount, 1);
      },
    );

    test('inactive user repeated wrong passwords -> lockedOut', () async {
      final init = InitializeNexaBizCore(store);
      await init(
        const CoreInitializationInput(
          companyCode: 'ACME',
          companyName: 'Acme Corp',
          adminName: 'Alice Admin',
          adminEmail: 'alice@acme.com',
          password: 'correct horse battery staple',
        ),
      );
      await store.database.customStatement(
        "UPDATE core_users SET status = 'inactive' WHERE email = 'alice@acme.com'",
      );

      var virtualNow = DateTime.utc(2026, 9, 21, 12, 0, 0);
      final auth = AuthenticateLocalUser(
        queryStore: store,
        nowProvider: () => virtualNow,
      );

      for (var i = 1; i <= 4; i++) {
        final res = await auth(
          const CoreAuthenticationInput(
            identifier: 'alice@acme.com',
            password: 'wrong password',
          ),
        );
        expect(res.status, CoreAuthenticationStatus.invalidCredentials);
        expect(res.isLockedOut, isFalse);
        expect(res.user, isNull);
      }

      final locked = await auth(
        const CoreAuthenticationInput(
          identifier: 'alice@acme.com',
          password: 'wrong password',
        ),
      );
      expect(locked.status, CoreAuthenticationStatus.lockedOut);
      expect(locked.isLockedOut, isTrue);
      expect(locked.user, isNull);
      expect(locked.lockoutExpiresAt, isNotNull);

      // Even correct password while locked out fails with lockedOut
      final lockedWithCorrectPass = await auth(
        const CoreAuthenticationInput(
          identifier: 'alice@acme.com',
          password: 'correct horse battery staple',
        ),
      );
      expect(lockedWithCorrectPass.status, CoreAuthenticationStatus.lockedOut);
      expect(lockedWithCorrectPass.isLockedOut, isTrue);
      expect(lockedWithCorrectPass.user, isNull);
    });

    test(
      'inactive user + correct password -> userInactive + no session',
      () async {
        final init = InitializeNexaBizCore(store);
        await init(
          const CoreInitializationInput(
            companyCode: 'ACME',
            companyName: 'Acme Corp',
            adminName: 'Alice Admin',
            adminEmail: 'alice@acme.com',
            password: 'correct horse battery staple',
          ),
        );
        await store.database.customStatement(
          "UPDATE core_users SET status = 'inactive' WHERE email = 'alice@acme.com'",
        );

        final controller = CoreSessionController(
          authenticateLocalUser: authenticate,
          queryStore: store,
        );
        addTearDown(controller.dispose);

        final result = await controller.login(
          const CoreAuthenticationInput(
            identifier: 'alice@acme.com',
            password: 'correct horse battery staple',
          ),
        );

        expect(result.status, CoreAuthenticationStatus.userInactive);
        expect(result.isSuccess, isFalse);
        expect(result.user?.email, 'alice@acme.com');
        expect(controller.currentSession.isActive, isFalse);
        expect(controller.currentSession.userId, isNull);
      },
    );

    test(
      'wrong-password behavior for inactive user is identical to non-existent identifier',
      () async {
        final init = InitializeNexaBizCore(store);
        await init(
          const CoreInitializationInput(
            companyCode: 'ACME',
            companyName: 'Acme Corp',
            adminName: 'Alice Admin',
            adminEmail: 'alice@acme.com',
            password: 'correct horse battery staple',
          ),
        );
        await store.database.customStatement(
          "UPDATE core_users SET status = 'inactive' WHERE email = 'alice@acme.com'",
        );

        final inactiveRes = await authenticate(
          const CoreAuthenticationInput(
            identifier: 'alice@acme.com',
            password: 'completely-wrong-password',
          ),
        );
        final unknownRes = await authenticate(
          const CoreAuthenticationInput(
            identifier: 'ghost-user@acme.com',
            password: 'completely-wrong-password',
          ),
        );

        expect(inactiveRes.status, unknownRes.status);
        expect(inactiveRes.status, CoreAuthenticationStatus.invalidCredentials);
        expect(inactiveRes.user, isNull);
        expect(unknownRes.user, isNull);
        expect(inactiveRes.isSuccess, unknownRes.isSuccess);
        expect(inactiveRes.isSuccess, isFalse);
        expect(inactiveRes.isLockedOut, unknownRes.isLockedOut);
        expect(inactiveRes.isLockedOut, isFalse);
        expect(inactiveRes.activeCompany, unknownRes.activeCompany);
        expect(inactiveRes.activeMembership, unknownRes.activeMembership);
        expect(inactiveRes.availableCompanies, unknownRes.availableCompanies);
        expect(inactiveRes.lockoutExpiresAt, unknownRes.lockoutExpiresAt);
      },
    );

    test(
      'failed attempts -> lockout -> restart/persistence -> still locked',
      () async {
        final init = InitializeNexaBizCore(store);
        await init(
          const CoreInitializationInput(
            companyCode: 'ACME',
            companyName: 'Acme Corp',
            adminName: 'Alice Admin',
            adminEmail: 'alice@acme.com',
            password: 'correct horse battery staple',
          ),
        );

        var virtualNow = DateTime.utc(2026, 9, 21, 12, 0, 0);
        var auth = AuthenticateLocalUser(
          queryStore: store,
          nowProvider: () => virtualNow,
        );

        // Attempts 1 through 4 fail with invalidCredentials without lockout
        for (var i = 1; i <= 4; i++) {
          final res = await auth(
            const CoreAuthenticationInput(
              identifier: 'alice@acme.com',
              password: 'wrong password',
            ),
          );
          expect(res.status, CoreAuthenticationStatus.invalidCredentials);
          expect(res.isLockedOut, isFalse);
          expect(res.user, isNull);
        }

        // 5th attempt triggers progressive lockout (30 seconds)
        final lockedRes = await auth(
          const CoreAuthenticationInput(
            identifier: 'alice@acme.com',
            password: 'wrong password',
          ),
        );
        expect(lockedRes.status, CoreAuthenticationStatus.lockedOut);
        expect(lockedRes.isLockedOut, isTrue);
        expect(
          lockedRes.lockoutExpiresAt,
          virtualNow.add(const Duration(seconds: 30)),
        );
        expect(lockedRes.user, isNull);

        // Simulate app restart / new process by closing store and reopening from disk
        final dbPath = p.join(tempDir.path, 'nexabiz.sqlite');
        await store.close();
        final reopenedStore = await DriftCoreInstallationStore.open(dbPath);
        store = reopenedStore; // for tearDown cleanup
        final restartedAuth = AuthenticateLocalUser(
          queryStore: reopenedStore,
          nowProvider: () => virtualNow,
        );

        // Even with the correct password, it is still locked out!
        final afterRestartRes = await restartedAuth(
          const CoreAuthenticationInput(
            identifier: 'alice@acme.com',
            password: 'correct horse battery staple',
          ),
        );
        expect(afterRestartRes.status, CoreAuthenticationStatus.lockedOut);
        expect(afterRestartRes.isLockedOut, isTrue);
        expect(afterRestartRes.user, isNull);

        // Advance virtual clock past the 30-second lockout window (zero real delays)
        virtualNow = virtualNow.add(const Duration(seconds: 31));

        // Now login with correct password succeeds!
        final successRes = await restartedAuth(
          const CoreAuthenticationInput(
            identifier: 'alice@acme.com',
            password: 'correct horse battery staple',
          ),
        );
        expect(successRes.status, CoreAuthenticationStatus.success);
        expect(successRes.isSuccess, isTrue);
      },
    );

    test('successful login -> failure state cleared', () async {
      final init = InitializeNexaBizCore(store);
      await init(
        const CoreInitializationInput(
          companyCode: 'ACME',
          companyName: 'Acme Corp',
          adminName: 'Alice Admin',
          adminEmail: 'alice@acme.com',
          password: 'correct horse battery staple',
        ),
      );

      var virtualNow = DateTime.utc(2026, 9, 21, 12, 0, 0);
      final auth = AuthenticateLocalUser(
        queryStore: store,
        nowProvider: () => virtualNow,
      );

      // 4 consecutive failed attempts (just below lockout threshold)
      for (var i = 1; i <= 4; i++) {
        final res = await auth(
          const CoreAuthenticationInput(
            identifier: 'alice@acme.com',
            password: 'wrong password',
          ),
        );
        expect(res.status, CoreAuthenticationStatus.invalidCredentials);
      }

      // Successful login clears failure state
      final successRes = await auth(
        const CoreAuthenticationInput(
          identifier: 'alice@acme.com',
          password: 'correct horse battery staple',
        ),
      );
      expect(successRes.status, CoreAuthenticationStatus.success);

      // Verify failure records are cleared:
      // Failing 4 more times should NOT trigger lockout (proves counter was cleared)
      for (var i = 1; i <= 4; i++) {
        final res = await auth(
          const CoreAuthenticationInput(
            identifier: 'alice@acme.com',
            password: 'wrong password',
          ),
        );
        expect(res.status, CoreAuthenticationStatus.invalidCredentials);
        expect(res.isLockedOut, isFalse);
      }

      // 5th attempt triggers lockout
      final fifthRes = await auth(
        const CoreAuthenticationInput(
          identifier: 'alice@acme.com',
          password: 'wrong password',
        ),
      );
      expect(fifthRes.status, CoreAuthenticationStatus.lockedOut);
    });

    test('does not reveal whether username or email exists', () async {
      final init = InitializeNexaBizCore(store);
      await init(
        const CoreInitializationInput(
          companyCode: 'ACME',
          companyName: 'Acme Corp',
          adminName: 'Alice Admin',
          adminEmail: 'alice@acme.com',
          password: 'correct horse battery staple',
        ),
      );

      var virtualNow = DateTime.utc(2026, 9, 21, 12, 0, 0);
      final auth = AuthenticateLocalUser(
        queryStore: store,
        nowProvider: () => virtualNow,
      );

      // Unknown user and known user return identical results on failed attempts
      final unknownRes = await auth(
        const CoreAuthenticationInput(
          identifier: 'ghost@acme.com',
          password: 'some password',
        ),
      );
      final knownRes = await auth(
        const CoreAuthenticationInput(
          identifier: 'alice@acme.com',
          password: 'wrong password',
        ),
      );

      expect(unknownRes.status, CoreAuthenticationStatus.invalidCredentials);
      expect(knownRes.status, CoreAuthenticationStatus.invalidCredentials);
      expect(unknownRes.user, isNull);
      expect(knownRes.user, isNull);

      // Repeated failures on unknown user also result in lockout without revealing existence
      for (var i = 2; i <= 5; i++) {
        await auth(
          const CoreAuthenticationInput(
            identifier: 'ghost@acme.com',
            password: 'wrong password',
          ),
        );
      }
      final lockedGhost = await auth(
        const CoreAuthenticationInput(
          identifier: 'ghost@acme.com',
          password: 'wrong password',
        ),
      );
      expect(lockedGhost.status, CoreAuthenticationStatus.lockedOut);
      expect(lockedGhost.user, isNull);
    });

    test(
      'reach max lockout -> lockout expires -> next failed attempt does not reset counter to 1',
      () async {
        final init = InitializeNexaBizCore(store);
        await init(
          const CoreInitializationInput(
            companyCode: 'ACME',
            companyName: 'Acme Corp',
            adminName: 'Alice Admin',
            adminEmail: 'alice@acme.com',
            password: 'correct horse battery staple',
          ),
        );

        var virtualNow = DateTime.utc(2026, 9, 21, 12, 0, 0);
        final auth = AuthenticateLocalUser(
          queryStore: store,
          nowProvider: () => virtualNow,
        );

        // Progressively reach max lockout (10 attempts)
        for (var i = 1; i <= 4; i++) {
          final res = await auth(
            const CoreAuthenticationInput(
              identifier: 'alice@acme.com',
              password: 'wrong password',
            ),
          );
          expect(res.status, CoreAuthenticationStatus.invalidCredentials);
        }

        for (var i = 5; i <= 10; i++) {
          final res = await auth(
            const CoreAuthenticationInput(
              identifier: 'alice@acme.com',
              password: 'wrong password',
            ),
          );
          expect(res.status, CoreAuthenticationStatus.lockedOut);
          virtualNow = res.lockoutExpiresAt!.add(const Duration(seconds: 1));
        }

        // Verify attempt count reached 10 in database
        final rowsBefore = await store.database
            .select(store.database.coreLoginAttempts)
            .get();
        expect(rowsBefore.single.attemptCount, 10);

        // Advance clock past the 15-minute max lockout, but WITHIN the 1-hour inactivity reset window
        // (5 minutes after lockout expiration)
        virtualNow = virtualNow.add(const Duration(minutes: 5));

        // Attempt 11 fails
        final res11 = await auth(
          const CoreAuthenticationInput(
            identifier: 'alice@acme.com',
            password: 'wrong password',
          ),
        );

        // The counter must NOT reset to 1. Progressive protection remains enforced.
        expect(res11.status, CoreAuthenticationStatus.lockedOut);
        expect(res11.isLockedOut, isTrue);

        final rowsAfter = await store.database
            .select(store.database.coreLoginAttempts)
            .get();
        expect(rowsAfter.single.attemptCount, 11);
      },
    );

    test(
      'max lockout expires -> wrong password -> progressive protection remains enforced',
      () async {
        final init = InitializeNexaBizCore(store);
        await init(
          const CoreInitializationInput(
            companyCode: 'ACME',
            companyName: 'Acme Corp',
            adminName: 'Alice Admin',
            adminEmail: 'alice@acme.com',
            password: 'correct horse battery staple',
          ),
        );

        var virtualNow = DateTime.utc(2026, 9, 21, 12, 0, 0);
        final auth = AuthenticateLocalUser(
          queryStore: store,
          nowProvider: () => virtualNow,
        );

        // Reach max lockout (10 attempts, max 15-minute lock)
        for (var i = 1; i <= 4; i++) {
          await auth(
            const CoreAuthenticationInput(
              identifier: 'alice@acme.com',
              password: 'wrong password',
            ),
          );
        }
        late CoreAuthenticationResult lastLockoutRes;
        for (var i = 5; i <= 10; i++) {
          lastLockoutRes = await auth(
            const CoreAuthenticationInput(
              identifier: 'alice@acme.com',
              password: 'wrong password',
            ),
          );
          if (i < 10) {
            virtualNow = lastLockoutRes.lockoutExpiresAt!.add(
              const Duration(seconds: 1),
            );
          }
        }
        expect(
          lastLockoutRes.lockoutExpiresAt,
          virtualNow.add(const Duration(minutes: 15)),
        );

        // Advance virtual clock past the 15-minute max lockout (10 seconds after expiry)
        virtualNow = lastLockoutRes.lockoutExpiresAt!.add(
          const Duration(seconds: 10),
        );

        // Wrong password immediately enforces maximum progressive lockout (15 minutes),
        // rather than starting over at 30 seconds or allowing 4 free attempts.
        final nextRes = await auth(
          const CoreAuthenticationInput(
            identifier: 'alice@acme.com',
            password: 'wrong password',
          ),
        );
        expect(nextRes.status, CoreAuthenticationStatus.lockedOut);
        expect(
          nextRes.lockoutExpiresAt,
          virtualNow.add(const Duration(minutes: 15)),
        );
      },
    );

    test(
      'genuine inactivity window expires -> counter resets according to explicit policy',
      () async {
        final init = InitializeNexaBizCore(store);
        await init(
          const CoreInitializationInput(
            companyCode: 'ACME',
            companyName: 'Acme Corp',
            adminName: 'Alice Admin',
            adminEmail: 'alice@acme.com',
            password: 'correct horse battery staple',
          ),
        );

        var virtualNow = DateTime.utc(2026, 9, 21, 12, 0, 0);
        final auth = AuthenticateLocalUser(
          queryStore: store,
          nowProvider: () => virtualNow,
        );

        // Trigger max lockout (attempt 10)
        for (var i = 1; i <= 4; i++) {
          await auth(
            const CoreAuthenticationInput(
              identifier: 'alice@acme.com',
              password: 'wrong password',
            ),
          );
        }
        late CoreAuthenticationResult lastLockoutRes;
        for (var i = 5; i <= 10; i++) {
          lastLockoutRes = await auth(
            const CoreAuthenticationInput(
              identifier: 'alice@acme.com',
              password: 'wrong password',
            ),
          );
          if (i < 10) {
            virtualNow = lastLockoutRes.lockoutExpiresAt!.add(
              const Duration(seconds: 1),
            );
          }
        }

        final lockoutExpiresAt = lastLockoutRes.lockoutExpiresAt!;

        // Policy: Genuine inactivity window is measured from when the account was first
        // eligible to attempt logging in again (lockout expiration).
        // Advance clock by inactivityResetWindow (1 hour) + 1 second past lockout expiration.
        virtualNow = lockoutExpiresAt
            .add(store.inactivityResetWindow)
            .add(const Duration(seconds: 1));

        // Next failed attempt now resets counter according to policy!
        final resAfterInactivity = await auth(
          const CoreAuthenticationInput(
            identifier: 'alice@acme.com',
            password: 'wrong password',
          ),
        );

        // Counter reset to 1 -> does not trigger lockout!
        expect(
          resAfterInactivity.status,
          CoreAuthenticationStatus.invalidCredentials,
        );
        expect(resAfterInactivity.isLockedOut, isFalse);

        final rows = await store.database
            .select(store.database.coreLoginAttempts)
            .get();
        expect(rows.single.attemptCount, 1);
        expect(rows.single.lockedUntil, isNull);
      },
    );

    test(
      'successful login after lockout expiry -> failed-attempt record cleared',
      () async {
        final init = InitializeNexaBizCore(store);
        await init(
          const CoreInitializationInput(
            companyCode: 'ACME',
            companyName: 'Acme Corp',
            adminName: 'Alice Admin',
            adminEmail: 'alice@acme.com',
            password: 'correct horse battery staple',
          ),
        );

        var virtualNow = DateTime.utc(2026, 9, 21, 12, 0, 0);
        final auth = AuthenticateLocalUser(
          queryStore: store,
          nowProvider: () => virtualNow,
        );

        // Trigger max lockout (attempt 10)
        for (var i = 1; i <= 4; i++) {
          await auth(
            const CoreAuthenticationInput(
              identifier: 'alice@acme.com',
              password: 'wrong password',
            ),
          );
        }
        late CoreAuthenticationResult lastLockoutRes;
        for (var i = 5; i <= 10; i++) {
          lastLockoutRes = await auth(
            const CoreAuthenticationInput(
              identifier: 'alice@acme.com',
              password: 'wrong password',
            ),
          );
          if (i < 10) {
            virtualNow = lastLockoutRes.lockoutExpiresAt!.add(
              const Duration(seconds: 1),
            );
          }
        }

        // Advance clock past the lockout expiration
        virtualNow = lastLockoutRes.lockoutExpiresAt!.add(
          const Duration(seconds: 10),
        );

        // Now attempt login with the correct password
        final successRes = await auth(
          const CoreAuthenticationInput(
            identifier: 'alice@acme.com',
            password: 'correct horse battery staple',
          ),
        );

        expect(successRes.status, CoreAuthenticationStatus.success);
        expect(successRes.isSuccess, isTrue);

        // Failed attempt record is completely cleared from the database
        final rows = await store.database
            .select(store.database.coreLoginAttempts)
            .get();
        expect(rows, isEmpty);

        final lockout = await store.checkLockout('alice@acme.com', virtualNow);
        expect(lockout, isNull);

        // Subsequent 4 failed attempts do not trigger lockout (proves clean start)
        for (var i = 1; i <= 4; i++) {
          final res = await auth(
            const CoreAuthenticationInput(
              identifier: 'alice@acme.com',
              password: 'wrong password',
            ),
          );
          expect(res.status, CoreAuthenticationStatus.invalidCredentials);
          expect(res.isLockedOut, isFalse);
        }
      },
    );

    test(
      'timing anti-enumeration: unknown identifier executes dummy Argon2id, existing user executes real Argon2id, both fail identically',
      () async {
        final init = InitializeNexaBizCore(store);
        await init(
          const CoreInitializationInput(
            companyCode: 'ACME',
            companyName: 'Acme Corp',
            adminName: 'Alice Admin',
            adminEmail: 'alice@acme.com',
            password: 'correct horse battery staple',
          ),
        );

        final alice = await store.findUserByIdentifier('alice@acme.com');
        expect(alice, isNotNull);
        final realCred = await store.readUserCredential(alice!.id);
        expect(realCred, isNotNull);

        // Path 1: Unknown identifier executes dummy Argon2id verification
        final trackingVerifierUnknown = _TrackingVerifier();
        final authUnknown = AuthenticateLocalUser(
          queryStore: store,
          verifier: trackingVerifierUnknown,
        );

        final unknownRes = await authUnknown(
          const CoreAuthenticationInput(
            identifier: 'ghost_user@acme.com',
            password: 'candidate_password_123',
          ),
        );

        expect(unknownRes.status, CoreAuthenticationStatus.invalidCredentials);
        expect(unknownRes.user, isNull);
        expect(unknownRes.isSuccess, isFalse);
        expect(trackingVerifierUnknown.calls, 1);
        expect(
          trackingVerifierUnknown.lastCandidatePassword,
          'candidate_password_123',
        );
        expect(trackingVerifierUnknown.lastCredential?.algorithm, 'argon2id');
        expect(
          trackingVerifierUnknown.lastCredential?.parameters,
          'v=19,m=19456,t=2,p=1,l=32',
        );
        expect(trackingVerifierUnknown.lastCredential?.salt, isNotEmpty);
        expect(trackingVerifierUnknown.lastCredential?.verifier, isNotEmpty);
        // Proves structurally valid dummy credential is not linked to any real user
        expect(
          trackingVerifierUnknown.lastCredential?.salt,
          isNot(equals(realCred!.salt)),
        );
        expect(
          trackingVerifierUnknown.lastCredential?.verifier,
          isNot(equals(realCred.verifier)),
        );

        // Path 2: Existing user + wrong password executes real Argon2id verification
        final trackingVerifierExisting = _TrackingVerifier();
        final authExisting = AuthenticateLocalUser(
          queryStore: store,
          verifier: trackingVerifierExisting,
        );

        final existingRes = await authExisting(
          const CoreAuthenticationInput(
            identifier: 'alice@acme.com',
            password: 'wrong_candidate_password_456',
          ),
        );

        expect(existingRes.status, CoreAuthenticationStatus.invalidCredentials);
        expect(existingRes.user, isNull);
        expect(existingRes.isSuccess, isFalse);
        expect(trackingVerifierExisting.calls, 1);
        expect(
          trackingVerifierExisting.lastCandidatePassword,
          'wrong_candidate_password_456',
        );
        expect(trackingVerifierExisting.lastCredential?.algorithm, 'argon2id');
        expect(
          trackingVerifierExisting.lastCredential?.salt,
          equals(realCred.salt),
        );
        expect(
          trackingVerifierExisting.lastCredential?.verifier,
          equals(realCred.verifier),
        );

        // Path 3: Unknown identifier still records failed attempt in Drift
        final attempts = await store.database
            .select(store.database.coreLoginAttempts)
            .get();
        expect(attempts, hasLength(2)); // 1 for ghost_user, 1 for alice

        // Path 4: Repeated unknown identifier attempts reach lockedOut
        final lockoutTrackingVerifier = _TrackingVerifier();
        final authLockout = AuthenticateLocalUser(
          queryStore: store,
          verifier: lockoutTrackingVerifier,
        );

        for (var i = 1; i <= 4; i++) {
          final res = await authLockout(
            CoreAuthenticationInput(
              identifier: 'target_probe@acme.com',
              password: 'probe_password_$i',
            ),
          );
          expect(res.status, CoreAuthenticationStatus.invalidCredentials);
          expect(res.user, isNull);
        }
        final lockedRes = await authLockout(
          const CoreAuthenticationInput(
            identifier: 'target_probe@acme.com',
            password: 'probe_password_5',
          ),
        );
        expect(lockedRes.status, CoreAuthenticationStatus.lockedOut);
        expect(lockedRes.lockoutExpiresAt, isNotNull);
        expect(lockedRes.user, isNull);
        expect(lockoutTrackingVerifier.calls, 5);

        // Path 5: Dummy verification can never produce an active session
        final controller = CoreSessionController(
          authenticateLocalUser: AuthenticateLocalUser(
            queryStore: store,
            verifier: trackingVerifierUnknown,
          ),
          queryStore: store,
        );
        addTearDown(controller.dispose);

        final sessionRes = await controller.login(
          const CoreAuthenticationInput(
            identifier: 'ghost_user@acme.com',
            password: 'candidate_password_123',
          ),
        );
        expect(sessionRes.isSuccess, isFalse);
        expect(sessionRes.status, CoreAuthenticationStatus.invalidCredentials);
        expect(sessionRes.user, isNull);
        expect(controller.currentSession.isActive, isFalse);
        expect(controller.currentSession.userId, isNull);
      },
    );
  });
}

final class _TrackingVerifier extends VerifyCoreCredential {
  int calls = 0;
  CorePreparedCredential? lastCredential;
  String? lastCandidatePassword;

  @override
  Future<bool> call({
    required String candidatePassword,
    required CorePreparedCredential storedCredential,
  }) {
    calls++;
    lastCandidatePassword = candidatePassword;
    lastCredential = storedCredential;
    return super.call(
      candidatePassword: candidatePassword,
      storedCredential: storedCredential,
    );
  }
}

class _DummyStore implements NexaBizCoreInstallationStore {
  @override
  Future<NexaBizSetupReadiness> readReadiness() async => NexaBizSetupReadiness(
    state: NexaBizSetupState.uninitialized,
    completed: {},
  );

  @override
  Future<NexaBizSetupReadiness> initialize(records) async =>
      NexaBizSetupReadiness(state: NexaBizSetupState.ready, completed: {});

  @override
  Future<void> close() async {}
}

extension on InitializeNexaBizCore {
  Future<CoreInitializationRecords> prepareForTest(String password) async {
    final salt = List<int>.filled(16, 7);
    final key = await Argon2id(
      memory: 19456,
      parallelism: 1,
      iterations: 2,
      hashLength: 32,
    ).deriveKeyFromPassword(password: password, nonce: salt);
    final verifierBytes = await key.extractBytes();

    return CoreInitializationRecords(
      companyId: 'c1',
      companyCode: 'ACME',
      companyName: 'Acme',
      userId: 'u1',
      adminName: 'Admin',
      adminEmail: 'admin@acme.com',
      membershipId: 'm1',
      createdAt: DateTime.now().toUtc(),
      credential: CorePreparedCredential(
        algorithm: 'argon2id',
        parameters: 'v=19,m=19456,t=2,p=1,l=32',
        salt: base64Encode(salt),
        verifier: base64Encode(verifierBytes),
      ),
    );
  }
}

/// Holds the final identity read until the test commits a concurrent revocation.
class _PendingIdentitySnapshotStore implements CoreIdentityQueryStore {
  _PendingIdentitySnapshotStore(this.delegate);
  final CoreIdentityQueryStore delegate;
  final started = Completer<void>();
  final release = Completer<void>();

  @override
  Future<CoreAuthIdentitySnapshot?> readAuthenticationSnapshot(
    String userId,
  ) async {
    started.complete();
    await release.future;
    return delegate.readAuthenticationSnapshot(userId);
  }

  @override
  Future<CoreAuthUserRef?> findUserByIdentifier(String identifier) =>
      delegate.findUserByIdentifier(identifier);
  @override
  Future<CorePreparedCredential?> readUserCredential(String userId) =>
      delegate.readUserCredential(userId);
  @override
  Future<bool> isSessionEligible(String userId, String? companyId) =>
      delegate.isSessionEligible(userId, companyId);
  @override
  Stream<bool> watchSessionEligibility(String userId, String? companyId) =>
      delegate.watchSessionEligibility(userId, companyId);
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
