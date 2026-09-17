import 'package:go_router/go_router.dart';
import '../../core/capabilities/nexabiz_capability_registry.dart';
import '../../core/navigation/nexabiz_navigation_registry.dart';
import '../router/nexabiz_router_adapter.dart';
import 'nexabiz_capability_manifest.dart';

/// Container for bootstrap execution results.
class AppBootstrapResult {
  final NexaBizCapabilityRegistry capabilityRegistry;
  final NexaBizNavigationRegistry navigationRegistry;
  final GoRouter router;

  const AppBootstrapResult({
    required this.capabilityRegistry,
    required this.navigationRegistry,
    required this.router,
  });
}

/// Orchestrates application initialization:
/// Manifest -> Capability Registry -> Navigation Registry -> GoRouter Adapter
abstract final class AppBootstrap {
  /// Execute startup sequence and build router configuration.
  static Future<AppBootstrapResult> initialize({
    String initialLocation = '/dashboard',
  }) async {
    // 1. Build & Register Capability Manifest
    final capabilityRegistry = NexaBizCapabilityRegistry();
    capabilityRegistry.registerAll(NexaBizCapabilityManifest.capabilities);

    // 2. Validate, Sort, and Lock Capability Registry
    capabilityRegistry.validateAndLock();

    // 3. Build & Collect Navigation Contributions
    final navigationRegistry = NexaBizNavigationRegistry();
    navigationRegistry.collectAndLock(capabilityRegistry);

    // 4. Adapt Navigation Registry to GoRouter
    final routerAdapter = NexaBizGoRouterAdapter(navigationRegistry);
    final router = routerAdapter.createRouter(initialLocation: initialLocation);

    return AppBootstrapResult(
      capabilityRegistry: capabilityRegistry,
      navigationRegistry: navigationRegistry,
      router: router,
    );
  }
}
