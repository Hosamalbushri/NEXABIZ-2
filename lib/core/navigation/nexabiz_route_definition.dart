import 'nexabiz_route_id.dart';

/// Framework-neutral route definition.
///
/// Represents a navigation node mapping a logical [routeId] to a URI transport [path].
/// The [pageBuilder] is an opaque builder delegate resolved by infrastructure router adapters.
class NexaBizRouteDefinition {
  /// Logical route identity.
  final NexaBizRouteId routeId;

  /// Transport URI path (e.g. '/demo').
  final String path;

  /// Framework-neutral page builder delegate.
  final Object? pageBuilder;

  const NexaBizRouteDefinition({
    required this.routeId,
    required this.path,
    this.pageBuilder,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NexaBizRouteDefinition &&
          runtimeType == other.runtimeType &&
          routeId == other.routeId &&
          path == other.path;

  @override
  int get hashCode => routeId.hashCode ^ path.hashCode;

  @override
  String toString() => 'NexaBizRouteDefinition(routeId: $routeId, path: $path)';
}
