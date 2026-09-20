import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:nexabiz/app/app.dart';
import 'package:nexabiz/app/router/nexabiz_flutter_route_definition.dart';
import 'package:nexabiz/app/router/nexabiz_router_adapter.dart';
import 'package:nexabiz/core/capabilities/capability_metadata.dart';
import 'package:nexabiz/core/capabilities/nexabiz_capability.dart';
import 'package:nexabiz/core/capabilities/nexabiz_capability_registry.dart';
import 'package:nexabiz/core/navigation/nexabiz_navigation_contribution.dart';
import 'package:nexabiz/core/navigation/nexabiz_navigation_registry.dart';
import 'package:nexabiz/core/navigation/nexabiz_route_access_requirement.dart';
import 'package:nexabiz/core/navigation/nexabiz_route_definition.dart';
import 'package:nexabiz/core/navigation/nexabiz_route_id.dart';

class _Contribution implements NexaBizNavigationContribution {
  @override
  final List<NexaBizRouteDefinition> routes;

  _Contribution(this.routes);

  @override
  NexaBizRouteId get rootRouteId => routes.first.routeId;
}

class _Capability implements NexaBizCapability {
  @override
  final NexaBizNavigationContribution? navigationContribution;

  _Capability(this.navigationContribution);

  @override
  String get capabilityId => 'test';

  @override
  CapabilityMetadata get metadata =>
      const CapabilityMetadata(nameKey: 'test', iconIdentifier: 'test');

  @override
  List<String> get dependsOn => const [];
}

NexaBizNavigationRegistry _registry(List<NexaBizRouteDefinition> routes) {
  final capabilities = NexaBizCapabilityRegistry();
  capabilities.register(
    _Capability(routes.isEmpty ? null : _Contribution(routes)),
  );
  capabilities.validateAndLock();
  return NexaBizNavigationRegistry()..collectAndLock(capabilities);
}

NexaBizFlutterRouteDefinition _route(String name) =>
    NexaBizFlutterRouteDefinition(
      routeId: NexaBizRouteId(namespace: 'test', routeName: name),
      path: '/$name',
      accessRequirement: const NexaBizRouteAccessRequirement(
        requiresReadySetup: false,
        requiresActiveSession: false,
        requiresCompanyScope: false,
      ),
      pageBuilder: (context) => Text('Page $name'),
    );

Iterable<GoRoute> _leafRoutes(Iterable<RouteBase> routes) sync* {
  for (final route in routes) {
    if (route is GoRoute) {
      yield route;
      yield* _leafRoutes(route.routes);
    } else if (route is ShellRoute) {
      yield* _leafRoutes(route.routes);
    } else if (route is StatefulShellRoute) {
      for (final branch in route.branches) {
        yield* _leafRoutes(branch.routes);
      }
    }
  }
}

void _expectUniqueTopology(
  GoRouter router,
  List<NexaBizRouteDefinition> expected,
) {
  final leaves = _leafRoutes(router.configuration.routes).toList();
  expect(leaves, hasLength(expected.length));
  for (final route in expected) {
    expect(
      leaves.where((leaf) => leaf.name == route.routeId.value),
      hasLength(1),
      reason: 'Name ${route.routeId.value} must occur exactly once',
    );
    expect(
      leaves.where((leaf) => leaf.path == route.path),
      hasLength(1),
      reason: 'Path ${route.path} must occur exactly once',
    );
  }
}

void _expectFallback(List<NexaBizRouteDefinition> routes) {
  final router = NexaBizGoRouterAdapter(
    _registry(routes),
  ).createRouter(initialLocation: routes.first.path);
  addTearDown(router.dispose);
  expect(router.configuration.routes, hasLength(1));
  final shell = router.configuration.routes.single;
  expect(shell, isA<ShellRoute>());
  expect((shell as ShellRoute).routes, hasLength(routes.length));
  _expectUniqueTopology(router, routes);
}

void main() {
  test('rejects an unlocked navigation registry', () {
    expect(
      () => NexaBizGoRouterAdapter(NexaBizNavigationRegistry()).createRouter(),
      throwsStateError,
    );
  });

  test('rejects an empty navigation registry', () {
    expect(
      () => NexaBizGoRouterAdapter(_registry([])).createRouter(),
      throwsStateError,
    );
  });

  test('rejects metadata-only routes before constructing a router', () {
    final registry = _registry([
      const NexaBizRouteDefinition(
        routeId: NexaBizRouteId(namespace: 'test', routeName: 'root'),
        path: '/test',
      ),
    ]);
    expect(
      () => NexaBizGoRouterAdapter(
        registry,
      ).createRouter(initialLocation: '/test'),
      throwsA(
        isA<StateError>().having(
          (error) => error.message,
          'message',
          contains('test.root'),
        ),
      ),
    );
  });

  test(
    'zero primary branches uses fallback with secondary routes inside the shell',
    () {
      _expectFallback([_route('demo'), _route('gallery')]);
    },
  );

  test('exactly one primary branch uses fallback without duplicate routes', () {
    _expectFallback([_route('dashboard'), _route('gallery')]);
  });

  test(
    'exactly three primary branches uses fallback without duplicate routes',
    () {
      _expectFallback([
        _route('dashboard'),
        _route('services'),
        _route('reports'),
        _route('gallery'),
      ]);
    },
  );

  test('multiple secondary routes each have one name and path', () {
    final routes = [
      _route('dashboard'),
      _route('services'),
      _route('reports'),
      _route('settings'),
      _route('gallery'),
      _route('demo'),
    ];
    final router = NexaBizGoRouterAdapter(_registry(routes)).createRouter();
    addTearDown(router.dispose);
    expect(router.configuration.routes.first, isA<StatefulShellRoute>());
    expect(router.configuration.routes, hasLength(3));
    expect(
      router.configuration.routes
          .skip(1)
          .map((route) => (route as GoRoute).path),
      ['/gallery', '/demo'],
    );
    _expectUniqueTopology(router, routes);
  });

  test(
    'complete primary shell retains canonical branches and external gallery',
    () {
      final routes = [
        _route('gallery'),
        _route('settings'),
        _route('reports'),
        _route('services'),
        _route('dashboard'),
      ];
      final router = NexaBizGoRouterAdapter(_registry(routes)).createRouter();
      addTearDown(router.dispose);
      final shell = router.configuration.routes.first as StatefulShellRoute;
      expect(
        shell.branches.map((branch) => (branch.routes.single as GoRoute).path),
        NexaBizGoRouterAdapter.primaryBranchPaths,
      );
      expect(router.configuration.routes, hasLength(2));
      expect((router.configuration.routes.last as GoRoute).path, '/gallery');
      expect(_leafRoutes(router.configuration.routes), hasLength(5));
      _expectUniqueTopology(router, routes);
    },
  );

  testWidgets(
    'unknown initial location uses router error handling and can recover',
    (tester) async {
      final router = NexaBizGoRouterAdapter(
        _registry([_route('demo')]),
      ).createRouter(initialLocation: '/unknown');
      addTearDown(router.dispose);
      expect(
        router.configuration.findMatch(Uri.parse('/unknown')).error,
        isA<GoException>(),
      );
      await tester.pumpWidget(NexaBizApp(router: router));
      await tester.pumpAndSettle();
      expect(
        router.routerDelegate.currentConfiguration.error,
        isA<GoException>(),
      );
      expect(find.text('Page demo'), findsNothing);
      expect(
        find.textContaining('no routes for location: /unknown'),
        findsOneWidget,
      );
      expect(tester.takeException(), isNull);
      router.goNamed('test.demo');
      await tester.pumpAndSettle();
      expect(router.routerDelegate.currentConfiguration.error, isNull);
      expect(find.text('Page demo'), findsOneWidget);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox.shrink());
    },
  );

  testWidgets(
    'typed page builder builds the intended Widget with a valid context',
    (tester) async {
      BuildContext? receivedContext;
      final first = NexaBizFlutterRouteDefinition(
        routeId: const NexaBizRouteId(namespace: 'test', routeName: 'demo'),
        path: '/demo',
        pageBuilder: (context) {
          receivedContext = context;
          return const Text('Typed demo page');
        },
      );
      final router = NexaBizGoRouterAdapter(
        _registry([first, _route('gallery')]),
      ).createRouter(initialLocation: '/demo');
      addTearDown(router.dispose);
      await tester.pumpWidget(NexaBizApp(router: router));
      await tester.pumpAndSettle();
      expect(receivedContext, isNotNull);
      expect(find.text('Typed demo page'), findsOneWidget);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox.shrink());
    },
  );

  testWidgets('navigation by logical name builds the intended destination', (
    tester,
  ) async {
    final router = NexaBizGoRouterAdapter(
      _registry([_route('demo'), _route('gallery')]),
    ).createRouter(initialLocation: '/demo');
    addTearDown(router.dispose);
    await tester.pumpWidget(NexaBizApp(router: router));
    await tester.pumpAndSettle();
    expect(find.text('Page demo'), findsOneWidget);
    router.goNamed('test.gallery');
    await tester.pumpAndSettle();
    expect(find.text('Page gallery'), findsOneWidget);
    expect(find.text('Page demo'), findsNothing);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox.shrink());
  });
}
