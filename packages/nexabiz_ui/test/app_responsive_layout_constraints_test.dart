import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nexabiz_ui/nexabiz_ui.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shadcn;

void main() {
  Widget buildTestableWidget(
    Widget child, {
    TextDirection textDirection = TextDirection.ltr,
  }) {
    return shadcn.ShadcnApp(
      theme: AppTheme.light(),
      home: Directionality(
        textDirection: textDirection,
        child: Material(child: child),
      ),
    );
  }

  group('Responsive Layout Constraints & AppListTile Hardening Tests', () {
    final screenWidths = [
      320.0,
      360.0,
      375.0,
      390.0,
      414.0,
      430.0,
      600.0,
      768.0,
      1024.0,
      1440.0,
    ];

    for (final width in screenWidths) {
      testWidgets(
        'AppListTile renders accounting identifier without overflow at width $width px',
        (WidgetTester tester) async {
          tester.view.physicalSize = Size(width, 800);
          tester.view.devicePixelRatio = 1.0;

          await tester.pumpWidget(
            buildTestableWidget(
              SizedBox(
                width: width,
                child: const AppSection(
                  title: 'Recent Activity',
                  child: AppListTile(
                    leading: Icon(AppIcons.receipt),
                    title: Text('Sales Invoice #INV-2026-0042'),
                    subtitle: Text('Customer: Acma Trading Co. • \$3,450.00'),
                    trailing: Text('10 mins ago'),
                  ),
                ),
              ),
            ),
          );

          expect(find.text('Sales Invoice #INV-2026-0042'), findsOneWidget);
          expect(
            find.text('Customer: Acma Trading Co. • \$3,450.00'),
            findsOneWidget,
          );
          expect(find.text('10 mins ago'), findsOneWidget);
          expect(tester.takeException(), isNull);

          tester.view.resetPhysicalSize();
          tester.view.resetDevicePixelRatio();
        },
      );
    }

    testWidgets(
      'AppListTile adapts trailing position under constrained 320px width',
      (WidgetTester tester) async {
        tester.view.physicalSize = const Size(320, 800);
        tester.view.devicePixelRatio = 1.0;

        await tester.pumpWidget(
          buildTestableWidget(
            const SizedBox(
              width: 320,
              child: AppListTile(
                leading: Icon(AppIcons.receipt),
                title: Text('Invoice #INV-2026-0042'),
                subtitle: Text('Acma Trading Co.'),
                trailing: Text('10 mins ago'),
              ),
            ),
          ),
        );

        expect(find.text('Invoice #INV-2026-0042'), findsOneWidget);
        expect(find.text('10 mins ago'), findsOneWidget);
        expect(tester.takeException(), isNull);

        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      },
    );

    testWidgets(
      'AppListTile handles RTL directionality with mixed Arabic/English content',
      (WidgetTester tester) async {
        tester.view.physicalSize = const Size(360, 800);
        tester.view.devicePixelRatio = 1.0;

        await tester.pumpWidget(
          buildTestableWidget(
            textDirection: TextDirection.rtl,
            const SizedBox(
              width: 360,
              child: AppListTile(
                leading: Icon(AppIcons.receipt),
                title: Text('فاتورة مبيعات #INV-2026-0042'),
                subtitle: Text('العميل: شركة أكما للتجارة • \$3,450.00'),
                trailing: Text('منذ 10 دقائق'),
              ),
            ),
          ),
        );

        expect(find.text('فاتورة مبيعات #INV-2026-0042'), findsOneWidget);
        expect(
          find.text('العميل: شركة أكما للتجارة • \$3,450.00'),
          findsOneWidget,
        );
        expect(find.text('منذ 10 دقائق'), findsOneWidget);
        expect(tester.takeException(), isNull);

        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      },
    );

    testWidgets('AppModuleHubGrid adapts to 1 column on narrow width 320px', (
      WidgetTester tester,
    ) async {
      tester.view.physicalSize = const Size(320, 800);
      tester.view.devicePixelRatio = 1.0;

      await tester.pumpWidget(
        buildTestableWidget(
          SizedBox(
            width: 320,
            child: AppModuleHubGrid(
              children: [
                AppModuleHubTile(
                  title: 'Component Gallery',
                  subtitle: 'Interactive shadcn_flutter playground',
                  icon: AppIcons.grid,
                  animate: false,
                  onTap: () {},
                ),
                AppModuleHubTile(
                  title: 'General Ledger',
                  subtitle: 'Journal entries & COA',
                  icon: AppIcons.bank,
                  animate: false,
                  onTap: () {},
                ),
              ],
            ),
          ),
        ),
      );

      expect(find.text('Component Gallery'), findsOneWidget);
      expect(find.text('General Ledger'), findsOneWidget);
      expect(tester.takeException(), isNull);

      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });
  });
}
