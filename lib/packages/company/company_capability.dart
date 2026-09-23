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
import '../../core/session/core_session_controller.dart';
import 'presentation/company_screen.dart';
import 'presentation/company_selection_screen.dart';

class _CompanyNavigationContribution implements NexaBizNavigationContribution {
  _CompanyNavigationContribution(this.sessionController);

  final CoreSessionController? sessionController;

  static const _home = NexaBizRouteId(namespace: 'company', routeName: 'home');
  static const _selection = NexaBizRouteId(
    namespace: 'company',
    routeName: 'selection',
  );

  @override
  NexaBizRouteId get rootRouteId => _home;

  @override
  List<NexaBizRouteDefinition> get routes => [
    NexaBizFlutterRouteDefinition(
      routeId: _home,
      path: '/company',
      accessRequirement: const NexaBizRouteAccessRequirement(
        requiresReadySetup: true,
        requiresActiveSession: true,
        requiresCompanyScope: true,
      ),
      pageBuilder: (context) => const CompanyScreen(),
    ),
    NexaBizFlutterRouteDefinition(
      routeId: _selection,
      path: '/company-selection',
      accessRequirement: const NexaBizRouteAccessRequirement(
        requiresReadySetup: true,
        requiresActiveSession: true,
        requiresCompanyScope: false,
      ),
      pageBuilder: (context) =>
          CompanySelectionScreen(sessionController: sessionController),
    ),
  ];
}

class _CompanyPermissionContribution implements NexaBizPermissionContribution {
  const _CompanyPermissionContribution();

  @override
  List<NexaBizPermissionId> get declaredPermissionIds => [
    NexaBizPermissionId('company.profile.view'),
    NexaBizPermissionId('company.profile.manage'),
    NexaBizPermissionId('company.membership.view'),
  ];

  @override
  List<NexaBizPermissionRequirement> get requiredPermissions => const [];
}

/// Foundation entry point for company scope, multi-company context, and switching capability.
class CompanyCapability implements NexaBizCapabilityWithRuntimeContributions {
  const CompanyCapability({this.sessionController});

  final CoreSessionController? sessionController;

  @override
  String get capabilityId => 'company';

  @override
  CapabilityMetadata get metadata => const CapabilityMetadata(
    nameKey: 'companyTitle',
    iconIdentifier: 'company',
  );

  @override
  List<String> get dependsOn => const [];

  @override
  NexaBizNavigationContribution get navigationContribution =>
      _CompanyNavigationContribution(sessionController);

  @override
  NexaBizSetupContribution? get setupContribution => null;

  @override
  NexaBizPermissionContribution get permissionContribution =>
      const _CompanyPermissionContribution();
}
