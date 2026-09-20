import '../../app/router/nexabiz_flutter_route_definition.dart';
import '../../core/capabilities/capability_metadata.dart';
import '../../core/capabilities/nexabiz_capability.dart';
import '../../core/navigation/nexabiz_navigation_contribution.dart';
import '../../core/navigation/nexabiz_route_access_requirement.dart';
import '../../core/navigation/nexabiz_route_definition.dart';
import '../../core/navigation/nexabiz_route_id.dart';
import 'presentation/splash_screen.dart';

class _SplashNavigationContribution implements NexaBizNavigationContribution {
  static const _root = NexaBizRouteId(namespace: 'splash', routeName: 'root');

  @override
  NexaBizRouteId get rootRouteId => _root;

  @override
  List<NexaBizRouteDefinition> get routes => [
        NexaBizFlutterRouteDefinition(
          routeId: _root,
          path: '/splash',
          accessRequirement: const NexaBizRouteAccessRequirement(
            requiresReadySetup: false,
            requiresActiveSession: false,
            requiresCompanyScope: false,
          ),
          pageBuilder: (context) => const SplashScreen(),
        ),
      ];
}

/// Foundation startup capability providing the initial safe /splash route.
class SplashCapability implements NexaBizCapability {
  const SplashCapability();

  @override
  String get capabilityId => 'splash';

  @override
  CapabilityMetadata get metadata => const CapabilityMetadata(
        nameKey: 'splashTitle',
        iconIdentifier: 'sparkles',
        sortOrder: 0,
      );

  @override
  List<String> get dependsOn => const [];

  @override
  NexaBizNavigationContribution get navigationContribution =>
      _SplashNavigationContribution();
}
