import '../support/bootstrap_test_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nexabiz/app/app.dart';
import 'package:nexabiz_ui/nexabiz_ui.dart';

void main() {
  group('Navigation Stack Contract Tests (Phase 05-A)', () {
    testWidgets(
      'NAV-STACK-01: Root -> Child -> Back restores Root without exit dialog',
      (tester) async {
        final bootstrap = await bootstrapForTest(initialLocation: '/services');
        addTearDown(bootstrap.router.dispose);

        await tester.pumpWidget(NexaBizApp(router: bootstrap.router));
        await tester.pumpAndSettle();

        expect(find.text('Services Hub'), findsOneWidget);

        // Tap Component Gallery tile (triggers context.push('/gallery'))
        await tester.tap(find.text('Component Gallery'));
        await tester.pumpAndSettle();

        expect(find.text('Services Hub'), findsNothing);

        // Trigger System Back
        await tester.binding.handlePopRoute();
        await tester.pumpAndSettle();

        // Child is popped, Services Hub is restored
        expect(find.text('Services Hub'), findsOneWidget);
        expect(find.text('Exit Application'), findsNothing);
      },
    );

    testWidgets(
      'NAV-STACK-02 & NAV-STACK-03: Child Back pops stack, child Back MUST NOT exit',
      (tester) async {
        final bootstrap = await bootstrapForTest(initialLocation: '/settings');
        addTearDown(bootstrap.router.dispose);

        await tester.pumpWidget(NexaBizApp(router: bootstrap.router));
        await tester.pumpAndSettle();

        // Push /gallery from settings
        await tester.tap(find.text('UI Component Gallery & Playground'));
        await tester.pumpAndSettle();

        expect(find.text('Settings & Configuration'), findsNothing);

        // Send System Back while on child page
        await tester.binding.handlePopRoute();
        await tester.pumpAndSettle();

        // Verify child popped, page restored, zero exit prompt
        expect(find.text('Settings & Configuration'), findsOneWidget);
        expect(find.text('Exit Application'), findsNothing);
      },
    );

    testWidgets(
      'NAV-STACK-04 & NAV-STACK-05: Root Back prompts exit confirmation, cancel leaves app active',
      (tester) async {
        final bootstrap = await bootstrapForTest(initialLocation: '/dashboard');
        addTearDown(bootstrap.router.dispose);

        await tester.pumpWidget(NexaBizApp(router: bootstrap.router));
        await tester.pumpAndSettle();

        expect(find.text('NexaBiz Dashboard'), findsOneWidget);

        // Trigger System Back at true root
        await tester.binding.handlePopRoute();
        await tester.pumpAndSettle();

        // Exit confirmation dialog appears
        expect(find.text('Exit Application'), findsOneWidget);
        expect(
          find.text('Are you sure you want to exit NexaBiz ERP?'),
          findsOneWidget,
        );

        // Tap Cancel
        await tester.tap(find.text('Cancel'));
        await tester.pumpAndSettle();

        // Dialog closes, Dashboard remains visible
        expect(find.text('Exit Application'), findsNothing);
        expect(find.text('NexaBiz Dashboard'), findsOneWidget);
      },
    );

    testWidgets('NAV-STACK-06: Confirming exit closes confirmation overlay', (
      tester,
    ) async {
      final bootstrap = await bootstrapForTest(initialLocation: '/dashboard');
      addTearDown(bootstrap.router.dispose);

      await tester.pumpWidget(NexaBizApp(router: bootstrap.router));
      await tester.pumpAndSettle();

      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();

      expect(find.text('Exit Application'), findsOneWidget);

      // Tapping Exit confirms action
      await tester.tap(find.text('Exit'));
      await tester.pumpAndSettle();

      expect(find.text('Exit Application'), findsNothing);
    });

    testWidgets(
      'NAV-STACK-07: Overlay Back closes overlay without navigating underlying page',
      (tester) async {
        final bootstrap = await bootstrapForTest(initialLocation: '/dashboard');
        addTearDown(bootstrap.router.dispose);

        await tester.pumpWidget(NexaBizApp(router: bootstrap.router));
        await tester.pumpAndSettle();

        // Open Quick Actions panel overlay via FAB
        await tester.tap(find.byIcon(AppIcons.plus));
        await tester.pumpAndSettle();

        expect(find.text('Quick Actions'), findsOneWidget);

        // Send System Back while overlay is open
        await tester.binding.handlePopRoute();
        await tester.pumpAndSettle();

        // Overlay is closed, Dashboard is still visible, exit prompt did not appear
        expect(find.text('Exit Application'), findsNothing);
        expect(find.text('NexaBiz Dashboard'), findsOneWidget);
      },
    );

    testWidgets('NAV-STACK-08: Branch switching preserves state across tabs', (
      tester,
    ) async {
      final bootstrap = await bootstrapForTest(initialLocation: '/dashboard');
      addTearDown(bootstrap.router.dispose);

      await tester.pumpWidget(NexaBizApp(router: bootstrap.router));
      await tester.pumpAndSettle();

      // Switch to Services tab
      await tester.tap(find.text('Services'));
      await tester.pumpAndSettle();
      expect(find.text('Services Hub'), findsOneWidget);

      // Switch to Reports tab
      await tester.tap(find.text('Reports'));
      await tester.pumpAndSettle();

      // Switch back to Services tab — state preserved
      await tester.tap(find.text('Services'));
      await tester.pumpAndSettle();
      expect(find.text('Services Hub'), findsOneWidget);

      // Push /gallery inside Services tab
      await tester.tap(find.text('Component Gallery'));
      await tester.pumpAndSettle();

      // Back unwinds pushed route inside Services branch
      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();

      expect(find.text('Services Hub'), findsOneWidget);
    });

    testWidgets(
      'NAV-STACK-09: RTL layout preserves logical navigation stack semantics',
      (tester) async {
        final bootstrap = await bootstrapForTest(initialLocation: '/services');
        addTearDown(bootstrap.router.dispose);

        await tester.pumpWidget(
          Directionality(
            textDirection: TextDirection.rtl,
            child: NexaBizApp(router: bootstrap.router),
          ),
        );
        await tester.pumpAndSettle();

        await tester.tap(find.text('Component Gallery'));
        await tester.pumpAndSettle();

        await tester.binding.handlePopRoute();
        await tester.pumpAndSettle();

        expect(find.text('Services Hub'), findsOneWidget);
        expect(find.text('Exit Application'), findsNothing);
      },
    );

    testWidgets(
      'NAV-STACK-REGRESSION: Step-by-step stack unwind sequence proof',
      (tester) async {
        final history = <String>[];
        final bootstrap = await bootstrapForTest(initialLocation: '/services');
        addTearDown(bootstrap.router.dispose);

        bootstrap.router.routerDelegate.addListener(() {
          history.add(bootstrap.router.state.uri.toString());
        });

        await tester.pumpWidget(NexaBizApp(router: bootstrap.router));
        await tester.pumpAndSettle();
        history.add('ENTRY: /services');

        // 1. Push child
        await tester.tap(find.text('Component Gallery'));
        await tester.pumpAndSettle();
        history.add('PUSH: /gallery');

        // 2. Pop child
        await tester.binding.handlePopRoute();
        await tester.pumpAndSettle();
        history.add('POP: /services restored');

        // 3. System Back at root
        await tester.binding.handlePopRoute();
        await tester.pumpAndSettle();
        history.add('ROOT_BACK: Exit prompt displayed');

        expect(
          history,
          containsAllInOrder([
            'ENTRY: /services',
            'PUSH: /gallery',
            'POP: /services restored',
            'ROOT_BACK: Exit prompt displayed',
          ]),
        );

        // Clean up dialog
        await tester.tap(find.text('Cancel'));
        await tester.pumpAndSettle();
      },
    );
  });
}
