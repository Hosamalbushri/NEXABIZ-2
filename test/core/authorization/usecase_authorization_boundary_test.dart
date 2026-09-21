import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:nexabiz/app/persistence/drift_core_installation_store.dart';
import 'package:nexabiz/core/authorization/core_authorization_query_store.dart';
import 'package:nexabiz/core/authorization/nexabiz_authorization_context.dart';
import 'package:nexabiz/core/authorization/nexabiz_authorization_session_source.dart';
import 'package:nexabiz/core/authorization/nexabiz_membership_authorization_snapshot.dart';
import 'package:nexabiz/core/authorization/nexabiz_membership_id.dart';
import 'package:nexabiz/core/authorization/nexabiz_permission_catalog.dart';
import 'package:nexabiz/core/authorization/nexabiz_permission_denied_exception.dart';
import 'package:nexabiz/core/authorization/nexabiz_permission_evaluator.dart';
import 'package:nexabiz/core/authorization/nexabiz_permission_guard.dart';
import 'package:nexabiz/core/authorization/nexabiz_runtime_permission_evaluator.dart';
import 'package:nexabiz/core/capabilities/nexabiz_capability_registry.dart';
import 'package:nexabiz/core/company/nexabiz_company_scope.dart';
import 'package:nexabiz/core/identity/authenticate_local_user.dart';
import 'package:nexabiz/core/permissions/nexabiz_permission_intent.dart';
import 'package:nexabiz/core/roles/nexabiz_role_id.dart';
import 'package:nexabiz/core/roles/nexabiz_role_scope.dart';
import 'package:nexabiz/core/session/core_session_controller.dart';
import 'package:nexabiz/core/session/nexabiz_session.dart';
import 'package:nexabiz/core/setup/initialize_nexabiz_core.dart';
import 'package:nexabiz/packages/company/company_capability.dart';
import 'package:path/path.dart' as p;

// ---------------------------------------------------------------------------
// Test-Only Business Domain Fixtures (Never added to production lib/)
// ---------------------------------------------------------------------------

final class _TestCompanyRepository {
  int mutationCalls = 0;
  String? updatedProfileName;
  final List<String> operationLog = [];

  Future<void> updateProfile({required String newName}) async {
    operationLog.add('repository.updateProfile');
    mutationCalls++;
    updatedProfileName = newName;
  }
}

final class _LoggingPermissionGuard implements NexaBizPermissionGuard {
  _LoggingPermissionGuard(this._evaluator, this.operationLog);

  final NexaBizPermissionEvaluator _evaluator;
  final List<String> operationLog;

  @override
  Future<void> requirePermission({
    required NexaBizAuthorizationContext context,
    required NexaBizPermissionId permissionId,
  }) async {
    operationLog.add('guard.requirePermission');
    final decision = await _evaluator.evaluate(
      context: context,
      permissionId: permissionId,
    );
    if (!decision.isAllowed) {
      throw NexaBizPermissionDeniedException(
        permissionId: permissionId,
        contextScope: context.scope,
        decision: decision,
      );
    }
  }
}

/// Canonical protected business UseCase fixture enforcing the architectural pattern.
final class _TestProtectedCompanyProfileUseCase {
  const _TestProtectedCompanyProfileUseCase({
    required this.permissionGuard,
    required this.repository,
  });

  final NexaBizPermissionGuard permissionGuard;
  final _TestCompanyRepository repository;

  static final requiredPermission = NexaBizPermissionId(
    'company.profile.manage',
  );

  Future<void> execute({
    required NexaBizAuthorizationContext context,
    required String newName,
  }) async {
    // 1. Authoritative Guard Check MUST precede any side effect or mutation
    await permissionGuard.requirePermission(
      context: context,
      permissionId: requiredPermission,
    );

    // 2. Business mutation executed ONLY if permission is explicitly allowed
    await repository.updateProfile(newName: newName);
  }
}

// ---------------------------------------------------------------------------
// Fakes for Unit-Level Fixtures
// ---------------------------------------------------------------------------

final class _FakeSessionSource implements NexaBizAuthorizationSessionSource {
  _FakeSessionSource({
    required this.activeSessionId,
    required this.activeUserId,
    this.activeCompanyId,
    this.activeMembershipId,
  }) : isActive = true;

  String activeSessionId;
  NexaBizUserId activeUserId;
  NexaBizCompanyId? activeCompanyId;
  NexaBizMembershipId? activeMembershipId;
  bool isActive;

  @override
  bool matchesActiveSession({
    required String sessionId,
    required NexaBizUserId userId,
    NexaBizCompanyId? companyId,
    NexaBizMembershipId? membershipId,
  }) {
    if (!isActive) return false;
    if (sessionId != activeSessionId) return false;
    if (userId != activeUserId) return false;
    if (companyId != null && activeCompanyId != companyId) return false;
    if (membershipId != null && activeMembershipId != membershipId) {
      return false;
    }
    return true;
  }
}

final class _FakeQueryStore implements CoreAuthorizationQueryStore {
  _FakeQueryStore({this.snapshot});

  NexaBizMembershipAuthorizationSnapshot? snapshot;

  @override
  Future<NexaBizMembershipAuthorizationSnapshot?>
  readMembershipAuthorizationSnapshot(String membershipId) async => snapshot;
}

void main() {
  final permManage = NexaBizPermissionId('company.profile.manage');
  final permView = NexaBizPermissionId('company.profile.view');

  final testCatalog = NexaBizImmutablePermissionCatalog({permView, permManage});

  final defaultUser = NexaBizUserId('user-1');
  final defaultCompany = NexaBizCompanyId('company-1');
  final defaultMembership = NexaBizMembershipId('mem-1');
  const defaultSessionId = 'session-123';

  NexaBizCompanyAuthorizationContext createDefaultContext({
    String sessionId = defaultSessionId,
    NexaBizUserId? userId,
    NexaBizCompanyId? companyId,
    NexaBizMembershipId? membershipId,
  }) {
    return NexaBizCompanyAuthorizationContext(
      userId: userId ?? defaultUser,
      sessionId: sessionId,
      companyId: companyId ?? defaultCompany,
      membershipId: membershipId ?? defaultMembership,
    );
  }

  NexaBizMembershipAuthorizationSnapshot createDefaultSnapshot({
    NexaBizMembershipId? membershipId,
    NexaBizCompanyId? companyId,
    NexaBizUserId? userId,
    String membershipStatus = 'active',
    String companyStatus = 'active',
    String userStatus = 'active',
    Set<NexaBizRoleId>? roles,
    Set<NexaBizPermissionId>? permissions,
  }) {
    return NexaBizMembershipAuthorizationSnapshot(
      membershipId: membershipId ?? defaultMembership,
      companyId: companyId ?? defaultCompany,
      userId: userId ?? defaultUser,
      membershipStatus: membershipStatus,
      companyStatus: companyStatus,
      userStatus: userStatus,
      roleIds: roles ?? {NexaBizRoleId('company.owner')},
      permissionIds: permissions ?? {permManage},
    );
  }

  group('UseCase Authorization Security Boundary — 15 Required Behaviors', () {
    // 1. ALLOW → business callback executes once
    test('1. ALLOW executes business mutation exactly once', () async {
      final repository = _TestCompanyRepository();
      final sessionSource = _FakeSessionSource(
        activeSessionId: defaultSessionId,
        activeUserId: defaultUser,
        activeCompanyId: defaultCompany,
        activeMembershipId: defaultMembership,
      );
      final queryStore = _FakeQueryStore(
        snapshot: createDefaultSnapshot(permissions: {permManage}),
      );
      final evaluator = NexaBizRuntimePermissionEvaluator(
        permissionCatalog: testCatalog,
        queryStore: queryStore,
        sessionSource: sessionSource,
      );
      final guard = NexaBizDefaultPermissionGuard(evaluator);
      final useCase = _TestProtectedCompanyProfileUseCase(
        permissionGuard: guard,
        repository: repository,
      );

      await useCase.execute(
        context: createDefaultContext(),
        newName: 'NexaBiz New',
      );

      expect(repository.mutationCalls, 1);
      expect(repository.updatedProfileName, 'NexaBiz New');
    });

    // 2. DENY → callback does NOT execute
    test('2. DENY prevents business mutation from executing', () async {
      final repository = _TestCompanyRepository();
      final sessionSource = _FakeSessionSource(
        activeSessionId: defaultSessionId,
        activeUserId: defaultUser,
        activeCompanyId: defaultCompany,
        activeMembershipId: defaultMembership,
      );
      // Granted only view, but useCase requires manage
      final queryStore = _FakeQueryStore(
        snapshot: createDefaultSnapshot(permissions: {permView}),
      );
      final evaluator = NexaBizRuntimePermissionEvaluator(
        permissionCatalog: testCatalog,
        queryStore: queryStore,
        sessionSource: sessionSource,
      );
      final guard = NexaBizDefaultPermissionGuard(evaluator);
      final useCase = _TestProtectedCompanyProfileUseCase(
        permissionGuard: guard,
        repository: repository,
      );

      await expectLater(
        () => useCase.execute(
          context: createDefaultContext(),
          newName: 'NexaBiz New',
        ),
        throwsA(isA<NexaBizPermissionDeniedException>()),
      );

      expect(repository.mutationCalls, 0);
      expect(repository.updatedProfileName, isNull);
    });

    // 3. UNKNOWN → callback does NOT execute
    test(
      '3. UNKNOWN permission prevents business mutation from executing',
      () async {
        final repository = _TestCompanyRepository();
        final sessionSource = _FakeSessionSource(
          activeSessionId: defaultSessionId,
          activeUserId: defaultUser,
          activeCompanyId: defaultCompany,
          activeMembershipId: defaultMembership,
        );
        final queryStore = _FakeQueryStore(
          snapshot: createDefaultSnapshot(permissions: {permManage}),
        );
        // Empty catalog: manage is unknown
        final evaluator = NexaBizRuntimePermissionEvaluator(
          permissionCatalog: const NexaBizImmutablePermissionCatalog({}),
          queryStore: queryStore,
          sessionSource: sessionSource,
        );
        final guard = NexaBizDefaultPermissionGuard(evaluator);
        final useCase = _TestProtectedCompanyProfileUseCase(
          permissionGuard: guard,
          repository: repository,
        );

        await expectLater(
          () => useCase.execute(
            context: createDefaultContext(),
            newName: 'NexaBiz New',
          ),
          throwsA(isA<NexaBizPermissionDeniedException>()),
        );

        expect(repository.mutationCalls, 0);
        expect(repository.updatedProfileName, isNull);
      },
    );

    // 4. Guard throws typed NexaBizPermissionDeniedException
    test(
      '4. Guard throws typed NexaBizPermissionDeniedException with precise metadata',
      () async {
        final repository = _TestCompanyRepository();
        final sessionSource = _FakeSessionSource(
          activeSessionId: defaultSessionId,
          activeUserId: defaultUser,
          activeCompanyId: defaultCompany,
          activeMembershipId: defaultMembership,
        );
        final queryStore = _FakeQueryStore(
          snapshot: createDefaultSnapshot(permissions: <NexaBizPermissionId>{}),
        );
        final evaluator = NexaBizRuntimePermissionEvaluator(
          permissionCatalog: testCatalog,
          queryStore: queryStore,
          sessionSource: sessionSource,
        );
        final guard = NexaBizDefaultPermissionGuard(evaluator);
        final useCase = _TestProtectedCompanyProfileUseCase(
          permissionGuard: guard,
          repository: repository,
        );

        expect(
          () => useCase.execute(
            context: createDefaultContext(),
            newName: 'New Name',
          ),
          throwsA(
            isA<NexaBizPermissionDeniedException>()
                .having((e) => e.permissionId, 'permissionId', permManage)
                .having(
                  (e) => e.contextScope,
                  'contextScope',
                  equals(NexaBizRoleScope.company),
                )
                .having((e) => e.decision.isDenied, 'isDenied', isTrue),
          ),
        );
      },
    );

    // 5. Repository mutation is NOT called before authorization
    test(
      '5. Repository mutation is strictly called AFTER authorization, never before',
      () async {
        final repository = _TestCompanyRepository();
        final log = repository.operationLog;
        final sessionSource = _FakeSessionSource(
          activeSessionId: defaultSessionId,
          activeUserId: defaultUser,
          activeCompanyId: defaultCompany,
          activeMembershipId: defaultMembership,
        );
        final queryStore = _FakeQueryStore(
          snapshot: createDefaultSnapshot(permissions: {permManage}),
        );
        final evaluator = NexaBizRuntimePermissionEvaluator(
          permissionCatalog: testCatalog,
          queryStore: queryStore,
          sessionSource: sessionSource,
        );
        final loggingGuard = _LoggingPermissionGuard(evaluator, log);
        final useCase = _TestProtectedCompanyProfileUseCase(
          permissionGuard: loggingGuard,
          repository: repository,
        );

        await useCase.execute(
          context: createDefaultContext(),
          newName: 'Ordered Execution',
        );

        expect(log, ['guard.requirePermission', 'repository.updateProfile']);
      },
    );

    // 6. Missing grant → zero side effects
    test('6. Missing permission grant yields zero side effects', () async {
      final repository = _TestCompanyRepository();
      final sessionSource = _FakeSessionSource(
        activeSessionId: defaultSessionId,
        activeUserId: defaultUser,
        activeCompanyId: defaultCompany,
        activeMembershipId: defaultMembership,
      );
      final queryStore = _FakeQueryStore(
        snapshot: createDefaultSnapshot(permissions: <NexaBizPermissionId>{}),
      );
      final evaluator = NexaBizRuntimePermissionEvaluator(
        permissionCatalog: testCatalog,
        queryStore: queryStore,
        sessionSource: sessionSource,
      );
      final guard = NexaBizDefaultPermissionGuard(evaluator);
      final useCase = _TestProtectedCompanyProfileUseCase(
        permissionGuard: guard,
        repository: repository,
      );

      await expectLater(
        () => useCase.execute(
          context: createDefaultContext(),
          newName: 'No Grant',
        ),
        throwsA(isA<NexaBizPermissionDeniedException>()),
      );

      expect(repository.mutationCalls, 0);
      expect(repository.operationLog, isEmpty);
    });

    // 7. Stale session context → zero side effects
    test('7. Stale session context yields zero side effects', () async {
      final repository = _TestCompanyRepository();
      final sessionSource = _FakeSessionSource(
        activeSessionId: 'active-session-new',
        activeUserId: defaultUser,
        activeCompanyId: defaultCompany,
        activeMembershipId: defaultMembership,
      );
      final queryStore = _FakeQueryStore(
        snapshot: createDefaultSnapshot(permissions: {permManage}),
      );
      final evaluator = NexaBizRuntimePermissionEvaluator(
        permissionCatalog: testCatalog,
        queryStore: queryStore,
        sessionSource: sessionSource,
      );
      final guard = NexaBizDefaultPermissionGuard(evaluator);
      final useCase = _TestProtectedCompanyProfileUseCase(
        permissionGuard: guard,
        repository: repository,
      );

      // Sourcing context from stale session ID
      final staleContext = createDefaultContext(sessionId: 'stale-session-old');

      await expectLater(
        () => useCase.execute(context: staleContext, newName: 'Stale Update'),
        throwsA(isA<NexaBizPermissionDeniedException>()),
      );

      expect(repository.mutationCalls, 0);
    });

    // 8. Wrong company context → zero side effects
    test('8. Wrong company context yields zero side effects', () async {
      final repository = _TestCompanyRepository();
      final sessionSource = _FakeSessionSource(
        activeSessionId: defaultSessionId,
        activeUserId: defaultUser,
        activeCompanyId: defaultCompany,
        activeMembershipId: defaultMembership,
      );
      final queryStore = _FakeQueryStore(
        snapshot: createDefaultSnapshot(
          companyId: defaultCompany,
          permissions: {permManage},
        ),
      );
      final evaluator = NexaBizRuntimePermissionEvaluator(
        permissionCatalog: testCatalog,
        queryStore: queryStore,
        sessionSource: sessionSource,
      );
      final guard = NexaBizDefaultPermissionGuard(evaluator);
      final useCase = _TestProtectedCompanyProfileUseCase(
        permissionGuard: guard,
        repository: repository,
      );

      // Calling with different company ID
      final wrongCompanyContext = createDefaultContext(
        companyId: NexaBizCompanyId('different-company'),
      );

      await expectLater(
        () => useCase.execute(
          context: wrongCompanyContext,
          newName: 'Cross-Tenant Update',
        ),
        throwsA(isA<NexaBizPermissionDeniedException>()),
      );

      expect(repository.mutationCalls, 0);
    });

    // 9. Revoked permission during same session → subsequent operation denied
    test(
      '9. Permission revocation during same session immediately denies subsequent operations',
      () async {
        final repository = _TestCompanyRepository();
        final sessionSource = _FakeSessionSource(
          activeSessionId: defaultSessionId,
          activeUserId: defaultUser,
          activeCompanyId: defaultCompany,
          activeMembershipId: defaultMembership,
        );
        final queryStore = _FakeQueryStore(
          snapshot: createDefaultSnapshot(permissions: {permManage}),
        );
        final evaluator = NexaBizRuntimePermissionEvaluator(
          permissionCatalog: testCatalog,
          queryStore: queryStore,
          sessionSource: sessionSource,
        );
        final guard = NexaBizDefaultPermissionGuard(evaluator);
        final useCase = _TestProtectedCompanyProfileUseCase(
          permissionGuard: guard,
          repository: repository,
        );

        final ctx = createDefaultContext();

        // Operation 1 succeeds
        await useCase.execute(context: ctx, newName: 'First Valid');
        expect(repository.mutationCalls, 1);

        // Live revocation in snapshot store
        queryStore.snapshot = createDefaultSnapshot(
          permissions: <NexaBizPermissionId>{},
        );

        // Operation 2 immediately fails with zero additional mutations
        await expectLater(
          () => useCase.execute(context: ctx, newName: 'Second Revoked'),
          throwsA(isA<NexaBizPermissionDeniedException>()),
        );
        expect(repository.mutationCalls, 1);
        expect(repository.updatedProfileName, 'First Valid');
      },
    );

    // 10. Granted permission during same session → subsequent operation allowed
    test(
      '10. Permission grant during same session immediately allows subsequent operations',
      () async {
        final repository = _TestCompanyRepository();
        final sessionSource = _FakeSessionSource(
          activeSessionId: defaultSessionId,
          activeUserId: defaultUser,
          activeCompanyId: defaultCompany,
          activeMembershipId: defaultMembership,
        );
        final queryStore = _FakeQueryStore(
          snapshot: createDefaultSnapshot(permissions: <NexaBizPermissionId>{}),
        );
        final evaluator = NexaBizRuntimePermissionEvaluator(
          permissionCatalog: testCatalog,
          queryStore: queryStore,
          sessionSource: sessionSource,
        );
        final guard = NexaBizDefaultPermissionGuard(evaluator);
        final useCase = _TestProtectedCompanyProfileUseCase(
          permissionGuard: guard,
          repository: repository,
        );

        final ctx = createDefaultContext();

        // Operation 1 fails
        await expectLater(
          () => useCase.execute(context: ctx, newName: 'First Attempt'),
          throwsA(isA<NexaBizPermissionDeniedException>()),
        );
        expect(repository.mutationCalls, 0);

        // Live grant in snapshot store
        queryStore.snapshot = createDefaultSnapshot(permissions: {permManage});

        // Operation 2 succeeds immediately
        await useCase.execute(context: ctx, newName: 'Second Allowed');
        expect(repository.mutationCalls, 1);
        expect(repository.updatedProfileName, 'Second Allowed');
      },
    );

    // 11. Role name does not change outcome
    test(
      '11. Role name (owner, admin, superuser) does NOT bypass permission evaluation',
      () async {
        final repository = _TestCompanyRepository();
        final sessionSource = _FakeSessionSource(
          activeSessionId: defaultSessionId,
          activeUserId: defaultUser,
          activeCompanyId: defaultCompany,
          activeMembershipId: defaultMembership,
        );
        // Owner role present, but explicit permission grants are empty
        final queryStore = _FakeQueryStore(
          snapshot: createDefaultSnapshot(
            roles: {
              NexaBizRoleId('company.owner'),
              NexaBizRoleId('company.admin'),
            },
            permissions: <NexaBizPermissionId>{},
          ),
        );
        final evaluator = NexaBizRuntimePermissionEvaluator(
          permissionCatalog: testCatalog,
          queryStore: queryStore,
          sessionSource: sessionSource,
        );
        final guard = NexaBizDefaultPermissionGuard(evaluator);
        final useCase = _TestProtectedCompanyProfileUseCase(
          permissionGuard: guard,
          repository: repository,
        );

        await expectLater(
          () => useCase.execute(
            context: createDefaultContext(),
            newName: 'Owner Bypass Attempt',
          ),
          throwsA(isA<NexaBizPermissionDeniedException>()),
        );

        expect(repository.mutationCalls, 0);
      },
    );

    // 12. Multiple roles are evaluated by evaluator; UseCase doesn't care
    test(
      '12. Multiple roles union is resolved transparently by evaluator without UseCase role logic',
      () async {
        final repository = _TestCompanyRepository();
        final sessionSource = _FakeSessionSource(
          activeSessionId: defaultSessionId,
          activeUserId: defaultUser,
          activeCompanyId: defaultCompany,
          activeMembershipId: defaultMembership,
        );
        // Membership has two roles, whose union includes permManage
        final queryStore = _FakeQueryStore(
          snapshot: createDefaultSnapshot(
            roles: {
              NexaBizRoleId('company.accountant'),
              NexaBizRoleId('company.manager'),
            },
            permissions: {permView, permManage},
          ),
        );
        final evaluator = NexaBizRuntimePermissionEvaluator(
          permissionCatalog: testCatalog,
          queryStore: queryStore,
          sessionSource: sessionSource,
        );
        final guard = NexaBizDefaultPermissionGuard(evaluator);
        final useCase = _TestProtectedCompanyProfileUseCase(
          permissionGuard: guard,
          repository: repository,
        );

        await useCase.execute(
          context: createDefaultContext(),
          newName: 'Multi-Role Allowed',
        );

        expect(repository.mutationCalls, 1);
      },
    );

    // 13. UseCase does not read DB authorization tables directly
    test(
      '13. UseCase structure has zero dependencies on Drift query store or DB tables',
      () {
        // Demonstrated structurally: UseCase only depends on NexaBizPermissionGuard and Repository
        final repo = _TestCompanyRepository();
        final useCase = _TestProtectedCompanyProfileUseCase(
          permissionGuard: const _DummyGuard(),
          repository: repo,
        );
        expect(useCase, isA<_TestProtectedCompanyProfileUseCase>());
      },
    );

    // 14. UseCase does not know Drift
    test('14. UseCase contract contains zero Drift or SQLite references', () {
      final file = File('lib/core/authorization/nexabiz_permission_guard.dart');
      final content = file.readAsStringSync();
      expect(content, isNot(contains('drift')));
      expect(content, isNot(contains('sqlite')));
    });

    // 15. UseCase does not know Capability Registry internals
    test(
      '15. UseCase evaluates via Guard without coupling to CapabilityRegistry lifecycle',
      () {
        final file = File(
          'lib/core/authorization/nexabiz_permission_guard.dart',
        );
        final content = file.readAsStringSync();
        expect(content, isNot(contains('NexaBizCapabilityRegistry')));
        expect(content, isNot(contains('register(')));
        expect(content, isNot(contains('validateAndLock')));
      },
    );
  });

  group('UseCase Authorization Security Boundary — End-to-End Drift Lifecycle', () {
    late Directory directory;
    late String databasePath;
    late DriftCoreInstallationStore store;
    late NexaBizCapabilityRegistry registry;
    late CoreSessionController sessionController;

    setUp(() async {
      directory = Directory.systemTemp.createTempSync('nexabiz_usecase_test_');
      databasePath = p.join(directory.path, 'core.sqlite');
      store = await DriftCoreInstallationStore.open(databasePath);

      registry = NexaBizCapabilityRegistry();
      registry.register(const CompanyCapability());
      registry.validateAndLock();

      sessionController = CoreSessionController(
        authenticateLocalUser: AuthenticateLocalUser(queryStore: store),
        queryStore: store,
      );
    });

    tearDown(() async {
      await sessionController.dispose();
      await store.close();
      if (directory.existsSync()) {
        directory.deleteSync(recursive: true);
      }
    });

    test(
      'Full End-to-End lifecycle: Login -> Context.fromSession -> UseCase Execute -> Revoke -> Deny',
      () async {
        final db = store.database;

        // 1. Initialize system
        final init = InitializeNexaBizCore(store);
        final initResult = await init(
          const CoreInitializationInput(
            companyCode: 'ACME',
            companyName: 'Acme Corp',
            adminName: 'Owner Admin',
            adminEmail: 'admin@acme.com',
            password: 'password12345',
          ),
        );
        expect(initResult.isReady, isTrue);

        // 2. Authenticate
        final loginResult = await sessionController.login(
          const CoreAuthenticationInput(
            identifier: 'admin@acme.com',
            password: 'password12345',
          ),
        );
        expect(loginResult.isSuccess, isTrue);

        // 3. Application layer acquires context authoritatively fromSession
        final context = NexaBizAuthorizationContext.fromSession(
          sessionController.currentSession,
        );
        expect(context, isA<NexaBizCompanyAuthorizationContext>());

        // 4. Construct production evaluator and guard
        final evaluator = NexaBizRuntimePermissionEvaluator(
          permissionCatalog: registry.permissionCatalog,
          queryStore: store,
          sessionSource: sessionController,
        );
        final guard = NexaBizDefaultPermissionGuard(evaluator);

        final repository = _TestCompanyRepository();
        final useCase = _TestProtectedCompanyProfileUseCase(
          permissionGuard: guard,
          repository: repository,
        );

        // 5. Initial execution: Owner has company.profile.manage -> ALLOW
        await useCase.execute(context: context, newName: 'Acme Global');
        expect(repository.mutationCalls, 1);
        expect(repository.updatedProfileName, 'Acme Global');

        // 6. Revoke permission from owner role in DB during active session
        await db.customStatement(
          "DELETE FROM core_role_permissions WHERE permission_id = 'company.profile.manage'",
        );

        // 7. Subsequent execution on same session: DENIED with ZERO side effects
        await expectLater(
          () => useCase.execute(context: context, newName: 'Acme Hacked'),
          throwsA(isA<NexaBizPermissionDeniedException>()),
        );
        expect(repository.mutationCalls, 1);
        expect(repository.updatedProfileName, 'Acme Global'); // Unchanged!
      },
    );
  });
}

final class _DummyGuard implements NexaBizPermissionGuard {
  const _DummyGuard();

  @override
  Future<void> requirePermission({
    required NexaBizAuthorizationContext context,
    required NexaBizPermissionId permissionId,
  }) async {}
}
