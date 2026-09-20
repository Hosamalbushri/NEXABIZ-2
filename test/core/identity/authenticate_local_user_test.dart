import 'dart:convert';
import 'dart:io';

import 'package:cryptography/cryptography.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nexabiz/app/persistence/drift_core_installation_store.dart';
import 'package:nexabiz/core/identity/authenticate_local_user.dart';
import 'package:nexabiz/core/identity/verify_core_credential.dart';
import 'package:nexabiz/core/setup/initialize_nexabiz_core.dart';
import 'package:nexabiz/core/setup/nexabiz_core_installation_store.dart';
import 'package:nexabiz/core/setup/nexabiz_setup_readiness.dart';
import 'package:path/path.dart' as p;

void main() {
  group('VerifyCoreCredential Unit Tests', () {
    const verifier = VerifyCoreCredential();

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

    test('valid setup administrator authenticates and resolves active company', () async {
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
    });

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
  });
}

class _DummyStore implements NexaBizCoreInstallationStore {
  @override
  Future<NexaBizSetupReadiness> readReadiness() async =>
      NexaBizSetupReadiness(
        state: NexaBizSetupState.uninitialized,
        completed: {},
      );

  @override
  Future<NexaBizSetupReadiness> initialize(records) async =>
      NexaBizSetupReadiness(
        state: NexaBizSetupState.ready,
        completed: {},
      );

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
