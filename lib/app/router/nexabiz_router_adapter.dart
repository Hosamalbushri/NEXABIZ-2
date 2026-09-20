import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

import '../../core/navigation/nexabiz_navigation_registry.dart';
import '../../core/navigation/nexabiz_route_access_requirement.dart';
import '../../core/navigation/nexabiz_route_definition.dart';
import '../../core/session/core_session_controller.dart';
import '../../core/setup/nexabiz_setup_readiness.dart';
import '../shell/app_exit_scope.dart';
import '../shell/application_shell.dart';
import 'nexabiz_flutter_route_definition.dart';

/// Infrastructure adapter that translates [NexaBizNavigationRegistry] metadata
/// into a [GoRouter] configuration instance supporting stateful branch navigation
/// and centralized authentication/setup gate evaluation.
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
  GoRouter createRouter({
    String initialLocation = '/splash',
    NexaBizSetupReadiness? readiness,
    CoreSessionController? sessionController,
    Listenable? refreshListenable,
  }) {
    if (!_navigationRegistry.isLocked) {
      throw StateError(
        'Navigation registry must be collected and locked before creating GoRouter configuration.',
      );
    }

    final registeredRoutes = _navigationRegistry.routes;
    if (registeredRoutes.isEmpty) {
      throw StateError('Cannot create a router without contributed routes.');
    }
    // Fail before constructing a partial router when any contributed page is unbound.
    for (final route in registeredRoutes) {
      if (route is! NexaBizFlutterRouteDefinition) {
        throw StateError(
          'Route "${route.routeId.value}" requires a Flutter route definition with a typed page builder.',
        );
      }
    }
    final childrenByParent = <String, List<NexaBizRouteDefinition>>{};
    for (final route in registeredRoutes) {
      final parentId = route.parentRouteId;
      if (parentId != null) {
        childrenByParent.putIfAbsent(parentId.value, () => []).add(route);
      }
    }
    GoRoute buildTree(NexaBizRouteDefinition route) {
      final parentId = route.parentRouteId;
      final parentPath = parentId == null
          ? null
          : _navigationRegistry.getRoute(parentId).path;
      final routePath = parentPath == null
          ? route.path
          : route.path.substring(parentPath == '/' ? 1 : parentPath.length + 1);
      return GoRoute(
        path: routePath,
        name: route.routeId.value,
        builder: (context, state) =>
            (route as NexaBizFlutterRouteDefinition).pageBuilder(context),
        routes: [
          for (final child
              in childrenByParent[route.routeId.value] ??
                  const <NexaBizRouteDefinition>[])
            buildTree(child),
        ],
      );
    }

    final rootDefinitions = registeredRoutes
        .where((route) => route.parentRouteId == null)
        .toList();
    final primaryBranchRoutes = <String, NexaBizRouteDefinition>{};
    final secondaryRoutes = <NexaBizRouteDefinition>[];

    for (final routeDef in rootDefinitions) {
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
          StatefulShellBranch(routes: [buildTree(routeDef)]),
        );
      }
    }

    // If all 4 primary branches exist, construct a StatefulShellRoute.indexedStack
    RouteBase mainShellRoute;
    if (statefulBranches.length == primaryBranchPaths.length) {
      mainShellRoute = StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return AppExitPopScope(
            child: ApplicationShell(
              navigationShell: navigationShell,
              currentPath: state.uri.toString(),
              child: navigationShell,
            ),
          );
        },
        branches: statefulBranches,
      );
    } else {
      // Fallback standard ShellRoute if custom capability manifests omit primary branches
      final allGoRoutes = rootDefinitions.map(buildTree).toList();
      mainShellRoute = ShellRoute(
        builder: (context, state, child) {
          return AppExitPopScope(
            child: ApplicationShell(
              currentPath: state.uri.toString(),
              child: child,
            ),
          );
        },
        routes: allGoRoutes,
      );
    }

    // Build secondary routes outside main shell if any exist
    final rootRoutes = <RouteBase>[
      mainShellRoute,
      if (statefulBranches.length == primaryBranchPaths.length)
        for (final secRoute in secondaryRoutes) buildTree(secRoute),
    ];

    return GoRouter(
      initialLocation: initialLocation,
      refreshListenable: refreshListenable,
      routes: rootRoutes,
      redirect: (context, state) {
        final path = state.uri.path;
        final hasSetupController = readiness != null;
        final isSetupReady = !hasSetupController || readiness.state == NexaBizSetupState.ready;

        // 1. Core Setup Gate: If core is not ready, enforce /system-setup
        if (hasSetupController && !isSetupReady && path != '/system-setup') {
          return '/system-setup';
        }
        // 2. Setup Guard: Block /system-setup when core is already ready
        if (hasSetupController && isSetupReady && path == '/system-setup') {
          return '/login';
        }

        // 3. Splash Screen Resolution
        if (path == '/splash') {
          if (hasSetupController && !isSetupReady) return '/system-setup';
          final session = sessionController?.currentSession;
          if (sessionController != null && session == null) return '/login';
          if (session != null && session.companyId == null) {
            return '/company-selection';
          }
          return '/dashboard';
        }

        // 4. Lookup target route access requirement
        NexaBizRouteDefinition? matchedRoute;
        for (final route in registeredRoutes) {
          if (route.path == path) {
            matchedRoute = route;
            break;
          }
        }

        final requirement = matchedRoute?.accessRequirement ??
            const NexaBizRouteAccessRequirement(
              requiresReadySetup: true,
              requiresActiveSession: true,
              requiresCompanyScope: true,
            );

        // Fail-closed Guard: Ready Setup
        if (hasSetupController && requirement.requiresReadySetup && !isSetupReady) {
          return '/system-setup';
        }

        final hasSessionController = sessionController != null;
        final activeSession = sessionController?.currentSession;
        final hasActiveSession =
            activeSession != null && activeSession.isActive;

        // Guard: Active Session requirement
        if (hasSessionController &&
            requirement.requiresActiveSession &&
            !hasActiveSession) {
          return '/login';
        }

        // Guard: Prevent authenticated user from staying on /login
        if (hasSessionController && path == '/login' && hasActiveSession) {
          return activeSession.companyId != null
              ? '/dashboard'
              : '/company-selection';
        }

        // Guard: Company Scope requirement
        if (hasSessionController &&
            requirement.requiresCompanyScope &&
            activeSession?.companyId == null) {
          return '/company-selection';
        }

        return null;
      },
    );
  }
}
