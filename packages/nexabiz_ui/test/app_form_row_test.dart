import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nexabiz_ui/nexabiz_ui.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shadcn;

void main() {
  Widget testApp({
    required Widget child,
    double textScale = 1,
    TextDirection direction = TextDirection.ltr,
  }) {
    return shadcn.ShadcnApp(
      theme: AppTheme.light(),
      home: MediaQuery(
        data: MediaQueryData(textScaler: TextScaler.linear(textScale)),
        child: Directionality(
          textDirection: direction,
          child: Scaffold(body: Center(child: child)),
        ),
      ),
    );
  }

  List<Widget> fields(int count) => [
    for (var index = 0; index < count; index++)
      SizedBox(
        key: ValueKey('field-$index'),
        height: 48,
        child: Text('Field $index'),
      ),
  ];

  int columnCount(WidgetTester tester, int count) {
    return {
      for (var index = 0; index < count; index++)
        tester.getTopLeft(find.byKey(ValueKey('field-$index'))).dx.round(),
    }.length;
  }

  testWidgets(
    'uses the complete required width matrix from local constraints',
    (tester) async {
      final expectedColumns = <double, int>{
        280: 1,
        320: 1,
        360: 1,
        430: 1,
        599: 2,
        600: 2,
        720: 2,
        800: 2,
        999: 3,
        1000: 3,
        1200: 3,
        1439: 3,
        1440: 3,
        1920: 3,
        2560: 3,
      };

      tester.view.physicalSize = const Size(2800, 1200);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      for (final entry in expectedColumns.entries) {
        await tester.pumpWidget(
          testApp(
            child: SizedBox(
              width: entry.key,
              child: AppFormRow(children: fields(5)),
            ),
          ),
        );
        expect(columnCount(tester, 5), entry.value, reason: '${entry.key}px');
        expect(tester.takeException(), isNull, reason: '${entry.key}px');
      }
    },
  );

  testWidgets('composes one, two, three, and five fields automatically', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1200, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    for (final count in <int>[1, 2, 3, 5]) {
      await tester.pumpWidget(
        testApp(
          child: SizedBox(
            width: 1000,
            child: AppFormRow(children: fields(count)),
          ),
        ),
      );
      expect(find.text('Field 0'), findsOneWidget);
      expect(columnCount(tester, count), count.clamp(1, 3));
      expect(tester.takeException(), isNull);
    }
  });

  testWidgets('keeps semantic full-width fields on their own row', (
    tester,
  ) async {
    await tester.pumpWidget(
      testApp(
        child: SizedBox(
          width: 720,
          child: AppFormRow(
            fullWidthChildren: const [
              SizedBox(
                key: ValueKey('full-field'),
                height: 48,
                child: Text('Full field'),
              ),
            ],
            children: fields(3),
          ),
        ),
      ),
    );

    expect(tester.getSize(find.byKey(const ValueKey('full-field'))).width, 720);
    expect(
      tester.getTopLeft(find.byKey(const ValueKey('full-field'))).dy,
      greaterThan(tester.getTopLeft(find.byKey(const ValueKey('field-0'))).dy),
    );
  });

  testWidgets(
    'uses 420px and deeply nested 472px local widths on large windows',
    (tester) async {
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      for (final localWidth in <double>[420, 472]) {
        await tester.pumpWidget(
          testApp(
            child: SizedBox(
              width: 520,
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: (520 - localWidth) / 2,
                ),
                child: AppFormRow(children: fields(3)),
              ),
            ),
          ),
        );
        expect(columnCount(tester, 3), 1, reason: '$localWidth local pixels');
      }
    },
  );

  testWidgets('long field content grows at 200 percent text scale', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(800, 1200);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      testApp(
        textScale: 2,
        child: const SizedBox(
          width: 720,
          child: AppFormRow(
            children: [
              AppTextField(
                key: ValueKey('long-field'),
                label:
                    'A deliberately long localized field label that must wrap',
                helperText:
                    'Long helper content remains readable and grows naturally.',
                errorText:
                    'Long validation feedback remains visible without clipping.',
              ),
              AppTextField(label: 'Second field'),
            ],
          ),
        ),
      ),
    );

    expect(
      tester.getSize(find.byKey(const ValueKey('long-field'))).height,
      greaterThan(AppDimensions.inputHeight),
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'preserves RTL ordering without changing the local column policy',
    (tester) async {
      await tester.pumpWidget(
        testApp(
          direction: TextDirection.rtl,
          child: SizedBox(width: 600, child: AppFormRow(children: fields(2))),
        ),
      );

      final first = tester.getTopLeft(find.byKey(const ValueKey('field-0'))).dx;
      final second = tester
          .getTopLeft(find.byKey(const ValueKey('field-1')))
          .dx;
      expect(first, greaterThan(second));
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('works inside an unbounded vertical scroll view', (tester) async {
    await tester.pumpWidget(
      testApp(
        child: SingleChildScrollView(
          child: SizedBox(width: 600, child: AppFormRow(children: fields(5))),
        ),
      ),
    );

    expect(find.text('Field 4'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('AppFormPage keeps content max width on a 2560px viewport', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(2560, 1200);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      testApp(
        child: const AppFormPage(
          title: 'Form',
          showFormActions: false,
          body: SizedBox(
            key: ValueKey('form-body'),
            width: double.infinity,
            height: 48,
          ),
        ),
      ),
    );

    expect(
      tester.getSize(find.byKey(const ValueKey('form-body'))).width,
      lessThanOrEqualTo(AppLayoutTokens.maxFormWidth),
    );
    expect(tester.takeException(), isNull);
  });
}
