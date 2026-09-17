import '../../core/capabilities/capability_metadata.dart';
import '../../core/capabilities/nexabiz_capability.dart';
import '../../core/navigation/nexabiz_navigation_contribution.dart';
import '../../core/navigation/nexabiz_route_definition.dart';
import '../../core/navigation/nexabiz_route_id.dart';
import 'presentation/services_screen.dart';

class _ServicesNavContribution implements NexaBizNavigationContribution {
  @override
  final NexaBizRouteId rootRouteId = const NexaBizRouteId(
    namespace: 'services',
    routeName: 'root',
  );

  @override
  late final List<NexaBizRouteDefinition> routes = [
    NexaBizRouteDefinition(
      routeId: rootRouteId,
      path: '/services',
      pageBuilder: (context, state) => const ServicesScreen(),
    ),
  ];
}

/// Services application capability.
class ServicesCapability implements NexaBizCapability {
  @override
  final String capabilityId = 'services';

  @override
  final CapabilityMetadata metadata = const CapabilityMetadata(
    nameKey: 'capability.services.name',
    iconIdentifier: 'apps',
    sortOrder: 2,
  );

  @override
  final List<String> dependsOn = const [];

  @override
  final NexaBizNavigationContribution navigationContribution =
      _ServicesNavContribution();
}
