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
    final routesById = <String, NexaBizRouteDefinition>{};
    final routesByPath = <String, NexaBizRouteDefinition>{};
    // The current router matches path literals case-insensitively. Preserve
    // definitions verbatim but reject topology aliases before committing them.
    final matchingPaths = <String>{};

    for (final capability in capabilityRegistry.capabilities) {
      final navContrib = capability.navigationContribution;
      if (navContrib == null) continue;

      final rootId = navContrib.rootRouteId;
      rootId.validate();
      final capRoutes = navContrib.routes;

      if (capRoutes.isEmpty) {
        throw StateError(
          'Capability "${capability.capabilityId}" declared a navigation contribution with no routes.',
        );
      }

      bool rootFound = false;

      for (final routeDef in capRoutes) {
        routeDef.routeId.validate();
        final routeIdStr = routeDef.routeId.value;
        final path = routeDef.path;

        final segments = path.split('/');
        if (!path.startsWith('/') ||
            path.contains('//') ||
            path.contains('\\') ||
            path.contains('?') ||
            path.contains('#') ||
            RegExp(r'\s').hasMatch(path) ||
            (path.length > 1 && path.endsWith('/')) ||
            segments.any((segment) => segment == '.' || segment == '..')) {
          throw StateError(
            'Route "$routeIdStr" has a noncanonical transport path "$path". Use an absolute path without empty/dot segments, backslashes, whitespace, query, fragment, or trailing slash.',
          );
        }

        if (routesById.containsKey(routeIdStr)) {
          throw StateError(
            'Duplicate route ID detected: "$routeIdStr" (contributed by capability "${capability.capabilityId}").',
          );
        }

        if (!matchingPaths.add(path.toLowerCase())) {
          throw StateError(
            'Conflicting transport path detected: "$path" is already registered (case-insensitive matching).',
          );
        }

        if (routeDef.routeId.namespace != capability.capabilityId) {
          throw StateError(
            'Route "$routeIdStr" namespace must match owning capability "${capability.capabilityId}".',
          );
        }

        if (routeDef.routeId == rootId) {
          rootFound = true;
        }

        routesById[routeIdStr] = routeDef;
        routesByPath[path] = routeDef;
        routesList.add(routeDef);
      }

      if (!rootFound) {
        throw StateError(
          'Capability "${capability.capabilityId}" declared rootRouteId "${rootId.value}" which was not found in its contributed routes.',
        );
      }
    }

    // Commit only after every contribution has passed validation.
    _routesById.addAll(routesById);
    _routesByPath.addAll(routesByPath);
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
      throw StateError(
        'Navigation registry must be collected and locked before reading.',
      );
    }
  }
}
