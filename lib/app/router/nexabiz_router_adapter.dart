import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import '../../core/navigation/nexabiz_navigation_registry.dart';
import '../../core/navigation/nexabiz_route_definition.dart';
import '../shell/application_shell.dart';

/// Infrastructure adapter that translates [NexaBizNavigationRegistry] metadata
/// into a [GoRouter] configuration instance supporting stateful branch navigation.
///
/// This adapter MUST be the only layer that imports or handles GoRouter types.
class NexaBizGoRouterAdapter {
  final NexaBizNavigationRegistry _navigationRegistry;

  const NexaBizGoRouterAdapter(this._navigationRegistry);

  /// Primary shell branch route paths in canonical order.
  static const List<String> primaryBranchPaths = [
    '/dashboard',
    '/services',
    '/reports',
    '/settings',
  ];

  /// Create a [GoRouter] instance configured from the navigation registry.
  GoRouter createRouter({String initialLocation = '/dashboard'}) {
    if (!_navigationRegistry.isLocked) {
      throw StateError(
        'Navigation registry must be collected and locked before creating GoRouter configuration.',
      );
    }

    final registeredRoutes = _navigationRegistry.routes;
    final primaryBranchRoutes = <String, NexaBizRouteDefinition>{};
    final secondaryRoutes = <NexaBizRouteDefinition>[];

    for (final routeDef in registeredRoutes) {
      if (primaryBranchPaths.contains(routeDef.path)) {
        primaryBranchRoutes[routeDef.path] = routeDef;
      } else {
        secondaryRoutes.add(routeDef);
      }
    }

    // Build StatefulShellBranches for the 4 main platform paths
    final statefulBranches = <StatefulShellBranch>[];

    for (final path in primaryBranchPaths) {
      final routeDef = primaryBranchRoutes[path];
      if (routeDef != null) {
        statefulBranches.add(
          StatefulShellBranch(
            routes: [
              _buildGoRoute(routeDef),
            ],
          ),
        );
      }
    }

    // If all 4 primary branches exist, construct a StatefulShellRoute.indexedStack
    RouteBase mainShellRoute;
    if (statefulBranches.length == primaryBranchPaths.length) {
      mainShellRoute = StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return ApplicationShell(
            navigationShell: navigationShell,
            currentPath: state.uri.toString(),
            child: navigationShell,
          );
        },
        branches: statefulBranches,
      );
    } else {
      // Fallback standard ShellRoute if custom capability manifests omit primary branches
      final allGoRoutes = registeredRoutes.map(_buildGoRoute).toList();
      mainShellRoute = ShellRoute(
        builder: (context, state, child) {
          return ApplicationShell(
            currentPath: state.uri.toString(),
            child: child,
          );
        },
        routes: allGoRoutes,
      );
    }

    // Build secondary routes outside main shell if any exist
    final rootRoutes = <RouteBase>[
      mainShellRoute,
      for (final secRoute in secondaryRoutes) _buildGoRoute(secRoute),
    ];

    return GoRouter(
      initialLocation: initialLocation,
      routes: rootRoutes,
    );
  }

  GoRoute _buildGoRoute(NexaBizRouteDefinition routeDef) {
    final builder = routeDef.pageBuilder;

    return GoRoute(
      path: routeDef.path,
      name: routeDef.routeId.value,
      builder: (context, state) {
        if (builder is Widget Function(BuildContext, dynamic)) {
          return builder(context, state);
        } else if (builder is Widget Function(BuildContext)) {
          return builder(context);
        } else if (builder is Widget) {
          return builder;
        } else {
          throw StateError(
            'Invalid page builder for route "${routeDef.routeId.value}". Expected a Widget builder function.',
          );
        }
      },
    );
  }
}
