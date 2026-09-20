import '../../core/capabilities/capability_metadata.dart';
import '../../core/capabilities/nexabiz_capability.dart';
import '../../core/navigation/nexabiz_navigation_contribution.dart';
import '../../core/navigation/nexabiz_route_definition.dart';
import '../../app/router/nexabiz_flutter_route_definition.dart';
import '../../core/navigation/nexabiz_route_access_requirement.dart';
import '../../core/navigation/nexabiz_route_id.dart';
import '../../core/session/core_session_controller.dart';
import 'presentation/settings_screen.dart';

class _SettingsNavContribution implements NexaBizNavigationContribution {
  _SettingsNavContribution(this.sessionController);

  final CoreSessionController? sessionController;

  @override
  final NexaBizRouteId rootRouteId = const NexaBizRouteId(
    namespace: 'settings',
    routeName: 'root',
  );

  @override
  late final List<NexaBizRouteDefinition> routes = [
    NexaBizFlutterRouteDefinition(
      routeId: rootRouteId,
      path: '/settings',
      accessRequirement: const NexaBizRouteAccessRequirement(
        requiresReadySetup: true,
        requiresActiveSession: true,
        requiresCompanyScope: true,
      ),
      pageBuilder: (context) => SettingsScreen(sessionController: sessionController),
    ),
  ];
}

/// Settings application capability.
class SettingsCapability implements NexaBizCapability {
  const SettingsCapability({this.sessionController});

  final CoreSessionController? sessionController;

  @override
  final String capabilityId = 'settings';

  @override
  final CapabilityMetadata metadata = const CapabilityMetadata(
    nameKey: 'capability.settings.name',
    iconIdentifier: 'settings',
    sortOrder: 4,
  );

  @override
  final List<String> dependsOn = const [];

  @override
  NexaBizNavigationContribution get navigationContribution =>
      _SettingsNavContribution(sessionController);
}
