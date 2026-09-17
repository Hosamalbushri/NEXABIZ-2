import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shadcn;
import 'package:nexabiz_ui/nexabiz_ui.dart';

void main() {
  Widget buildTestApp(Widget child, {Size size = const Size(1200, 800)}) {
    return shadcn.ShadcnApp(
      home: MediaQuery(
        data: MediaQueryData(size: size),
        child: Directionality(
          textDirection: TextDirection.rtl,
          child: child,
        ),
      ),
    );
  }

  group('AppContainer Primitive Tests', () {
    testWidgets('AppContainer.page enforces max width 1200', (tester) async {
      await tester.pumpWidget(
        buildTestApp(
          const AppContainer.page(
            child: Text('Page Content'),
          ),
        ),
      );

      expect(find.text('Page Content'), findsOneWidget);
      final constrainedBox = tester.widget<ConstrainedBox>(
        find.ancestor(
          of: find.text('Page Content'),
          matching: find.byType(ConstrainedBox),
        ).first,
      );
      expect(constrainedBox.constraints.maxWidth, 1200.0);
    });

    testWidgets('AppContainer.form enforces max width 640', (tester) async {
      await tester.pumpWidget(
        buildTestApp(
          const AppContainer.form(
            child: Text('Form Content'),
          ),
        ),
      );

      expect(find.text('Form Content'), findsOneWidget);
      final constrainedBox = tester.widget<ConstrainedBox>(
        find.ancestor(
          of: find.text('Form Content'),
          matching: find.byType(ConstrainedBox),
        ).first,
      );
      expect(constrainedBox.constraints.maxWidth, 640.0);
    });
  });

  group('AppPageState Primitive Tests', () {
    testWidgets('AppLoading renders loading indicator correctly', (tester) async {
      await tester.pumpWidget(
        buildTestApp(
          const AppLoading(message: 'Loading Ledger Data...'),
        ),
      );

      expect(find.byType(AppLoading), findsOneWidget);
    });

    testWidgets('AppErrorState renders error message and retry button', (tester) async {
      bool retried = false;
      await tester.pumpWidget(
        buildTestApp(
          AppErrorState(
            message: 'Unable to reach backend server',
            onRetry: () => retried = true,
          ),
        ),
      );

      expect(find.text('Unable to reach backend server'), findsOneWidget);
      expect(find.byType(AppErrorState), findsOneWidget);
      expect(retried, isFalse);
    });

    testWidgets('AppEmptyState renders empty state correctly', (tester) async {
      await tester.pumpWidget(
        buildTestApp(
          const AppEmptyState(
            title: 'No Entries Found',
          ),
        ),
      );

      expect(find.text('No Entries Found'), findsOneWidget);
    });
  });
}
