import '../support/bootstrap_test_helper.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nexabiz/app/app.dart';
import 'package:nexabiz/core/identity/authenticate_local_user.dart';
import 'package:nexabiz/core/navigation/nexabiz_route_id.dart';
import 'package:nexabiz/core/setup/initialize_nexabiz_core.dart';

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
        final bootstrap = await bootstrapForTest(initialLocation: '/dashboard');
        addTearDown(bootstrap.router.dispose);

        // Initialize Core database & authenticate session to pass Security Gate
        final initializer = InitializeNexaBizCore(bootstrap.coreInstallationStore);
        await initializer(
          const CoreInitializationInput(
            companyCode: 'COMP01',
            companyName: 'Test Company',
            adminName: 'Admin User',
            adminEmail: 'admin@nexabiz.test',
            password: 'Password123!',
          ),
        );

        await bootstrap.sessionController.login(
          const CoreAuthenticationInput(
            identifier: 'admin@nexabiz.test',
            password: 'Password123!',
          ),
        );

        bootstrap.router.go('/dashboard');

        await tester.pumpWidget(NexaBizApp(router: bootstrap.router));
        await tester.pumpAndSettle();

        expect(find.text('NexaBiz Dashboard'), findsOneWidget);
        expect(find.text('Welcome back to NexaBiz ERP'), findsOneWidget);
      },
    );
  });
}
