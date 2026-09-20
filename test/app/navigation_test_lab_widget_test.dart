import '../support/bootstrap_test_helper.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nexabiz/app/app.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Navigation Test Lab Widget & Stack Tests', () {
    testWidgets('Dashboard renders and navigates to deep Branch A routes', (
      tester,
    ) async {
      final bootstrap = await bootstrapForTest(
        initialLocation: '/dev/navigation',
      );
      addTearDown(() => bootstrap.router.dispose());

      await tester.pumpWidget(NexaBizApp(router: bootstrap.router));
      await tester.pumpAndSettle();

      // 1. Verify Navigation Test Lab Dashboard
      expect(find.text('Navigation Test Lab'), findsOneWidget);
      expect(find.text('BRANCH TEST LAUNCHERS'), findsOneWidget);

      // 2. Tap Branch A Launcher
      await tester.tap(find.text('Branch A (4-Level Linear & Sibling Test)'));
      await tester.pumpAndSettle();

      // 3. Verify Node A Root
      expect(
        find.text('Branch A Root'),
        findsNWidgets(2),
      ); // Header + Telemetry
      expect(find.text('Stack Depth'), findsOneWidget);

      // 4. Push to Node A1
      await tester.tap(find.text('Node A1'));
      await tester.pumpAndSettle();
      expect(find.text('Node A1'), findsNWidgets(2)); // Header + Telemetry

      // 5. Push to Node A1.1
      await tester.tap(find.text('Node A1.1'));
      await tester.pumpAndSettle();
      expect(find.text('Node A1.1'), findsNWidgets(2));

      // 6. Push to Node A1.1.1 (Level 4 Deepest)
      await tester.tap(find.text('Node A1.1.1 (Deepest)'));
      await tester.pumpAndSettle();
      expect(find.text('Node A1.1.1'), findsNWidgets(2));

      // 7. Unwind stack using system back button
      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();
      expect(find.text('Node A1.1'), findsNWidgets(2));

      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();
      expect(find.text('Node A1'), findsNWidgets(2));

      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();
      expect(find.text('Branch A Root'), findsNWidgets(2));

      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();
      expect(find.text('Navigation Test Lab'), findsOneWidget);
    });

    testWidgets('Parameterized routes parse item IDs correctly', (
      tester,
    ) async {
      final bootstrap = await bootstrapForTest(
        initialLocation: '/dev/navigation/param/100',
      );
      addTearDown(() => bootstrap.router.dispose());

      await tester.pumpWidget(NexaBizApp(router: bootstrap.router));
      await tester.pumpAndSettle();

      expect(find.text('Parameter Test (Item #100)'), findsOneWidget);
      expect(find.text('/dev/navigation/param/100'), findsOneWidget);
    });
  });
}
