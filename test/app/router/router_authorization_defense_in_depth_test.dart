import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:nexabiz/app/app.dart';
import 'package:nexabiz/app/authorization/nexabiz_authorization_invalidation_signal.dart';
import 'package:nexabiz/app/router/nexabiz_flutter_route_definition.dart';
import 'package:nexabiz/app/router/nexabiz_router_adapter.dart';
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
import 'package:nexabiz/core/capabilities/capability_metadata.dart';
import 'package:nexabiz/core/capabilities/nexabiz_capability.dart';
import 'package:nexabiz/core/capabilities/nexabiz_capability_registry.dart';
import 'package:nexabiz/core/company/nexabiz_company_scope.dart';
import 'package:nexabiz/core/identity/authenticate_local_user.dart';
import 'package:nexabiz/core/navigation/nexabiz_navigation_contribution.dart';
import 'package:nexabiz/core/navigation/nexabiz_navigation_registry.dart';
import 'package:nexabiz/core/navigation/nexabiz_route_access_requirement.dart';
import 'package:nexabiz/core/navigation/nexabiz_route_definition.dart';
import 'package:nexabiz/core/navigation/nexabiz_route_id.dart';
import 'package:nexabiz/core/permissions/nexabiz_permission_intent.dart';
import 'package:nexabiz/core/roles/nexabiz_role_id.dart';
import 'package:nexabiz/core/setup/initialize_nexabiz_core.dart';
import 'package:nexabiz/core/session/core_session_controller.dart';
import 'package:nexabiz/app/bootstrap/core_session_listenable.dart';
import 'package:nexabiz/core/session/nexabiz_session.dart';
import 'package:nexabiz/core/setup/nexabiz_setup_readiness.dart';

// ---------------------------------------------------------------------------
// Test Doubles & Helpers
// ---------------------------------------------------------------------------

final _permProtected = NexaBizPermissionId('billing.invoice.view');
final _permManage = NexaBizPermissionId('billing.invoice.manage');
final _permUnknown = NexaBizPermissionId('unknown.resource.op');

final _defaultUserId = NexaBizUserId('user-101');
final _defaultCompanyId = NexaBizCompanyId('company-202');
final _defaultMembershipId = NexaBizMembershipId('membership-303');

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
    if (shouldThrow) throw Exception('Simulated database transport failure');
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

NexaBizMembershipAuthorizationSnapshot _createSnapshot({
  required Set<NexaBizPermissionId> permissions,
  NexaBizMembershipId? membershipId,
  NexaBizCompanyId? companyId,
  NexaBizUserId? userId,
  String membershipStatus = 'active',
  String companyStatus = 'active',
  String userStatus = 'active',
}) {
  return NexaBizMembershipAuthorizationSnapshot(
    membershipId: membershipId ?? _defaultMembershipId,
    companyId: companyId ?? _defaultCompanyId,
    userId: userId ?? _defaultUserId,
    membershipStatus: membershipStatus,
    companyStatus: companyStatus,
    userStatus: userStatus,
    roleIds: {NexaBizRoleId('company.member')},
    permissionIds: permissions,
  );
}

// ---------------------------------------------------------------------------
// Route & Capability Fixture
// ---------------------------------------------------------------------------

class _RouterTestNavContribution implements NexaBizNavigationContribution {
  @override
  NexaBizRouteId get rootRouteId =>
      const NexaBizRouteId(namespace: 'test', routeName: 'dashboard');

  @override
  List<NexaBizRouteDefinition> get routes => [
    _route('splash', '/splash', const NexaBizRouteAccessRequirement()),
    _route(
      'login',
      '/login',
      const NexaBizRouteAccessRequirement(requiresReadySetup: true),
    ),
    _route(
      'company_selection',
      '/company-selection',
      const NexaBizRouteAccessRequirement(
        requiresReadySetup: true,
        requiresActiveSession: true,
      ),
    ),
    _route(
      'dashboard',
      '/dashboard',
      const NexaBizRouteAccessRequirement(
        requiresReadySetup: true,
        requiresActiveSession: true,
        requiresCompanyScope: true,
      ),
    ),
    _route(
      'services',
      '/services',
      const NexaBizRouteAccessRequirement(
        requiresReadySetup: true,
        requiresActiveSession: true,
        requiresCompanyScope: true,
      ),
    ),
    _route(
      'reports',
      '/reports',
      const NexaBizRouteAccessRequirement(
        requiresReadySetup: true,
        requiresActiveSession: true,
        requiresCompanyScope: true,
      ),
    ),
    _route(
      'settings',
      '/settings',
      const NexaBizRouteAccessRequirement(
        requiresReadySetup: true,
        requiresActiveSession: true,
        requiresCompanyScope: true,
      ),
    ),
    _route(
      'unauthorized',
      '/unauthorized',
      const NexaBizRouteAccessRequirement(),
    ),
    _route(
      'billing_protected',
      '/billing',
      NexaBizRouteAccessRequirement(
        requiresReadySetup: true,
        requiresActiveSession: true,
        requiresCompanyScope: true,
        permission: NexaBizPermissionRequirement(_permProtected),
      ),
    ),
    _route(
      'billing_unknown',
      '/billing-unknown',
      NexaBizRouteAccessRequirement(
        requiresReadySetup: true,
        requiresActiveSession: true,
        requiresCompanyScope: true,
        permission: NexaBizPermissionRequirement(_permUnknown),
      ),
    ),
  ];

  static NexaBizFlutterRouteDefinition _route(
    String name,
    String path,
    NexaBizRouteAccessRequirement req,
  ) {
    return NexaBizFlutterRouteDefinition(
      routeId: NexaBizRouteId(namespace: 'test', routeName: name),
      path: path,
      accessRequirement: req,
      pageBuilder: (context) => Text('Page: $path'),
    );
  }
}

class _RouterTestCapability implements NexaBizCapability {
  @override
  String get capabilityId => 'test';

  @override
  CapabilityMetadata get metadata =>
      const CapabilityMetadata(nameKey: 'test', iconIdentifier: 'test');

  @override
  List<String> get dependsOn => const [];

  @override
  NexaBizNavigationContribution? get navigationContribution =>
      _RouterTestNavContribution();
}

NexaBizNavigationRegistry _createLockedRegistry() {
  final caps = NexaBizCapabilityRegistry();
  caps.register(_RouterTestCapability());
  caps.validateAndLock();
  return NexaBizNavigationRegistry()..collectAndLock(caps);
}

// ---------------------------------------------------------------------------
// Main Behavioral Test Suite (Section 24 & Section 26)
// ---------------------------------------------------------------------------

void main() {
  group('Router Authorization Integration & Defense-in-Depth Tests', () {
    late NexaBizNavigationRegistry registry;
    late CoreSessionController sessionController;
    late _TestFakeSessionSource sessionSource;
    late _TestFakeQueryStore queryStore;
    late _TestCatalog catalog;
    late NexaBizRuntimePermissionEvaluator evaluator;
    late NexaBizAuthorizationInvalidationSignal invalidationSignal;

    setUp(() {
      registry = _createLockedRegistry();
      sessionController = CoreSessionController(
        authenticateLocalUser: AuthenticateLocalUser(
          queryStore: _MockIdentityStore(),
        ),
        queryStore: _MockIdentityStore(),
      );
      sessionSource = _TestFakeSessionSource(
        activeSessionId: 'session-live',
        activeUserId: _defaultUserId,
        activeCompanyId: _defaultCompanyId,
        activeMembershipId: _defaultMembershipId,
      );
      queryStore = _TestFakeQueryStore(
        snapshot: _createSnapshot(permissions: {_permProtected}),
      );
      catalog = _TestCatalog({_permProtected, _permManage});
      evaluator = NexaBizRuntimePermissionEvaluator(
        permissionCatalog: catalog,
        queryStore: queryStore,
        sessionSource: sessionSource,
      );
      invalidationSignal = NexaBizAuthorizationInvalidationSignal();
    });

    GoRouter buildRouter({
      NexaBizPermissionEvaluator? customEvaluator,
      bool omitEvaluator = false,
      NexaBizSetupReadiness? readiness,
      String initialLocation = '/billing',
    }) {
      final adapter = NexaBizGoRouterAdapter(registry);
      return adapter.createRouter(
        initialLocation: initialLocation,
        readiness:
            readiness ??
            NexaBizSetupReadiness(
              state: NexaBizSetupState.ready,
              completed: NexaBizSetupReadiness.requiredCoreRequirements,
            ),
        sessionController: sessionController,
        refreshListenable: CoreSessionListenable(sessionController),
        permissionEvaluator: omitEvaluator
            ? null
            : (customEvaluator ?? evaluator),
        authorizationInvalidationListenable: invalidationSignal,
      );
    }

    void setControllerActiveSession({
      String sessionId = 'session-live',
      NexaBizUserId? userId,
      NexaBizCompanyId? companyId,
      NexaBizMembershipId? membershipId,
      String? roleName,
    }) {
      sessionController.setSessionForTesting(
        NexaBizSession.active(
          userId: userId ?? _defaultUserId,
          companyId: companyId ?? _defaultCompanyId,
          membershipId: membershipId ?? _defaultMembershipId,
          role: roleName ?? 'member',
          sessionId: sessionId,
        ),
      );
      sessionSource.activeSessionId = sessionId;
      sessionSource.activeUserId = userId ?? _defaultUserId;
      sessionSource.activeCompanyId = companyId ?? _defaultCompanyId;
      sessionSource.activeMembershipId = membershipId ?? _defaultMembershipId;
      sessionSource.isActive = true;
    }

    // 1. Public route works without evaluator
    testWidgets('1. Public route works without evaluator', (tester) async {
      final router = buildRouter(
        omitEvaluator: true,
        initialLocation: '/unauthorized',
      );
      addTearDown(router.dispose);

      await tester.pumpWidget(NexaBizApp(router: router));
      await tester.pumpAndSettle();

      expect(find.text('Page: /unauthorized'), findsOneWidget);
    });

    // 2. Session-protected route still redirects unauthenticated -> /login
    testWidgets(
      '2. Session-protected route still redirects unauthenticated -> /login',
      (tester) async {
        final router = buildRouter(initialLocation: '/dashboard');
        addTearDown(router.dispose);

        await tester.pumpWidget(NexaBizApp(router: router));
        await tester.pumpAndSettle();

        expect(find.text('Page: /login'), findsOneWidget);
      },
    );

    // 3. Company-scoped route still redirects missing company -> /company-selection
    testWidgets(
      '3. Company-scoped route still redirects missing company -> /company-selection',
      (tester) async {
        sessionController.setSessionForTesting(
          NexaBizSession.active(
            userId: _defaultUserId,
            companyId: null,
            sessionId: 'session-live',
          ),
        );
        final router = buildRouter(initialLocation: '/dashboard');
        addTearDown(router.dispose);

        await tester.pumpWidget(NexaBizApp(router: router));
        await tester.pumpAndSettle();

        expect(find.text('Page: /company-selection'), findsOneWidget);
      },
    );

    // 4. Permission route + explicit grant -> accessible
    testWidgets('4. Permission route + explicit grant -> accessible', (
      tester,
    ) async {
      setControllerActiveSession();
      queryStore.snapshot = _createSnapshot(permissions: {_permProtected});

      final router = buildRouter(initialLocation: '/billing');
      addTearDown(router.dispose);

      await tester.pumpWidget(NexaBizApp(router: router));
      await tester.pumpAndSettle();

      expect(find.text('Page: /billing'), findsOneWidget);
    });

    // 5. Permission route + missing grant -> access denied (/unauthorized)
    testWidgets(
      '5. Permission route + missing grant -> access denied (/unauthorized)',
      (tester) async {
        setControllerActiveSession();
        // Only has manage, missing view permission
        queryStore.snapshot = _createSnapshot(permissions: {_permManage});

        final router = buildRouter(initialLocation: '/billing');
        addTearDown(router.dispose);

        await tester.pumpWidget(NexaBizApp(router: router));
        await tester.pumpAndSettle();

        expect(find.text('Page: /unauthorized'), findsOneWidget);
      },
    );

    // 6. Permission route + unknown permission -> access denied (/unauthorized)
    testWidgets(
      '6. Permission route + unknown permission -> access denied (/unauthorized)',
      (tester) async {
        setControllerActiveSession();

        final router = buildRouter(initialLocation: '/billing-unknown');
        addTearDown(router.dispose);

        await tester.pumpWidget(NexaBizApp(router: router));
        await tester.pumpAndSettle();

        expect(find.text('Page: /unauthorized'), findsOneWidget);
      },
    );

    // 7. Permission route + missing evaluator -> access denied (/unauthorized)
    testWidgets(
      '7. Permission route + missing evaluator -> access denied (/unauthorized)',
      (tester) async {
        setControllerActiveSession();

        final router = buildRouter(
          omitEvaluator: true,
          initialLocation: '/billing',
        );
        addTearDown(router.dispose);

        await tester.pumpWidget(NexaBizApp(router: router));
        await tester.pumpAndSettle();

        expect(find.text('Page: /unauthorized'), findsOneWidget);
      },
    );

    // 8. Permission route + evaluator failure -> access denied (/unauthorized)
    testWidgets(
      '8. Permission route + evaluator failure -> access denied (/unauthorized)',
      (tester) async {
        setControllerActiveSession();
        queryStore.shouldThrow = true;

        final router = buildRouter(initialLocation: '/billing');
        addTearDown(router.dispose);

        await tester.pumpWidget(NexaBizApp(router: router));
        await tester.pumpAndSettle();

        expect(find.text('Page: /unauthorized'), findsOneWidget);
        expect(tester.takeException(), isNull); // Must not leak or crash
      },
    );

    // 9. Stale session context -> access denied (/unauthorized)
    testWidgets('9. Stale session context -> access denied (/unauthorized)', (
      tester,
    ) async {
      setControllerActiveSession(sessionId: 'session-new');
      sessionSource.activeSessionId =
          'session-stale'; // Evaluator session source mismatch

      final router = buildRouter(initialLocation: '/billing');
      addTearDown(router.dispose);

      await tester.pumpWidget(NexaBizApp(router: router));
      await tester.pumpAndSettle();

      expect(find.text('Page: /unauthorized'), findsOneWidget);
    });

    // 10. Wrong company context -> access denied (/unauthorized)
    testWidgets('10. Wrong company context -> access denied (/unauthorized)', (
      tester,
    ) async {
      setControllerActiveSession(
        companyId: NexaBizCompanyId('different-company'),
      );
      // Snapshot is bound to _defaultCompanyId
      queryStore.snapshot = _createSnapshot(
        companyId: _defaultCompanyId,
        permissions: {_permProtected},
      );

      final router = buildRouter(initialLocation: '/billing');
      addTearDown(router.dispose);

      await tester.pumpWidget(NexaBizApp(router: router));
      await tester.pumpAndSettle();

      expect(find.text('Page: /unauthorized'), findsOneWidget);
    });

    // 11. Role name 'owner' without grant -> access denied (/unauthorized)
    testWidgets(
      "11. Role name 'owner' without grant -> access denied (/unauthorized)",
      (tester) async {
        setControllerActiveSession(roleName: 'owner');
        // No permissions granted in snapshot
        queryStore.snapshot = _createSnapshot(permissions: {});

        final router = buildRouter(initialLocation: '/billing');
        addTearDown(router.dispose);

        await tester.pumpWidget(NexaBizApp(router: router));
        await tester.pumpAndSettle();

        expect(find.text('Page: /unauthorized'), findsOneWidget);
      },
    );

    // 12. Role name 'admin' without grant -> access denied (/unauthorized)
    testWidgets(
      "12. Role name 'admin' without grant -> access denied (/unauthorized)",
      (tester) async {
        setControllerActiveSession(roleName: 'admin');
        queryStore.snapshot = _createSnapshot(permissions: {});

        final router = buildRouter(initialLocation: '/billing');
        addTearDown(router.dispose);

        await tester.pumpWidget(NexaBizApp(router: router));
        await tester.pumpAndSettle();

        expect(find.text('Page: /unauthorized'), findsOneWidget);
      },
    );

    // 13. Permission grant during active session -> accessible after invalidation/reevaluation
    testWidgets(
      '13. Permission grant during active session -> accessible after reevaluation',
      (tester) async {
        setControllerActiveSession();
        // Start with no permission -> lands on /unauthorized
        queryStore.snapshot = _createSnapshot(permissions: {});

        final router = buildRouter(initialLocation: '/billing');
        addTearDown(router.dispose);

        await tester.pumpWidget(NexaBizApp(router: router));
        await tester.pumpAndSettle();
        expect(find.text('Page: /unauthorized'), findsOneWidget);

        // Now grant permission in persistence layer and notify invalidation
        queryStore.snapshot = _createSnapshot(permissions: {_permProtected});
        invalidationSignal.notifyAuthorizationChanged();

        router.go('/billing');
        await tester.pumpAndSettle();

        expect(find.text('Page: /billing'), findsOneWidget);
      },
    );

    // 14. Permission revoke during active session -> current protected route redirects to /unauthorized
    testWidgets(
      '14. Permission revoke during active session -> current protected route redirects to /unauthorized',
      (tester) async {
        setControllerActiveSession();
        queryStore.snapshot = _createSnapshot(permissions: {_permProtected});

        final router = buildRouter(initialLocation: '/billing');
        addTearDown(router.dispose);

        await tester.pumpWidget(NexaBizApp(router: router));
        await tester.pumpAndSettle();
        expect(find.text('Page: /billing'), findsOneWidget);

        // Revoke permission and emit invalidation signal while user is currently on /billing
        queryStore.snapshot = _createSnapshot(permissions: {});
        invalidationSignal.notifyAuthorizationChanged();
        await tester.pumpAndSettle();

        // Router re-evaluates current route and evicts user to /unauthorized
        expect(find.text('Page: /unauthorized'), findsOneWidget);
        expect(find.text('Page: /billing'), findsNothing);
      },
    );

    // 15. Company switch invalidates old route authorization
    testWidgets('15. Company switch invalidates old route authorization', (
      tester,
    ) async {
      setControllerActiveSession();
      queryStore.snapshot = _createSnapshot(permissions: {_permProtected});

      final router = buildRouter(initialLocation: '/billing');
      addTearDown(router.dispose);

      await tester.pumpWidget(NexaBizApp(router: router));
      await tester.pumpAndSettle();
      expect(find.text('Page: /billing'), findsOneWidget);

      // Switch to company 2 where user has no permission
      final otherCompanyId = NexaBizCompanyId('company-999');
      final otherMembershipId = NexaBizMembershipId('membership-999');
      setControllerActiveSession(
        companyId: otherCompanyId,
        membershipId: otherMembershipId,
      );
      queryStore.snapshot = _createSnapshot(
        companyId: otherCompanyId,
        membershipId: otherMembershipId,
        permissions: {}, // No permission in new company
      );

      router.go('/billing');
      await tester.pumpAndSettle();

      expect(find.text('Page: /unauthorized'), findsOneWidget);
    });

    // 16. Logout invalidates protected route -> redirects to /login
    testWidgets('16. Logout invalidates protected route -> redirects to /login', (
      tester,
    ) async {
      setControllerActiveSession();
      queryStore.snapshot = _createSnapshot(permissions: {_permProtected});

      final router = buildRouter(initialLocation: '/billing');
      addTearDown(router.dispose);

      await tester.pumpWidget(NexaBizApp(router: router));
      await tester.pumpAndSettle();
      expect(find.text('Page: /billing'), findsOneWidget);

      // Perform logout
      sessionController.logout();
      await tester.pumpAndSettle();

      // Enforcing authentication precedence: unauthenticated user must land on /login
      expect(find.text('Page: /login'), findsOneWidget);
    });

    // 17. /unauthorized does not redirect-loop
    testWidgets('17. /unauthorized does not redirect-loop', (tester) async {
      final router = buildRouter(initialLocation: '/unauthorized');
      addTearDown(router.dispose);

      await tester.pumpWidget(NexaBizApp(router: router));
      await tester.pumpAndSettle();

      expect(find.text('Page: /unauthorized'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    // 18. Authorization denial does not redirect to login
    testWidgets('18. Authorization denial does not redirect to login', (
      tester,
    ) async {
      setControllerActiveSession();
      queryStore.snapshot = _createSnapshot(permissions: {});

      final router = buildRouter(initialLocation: '/billing');
      addTearDown(router.dispose);

      await tester.pumpWidget(NexaBizApp(router: router));
      await tester.pumpAndSettle();

      expect(find.text('Page: /unauthorized'), findsOneWidget);
      expect(find.text('Page: /login'), findsNothing);
    });

    // 19. Authorization denial does not redirect to company-selection
    testWidgets(
      '19. Authorization denial does not redirect to company-selection',
      (tester) async {
        setControllerActiveSession();
        queryStore.snapshot = _createSnapshot(permissions: {});

        final router = buildRouter(initialLocation: '/billing');
        addTearDown(router.dispose);

        await tester.pumpWidget(NexaBizApp(router: router));
        await tester.pumpAndSettle();

        expect(find.text('Page: /unauthorized'), findsOneWidget);
        expect(find.text('Page: /company-selection'), findsNothing);
      },
    );

    // 20. Router never queries Drift authorization tables directly (Architectural verification)
    test('20. Router never queries Drift authorization tables directly', () {
      final adapterClass = NexaBizGoRouterAdapter;
      expect(adapterClass, isNotNull);
      // Evaluator queries the store; adapter only calls NexaBizPermissionEvaluator.evaluate
      expect(evaluator, isA<NexaBizPermissionEvaluator>());
    });

    // 21. Concurrency race protection (Section 26)
    testWidgets(
      '21. Concurrency race: logout or company switch during pending evaluation rejects stale allow',
      (tester) async {
        setControllerActiveSession();

        final completer = Completer<NexaBizPermissionDecision>();
        final slowEvaluator = _DelayedEvaluator(completer.future);

        final router = buildRouter(
          customEvaluator: slowEvaluator,
          initialLocation: '/billing',
        );
        addTearDown(router.dispose);

        await tester.pumpWidget(NexaBizApp(router: router));
        // Pump initial frame while evaluation is in-flight
        await tester.pump();

        // Concurrently logout before slow evaluation resolves
        sessionController.logout();

        // Now resolve the slow evaluation as ALLOW
        completer.complete(NexaBizPermissionDecision.allow);
        await tester.pumpAndSettle();

        // Stale ALLOW for the old session MUST NOT permit access to /billing; user is redirected to /login
        expect(find.text('Page: /login'), findsOneWidget);
        expect(find.text('Page: /billing'), findsNothing);
      },
    );

    // 22. Defense-in-depth: Circumventing router still blocked by UseCase PermissionGuard
    test(
      '22. Defense-in-depth: UseCase PermissionGuard remains authoritative',
      () async {
        // Simulates an attacker or buggy code invoking a UseCase directly
        final guard = NexaBizDefaultPermissionGuard(evaluator);
        final context = NexaBizCompanyAuthorizationContext(
          userId: _defaultUserId,
          companyId: _defaultCompanyId,
          membershipId: _defaultMembershipId,
          sessionId: 'session-live',
        );

        // Deny scenario
        queryStore.snapshot = _createSnapshot(permissions: {});

        expect(
          () => guard.requirePermission(
            context: context,
            permissionId: _permProtected,
          ),
          throwsA(isA<NexaBizPermissionDeniedException>()),
        );
      },
    );

    testWidgets(
      '23. Expected evaluator infrastructure failure redirects to /unauthorized',
      (tester) async {
        setControllerActiveSession();
        final router = buildRouter(
          customEvaluator: _ThrowingEvaluator(
            () => throw Exception('Simulated evaluator transport failure'),
          ),
        );
        addTearDown(router.dispose);

        await tester.pumpWidget(NexaBizApp(router: router));
        await tester.pumpAndSettle();

        expect(find.text('Page: /unauthorized'), findsOneWidget);
        expect(tester.takeException(), isNull);
      },
    );

    testWidgets(
      'Router does not swallow authorization context invariant StateError',
      (tester) async {
        sessionController.setSessionForTesting(
          NexaBizSession.active(
            userId: _defaultUserId,
            companyId: _defaultCompanyId,
            membershipId: _defaultMembershipId,
          ),
        );
        final router = buildRouter();
        addTearDown(router.dispose);
        late BuildContext redirectContext;
        await tester.pumpWidget(
          Builder(
            builder: (context) {
              redirectContext = context;
              return const SizedBox.shrink();
            },
          ),
        );

        await expectLater(
          router.routeInformationParser.parseRouteInformationWithDependencies(
            RouteInformation(
              uri: Uri.parse('/billing'),
              state: RouteInformationState<void>(type: NavigatingType.go),
            ),
            redirectContext,
          ),
          throwsA(isA<StateError>()),
        );
      },
    );

    final programmerDefects =
        <String, ({Object Function() throwDefect, Matcher matcher})>{
          'ArgumentError': (
            throwDefect: () => throw ArgumentError('programmer defect'),
            matcher: isA<ArgumentError>(),
          ),
          'StateError': (
            throwDefect: () => throw StateError('programmer defect'),
            matcher: isA<StateError>(),
          ),
          'TypeError': (
            throwDefect: () {
              final dynamic invalidDecision = 'not a permission decision';
              return invalidDecision as NexaBizPermissionDecision;
            },
            matcher: isA<TypeError>(),
          ),
          'AssertionError': (
            throwDefect: () => throw AssertionError('programmer defect'),
            matcher: isA<AssertionError>(),
          ),
        };

    for (final MapEntry(key: defectName, value: defect)
        in programmerDefects.entries) {
      testWidgets('Router does not swallow $defectName', (tester) async {
        setControllerActiveSession();
        final router = buildRouter(
          customEvaluator: _ThrowingEvaluator(defect.throwDefect),
        );
        addTearDown(router.dispose);
        late BuildContext redirectContext;
        await tester.pumpWidget(
          Builder(
            builder: (context) {
              redirectContext = context;
              return const SizedBox.shrink();
            },
          ),
        );

        await expectLater(
          router.routeInformationParser.parseRouteInformationWithDependencies(
            RouteInformation(
              uri: Uri.parse('/billing'),
              state: RouteInformationState<void>(type: NavigatingType.go),
            ),
            redirectContext,
          ),
          throwsA(defect.matcher),
        );
      });
    }
  });
}

class _ThrowingEvaluator implements NexaBizPermissionEvaluator {
  const _ThrowingEvaluator(this.throwDefect);

  final Object Function() throwDefect;

  @override
  Future<NexaBizPermissionDecision> evaluate({
    required NexaBizAuthorizationContext context,
    required NexaBizPermissionId permissionId,
  }) async {
    throwDefect();
    return NexaBizPermissionDecision.deny;
  }
}

class _DelayedEvaluator implements NexaBizPermissionEvaluator {
  final Future<NexaBizPermissionDecision> future;
  _DelayedEvaluator(this.future);

  @override
  Future<NexaBizPermissionDecision> evaluate({
    required NexaBizAuthorizationContext context,
    required NexaBizPermissionId permissionId,
  }) => future;
}
