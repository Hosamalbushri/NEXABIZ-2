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
import 'presentation/identity_screen.dart';
import 'presentation/login_screen.dart';

class _IdentityNavigationContribution implements NexaBizNavigationContribution {
  _IdentityNavigationContribution(this.sessionController);

  final CoreSessionController? sessionController;

  static const _home = NexaBizRouteId(namespace: 'identity', routeName: 'home');
  static const _login = NexaBizRouteId(namespace: 'identity', routeName: 'login');

  @override
  NexaBizRouteId get rootRouteId => _home;

  @override
  List<NexaBizRouteDefinition> get routes => [
    NexaBizFlutterRouteDefinition(
      routeId: _home,
      path: '/identity',
      accessRequirement: const NexaBizRouteAccessRequirement(
        requiresReadySetup: true,
        requiresActiveSession: true,
        requiresCompanyScope: false,
      ),
      pageBuilder: (context) => const IdentityScreen(),
    ),
    NexaBizFlutterRouteDefinition(
      routeId: _login,
      path: '/login',
      accessRequirement: const NexaBizRouteAccessRequirement(
        requiresReadySetup: true,
        requiresActiveSession: false,
        requiresCompanyScope: false,
      ),
      pageBuilder: (context) => LoginScreen(sessionController: sessionController),
    ),
  ];
}

class _IdentityPermissionContribution implements NexaBizPermissionContribution {
  const _IdentityPermissionContribution();

  @override
  List<NexaBizPermissionId> get declaredPermissionIds => [
    NexaBizPermissionId('identity.session.view'),
    NexaBizPermissionId('identity.user.manage'),
  ];

  @override
  List<NexaBizPermissionRequirement> get requiredPermissions => const [];
}

/// Entry point for local identity, authentication, and session capability.
class IdentityCapability implements NexaBizCapabilityWithRuntimeContributions {
  const IdentityCapability({this.sessionController});

  final CoreSessionController? sessionController;

  @override
  String get capabilityId => 'identity';

  @override
  CapabilityMetadata get metadata => const CapabilityMetadata(
    nameKey: 'identityTitle',
    iconIdentifier: 'identity',
  );

  @override
  List<String> get dependsOn => const [];

  @override
  NexaBizNavigationContribution get navigationContribution =>
      _IdentityNavigationContribution(sessionController);

  @override
  NexaBizSetupContribution? get setupContribution => null;

  @override
  NexaBizPermissionContribution get permissionContribution =>
      const _IdentityPermissionContribution();
}
