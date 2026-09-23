import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../../core/authorization/nexabiz_permission_evaluator.dart';
import '../../core/authorization/nexabiz_permission_guard.dart';
import '../../core/authorization/nexabiz_runtime_permission_evaluator.dart';
import '../../core/capabilities/nexabiz_capability_registry.dart';
import '../../core/identity/authenticate_local_user.dart';
import '../../core/navigation/nexabiz_navigation_registry.dart';
import '../../core/session/core_session_controller.dart';
import 'core_session_listenable.dart';
import '../../core/setup/initialize_nexabiz_core.dart';
import '../../core/setup/nexabiz_core_installation_store.dart';
import '../../core/setup/nexabiz_setup_readiness.dart';
import '../authorization/nexabiz_authorization_administration.dart';
import '../authorization/nexabiz_authorization_invalidation_signal.dart';
import '../persistence/drift_authorization_administration_store.dart';
import '../persistence/drift_core_installation_store.dart';
import '../router/nexabiz_router_adapter.dart';
import 'nexabiz_capability_manifest.dart';

/// Container for bootstrap execution results.
class AppBootstrapResult {
  final NexaBizCapabilityRegistry capabilityRegistry;
  final NexaBizNavigationRegistry navigationRegistry;
  final GoRouter router;
  final NexaBizCoreInstallationStore coreInstallationStore;
  final ValueListenable<NexaBizSetupReadiness> setupReadiness;
  NexaBizSetupReadiness get coreReadiness => setupReadiness.value;
  final CoreSessionController sessionController;
  final NexaBizPermissionEvaluator permissionEvaluator;
  final NexaBizAuthorizationInvalidationSignal authorizationInvalidationSignal;
  final NexaBizAuthorizationAdministration authorizationAdministration;

  const AppBootstrapResult({
    required this.capabilityRegistry,
    required this.navigationRegistry,
    required this.router,
    required this.coreInstallationStore,
    required this.setupReadiness,
    required this.sessionController,
    required this.permissionEvaluator,
    required this.authorizationInvalidationSignal,
    required this.authorizationAdministration,
  });
}

/// Orchestrates application initialization:
/// Manifest -> Capability Registry -> Navigation Registry -> GoRouter Adapter
abstract final class AppBootstrap {
  /// Execute startup sequence and build router configuration.
  static Future<AppBootstrapResult> initialize({
    String? initialLocation,
    String? databasePath,
  }) async {
    final resolvedDatabasePath =
        databasePath ??
        p.join((await getApplicationSupportDirectory()).path, 'nexabiz.sqlite');
    final coreInstallationStore = await DriftCoreInstallationStore.open(
      resolvedDatabasePath,
    );
    try {
      final setupReadiness = coreInstallationStore.readiness;

      final sessionController = CoreSessionController(
        authenticateLocalUser: AuthenticateLocalUser(
          queryStore: coreInstallationStore,
        ),
        queryStore: coreInstallationStore,
      );

      // 1. Build & Register Capability Manifest
      final capabilityRegistry = NexaBizCapabilityRegistry();
      capabilityRegistry.registerAll(
        NexaBizCapabilityManifest.capabilitiesFor(
          initializer: InitializeNexaBizCore(coreInstallationStore),
          readiness: setupReadiness.value,
          sessionController: sessionController,
        ),
      );

      // 2. Validate, Sort, and Lock Capability Registry
      capabilityRegistry.validateAndLock();

      // 3. Build & Collect Navigation Contributions
      final navigationRegistry = NexaBizNavigationRegistry();
      navigationRegistry.collectAndLock(capabilityRegistry);

      // 4. Adapt Navigation Registry to GoRouter with Security Gate
      // 4. Build Runtime Permission Evaluator & Invalidation Signal
      final permissionEvaluator = NexaBizRuntimePermissionEvaluator(
        permissionCatalog: capabilityRegistry.permissionCatalog,
        queryStore: coreInstallationStore,
        sessionSource: sessionController,
      );
      final authorizationInvalidationSignal =
          NexaBizAuthorizationInvalidationSignal();

      // 5. Adapt Navigation Registry to GoRouter with Security Gate
      final routerAdapter = NexaBizGoRouterAdapter(navigationRegistry);
      final router = routerAdapter.createRouter(
        initialLocation: initialLocation ?? '/splash',
        readinessListenable: setupReadiness,
        sessionController: sessionController,
        refreshListenable: CoreSessionListenable(sessionController),
        permissionEvaluator: permissionEvaluator,
        authorizationInvalidationListenable: authorizationInvalidationSignal,
      );

      // 6. Build Authorization Administration Application Facade
      final administrationStore = DriftAuthorizationAdministrationStore(
        coreInstallationStore.database,
        permissionCatalog: capabilityRegistry.permissionCatalog,
      );
      final permissionGuard = NexaBizDefaultPermissionGuard(
        permissionEvaluator,
      );
      final authorizationAdministration =
          NexaBizAuthorizationAdministration.create(
            permissionGuard: permissionGuard,
            queryStore: administrationStore,
            mutationStore: administrationStore,
            invalidationSignal: authorizationInvalidationSignal,
            permissionCatalog: capabilityRegistry.permissionCatalog,
          );

      return AppBootstrapResult(
        capabilityRegistry: capabilityRegistry,
        navigationRegistry: navigationRegistry,
        router: router,
        coreInstallationStore: coreInstallationStore,
        setupReadiness: setupReadiness,
        sessionController: sessionController,
        permissionEvaluator: permissionEvaluator,
        authorizationInvalidationSignal: authorizationInvalidationSignal,
        authorizationAdministration: authorizationAdministration,
      );
    } catch (_) {
      await coreInstallationStore.close();
      rethrow;
    }
  }
}
