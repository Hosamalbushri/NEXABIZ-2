import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'nexabiz_navigation_registry.dart';
import 'nexabiz_route_id.dart';

/// Canonical application navigation controller.
///
/// Provides a single, unified application navigation API that translates
/// logical route identities ([NexaBizRouteId]) or paths into GoRouter calls.
class NexaBizNavigationController {
  final NexaBizNavigationRegistry _registry;

  const NexaBizNavigationController(this._registry);

  /// Navigate to a logical route by its [NexaBizRouteId].
  void navigateTo(BuildContext context, NexaBizRouteId routeId, {Object? extra}) {
    final routeDef = _registry.getRoute(routeId);
    context.go(routeDef.path, extra: extra);
  }

  /// Navigate to a transport URI [path].
  void navigateToPath(BuildContext context, String path, {Object? extra}) {
    context.go(path, extra: extra);
  }

  /// Push a route onto the navigation stack by its [NexaBizRouteId].
  void push(BuildContext context, NexaBizRouteId routeId, {Object? extra}) {
    final routeDef = _registry.getRoute(routeId);
    context.push(routeDef.path, extra: extra);
  }

  /// Pop the current top route.
  void pop(BuildContext context, [Object? result]) {
    context.pop(result);
  }
}
