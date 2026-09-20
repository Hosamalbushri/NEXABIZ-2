import '../permissions/nexabiz_permission_intent.dart';

/// Declarative access intent enforced by [NexaBizGoRouterAdapter].
final class NexaBizRouteAccessRequirement {
  const NexaBizRouteAccessRequirement({
    this.requiresActiveSession = false,
    this.requiresCompanyScope = false,
    this.requiresReadySetup = false,
    this.permission,
  });

  final bool requiresActiveSession;
  final bool requiresCompanyScope;
  final bool requiresReadySetup;
  final NexaBizPermissionRequirement? permission;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NexaBizRouteAccessRequirement &&
          requiresActiveSession == other.requiresActiveSession &&
          requiresCompanyScope == other.requiresCompanyScope &&
          requiresReadySetup == other.requiresReadySetup &&
          permission == other.permission;

  @override
  int get hashCode => Object.hash(
    requiresActiveSession,
    requiresCompanyScope,
    requiresReadySetup,
    permission,
  );
}
