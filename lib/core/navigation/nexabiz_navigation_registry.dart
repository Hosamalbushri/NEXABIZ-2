import '../capabilities/nexabiz_capability_registry.dart';
import 'nexabiz_route_definition.dart';
import 'nexabiz_route_id.dart';

/// Registry responsible for collecting capability navigation contributions,
/// validating route IDs and paths, ensuring root route presence, and locking navigation metadata.
///
/// Architecture:
/// Capability Manifest -> Capability Registry -> Navigation Contributions -> Navigation Registry
class NexaBizNavigationRegistry {
  final Map<String, NexaBizRouteDefinition> _routesById = {};
  final Map<String, NexaBizRouteDefinition> _routesByPath = {};
  List<NexaBizRouteDefinition> _allRoutes = [];
  bool _isLocked = false;

  /// Whether the navigation registry is validated and locked.
  bool get isLocked => _isLocked;

  /// Collect navigation contributions from a locked [capabilityRegistry], validate routes, and lock registry.
  void collectAndLock(NexaBizCapabilityRegistry capabilityRegistry) {
    _checkNotLocked();

    if (!capabilityRegistry.isLocked) {
      throw StateError(
        'Capability registry must be validated and locked before collecting navigation contributions.',
      );
    }

    final routesList = <NexaBizRouteDefinition>[];

    for (final capability in capabilityRegistry.capabilities) {
      final navContrib = capability.navigationContribution;
      if (navContrib == null) continue;

      final rootId = navContrib.rootRouteId;
      final capRoutes = navContrib.routes;

      if (capRoutes.isEmpty) {
        throw StateError(
          'Capability "${capability.capabilityId}" declared a navigation contribution with no routes.',
        );
      }

      bool rootFound = false;

      for (final routeDef in capRoutes) {
        final routeIdStr = routeDef.routeId.value;
        final path = routeDef.path;

        if (path.trim().isEmpty || !path.startsWith('/')) {
          throw StateError(
            'Route "$routeIdStr" has an invalid transport path "$path". Paths must start with "/".',
          );
        }

        if (_routesById.containsKey(routeIdStr)) {
          throw StateError(
            'Duplicate route ID detected: "$routeIdStr" (contributed by capability "${capability.capabilityId}").',
          );
        }

        if (_routesByPath.containsKey(path)) {
          throw StateError(
            'Conflicting transport path detected: "$path" already registered for route "${_routesByPath[path]!.routeId.value}".',
          );
        }

        if (routeDef.routeId == rootId) {
          rootFound = true;
        }

        _routesById[routeIdStr] = routeDef;
        _routesByPath[path] = routeDef;
        routesList.add(routeDef);
      }

      if (!rootFound) {
        throw StateError(
          'Capability "${capability.capabilityId}" declared rootRouteId "${rootId.value}" which was not found in its contributed routes.',
        );
      }
    }

    _allRoutes = List.unmodifiable(routesList);
    _isLocked = true;
  }

  /// Read-only list of all registered route definitions.
  List<NexaBizRouteDefinition> get routes {
    _checkIsLocked();
    return _allRoutes;
  }

  /// Retrieve a route definition by its logical [routeId].
  NexaBizRouteDefinition getRoute(NexaBizRouteId routeId) {
    _checkIsLocked();
    final route = _routesById[routeId.value];
    if (route == null) {
      throw StateError('Route ID "${routeId.value}" is not registered.');
    }
    return route;
  }

  /// Retrieve a route definition by its transport [path].
  NexaBizRouteDefinition getRouteByPath(String path) {
    _checkIsLocked();
    final route = _routesByPath[path];
    if (route == null) {
      throw StateError('Path "$path" is not registered.');
    }
    return route;
  }

  void _checkNotLocked() {
    if (_isLocked) {
      throw StateError('Navigation registry is locked and cannot be mutated.');
    }
  }

  void _checkIsLocked() {
    if (!_isLocked) {
      throw StateError('Navigation registry must be collected and locked before reading.');
    }
  }
}
