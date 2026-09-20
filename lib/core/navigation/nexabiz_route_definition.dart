import 'nexabiz_route_id.dart';
import 'nexabiz_route_access_requirement.dart';

/// Framework-neutral route definition.
///
/// Represents a navigation node mapping a logical [routeId] to a URI transport [path].
/// Presentation bindings are supplied by infrastructure-specific definitions.
class NexaBizRouteDefinition {
  /// Logical route identity.
  final NexaBizRouteId routeId;

  /// Transport URI path (e.g. '/demo').
  final String path;

  /// Optional parent route in the same capability contribution.
  final NexaBizRouteId? parentRouteId;

  /// Descriptive guard requirements; not enforced by the current router.
  final NexaBizRouteAccessRequirement? accessRequirement;

  const NexaBizRouteDefinition({
    required this.routeId,
    required this.path,
    this.parentRouteId,
    this.accessRequirement,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NexaBizRouteDefinition &&
          runtimeType == other.runtimeType &&
          routeId == other.routeId &&
          path == other.path &&
          parentRouteId == other.parentRouteId &&
          accessRequirement == other.accessRequirement;

  @override
  int get hashCode =>
      Object.hash(routeId, path, parentRouteId, accessRequirement);

  @override
  String toString() =>
      'NexaBizRouteDefinition(routeId: $routeId, path: $path, parentRouteId: $parentRouteId, accessRequirement: $accessRequirement)';
}
