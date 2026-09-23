import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';

import '../../core/authorization/nexabiz_authorization_context.dart';
import '../../core/authorization/nexabiz_permission_evaluator.dart';
import '../../core/navigation/nexabiz_navigation_registry.dart';
import '../../core/navigation/nexabiz_route_access_requirement.dart';
import '../../core/navigation/nexabiz_route_definition.dart';
import '../../core/permissions/nexabiz_permission_intent.dart';
import '../../core/session/core_session_controller.dart';
import '../../core/setup/nexabiz_setup_readiness.dart';
import '../shell/app_exit_scope.dart';
import '../shell/application_shell.dart';
import 'nexabiz_flutter_route_definition.dart';

bool _isAuthorizationProgrammerDefect(Object error) =>
    error is ArgumentError ||
    error is StateError ||
    error is TypeError ||
    error is AssertionError;

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
    ValueListenable<NexaBizSetupReadiness>? readinessListenable,
    CoreSessionController? sessionController,
    Listenable? refreshListenable,
    NexaBizPermissionEvaluator? permissionEvaluator,
    Listenable? authorizationInvalidationListenable,
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
      refreshListenable: Listenable.merge([
        refreshListenable,
        readinessListenable,
        authorizationInvalidationListenable,
      ]),
      routes: rootRoutes,
      redirect: (context, state) async {
        final path = state.uri.path;
        final currentReadiness = readinessListenable?.value ?? readiness;
        final hasSetupController = currentReadiness != null;
        final isSetupReady = !hasSetupController || currentReadiness.isReady;

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
          if (sessionController != null) {
            if (session == null || !session.isActive) return '/login';
            if (session.companyId == null) return '/company-selection';
            return '/dashboard';
          }
          final hasLogin = registeredRoutes.any((r) => r.path == '/login');
          return hasLogin ? '/login' : '/dashboard';
        }

        // 4. Access Denied (/unauthorized) Route - Loop Prevention
        if (path == '/unauthorized') {
          return null;
        }

        // 5. Lookup target route access requirement
        NexaBizRouteDefinition? matchedRoute;
        for (final route in registeredRoutes) {
          if (route.path == path) {
            matchedRoute = route;
            break;
          }
        }

        // If path is not registered, let router error handling (404) take over
        if (matchedRoute == null) {
          return null;
        }

        final requirement =
            matchedRoute.accessRequirement ??
            const NexaBizRouteAccessRequirement();

        // Fail-closed Guard: Ready Setup
        if (hasSetupController &&
            requirement.requiresReadySetup &&
            !isSetupReady) {
          return '/system-setup';
        }

        final activeSession = sessionController?.currentSession;
        final hasActiveSession =
            activeSession != null && activeSession.isActive;

        // Guard: Active Session requirement (Fail-Closed)
        if (requirement.requiresActiveSession && !hasActiveSession) {
          return '/login';
        }

        // Guard: Prevent authenticated user from staying on /login
        if (path == '/login' && hasActiveSession) {
          return activeSession.companyId != null
              ? '/dashboard'
              : '/company-selection';
        }

        // Guard: Company Scope requirement (Fail-Closed)
        if (requirement.requiresCompanyScope) {
          if (!hasActiveSession) {
            return '/login';
          }
          if (activeSession.companyId == null) {
            return '/company-selection';
          }
        }

        // Guard: Declarative Permission requirement (Defense-in-Depth)
        final permissionRequirement = requirement.permission;
        if (permissionRequirement != null) {
          // 1. Session must be active (Authentication precedes Authorization)
          if (!hasActiveSession) {
            return '/login';
          }

          // 2. If company scope is required, ensure active company is selected
          if (requirement.requiresCompanyScope &&
              activeSession.companyId == null) {
            return '/company-selection';
          }

          // 3. Missing evaluator dependency -> Fail-Closed
          if (permissionEvaluator == null) {
            return '/unauthorized';
          }

          // 4. Construct trusted authorization context from active session
          final NexaBizAuthorizationContext authContext;
          try {
            authContext = NexaBizAuthorizationContext.fromSession(
              activeSession,
            );
          } catch (error) {
            if (_isAuthorizationProgrammerDefect(error)) rethrow;
            return '/unauthorized';
          }

          // 5. Concurrency snapshot: record session state at evaluation start
          final sessionAtStart = activeSession;

          // 6. Asynchronous permission evaluation
          final NexaBizPermissionDecision decision;
          try {
            decision = await permissionEvaluator.evaluate(
              context: authContext,
              permissionId: permissionRequirement.permissionId,
            );
          } catch (error) {
            if (_isAuthorizationProgrammerDefect(error)) rethrow;
            // Infrastructure / evaluator failure -> Fail-closed safely
            return '/unauthorized';
          }

          // 7. Concurrency check: verify session identity was not altered during flight
          final sessionAtEnd = sessionController?.currentSession;
          if (sessionAtEnd == null ||
              !sessionAtEnd.isActive ||
              sessionAtEnd.sessionId != sessionAtStart.sessionId ||
              sessionAtEnd.companyId != sessionAtStart.companyId) {
            return sessionAtEnd != null && sessionAtEnd.isActive
                ? (sessionAtEnd.companyId != null
                      ? '/dashboard'
                      : '/company-selection')
                : '/login';
          }

          // 8. Enforce decision: ALLOW required; DENY and UNKNOWN yield Access Denied
          if (!decision.isAllowed) {
            return '/unauthorized';
          }
        }

        return null;
      },
    );
  }
}
