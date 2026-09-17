import 'package:flutter_test/flutter_test.dart';
import 'package:nexabiz/app/app.dart';
import 'package:nexabiz/app/bootstrap/app_bootstrap.dart';

void main() {
  group('AppBootstrap Integration Test', () {
    test('initializes Capability Registry, Navigation Registry, and GoRouter cleanly', () async {
      final bootstrap = await AppBootstrap.initialize(initialLocation: '/dashboard');

      expect(bootstrap.capabilityRegistry.isLocked, isTrue);
      expect(bootstrap.navigationRegistry.isLocked, isTrue);
      expect(bootstrap.capabilityRegistry.containsCapability('dashboard'), isTrue);
      expect(bootstrap.capabilityRegistry.containsCapability('services'), isTrue);
      expect(bootstrap.capabilityRegistry.containsCapability('reports'), isTrue);
      expect(bootstrap.capabilityRegistry.containsCapability('settings'), isTrue);
      expect(bootstrap.navigationRegistry.routes.length, equals(4));
    });

    testWidgets('renders Dashboard Page via AppBootstrap router using NexaBiz UI', (tester) async {
      final bootstrap = await AppBootstrap.initialize(initialLocation: '/dashboard');

      await tester.pumpWidget(NexaBizApp(router: bootstrap.router));
      await tester.pumpAndSettle();

      expect(find.text('NexaBiz Dashboard'), findsOneWidget);
      expect(find.text('Welcome back to NexaBiz ERP'), findsOneWidget);
    });
  });
}
