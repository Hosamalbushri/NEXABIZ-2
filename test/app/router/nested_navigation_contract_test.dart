import '../../support/bootstrap_test_helper.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:nexabiz/app/app.dart';
import 'package:nexabiz/app/localization/app_locale_controller.dart';
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
import 'package:shared_preferences/shared_preferences.dart';

const _root = NexaBizRouteId(namespace: 'nested_test', routeName: 'root');
const _details = NexaBizRouteId(namespace: 'nested_test', routeName: 'details');
const _audit = NexaBizRouteId(namespace: 'nested_test', routeName: 'audit');

class _Contribution implements NexaBizNavigationContribution {
  _Contribution(this.routes);

  @override
  NexaBizRouteId get rootRouteId => _root;

  @override
  final List<NexaBizRouteDefinition> routes;
}

class _Capability implements NexaBizCapability {
  _Capability(this.navigationContribution);

  @override
  String get capabilityId => 'nested_test';

  @override
  CapabilityMetadata get metadata =>
      const CapabilityMetadata(nameKey: 'nestedTest', iconIdentifier: 'test');

  @override
  List<String> get dependsOn => const [];

  @override
  final NexaBizNavigationContribution navigationContribution;
}

NexaBizNavigationRegistry _collect(List<NexaBizRouteDefinition> routes) {
  final capabilities = NexaBizCapabilityRegistry();
  capabilities.register(_Capability(_Contribution(routes)));
  capabilities.validateAndLock();
  return NexaBizNavigationRegistry()..collectAndLock(capabilities);
}

NexaBizFlutterRouteDefinition _route(
  NexaBizRouteId id,
  String path, {
  NexaBizRouteId? parent,
  NexaBizRouteAccessRequirement? accessRequirement,
}) => NexaBizFlutterRouteDefinition(
  routeId: id,
  path: path,
  parentRouteId: parent,
  accessRequirement: accessRequirement,
  pageBuilder: (context) => Text(id.value),
);

void main() {
  test('registry accepts a valid nested route hierarchy', () {
    final registry = _collect([
      _route(_root, '/nested-test'),
      _route(_details, '/nested-test/details', parent: _root),
      _route(_audit, '/nested-test/details/audit', parent: _details),
    ]);
    expect(registry.routes, hasLength(3));
    expect(registry.getRoute(_audit).parentRouteId, _details);
  });

  test('registry rejects a missing parent and remains unlocked', () {
    final navigation = NexaBizNavigationRegistry();
    final capabilities = NexaBizCapabilityRegistry();
    capabilities.register(
      _Capability(
        _Contribution([
          _route(_root, '/nested-test'),
          _route(_audit, '/nested-test/details/audit', parent: _details),
        ]),
      ),
    );
    capabilities.validateAndLock();
    expect(() => navigation.collectAndLock(capabilities), throwsStateError);
    expect(navigation.isLocked, isFalse);
  });

  test('registry rejects a hierarchy cycle', () {
    expect(
      () => _collect([
        _route(_root, '/nested-test'),
        _route(_details, '/nested-test/details', parent: _audit),
        _route(_audit, '/nested-test/details/audit', parent: _details),
      ]),
      throwsA(
        isA<StateError>().having(
          (error) => error.message,
          'message',
          contains('cycle'),
        ),
      ),
    );
  });

  test('registry rejects duplicate nested paths and non-direct children', () {
    expect(
      () => _collect([
        _route(_root, '/nested-test'),
        _route(_details, '/nested-test/details', parent: _root),
        _route(_audit, '/NESTED-TEST/DETAILS', parent: _root),
      ]),
      throwsStateError,
    );
    expect(
      () => _collect([
        _route(_root, '/nested-test'),
        _route(_audit, '/nested-test/details/audit', parent: _root),
      ]),
      throwsStateError,
    );
  });

  test('registry rejects noncanonical paths and duplicate IDs', () {
    for (final path in [
      '//double',
      '/path/',
      '../escape',
      '/path?query=1',
      '/path#fragment',
    ]) {
      expect(() => _collect([_route(_root, path)]), throwsStateError);
    }
    expect(
      () => _collect([
        _route(_root, '/nested-test'),
        _route(_root, '/nested-test/duplicate'),
      ]),
      throwsStateError,
    );
    expect(
      () => _collect([
        _route(_root, '/nested-test'),
        _route(
          const NexaBizRouteId(namespace: 'other', routeName: 'child'),
          '/nested-test/child',
          parent: _root,
        ),
      ]),
      throwsStateError,
    );
  });

  test('router adapter nests relative GoRoutes from registry', () {
    final router = NexaBizGoRouterAdapter(
      _collect([
        _route(_root, '/nested-test'),
        _route(_details, '/nested-test/details', parent: _root),
        _route(_audit, '/nested-test/details/audit', parent: _details),
      ]),
    ).createRouter(initialLocation: '/nested-test');
    addTearDown(router.dispose);
    final shell = router.configuration.routes.single as ShellRoute;
    final root = shell.routes.single as GoRoute;
    expect(root.path, '/nested-test');
    final details = root.routes.single as GoRoute;
    expect(details.path, 'details');
    expect((details.routes.single as GoRoute).path, 'audit');
  });

  test('route access metadata does not alter GoRouter construction', () {
    final registry = _collect([
      _route(
        _root,
        '/nested-test',
        accessRequirement: const NexaBizRouteAccessRequirement(
          requiresActiveSession: true,
          requiresCompanyScope: true,
        ),
      ),
      _route(_details, '/nested-test/details', parent: _root),
    ]);
    final router = NexaBizGoRouterAdapter(
      registry,
    ).createRouter(initialLocation: '/nested-test');
    addTearDown(router.dispose);
    final shell = router.configuration.routes.single as ShellRoute;
    final root = shell.routes.single as GoRoute;
    expect(root.path, '/nested-test');
    expect((root.routes.single as GoRoute).path, 'details');
    expect(
      registry.getRoute(_root).accessRequirement?.requiresActiveSession,
      isTrue,
    );
  });

  test('router adapter rejects an unbound nested page before construction', () {
    final registry = _collect([
      _route(_root, '/nested-test'),
      const NexaBizRouteDefinition(
        routeId: _details,
        parentRouteId: _root,
        path: '/nested-test/details',
      ),
    ]);
    expect(
      () => NexaBizGoRouterAdapter(registry).createRouter(),
      throwsA(
        isA<StateError>().having(
          (error) => error.message,
          'message',
          contains('nested_test.details'),
        ),
      ),
    );
  });

  test('bootstrap contains every nested manual route', () async {
    final bootstrap = await bootstrapForTest();
    addTearDown(bootstrap.router.dispose);
    const expectedRoutes = {
      '/navigation-test-lab': 'nested_root',
      '/navigation-test-lab/details': 'nested_details',
      '/navigation-test-lab/details/audit': 'nested_audit',
      '/navigation-test-lab/settings': 'nested_settings',
      '/navigation-test-lab/settings/advanced': 'nested_advanced',
    };
    for (final entry in expectedRoutes.entries) {
      expect(
        bootstrap.navigationRegistry.getRouteByPath(entry.key).routeId,
        NexaBizRouteId(
          namespace: 'navigation_test_lab',
          routeName: entry.value,
        ),
      );
    }
  });

  testWidgets('nested push, Back, direct link, and locale switching work', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    await AppLocaleController.setLocale(const Locale('en'));
    final bootstrap = await bootstrapForTest(
      initialLocation: '/navigation-test-lab',
    );
    addTearDown(bootstrap.router.dispose);
    await tester.pumpWidget(NexaBizApp(router: bootstrap.router));
    await tester.pumpAndSettle();
    expect(find.text('Nested Navigation Test'), findsOneWidget);

    await tester.tap(find.text('Open details'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Open audit'));
    await tester.pumpAndSettle();
    expect(find.text('Nested Audit'), findsOneWidget);
    await AppLocaleController.setLocale(const Locale('ar'));
    await tester.pumpAndSettle();
    expect(find.text('تدقيق المسار المتشعب'), findsOneWidget);
    await tester.tap(find.text('رجوع (POP)'));
    await tester.pumpAndSettle();
    expect(find.text('التفاصيل المتشعبة'), findsOneWidget);

    await tester.tap(find.text('رجوع (POP)'));
    await tester.pumpAndSettle();
    expect(find.text('اختبار التنقل المتشعب'), findsOneWidget);
    await tester.tap(find.text('افتح الإعدادات'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('افتح الإعدادات المتقدمة'));
    await tester.pumpAndSettle();
    expect(find.text('إعدادات متقدمة للمسار المتشعب'), findsOneWidget);

    bootstrap.router.go('/navigation-test-lab/details/audit');
    await tester.pumpAndSettle();
    expect(find.text('تدقيق المسار المتشعب'), findsOneWidget);
  });
}
