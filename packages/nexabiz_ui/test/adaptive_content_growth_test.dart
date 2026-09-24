import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nexabiz_ui/nexabiz_ui.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shadcn;

void main() {
  Widget testApp({required Widget child, double textScale = 1}) {
    return shadcn.ShadcnApp(
      theme: AppTheme.light(),
      home: MediaQuery(
        data: MediaQueryData(textScaler: TextScaler.linear(textScale)),
        child: Scaffold(body: Center(child: child)),
      ),
    );
  }

  testWidgets('button keeps a minimum control height and grows for content', (
    tester,
  ) async {
    await tester.pumpWidget(
      testApp(
        textScale: 2,
        child: SizedBox(
          width: 180,
          child: AppButton(
            label: 'A long primary action that remains readable',
            onPressed: () {},
          ),
        ),
      ),
    );

    expect(
      tester.getSize(find.byType(AppButton)).height,
      greaterThan(AppDimensions.desktopButtonHeight),
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('bottom actions stack from their 420px parent on a wide window', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1920, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      testApp(
        child: const SizedBox(
          width: 420,
          child: AppBottomActions(
            primaryAction: SizedBox(key: ValueKey('primary'), height: 48),
            secondaryAction: SizedBox(key: ValueKey('secondary'), height: 48),
          ),
        ),
      ),
    );

    final primary = tester.getTopLeft(find.byKey(const ValueKey('primary')));
    final secondary = tester.getTopLeft(
      find.byKey(const ValueKey('secondary')),
    );
    expect(primary.dy, lessThan(secondary.dy));
    expect(tester.takeException(), isNull);
  });

  testWidgets('section header stacks local actions and grows long text', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1600, 2000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      testApp(
        textScale: 2,
        child: SizedBox(
          width: 420,
          child: AppSection(
            title: 'A long section heading that must remain fully readable',
            description:
                'A long description grows naturally rather than being clipped.',
            actions: [
              AppButton(label: 'Long section action', onPressed: () {}),
            ],
            child: const Text('Section content'),
          ),
        ),
      ),
    );

    expect(find.text('Section content'), findsOneWidget);
    expect(find.text('Long section action'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('editable table sizes horizontal content from its local parent', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1920, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      testApp(
        child: SizedBox(
          width: 420,
          child: AppEditableTableShell<int>(
            items: const [1],
            columns: const [
              AppEditableTableColumn<int>(label: 'A', width: 200),
              AppEditableTableColumn<int>(label: 'B', width: 200),
            ],
            rowCellBuilder: (context, index, item, column) => Text('$item'),
          ),
        ),
      ),
    );

    final horizontalScroll = find.byWidgetPredicate(
      (widget) =>
          widget is SingleChildScrollView &&
          widget.scrollDirection == Axis.horizontal,
    );
    expect(horizontalScroll, findsOneWidget);
    final sizedBoxes = tester.widgetList<SizedBox>(
      find.descendant(of: horizontalScroll, matching: find.byType(SizedBox)),
    );
    expect(
      sizedBoxes.any(
        (box) => box.width != null && box.width! > 420 && box.width! < 1000,
      ),
      isTrue,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'search toolbar recomposes from local width at 200 percent text',
    (tester) async {
      tester.view.physicalSize = const Size(1600, 1000);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        testApp(
          textScale: 2,
          child: SizedBox(
            width: 320,
            child: AppSearchToolbar(
              filterCount: 3,
              onFilterTap: () {},
              actions: [
                AppButton(
                  label: 'A secondary toolbar action',
                  onPressed: () {},
                ),
              ],
            ),
          ),
        ),
      );

      expect(find.text('Active filters: 3'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );
}
