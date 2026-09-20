import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nexabiz/app/app.dart';
import 'package:nexabiz/app/persistence/drift_core_installation_store.dart';
import 'package:nexabiz/app/router/nexabiz_flutter_route_definition.dart';
import 'package:nexabiz/app/router/nexabiz_router_adapter.dart';
import 'package:nexabiz/core/capabilities/capability_metadata.dart';
import 'package:nexabiz/core/capabilities/nexabiz_capability.dart';
import 'package:nexabiz/core/capabilities/nexabiz_capability_registry.dart';
import 'package:nexabiz/core/identity/authenticate_local_user.dart';
import 'package:nexabiz/core/navigation/nexabiz_navigation_contribution.dart';
import 'package:nexabiz/core/navigation/nexabiz_navigation_registry.dart';
import 'package:nexabiz/core/navigation/nexabiz_route_access_requirement.dart';
import 'package:nexabiz/core/navigation/nexabiz_route_definition.dart';
import 'package:nexabiz/core/navigation/nexabiz_route_id.dart';
import 'package:nexabiz/core/session/core_session_controller.dart';
import 'package:nexabiz/core/setup/initialize_nexabiz_core.dart';
import 'package:nexabiz/core/setup/nexabiz_setup_readiness.dart';
import 'package:path/path.dart' as p;

class _TestContribution implements NexaBizNavigationContribution {
  @override
  List<NexaBizRouteDefinition> get routes => [
        const NexaBizFlutterRouteDefinition(
          routeId: NexaBizRouteId(namespace: 'test', routeName: 'system_setup'),
          path: '/system-setup',
          accessRequirement: NexaBizRouteAccessRequirement(
            requiresReadySetup: false,
            requiresActiveSession: false,
            requiresCompanyScope: false,
          ),
          pageBuilder: _page,
        ),
        const NexaBizFlutterRouteDefinition(
          routeId: NexaBizRouteId(namespace: 'test', routeName: 'splash'),
          path: '/splash',
          accessRequirement: NexaBizRouteAccessRequirement(
            requiresReadySetup: false,
            requiresActiveSession: false,
            requiresCompanyScope: false,
          ),
          pageBuilder: _page,
        ),
        const NexaBizFlutterRouteDefinition(
          routeId: NexaBizRouteId(namespace: 'test', routeName: 'login'),
          path: '/login',
          accessRequirement: NexaBizRouteAccessRequirement(
            requiresReadySetup: true,
            requiresActiveSession: false,
            requiresCompanyScope: false,
          ),
          pageBuilder: _page,
        ),
        const NexaBizFlutterRouteDefinition(
          routeId: NexaBizRouteId(namespace: 'test', routeName: 'company_selection'),
          path: '/company-selection',
          accessRequirement: NexaBizRouteAccessRequirement(
            requiresReadySetup: true,
            requiresActiveSession: true,
            requiresCompanyScope: false,
          ),
          pageBuilder: _page,
        ),
        const NexaBizFlutterRouteDefinition(
          routeId: NexaBizRouteId(namespace: 'test', routeName: 'dashboard'),
          path: '/dashboard',
          accessRequirement: NexaBizRouteAccessRequirement(
            requiresReadySetup: true,
            requiresActiveSession: true,
            requiresCompanyScope: true,
          ),
          pageBuilder: _page,
        ),
        const NexaBizFlutterRouteDefinition(
          routeId: NexaBizRouteId(namespace: 'test', routeName: 'settings'),
          path: '/settings',
          accessRequirement: NexaBizRouteAccessRequirement(
            requiresReadySetup: true,
            requiresActiveSession: true,
            requiresCompanyScope: true,
          ),
          pageBuilder: _page,
        ),
      ];

  static Widget _page(BuildContext context) => const Text('Test Screen');

  @override
  NexaBizRouteId get rootRouteId => routes.last.routeId;
}

class _TestCapability implements NexaBizCapability {
  @override
  NexaBizNavigationContribution? get navigationContribution => _TestContribution();

  @override
  String get capabilityId => 'test';

  @override
  CapabilityMetadata get metadata =>
      const CapabilityMetadata(nameKey: 'test', iconIdentifier: 'test');

  @override
  List<String> get dependsOn => const [];
}

NexaBizNavigationRegistry _buildNavigationRegistry() {
  final caps = NexaBizCapabilityRegistry();
  caps.register(_TestCapability());
  caps.validateAndLock();
  return NexaBizNavigationRegistry()..collectAndLock(caps);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('NexaBiz Authentication & Startup Security Gate Matrix', () {
    late Directory tempDir;
    late String dbPath;

    setUp(() {
      tempDir = Directory.systemTemp.createTempSync('nexabiz_auth_gate_test_');
      dbPath = p.join(tempDir.path, 'nexabiz.sqlite');
    });

    tearDown(() {
      if (tempDir.existsSync()) {
        tempDir.deleteSync(recursive: true);
      }
    });

    testWidgets('Scenario 01 & 02: Uninitialized DB forces cold start and direct URL to /system-setup', (
      tester,
    ) async {
      final navRegistry = _buildNavigationRegistry();
      final adapter = NexaBizGoRouterAdapter(navRegistry);
      final readiness = NexaBizSetupReadiness(
        state: NexaBizSetupState.uninitialized,
        completed: const [],
      );

      final router = adapter.createRouter(
        initialLocation: '/dashboard',
        readiness: readiness,
      );
      addTearDown(router.dispose);

      await tester.pumpWidget(NexaBizApp(router: router));
      await tester.pumpAndSettle();

      expect(router.state.uri.path, equals('/system-setup'));
    });

    testWidgets('Scenario 04 & 05: Ready DB with no session forces cold start & direct URL to /login', (
      tester,
    ) async {
      final store = await DriftCoreInstallationStore.open(dbPath);
      addTearDown(store.close);

      final sessionController = CoreSessionController(
        authenticateLocalUser: AuthenticateLocalUser(queryStore: store),
        queryStore: store,
      );
      addTearDown(sessionController.dispose);

      final navRegistry = _buildNavigationRegistry();
      final adapter = NexaBizGoRouterAdapter(navRegistry);
      final readiness = NexaBizSetupReadiness(
        state: NexaBizSetupState.ready,
        completed: NexaBizSetupReadiness.requiredCoreRequirements,
      );

      final router = adapter.createRouter(
        initialLocation: '/dashboard',
        readiness: readiness,
        sessionController: sessionController,
      );
      addTearDown(router.dispose);

      await tester.pumpWidget(NexaBizApp(router: router));
      await tester.pumpAndSettle();

      expect(router.state.uri.path, equals('/login'));
    });

    testWidgets('Scenario 11: Protected routes (/settings) redirect to /login when session is missing', (
      tester,
    ) async {
      final store = await DriftCoreInstallationStore.open(dbPath);
      addTearDown(store.close);

      final sessionController = CoreSessionController(
        authenticateLocalUser: AuthenticateLocalUser(queryStore: store),
        queryStore: store,
      );
      addTearDown(sessionController.dispose);

      final navRegistry = _buildNavigationRegistry();
      final adapter = NexaBizGoRouterAdapter(navRegistry);
      final readiness = NexaBizSetupReadiness(
        state: NexaBizSetupState.ready,
        completed: NexaBizSetupReadiness.requiredCoreRequirements,
      );

      final router = adapter.createRouter(
        initialLocation: '/settings',
        readiness: readiness,
        sessionController: sessionController,
      );
      addTearDown(router.dispose);

      await tester.pumpWidget(NexaBizApp(router: router));
      await tester.pumpAndSettle();

      expect(router.state.uri.path, equals('/login'));
    });

    testWidgets('Scenario 15: Splash screen resolves to /system-setup when core uninitialized', (
      tester,
    ) async {
      final navRegistry = _buildNavigationRegistry();
      final adapter = NexaBizGoRouterAdapter(navRegistry);
      final readiness = NexaBizSetupReadiness(
        state: NexaBizSetupState.uninitialized,
        completed: const [],
      );

      final router = adapter.createRouter(
        initialLocation: '/splash',
        readiness: readiness,
      );
      addTearDown(router.dispose);

      await tester.pumpWidget(NexaBizApp(router: router));
      await tester.pumpAndSettle();

      expect(router.state.uri.path, equals('/system-setup'));
    });

    test('Scenario 03 & 06: End-to-end Bootstrap & Core Setup Initialization', () async {
      final store = await DriftCoreInstallationStore.open(dbPath);
      final initializer = InitializeNexaBizCore(store);
      await initializer(
        const CoreInitializationInput(
          companyCode: 'COMP01',
          companyName: 'Test Company',
          adminName: 'Admin User',
          adminEmail: 'admin@nexabiz.test',
          password: 'Password123!',
        ),
      );

      final readiness = await store.readReadiness();
      expect(readiness.isReady, isTrue);

      final sessionController = CoreSessionController(
        authenticateLocalUser: AuthenticateLocalUser(queryStore: store),
        queryStore: store,
      );

      final loginResult = await sessionController.login(
        const CoreAuthenticationInput(
          identifier: 'admin@nexabiz.test',
          password: 'Password123!',
        ),
      );

      expect(loginResult.isSuccess, isTrue);
      expect(sessionController.currentSession.isActive, isTrue);

      await sessionController.dispose();
      await store.close();
    });
  });
}
