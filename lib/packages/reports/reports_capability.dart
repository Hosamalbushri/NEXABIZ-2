import '../../core/capabilities/capability_metadata.dart';
import '../../core/capabilities/nexabiz_capability.dart';
import '../../core/navigation/nexabiz_navigation_contribution.dart';
import '../../core/navigation/nexabiz_route_definition.dart';
import '../../app/router/nexabiz_flutter_route_definition.dart';
import '../../core/navigation/nexabiz_route_access_requirement.dart';
import '../../core/navigation/nexabiz_route_id.dart';
import 'presentation/reports_screen.dart';

class _ReportsNavContribution implements NexaBizNavigationContribution {
  @override
  final NexaBizRouteId rootRouteId = const NexaBizRouteId(
    namespace: 'reports',
    routeName: 'root',
  );

  @override
  late final List<NexaBizRouteDefinition> routes = [
    NexaBizFlutterRouteDefinition(
      routeId: rootRouteId,
      path: '/reports',
      accessRequirement: const NexaBizRouteAccessRequirement(
        requiresReadySetup: true,
        requiresActiveSession: true,
        requiresCompanyScope: true,
      ),
      pageBuilder: (context) => const ReportsScreen(),
    ),
  ];
}

/// Reports application capability.
class ReportsCapability implements NexaBizCapability {
  @override
  final String capabilityId = 'reports';

  @override
  final CapabilityMetadata metadata = const CapabilityMetadata(
    nameKey: 'capability.reports.name',
    iconIdentifier: 'assessment',
    sortOrder: 3,
  );

  @override
  final List<String> dependsOn = const [];

  @override
  final NexaBizNavigationContribution navigationContribution =
      _ReportsNavContribution();
}
