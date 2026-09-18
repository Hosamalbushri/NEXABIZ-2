import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:nexabiz/app/app.dart';
import 'package:nexabiz/app/shell/application_shell.dart';
import 'package:nexabiz_ui/nexabiz_ui.dart';

void main() {
  group('ApplicationShell Widget Tests', () {
    Widget buildTestShell({
      required double width,
      required double height,
      String currentPath = '/dashboard',
    }) {
      final router = GoRouter(
        initialLocation: currentPath,
        routes: [
          ShellRoute(
            builder: (context, state, child) => ApplicationShell(
              currentPath: state.uri.toString(),
              child: child,
            ),
            routes: [
              GoRoute(
                path: '/dashboard',
                builder: (context, state) => const Text('Dashboard Content'),
              ),
              GoRoute(
                path: '/services',
                builder: (context, state) => const Text('Services Content'),
              ),
              GoRoute(
                path: '/reports',
                builder: (context, state) => const Text('Reports Content'),
              ),
              GoRoute(
                path: '/settings',
                builder: (context, state) => const Text('Settings Content'),
              ),
            ],
          ),
        ],
      );

      return MediaQuery(
        data: MediaQueryData(size: Size(width, height)),
        child: NexaBizApp(router: router),
      );
    }

    testWidgets(
      'renders AppResponsiveScaffold and AppCustomBottomNav on Mobile',
      (tester) async {
        tester.view.physicalSize = const Size(400, 800);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);

        await tester.pumpWidget(buildTestShell(width: 400, height: 800));
        await tester.pumpAndSettle();

        expect(find.byType(AppCustomBottomNav), findsOneWidget);
        expect(find.text('Dashboard Content'), findsOneWidget);
      },
    );

    testWidgets('renders AppResponsiveScaffold on Tablet & Desktop', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(1200, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(buildTestShell(width: 1200, height: 900));
      await tester.pumpAndSettle();

      expect(find.byType(AppResponsiveScaffold), findsOneWidget);
      expect(find.text('Dashboard Content'), findsOneWidget);
    });
  });
}
