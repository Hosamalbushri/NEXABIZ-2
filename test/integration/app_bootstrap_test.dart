import '../support/bootstrap_test_helper.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nexabiz/app/app.dart';
import 'package:nexabiz/app/authorization/app_permission_scope.dart';
import 'package:nexabiz/core/navigation/nexabiz_route_id.dart';
import 'package:nexabiz/main.dart' show createProductionApp;
import 'package:nexabiz_ui/nexabiz_ui.dart';

void main() {
  group('AppBootstrap Integration Test', () {
    test(
      'initializes Capability Registry, Navigation Registry, and GoRouter cleanly',
      () async {
        final bootstrap = await bootstrapForTest(initialLocation: '/dashboard');
        addTearDown(bootstrap.router.dispose);

        expect(bootstrap.capabilityRegistry.isLocked, isTrue);
        expect(bootstrap.navigationRegistry.isLocked, isTrue);
        expect(
          bootstrap.capabilityRegistry.containsCapability('dashboard'),
          isTrue,
        );
        expect(
          bootstrap.capabilityRegistry.containsCapability('services'),
          isTrue,
        );
        expect(
          bootstrap.capabilityRegistry.containsCapability('reports'),
          isTrue,
        );
        expect(
          bootstrap.capabilityRegistry.containsCapability('settings'),
          isTrue,
        );
        expect(
          bootstrap.capabilityRegistry.containsCapability('gallery'),
          isTrue,
        );
        expect(
          bootstrap.capabilityRegistry.containsCapability(
            'navigation_test_lab',
          ),
          isTrue,
        );
        final routeIds = bootstrap.navigationRegistry.routes
            .map((route) => route.routeId)
            .toList();
        expect(
          routeIds,
          containsAll(const [
            NexaBizRouteId(namespace: 'dashboard', routeName: 'root'),
            NexaBizRouteId(namespace: 'services', routeName: 'root'),
            NexaBizRouteId(namespace: 'reports', routeName: 'root'),
            NexaBizRouteId(namespace: 'settings', routeName: 'root'),
            NexaBizRouteId(namespace: 'gallery', routeName: 'root'),
            NexaBizRouteId(
              namespace: 'navigation_test_lab',
              routeName: 'navigation_lab_root',
            ),
          ]),
        );
      },
    );

    testWidgets(
      'renders Dashboard Page via AppBootstrap router using NexaBiz UI',
      (tester) async {
        final bootstrap = await bootstrapForTest(
          initialLocation: '/dashboard',
          authenticated: true,
        );
        addTearDown(bootstrap.router.dispose);

        bootstrap.router.go('/dashboard');

        await tester.pumpWidget(NexaBizApp(router: bootstrap.router));
        await tester.pumpAndSettle();

        expect(find.text('NexaBiz Dashboard'), findsOneWidget);
        expect(find.text('Welcome back to NexaBiz ERP'), findsOneWidget);
      },
    );

    testWidgets(
      'NexaBizApp mounts AppPermissionScope with identical canonical bootstrap instances',
      (tester) async {
        final bootstrap = await bootstrapForTest(
          initialLocation: '/dashboard',
          authenticated: false,
        );
        addTearDown(bootstrap.router.dispose);

        final app = createProductionApp(bootstrap);

        expect(identical(app.router, bootstrap.router), isTrue);
        expect(
          identical(app.permissionEvaluator, bootstrap.permissionEvaluator),
          isTrue,
        );
        expect(
          identical(app.sessionController, bootstrap.sessionController),
          isTrue,
        );
        expect(
          identical(
            app.authorizationInvalidationSignal,
            bootstrap.authorizationInvalidationSignal,
          ),
          isTrue,
        );

        await tester.pumpWidget(app);
        await tester.pump();

        final appRootContext = tester.element(find.byType(NexaBizRootApp));
        final scope = AppPermissionScope.of(appRootContext);

        expect(
          identical(scope.permissionEvaluator, bootstrap.permissionEvaluator),
          isTrue,
          reason:
              'Scope evaluator must be identical to canonical bootstrap instance',
        );
        expect(
          identical(scope.sessionController, bootstrap.sessionController),
          isTrue,
          reason:
              'Scope sessionController must be identical to canonical bootstrap instance',
        );
        expect(
          identical(
            scope.invalidationSignal,
            bootstrap.authorizationInvalidationSignal,
          ),
          isTrue,
          reason:
              'Scope invalidationSignal must be identical to canonical bootstrap instance',
        );
        expect(
          identical(
            scope.authorizationAdministration,
            bootstrap.authorizationAdministration,
          ),
          isTrue,
          reason:
              'Scope authorizationAdministration must be identical to canonical bootstrap instance',
        );
      },
    );
  });
}
