import 'package:go_router/go_router.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../../core/capabilities/nexabiz_capability_registry.dart';
import '../../core/identity/authenticate_local_user.dart';
import '../../core/navigation/nexabiz_navigation_registry.dart';
import '../../core/session/core_session_controller.dart';
import '../../core/setup/initialize_nexabiz_core.dart';
import '../../core/setup/nexabiz_core_installation_store.dart';
import '../../core/setup/nexabiz_setup_readiness.dart';
import '../../core/session/core_session_listenable.dart';
import '../persistence/drift_core_installation_store.dart';
import '../router/nexabiz_router_adapter.dart';
import 'nexabiz_capability_manifest.dart';

/// Container for bootstrap execution results.
class AppBootstrapResult {
  final NexaBizCapabilityRegistry capabilityRegistry;
  final NexaBizNavigationRegistry navigationRegistry;
  final GoRouter router;
  final NexaBizCoreInstallationStore coreInstallationStore;
  final NexaBizSetupReadiness coreReadiness;
  final CoreSessionController sessionController;

  const AppBootstrapResult({
    required this.capabilityRegistry,
    required this.navigationRegistry,
    required this.router,
    required this.coreInstallationStore,
    required this.coreReadiness,
    required this.sessionController,
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
      final coreReadiness = await coreInstallationStore.readReadiness();

      final sessionController = CoreSessionController(
        authenticateLocalUser: AuthenticateLocalUser(queryStore: coreInstallationStore),
        queryStore: coreInstallationStore,
      );

      // 1. Build & Register Capability Manifest
      final capabilityRegistry = NexaBizCapabilityRegistry();
      capabilityRegistry.registerAll(
        NexaBizCapabilityManifest.capabilitiesFor(
          initializer: InitializeNexaBizCore(coreInstallationStore),
          readiness: coreReadiness,
          sessionController: sessionController,
        ),
      );

      // 2. Validate, Sort, and Lock Capability Registry
      capabilityRegistry.validateAndLock();

      // 3. Build & Collect Navigation Contributions
      final navigationRegistry = NexaBizNavigationRegistry();
      navigationRegistry.collectAndLock(capabilityRegistry);

      // 4. Adapt Navigation Registry to GoRouter with Security Gate
      final routerAdapter = NexaBizGoRouterAdapter(navigationRegistry);
      final router = routerAdapter.createRouter(
        initialLocation: initialLocation ?? '/splash',
        readiness: coreReadiness,
        sessionController: sessionController,
        refreshListenable: CoreSessionListenable(sessionController),
      );

      return AppBootstrapResult(
        capabilityRegistry: capabilityRegistry,
        navigationRegistry: navigationRegistry,
        router: router,
        coreInstallationStore: coreInstallationStore,
        coreReadiness: coreReadiness,
        sessionController: sessionController,
      );
    } catch (_) {
      await coreInstallationStore.close();
      rethrow;
    }
  }
}
