import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nexabiz_ui/nexabiz_ui.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shadcn;

void main() {
  testWidgets('underline tabs remain reachable in compact RTL at 2x text', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(400, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    var selectedIndex = 0;

    await tester.pumpWidget(
      MediaQuery(
        data: const MediaQueryData(textScaler: TextScaler.linear(2)),
        child: shadcn.ShadcnApp(
          theme: AppTheme.light(),
          home: Directionality(
            textDirection: TextDirection.rtl,
            child: SizedBox(
              width: 400,
              height: 800,
              child: AppTabs(
                index: selectedIndex,
                onChanged: (index) => selectedIndex = index,
                style: AppTabStyle.underline,
                items: const [
                  AppTabItem(label: 'نظرة عامة', child: SizedBox()),
                  AppTabItem(label: 'الصلاحيات', child: SizedBox()),
                  AppTabItem(label: 'الأعضاء المعينون', child: SizedBox()),
                ],
              ),
            ),
          ),
        ),
      ),
    );

    final horizontalScrollView = find.byWidgetPredicate(
      (widget) =>
          widget is SingleChildScrollView &&
          widget.scrollDirection == Axis.horizontal,
    );
    expect(horizontalScrollView, findsOneWidget);
    final horizontalScroll = find.descendant(
      of: horizontalScrollView,
      matching: find.byType(Scrollable),
    );
    expect(horizontalScroll, findsOneWidget);

    await tester.scrollUntilVisible(
      find.text('الأعضاء المعينون'),
      100,
      scrollable: horizontalScroll,
    );
    await tester.tap(find.text('الأعضاء المعينون'));
    await tester.pump();

    expect(selectedIndex, 2);
    expect(tester.takeException(), isNull);
  });
}
