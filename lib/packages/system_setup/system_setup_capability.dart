import '../../core/setup/initialize_nexabiz_core.dart';
import '../../core/setup/nexabiz_setup_readiness.dart';
import '../../app/router/nexabiz_flutter_route_definition.dart';
import '../../core/capabilities/capability_metadata.dart';
import '../../core/capabilities/contributions/nexabiz_capability_runtime_contributions.dart';
import '../../core/capabilities/contributions/nexabiz_permission_contribution.dart';
import '../../core/capabilities/contributions/nexabiz_setup_contribution.dart';
import '../../core/navigation/nexabiz_navigation_contribution.dart';
import '../../core/navigation/nexabiz_route_access_requirement.dart';
import '../../core/navigation/nexabiz_route_definition.dart';
import '../../core/navigation/nexabiz_route_id.dart';
import '../../core/setup/nexabiz_setup_requirement_id.dart';
import 'presentation/system_setup_screen.dart';

class _SystemSetupNavigationContribution
    implements NexaBizNavigationContribution {
  const _SystemSetupNavigationContribution(this.initializer, this.readiness);
  final InitializeNexaBizCore? initializer;
  final NexaBizSetupReadiness? readiness;
  static const _home = NexaBizRouteId(
    namespace: 'system_setup',
    routeName: 'home',
  );

  @override
  NexaBizRouteId get rootRouteId => _home;

  @override
  List<NexaBizRouteDefinition> get routes => [
    NexaBizFlutterRouteDefinition(
      routeId: _home,
      path: '/system-setup',
      accessRequirement: const NexaBizRouteAccessRequirement(
        requiresReadySetup: false,
        requiresActiveSession: false,
        requiresCompanyScope: false,
      ),
      pageBuilder: (context) =>
          SystemSetupScreen(initializer: initializer, readiness: readiness),
    ),
  ];
}

/// Ownership declarations only; setup completion is not implemented here.
class _SystemSetupContribution implements NexaBizSetupContribution {
  const _SystemSetupContribution();

  @override
  List<NexaBizSetupRequirementId> get providedRequirements => const [
    NexaBizSetupRequirementId('system_setup.company'),
    NexaBizSetupRequirementId('system_setup.admin_user'),
  ];

  @override
  List<NexaBizSetupRequirementId> get requiredRequirements => const [];
}

/// Foundation entry point for future system setup work.
class SystemSetupCapability
    implements NexaBizCapabilityWithRuntimeContributions {
  const SystemSetupCapability({this.initializer, this.readiness});
  final InitializeNexaBizCore? initializer;
  final NexaBizSetupReadiness? readiness;
  @override
  String get capabilityId => 'system_setup';

  @override
  CapabilityMetadata get metadata => const CapabilityMetadata(
    nameKey: 'systemSetupTitle',
    iconIdentifier: 'settings',
  );

  @override
  List<String> get dependsOn => const [];

  @override
  NexaBizNavigationContribution get navigationContribution =>
      _SystemSetupNavigationContribution(initializer, readiness);

  @override
  NexaBizSetupContribution get setupContribution =>
      const _SystemSetupContribution();

  @override
  NexaBizPermissionContribution? get permissionContribution => null;
}
