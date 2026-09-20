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

    test('initial state is noSession', () {
      expect(controller.currentSession.state, NexaBizSessionState.noSession);
      expect(controller.currentSession.isActive, isFalse);
    });

    test('successful single-company login establishes active company session', () async {
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
    });

    test('logout invalidates active session and resets state to noSession', () async {
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
    });

    test('company switch terminates old session context and establishes new context', () async {
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
      final alphaRow = await db.customSelect("SELECT id FROM core_companies WHERE code = 'ALPHA'").getSingle();
      final alphaCompanyId = alphaRow.read<String>('id');

      const secondCompanyId = 'comp-beta-777';
      const secondMembershipId = 'mem-beta-888';
      final now = DateTime.now().toUtc();

      await db.customStatement(
        "INSERT INTO core_companies (id, code, name, status, created_at, updated_at) VALUES ('$secondCompanyId', 'BETA', 'Beta LLC', 'active', '${now.toIso8601String()}', '${now.toIso8601String()}')",
      );

      final userRow = await db.customSelect("SELECT id FROM core_users WHERE email = 'alice@alpha.com'").getSingle();
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
      final switched = await controller.selectOrSwitchCompany(secondCompanyId);

      expect(switched, isTrue);
      expect(controller.currentSession.companyCode, 'BETA');
      expect(controller.currentSession.companyName, 'Beta LLC');
      expect(controller.currentSession.role, 'admin');
      expect(controller.currentSession.sessionId, isNot(oldSessionId));
    });

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

      final switched = await controller.selectOrSwitchCompany('unauthorized-company-xyz');

      expect(switched, isFalse);
      expect(controller.currentSession.companyCode, 'ALPHA');
      expect(controller.currentSession.sessionId, oldSessionId);
    });
  });
}
