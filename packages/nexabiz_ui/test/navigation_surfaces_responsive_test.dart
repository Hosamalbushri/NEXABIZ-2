import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nexabiz_ui/nexabiz_ui.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shadcn;

void main() {
  Widget harness(
    Widget child, {
    TextDirection direction = TextDirection.ltr,
    double textScale = 1,
  }) {
    return shadcn.ShadcnApp(
      theme: AppTheme.light(),
      home: Directionality(
        textDirection: direction,
        child: MediaQuery(
          data: MediaQueryData(textScaler: TextScaler.linear(textScale)),
          child: child,
        ),
      ),
    );
  }

  group('canonical responsive navigation surfaces', () {
    for (final width in <double>[
      320,
      430,
      599,
      600,
      800,
      999,
      1000,
      1200,
      1439,
      1440,
      1920,
    ]) {
      testWidgets('selects one application navigation surface at $width', (
        tester,
      ) async {
        tester.view.physicalSize = Size(width, 900);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        await tester.pumpWidget(
          harness(
            const AppResponsiveScaffold(
              sidebar: Text('desktop-navigation'),
              topHeader: Text('global-header'),
              mobileBottomBar: Text('mobile-navigation'),
              body: Text('page-content'),
            ),
          ),
        );

        final desktop = width >= AppBreakpoints.expandedMin;
        expect(
          find.text('desktop-navigation'),
          desktop ? findsOneWidget : findsNothing,
        );
        expect(
          find.text('global-header'),
          desktop ? findsOneWidget : findsNothing,
        );
        expect(
          find.text('mobile-navigation'),
          desktop ? findsNothing : findsOneWidget,
        );
        expect(find.text('page-content'), findsOneWidget);
        expect(tester.takeException(), isNull);
      });
    }

    testWidgets('bottom navigation supports RTL, 200% text, and keyboard', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(430, 900);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      String? selected;

      await tester.pumpWidget(
        harness(
          AppCustomBottomNav(
            selectedId: 'home',
            items: const [
              AppNavigationItem(
                id: 'home',
                label: 'الرئيسية',
                icon: AppIcons.dashboard,
              ),
              AppNavigationItem(
                id: 'reports',
                label: 'التقارير',
                icon: AppIcons.chart,
              ),
            ],
            onSelected: (id) => selected = id,
            fabTooltip: 'إجراءات سريعة',
          ),
          direction: TextDirection.rtl,
          textScale: 2,
        ),
      );

      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pump();

      expect(selected, isNotNull);
      expect(tester.takeException(), isNull);
    });

    testWidgets('quick actions trigger supports keyboard activation', (
      tester,
    ) async {
      var activations = 0;
      await tester.pumpWidget(
        harness(
          Center(
            child: QuickActionsFab(
              tooltip: 'Quick actions',
              isOpen: false,
              onPressed: () => activations++,
            ),
          ),
        ),
      );

      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pump();

      expect(activations, 1);
      expect(tester.takeException(), isNull);
    });
  });
}
