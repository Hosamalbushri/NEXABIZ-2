import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:nexabiz/app/app.dart';
import 'package:nexabiz/app/authorization/nexabiz_authorization_administration.dart';
import 'package:nexabiz/app/authorization/nexabiz_authorization_invalidation_signal.dart';
import 'package:nexabiz/app/bootstrap/core_session_listenable.dart';
import 'package:nexabiz/app/localization/app_locale_controller.dart';
import 'package:nexabiz/app/router/nexabiz_router_adapter.dart';
import 'package:nexabiz/core/authorization/administration/nexabiz_authorization_administration_models.dart';
import 'package:nexabiz/core/authorization/administration/nexabiz_authorization_administration_permissions.dart';
import 'package:nexabiz/core/authorization/administration/nexabiz_authorization_administration_store.dart';
import 'package:nexabiz/core/authorization/core_authorization_query_store.dart';
import 'package:nexabiz/core/authorization/nexabiz_authorization_context.dart';
import 'package:nexabiz/core/authorization/nexabiz_authorization_session_source.dart';
import 'package:nexabiz/core/authorization/nexabiz_membership_authorization_snapshot.dart';
import 'package:nexabiz/core/authorization/nexabiz_membership_id.dart';
import 'package:nexabiz/core/authorization/nexabiz_permission_catalog.dart';
import 'package:nexabiz/core/authorization/nexabiz_permission_guard.dart';
import 'package:nexabiz/core/authorization/nexabiz_runtime_permission_evaluator.dart';
import 'package:nexabiz/core/capabilities/nexabiz_capability_registry.dart';
import 'package:nexabiz/core/company/nexabiz_company_scope.dart';
import 'package:nexabiz/core/identity/authenticate_local_user.dart';
import 'package:nexabiz/core/navigation/nexabiz_navigation_registry.dart';
import 'package:nexabiz/core/permissions/nexabiz_permission_intent.dart';
import 'package:nexabiz/core/roles/nexabiz_role_id.dart';
import 'package:nexabiz/core/session/core_session_controller.dart';
import 'package:nexabiz/core/session/nexabiz_session.dart';
import 'package:nexabiz/core/setup/initialize_nexabiz_core.dart';
import 'package:nexabiz/core/setup/nexabiz_setup_readiness.dart';
import 'package:nexabiz/packages/identity/identity_capability.dart';
import 'package:nexabiz/packages/permissions/permissions_capability.dart';
import 'package:nexabiz/packages/permissions/presentation/roles_screen.dart';
import 'package:nexabiz/packages/permissions/presentation/unauthorized_screen.dart';
import 'package:nexabiz/packages/settings/settings_capability.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ---------------------------------------------------------------------------
// Test Doubles
// ---------------------------------------------------------------------------

final _testUserId = NexaBizUserId('usr-test-101');
final _testCompanyId = NexaBizCompanyId('cmp-test-202');
final _testMembershipId = NexaBizMembershipId('mem-test-303');
final _testRoleId = NexaBizRoleId('company.owner');

class _TestCatalog implements NexaBizPermissionCatalog {
  final Set<NexaBizPermissionId> declared;
  _TestCatalog(this.declared);

  @override
  Set<NexaBizPermissionId> get declaredPermissions => declared;

  @override
  bool isDeclared(NexaBizPermissionId permissionId) =>
      declared.contains(permissionId);
}

class _TestFakeSessionSource implements NexaBizAuthorizationSessionSource {
  _TestFakeSessionSource({
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

class _TestFakeQueryStore implements CoreAuthorizationQueryStore {
  NexaBizMembershipAuthorizationSnapshot? snapshot;
  bool shouldThrow = false;

  _TestFakeQueryStore({this.snapshot});

  @override
  Future<NexaBizMembershipAuthorizationSnapshot?>
  readMembershipAuthorizationSnapshot(String membershipId) async {
    if (shouldThrow) throw Exception('Simulated database fault');
    return snapshot;
  }
}

class _MockIdentityStore implements CoreIdentityQueryStore {
  @override
  Future<CoreAuthUserRef?> findUserByIdentifier(
    String normalizedIdentifier,
  ) async => null;

  @override
  Future<CorePreparedCredential?> readUserCredential(String userId) async =>
      null;

  @override
  Future<CoreAuthIdentitySnapshot?> readAuthenticationSnapshot(
    String userId,
  ) async => null;

  @override
  Future<CoreLoginLockout?> checkLockout(
    String normalizedIdentifier,
    DateTime nowUtc,
  ) async => null;

  @override
  Future<CoreLoginLockout?> recordFailedAttempt(
    String normalizedIdentifier,
    DateTime nowUtc,
  ) async => null;

  @override
  Future<void> clearFailedAttempts(String normalizedIdentifier) async {}

  @override
  Future<bool> isSessionEligible(String userId, String? companyId) async =>
      true;

  @override
  Stream<bool> watchSessionEligibility(String userId, String? companyId) =>
      const Stream.empty();
}

class _FakeAdminStore implements NexaBizAuthorizationAdministrationStore {
  final Map<String, List<NexaBizCompanyRoleSummary>> rolesByCompany = {};
  final Map<String, NexaBizCompanyRoleDetails> roleDetailsByRole = {};

  NexaBizCompanyRoleSummary dummySummary({
    required NexaBizCompanyId companyId,
    required NexaBizRoleId roleId,
    String name = 'Owner',
  }) {
    return NexaBizCompanyRoleSummary(
      companyId: companyId,
      roleId: roleId,
      metadata: NexaBizRoleMetadata(displayName: NexaBizRoleDisplayName(name)),
      kind: NexaBizCompanyRoleKind.builtIn,
      membershipAssignmentCount: 1,
    );
  }

  @override
  Future<NexaBizAuthorizationAdministrationPage<NexaBizCompanyRoleSummary>>
  listCompanyRoles({
    required NexaBizCompanyId companyId,
    required NexaBizAuthorizationAdministrationPageRequest page,
    NexaBizCompanyRoleFilter? filter,
  }) async {
    return NexaBizAuthorizationAdministrationPage(
      items: [
        dummySummary(companyId: companyId, roleId: _testRoleId, name: 'Owner'),
      ],
      nextCursor: null,
    );
  }

  @override
  Future<NexaBizCompanyRoleDetails> readCompanyRole({
    required NexaBizCompanyId companyId,
    required NexaBizRoleId roleId,
  }) async {
    return NexaBizCompanyRoleDetails(
      companyId: companyId,
      roleId: roleId,
      metadata: NexaBizRoleMetadata(
        displayName: NexaBizRoleDisplayName('Owner'),
      ),
      kind: NexaBizCompanyRoleKind.builtIn,
      membershipAssignmentCount: 1,
      permissionAssignmentCount: 1,
      createdAt: DateTime.utc(2026, 1, 1),
      updatedAt: DateTime.utc(2026, 1, 1),
    );
  }

  @override
  Future<
    NexaBizAuthorizationAdministrationPage<NexaBizRolePermissionAssignment>
  >
  listRolePermissions({
    required NexaBizCompanyId companyId,
    required NexaBizRoleId roleId,
    required NexaBizAuthorizationAdministrationPageRequest page,
  }) async {
    return NexaBizAuthorizationAdministrationPage(
      items: [
        NexaBizRolePermissionAssignment(
          companyId: companyId,
          roleId: roleId,
          permissionId:
              NexaBizAuthorizationAdministrationPermissions.policyReview,
          assignedAt: DateTime.utc(2026, 1, 1),
        ),
      ],
      nextCursor: null,
    );
  }

  @override
  Future<
    NexaBizAuthorizationAdministrationPage<NexaBizMembershipRoleAssignment>
  >
  listRoleMemberships({
    required NexaBizCompanyId companyId,
    required NexaBizRoleId roleId,
    required NexaBizAuthorizationAdministrationPageRequest page,
  }) async {
    return NexaBizAuthorizationAdministrationPage(items: [], nextCursor: null);
  }

  @override
  Future<
    NexaBizAuthorizationAdministrationPage<NexaBizMembershipRoleAssignment>
  >
  listMembershipRoles({
    required NexaBizCompanyId companyId,
    required NexaBizMembershipId membershipId,
    required NexaBizAuthorizationAdministrationPageRequest page,
  }) async {
    return NexaBizAuthorizationAdministrationPage(items: [], nextCursor: null);
  }

  @override
  Future<NexaBizAuthorizationAdministrationPage<NexaBizAssignableMembership>>
  listAssignableMembershipsForRole({
    required NexaBizCompanyId companyId,
    required NexaBizRoleId roleId,
    required NexaBizAuthorizationAdministrationPageRequest page,
    String? search,
  }) async {
    return NexaBizAuthorizationAdministrationPage(items: [], nextCursor: null);
  }

  @override
  Future<NexaBizMembershipEffectivePermissionInfo>
  inspectMembershipEffectivePermissions({
    required NexaBizCompanyId companyId,
    required NexaBizMembershipId membershipId,
  }) async {
    return NexaBizMembershipEffectivePermissionInfo(
      companyId: companyId,
      membershipId: membershipId,
      userId: _testUserId,
      roleIds: {_testRoleId},
      permissionIds: {
        NexaBizAuthorizationAdministrationPermissions.policyReview,
      },
      isEligible: true,
    );
  }

  @override
  Future<
    NexaBizAuthorizationAdministrationMutationResult<NexaBizCompanyRoleDetails>
  >
  createCompanyRole({
    required NexaBizCompanyId companyId,
    required NexaBizRoleId roleId,
    required NexaBizRoleMetadata metadata,
  }) => throw UnimplementedError('Read-only in Step 05');

  @override
  Future<
    NexaBizAuthorizationAdministrationMutationResult<NexaBizCompanyRoleDetails>
  >
  updateCompanyRoleMetadata({
    required NexaBizCompanyId companyId,
    required NexaBizRoleId roleId,
    required NexaBizRoleMetadata metadata,
  }) => throw UnimplementedError('Read-only in Step 05');

  @override
  Future<
    NexaBizAuthorizationAdministrationMutationResult<NexaBizCompanyRoleDetails>
  >
  deleteCompanyRole({
    required NexaBizCompanyId companyId,
    required NexaBizRoleId roleId,
  }) => throw UnimplementedError('Read-only in Step 05');

  @override
  Future<
    NexaBizAuthorizationAdministrationMutationResult<
      NexaBizRolePermissionAssignment
    >
  >
  grantPermissionToRole({
    required NexaBizCompanyId companyId,
    required NexaBizRoleId roleId,
    required NexaBizPermissionId permissionId,
  }) => throw UnimplementedError('Read-only in Step 05');

  @override
  Future<
    NexaBizAuthorizationAdministrationMutationResult<
      NexaBizRolePermissionAssignment
    >
  >
  revokePermissionFromRole({
    required NexaBizCompanyId companyId,
    required NexaBizRoleId roleId,
    required NexaBizPermissionId permissionId,
  }) => throw UnimplementedError('Read-only in Step 05');

  @override
  Future<
    NexaBizAuthorizationAdministrationMutationResult<
      NexaBizMembershipRoleAssignment
    >
  >
  assignRoleToMembership({
    required NexaBizCompanyId companyId,
    required NexaBizMembershipId membershipId,
    required NexaBizRoleId roleId,
  }) => throw UnimplementedError('Read-only in Step 05');

  @override
  Future<
    NexaBizAuthorizationAdministrationMutationResult<
      NexaBizMembershipRoleAssignment
    >
  >
  unassignRoleFromMembership({
    required NexaBizCompanyId companyId,
    required NexaBizMembershipId membershipId,
    required NexaBizRoleId roleId,
  }) => throw UnimplementedError('Read-only in Step 05');
}

final class _PassThroughGuard implements NexaBizPermissionGuard {
  const _PassThroughGuard();
  @override
  Future<void> requirePermission({
    required NexaBizAuthorizationContext context,
    required NexaBizPermissionId permissionId,
  }) async {}
}

NexaBizMembershipAuthorizationSnapshot _createSnapshot({
  required Set<NexaBizPermissionId> permissions,
}) {
  return NexaBizMembershipAuthorizationSnapshot(
    membershipId: _testMembershipId,
    companyId: _testCompanyId,
    userId: _testUserId,
    membershipStatus: 'active',
    companyStatus: 'active',
    userStatus: 'active',
    roleIds: {_testRoleId},
    permissionIds: permissions,
  );
}

void main() {
  group('Roles Administration Navigation & Routing Security Verification', () {
    late NexaBizNavigationRegistry registry;
    late CoreSessionController sessionController;
    late _TestFakeSessionSource sessionSource;
    late _TestFakeQueryStore queryStore;
    late _TestCatalog catalog;
    late NexaBizRuntimePermissionEvaluator evaluator;
    late NexaBizAuthorizationInvalidationSignal invalidationSignal;
    late NexaBizAuthorizationAdministration adminFacade;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      await AppLocaleController.initialize();

      sessionController = CoreSessionController(
        authenticateLocalUser: AuthenticateLocalUser(
          queryStore: _MockIdentityStore(),
        ),
        queryStore: _MockIdentityStore(),
      );

      final caps = NexaBizCapabilityRegistry();
      caps.register(PermissionsCapability());
      caps.register(SettingsCapability(sessionController: sessionController));
      caps.register(IdentityCapability(sessionController: sessionController));
      caps.validateAndLock();

      registry = NexaBizNavigationRegistry()..collectAndLock(caps);

      sessionSource = _TestFakeSessionSource(
        activeSessionId: 'session-live',
        activeUserId: _testUserId,
        activeCompanyId: _testCompanyId,
        activeMembershipId: _testMembershipId,
      );

      queryStore = _TestFakeQueryStore(
        snapshot: _createSnapshot(
          permissions: {
            NexaBizAuthorizationAdministrationPermissions.policyReview,
          },
        ),
      );

      catalog = _TestCatalog({
        NexaBizAuthorizationAdministrationPermissions.policyReview,
        NexaBizAuthorizationAdministrationPermissions.roleManage,
      });

      evaluator = NexaBizRuntimePermissionEvaluator(
        permissionCatalog: catalog,
        queryStore: queryStore,
        sessionSource: sessionSource,
      );

      invalidationSignal = NexaBizAuthorizationInvalidationSignal();

      final fakeStore = _FakeAdminStore();
      adminFacade = NexaBizAuthorizationAdministration.create(
        permissionGuard: const _PassThroughGuard(),
        queryStore: fakeStore,
        mutationStore: fakeStore,
        invalidationSignal: invalidationSignal,
        permissionCatalog: NexaBizImmutablePermissionCatalog({
          NexaBizAuthorizationAdministrationPermissions.policyReview,
          NexaBizAuthorizationAdministrationPermissions.roleManage,
        }),
      );
    });

    void setControllerActiveSession() {
      sessionController.setSessionForTesting(
        NexaBizSession.active(
          sessionId: 'session-live',
          userId: _testUserId,
          companyId: _testCompanyId,
          membershipId: _testMembershipId,
          companyName: 'Test Company',
          role: 'Owner',
        ),
      );
    }

    GoRouter buildRouter({String initialLocation = '/permissions/roles'}) {
      final adapter = NexaBizGoRouterAdapter(registry);
      return adapter.createRouter(
        initialLocation: initialLocation,
        readiness: NexaBizSetupReadiness(
          state: NexaBizSetupState.ready,
          completed: NexaBizSetupReadiness.requiredCoreRequirements,
        ),
        sessionController: sessionController,
        refreshListenable: CoreSessionListenable(sessionController),
        permissionEvaluator: evaluator,
        authorizationInvalidationListenable: invalidationSignal,
      );
    }

    Widget buildApp(GoRouter router) {
      return NexaBizApp(
        router: router,
        sessionController: sessionController,
        permissionEvaluator: evaluator,
        authorizationInvalidationSignal: invalidationSignal,
        authorizationAdministration: adminFacade,
      );
    }

    testWidgets(
      '1. Authorized navigation to /permissions/roles succeeds with policyReview',
      (tester) async {
        setControllerActiveSession();
        queryStore.snapshot = _createSnapshot(
          permissions: {
            NexaBizAuthorizationAdministrationPermissions.policyReview,
          },
        );

        final router = buildRouter(initialLocation: '/permissions/roles');
        addTearDown(router.dispose);

        await tester.pumpWidget(buildApp(router));
        await tester.pumpAndSettle();

        expect(find.byType(RolesScreen), findsOneWidget);
        expect(find.text('Roles & Access Control'), findsOneWidget);
      },
    );

    testWidgets(
      '2. Unauthorized navigation to /permissions/roles redirects to /unauthorized without policyReview',
      (tester) async {
        setControllerActiveSession();
        queryStore.snapshot = _createSnapshot(permissions: {});

        final router = buildRouter(initialLocation: '/permissions/roles');
        addTearDown(router.dispose);

        await tester.pumpWidget(buildApp(router));
        await tester.pumpAndSettle();

        expect(find.byType(UnauthorizedScreen), findsOneWidget);
        expect(find.byType(RolesScreen), findsNothing);
      },
    );

    testWidgets(
      '3. Live revocation during active viewing of /permissions/roles immediately evicts to /unauthorized',
      (tester) async {
        setControllerActiveSession();
        queryStore.snapshot = _createSnapshot(
          permissions: {
            NexaBizAuthorizationAdministrationPermissions.policyReview,
          },
        );

        final router = buildRouter(initialLocation: '/permissions/roles');
        addTearDown(router.dispose);

        await tester.pumpWidget(buildApp(router));
        await tester.pumpAndSettle();

        expect(find.byType(RolesScreen), findsOneWidget);

        // Revoke permission while active on screen
        queryStore.snapshot = _createSnapshot(permissions: {});
        invalidationSignal.notifyAuthorizationChanged();
        await tester.pumpAndSettle();

        expect(find.byType(UnauthorizedScreen), findsOneWidget);
        expect(find.byType(RolesScreen), findsNothing);
      },
    );

    testWidgets(
      '4. Settings entry: Security & Access Controls is visible when holding policyReview',
      (tester) async {
        tester.view.physicalSize = const Size(1200, 1400);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        setControllerActiveSession();
        queryStore.snapshot = _createSnapshot(
          permissions: {
            NexaBizAuthorizationAdministrationPermissions.policyReview,
          },
        );

        final router = buildRouter(initialLocation: '/settings');
        addTearDown(router.dispose);

        await tester.pumpWidget(buildApp(router));
        await tester.pumpAndSettle();

        expect(find.text('Security & Access Controls'), findsOneWidget);
      },
    );

    testWidgets(
      '5. Settings entry: Security & Access Controls is hidden when lacking policyReview',
      (tester) async {
        tester.view.physicalSize = const Size(1200, 1400);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        setControllerActiveSession();
        queryStore.snapshot = _createSnapshot(permissions: {});

        final router = buildRouter(initialLocation: '/settings');
        addTearDown(router.dispose);

        await tester.pumpWidget(buildApp(router));
        await tester.pumpAndSettle();

        expect(find.text('Security & Access Controls'), findsNothing);
      },
    );

    testWidgets(
      '6. Settings entry: tapping Security & Access Controls pushes /permissions/roles',
      (tester) async {
        tester.view.physicalSize = const Size(1200, 1400);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        setControllerActiveSession();
        queryStore.snapshot = _createSnapshot(
          permissions: {
            NexaBizAuthorizationAdministrationPermissions.policyReview,
          },
        );

        final router = buildRouter(initialLocation: '/settings');
        addTearDown(router.dispose);

        await tester.pumpWidget(buildApp(router));
        await tester.pumpAndSettle();

        expect(find.text('Security & Access Controls'), findsOneWidget);

        await tester.tap(find.text('Security & Access Controls'));
        await tester.pumpAndSettle();

        expect(find.byType(RolesScreen), findsOneWidget);
      },
    );
  });
}
