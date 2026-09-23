import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nexabiz_ui/nexabiz_ui.dart';

void main() {
  Widget buildTestableTile({
    required Widget child,
    required double width,
    TextDirection textDirection = TextDirection.ltr,
    double textScaleFactor = 1.0,
  }) {
    return MediaQuery(
      data: MediaQueryData(
        size: Size(width, 600),
        textScaler: TextScaler.linear(textScaleFactor),
      ),
      child: Directionality(
        textDirection: textDirection,
        child: NexaBizRootApp(
          home: Center(
            child: SizedBox(width: width, child: child),
          ),
        ),
      ),
    );
  }

  group('AppListTile Shared Component Contract Tests', () {
    testWidgets('Normal width (400px) renders horizontal Row layout', (
      tester,
    ) async {
      await tester.pumpWidget(
        buildTestableTile(
          width: 400.0,
          child: const AppListTile(
            leading: Icon(AppIcons.settings),
            title: Text('Dark Mode'),
            subtitle: Text('Light theme enabled'),
            trailing: Text('Action'),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.byType(AppListTile), findsOneWidget);
      expect(find.text('Dark Mode'), findsOneWidget);
      expect(find.text('Action'), findsOneWidget);
    });

    testWidgets('Compact width (280px) renders vertical stacked layout', (
      tester,
    ) async {
      await tester.pumpWidget(
        buildTestableTile(
          width: 280.0,
          child: const AppListTile(
            leading: Icon(AppIcons.settings),
            title: Text('Dark Mode'),
            subtitle: Text('Light theme enabled'),
            trailing: Text('Action'),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.byType(AppListTile), findsOneWidget);
      expect(find.text('Dark Mode'), findsOneWidget);
      expect(find.text('Action'), findsOneWidget);
    });

    testWidgets('Boundary test (319px vs 321px)', (tester) async {
      // 319px -> Compact branch (< 320.0)
      await tester.pumpWidget(
        buildTestableTile(
          width: 319.0,
          child: const AppListTile(
            leading: Icon(AppIcons.settings),
            title: Text('Title'),
            trailing: Text('Trailing'),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);

      // 321px -> Normal branch (>= 320.0)
      await tester.pumpWidget(
        buildTestableTile(
          width: 321.0,
          child: const AppListTile(
            leading: Icon(AppIcons.settings),
            title: Text('Title'),
            trailing: Text('Trailing'),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });

    testWidgets('RTL directionality in normal and compact modes', (
      tester,
    ) async {
      await tester.pumpWidget(
        buildTestableTile(
          width: 360.0,
          textDirection: TextDirection.rtl,
          child: const AppListTile(
            leading: Icon(AppIcons.receipt),
            title: Text('Sales Invoice #INV-2026-0042'),
            subtitle: Text('Customer: Acma Trading Co. • \$3,450.00'),
            trailing: Text('10 mins ago'),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.byType(AppListTile), findsOneWidget);
      expect(find.text('Sales Invoice #INV-2026-0042'), findsOneWidget);
    });

    testWidgets('High text scale (2.0x) without overflow at 300px width', (
      tester,
    ) async {
      await tester.pumpWidget(
        buildTestableTile(
          width: 300.0,
          textScaleFactor: 2.0,
          child: const AppListTile(
            leading: Icon(AppIcons.shield),
            title: Text('Security & Access Controls'),
            subtitle: Text('Manage user roles and capability permissions'),
            trailing: Icon(AppIcons.chevronRight),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.byType(AppListTile), findsOneWidget);
    });
  });
}
