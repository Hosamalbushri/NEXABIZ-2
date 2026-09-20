import '../../core/capabilities/capability_metadata.dart';
import '../../core/capabilities/nexabiz_capability.dart';
import '../../core/navigation/nexabiz_navigation_contribution.dart';
import '../../core/navigation/nexabiz_route_definition.dart';
import '../../app/router/nexabiz_flutter_route_definition.dart';
import '../../core/navigation/nexabiz_route_access_requirement.dart';
import '../../core/navigation/nexabiz_route_id.dart';
import 'presentation/dashboard_screen.dart';

class _DashboardNavContribution implements NexaBizNavigationContribution {
  @override
  final NexaBizRouteId rootRouteId = const NexaBizRouteId(
    namespace: 'dashboard',
    routeName: 'root',
  );

  @override
  late final List<NexaBizRouteDefinition> routes = [
    NexaBizFlutterRouteDefinition(
      routeId: rootRouteId,
      path: '/dashboard',
      accessRequirement: const NexaBizRouteAccessRequirement(
        requiresReadySetup: true,
        requiresActiveSession: true,
        requiresCompanyScope: true,
      ),
      pageBuilder: (context) => const DashboardScreen(),
    ),
  ];
}

/// Dashboard application capability.
class DashboardCapability implements NexaBizCapability {
  @override
  final String capabilityId = 'dashboard';

  @override
  final CapabilityMetadata metadata = const CapabilityMetadata(
    nameKey: 'capability.dashboard.name',
    iconIdentifier: 'dashboard',
    sortOrder: 1,
  );

  @override
  final List<String> dependsOn = const [];

  @override
  final NexaBizNavigationContribution navigationContribution =
      _DashboardNavContribution();
}
