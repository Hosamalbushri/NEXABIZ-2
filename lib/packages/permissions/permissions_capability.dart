import '../../app/router/nexabiz_flutter_route_definition.dart';
import '../../core/capabilities/capability_metadata.dart';
import '../../core/capabilities/contributions/nexabiz_capability_runtime_contributions.dart';
import '../../core/capabilities/contributions/nexabiz_permission_contribution.dart';
import '../../core/capabilities/contributions/nexabiz_setup_contribution.dart';
import '../../core/navigation/nexabiz_navigation_contribution.dart';
import '../../core/navigation/nexabiz_route_access_requirement.dart';
import '../../core/navigation/nexabiz_route_definition.dart';
import '../../core/navigation/nexabiz_route_id.dart';
import '../../core/permissions/nexabiz_permission_intent.dart';
import 'presentation/permissions_screen.dart';

class _PermissionsNavigationContribution
    implements NexaBizNavigationContribution {
  static const _home = NexaBizRouteId(
    namespace: 'permissions',
    routeName: 'home',
  );

  @override
  NexaBizRouteId get rootRouteId => _home;

  @override
  List<NexaBizRouteDefinition> get routes => [
    NexaBizFlutterRouteDefinition(
      routeId: _home,
      path: '/permissions',
      accessRequirement: const NexaBizRouteAccessRequirement(
        requiresReadySetup: true,
        requiresActiveSession: true,
        requiresCompanyScope: true,
      ),
      pageBuilder: (context) => const PermissionsScreen(),
    ),
  ];
}

/// Catalog identities only; no roles, grants, or decisions are defined.
class _PermissionsPermissionContribution
    implements NexaBizPermissionContribution {
  const _PermissionsPermissionContribution();

  @override
  List<NexaBizPermissionId> get declaredPermissionIds => [
    NexaBizPermissionId('permissions.catalog.view'),
    NexaBizPermissionId('permissions.policy.review'),
  ];

  @override
  List<NexaBizPermissionRequirement> get requiredPermissions => const [];
}

/// Foundation entry point for a future permission catalog and policy intent.
class PermissionsCapability
    implements NexaBizCapabilityWithRuntimeContributions {
  @override
  String get capabilityId => 'permissions';

  @override
  CapabilityMetadata get metadata => const CapabilityMetadata(
    nameKey: 'permissionsTitle',
    iconIdentifier: 'permissions',
  );

  @override
  List<String> get dependsOn => const [];

  @override
  NexaBizNavigationContribution get navigationContribution =>
      _PermissionsNavigationContribution();

  @override
  NexaBizSetupContribution? get setupContribution => null;

  @override
  NexaBizPermissionContribution get permissionContribution =>
      const _PermissionsPermissionContribution();
}
