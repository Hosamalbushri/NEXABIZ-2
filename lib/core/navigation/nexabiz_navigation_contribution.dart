import 'nexabiz_route_definition.dart';
import 'nexabiz_route_id.dart';

/// Abstract interface for navigation contributions declared by capabilities.
///
/// MUST remain framework-neutral and decoupled from UI or router implementations.
abstract interface class NexaBizNavigationContribution {
  /// The root route ID for the capability.
  NexaBizRouteId get rootRouteId;

  /// List of route definitions contributed by the capability.
  List<NexaBizRouteDefinition> get routes;
}
