import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nexabiz_ui/nexabiz_ui.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shadcn;

void main() {
  Widget buildTestApp(Widget child) {
    return shadcn.ShadcnApp(
      theme: AppTheme.light(),
      home: Scaffold(body: child),
    );
  }

  group('Phase 06: Nested Responsive & Available Width Tests', () {
    testWidgets(
      'MANDATORY: 420px container inside 1600px window evaluates as compact tier',
      (WidgetTester tester) async {
        // Configure large desktop physical viewport (1600 x 900)
        tester.view.physicalSize = const Size(1600, 900);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        AppBreakpointTier? evaluatedTier;
        String? evaluatedValue;
        double? evaluatedWidth;

        await tester.pumpWidget(
          buildTestApp(
            Center(
              child: SizedBox(
                width: 420,
                child: AppResponsive.builder(
                  builder: (context, tier, constraints) {
                    evaluatedTier = tier;
                    evaluatedWidth = AppResponsive.of(context).availableWidth;
                    evaluatedValue = AppResponsive.value<String>(
                      context,
                      compact: 'COMPACT_LAYOUT',
                      medium: 'MEDIUM_LAYOUT',
                      expanded: 'EXPANDED_LAYOUT',
                      wide: 'WIDE_LAYOUT',
                    );

                    final bpTier = AppBreakpoints.of(context);
                    expect(bpTier, AppBreakpointTier.compact);

                    return Text(evaluatedValue!);
                  },
                ),
              ),
            ),
          ),
        );

        expect(evaluatedTier, equals(AppBreakpointTier.compact));
        expect(evaluatedWidth, equals(420.0));
        expect(evaluatedValue, equals('COMPACT_LAYOUT'));
        expect(find.text('COMPACT_LAYOUT'), findsOneWidget);
      },
    );

    testWidgets(
      'Nested container tier evaluation across medium, expanded, and wide inside 1600px window',
      (WidgetTester tester) async {
        tester.view.physicalSize = const Size(1600, 900);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        // 800px container -> Medium tier (600 - 999)
        AppBreakpointTier? mediumTier;
        await tester.pumpWidget(
          buildTestApp(
            Center(
              child: SizedBox(
                width: 800,
                child: AppResponsive.builder(
                  builder: (context, tier, constraints) {
                    mediumTier = tier;
                    return Text(tier.name);
                  },
                ),
              ),
            ),
          ),
        );
        expect(mediumTier, equals(AppBreakpointTier.medium));

        // 1100px container -> Expanded tier (1000 - 1439)
        AppBreakpointTier? expandedTier;
        await tester.pumpWidget(
          buildTestApp(
            Center(
              child: SizedBox(
                width: 1100,
                child: AppResponsive.builder(
                  builder: (context, tier, constraints) {
                    expandedTier = tier;
                    return Text(tier.name);
                  },
                ),
              ),
            ),
          ),
        );
        expect(expandedTier, equals(AppBreakpointTier.expanded));

        // 1500px container -> Wide tier (>= 1440)
        AppBreakpointTier? wideTier;
        await tester.pumpWidget(
          buildTestApp(
            Center(
              child: SizedBox(
                width: 1500,
                child: AppResponsive.builder(
                  builder: (context, tier, constraints) {
                    wideTier = tier;
                    return Text(tier.name);
                  },
                ),
              ),
            ),
          ),
        );
        expect(wideTier, equals(AppBreakpointTier.wide));
      },
    );

    testWidgets(
      'AppResponsiveLayout declarative switching responds to local container width',
      (WidgetTester tester) async {
        tester.view.physicalSize = const Size(1600, 900);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        await tester.pumpWidget(
          buildTestApp(
            const Center(
              child: SizedBox(
                width: 450,
                child: AppResponsiveLayout(
                  compact: Text('Local Compact'),
                  medium: Text('Local Medium'),
                  expanded: Text('Local Expanded'),
                  wide: Text('Local Wide'),
                ),
              ),
            ),
          ),
        );

        expect(find.text('Local Compact'), findsOneWidget);
        expect(find.text('Local Wide'), findsNothing);
      },
    );
  });

  group('Phase 06: AppGrid Fluid & Safe Layout Tests', () {
    testWidgets(
      'AppGrid calculates columns dynamically when minItemWidth is provided',
      (WidgetTester tester) async {
        // Container width 600px with minItemWidth = 200, spacing = 16:
        // (600 + 16) / (200 + 16) = 616 / 216 = 2 columns
        await tester.pumpWidget(
          buildTestApp(
            SizedBox(
              width: 600,
              child: AppGrid(
                minItemWidth: 200,
                spacing: 16,
                runSpacing: 16,
                children: const [
                  Text('Grid Item 1'),
                  Text('Grid Item 2'),
                  Text('Grid Item 3'),
                  Text('Grid Item 4'),
                ],
              ),
            ),
          ),
        );

        expect(find.text('Grid Item 1'), findsOneWidget);
        expect(find.text('Grid Item 4'), findsOneWidget);

        // Find sized boxes wrapping the items
        final sizedBoxes = tester
            .widgetList<SizedBox>(
              find.descendant(
                of: find.byType(Wrap),
                matching: find.byType(SizedBox),
              ),
            )
            .toList();

        // 2 columns: itemWidth = (600 - 16 * 1) / 2 = 584 / 2 = 292.0
        expect(sizedBoxes.first.width, equals(292.0));
      },
    );

    testWidgets('AppGrid respects maxColumns limit', (
      WidgetTester tester,
    ) async {
      tester.view.physicalSize = const Size(1400, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      // 1200px width with minItemWidth = 100 would allow 10+ columns,
      // but maxColumns = 3 caps it.
      await tester.pumpWidget(
        buildTestApp(
          SizedBox(
            width: 1200,
            child: AppGrid(
              minItemWidth: 100,
              maxColumns: 3,
              spacing: 16,
              children: const [Text('Item 1'), Text('Item 2'), Text('Item 3')],
            ),
          ),
        ),
      );

      final sizedBoxes = tester
          .widgetList<SizedBox>(
            find.descendant(
              of: find.byType(Wrap),
              matching: find.byType(SizedBox),
            ),
          )
          .toList();

      // 3 columns: (1200 - 16 * 2) / 3 = 1168 / 3 = 389.3333333333333
      expect(sizedBoxes.first.width, closeTo(389.33, 0.01));
    });

    testWidgets('AppGrid handles empty children gracefully without error', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(buildTestApp(const AppGrid(children: [])));
      expect(tester.takeException(), isNull);
      expect(find.byType(SizedBox), findsOneWidget);
    });

    testWidgets('AppGrid handles zero width safely without division by zero', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        buildTestApp(
          const SizedBox(
            width: 0,
            child: AppGrid(
              minItemWidth: 200,
              children: [Text('Zero Item 1'), Text('Zero Item 2')],
            ),
          ),
        ),
      );
      expect(tester.takeException(), isNull);
    });

    testWidgets(
      'AppGrid safely renders under unbounded horizontal constraints',
      (WidgetTester tester) async {
        await tester.pumpWidget(
          buildTestApp(
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: AppGrid(
                minItemWidth: 250,
                children: const [Text('Scroll 1'), Text('Scroll 2')],
              ),
            ),
          ),
        );
        expect(tester.takeException(), isNull);
        expect(find.text('Scroll 1'), findsOneWidget);
      },
    );
  });

  group('Phase 06: Form & Content Container Available Width Tests', () {
    testWidgets(
      'AppFormPage stacks secondary body when placed in narrow container (< 640px) on wide screen',
      (WidgetTester tester) async {
        tester.view.physicalSize = const Size(1920, 1080);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        // Constrain AppFormPage to 500px width (e.g. side drawer or dialog)
        await tester.pumpWidget(
          buildTestApp(
            Center(
              child: SizedBox(
                width: 500,
                child: AppFormPage(
                  title: 'Drawer Form',
                  body: const Text('Primary Form Body'),
                  secondaryBody: const Text('Secondary Side Panel'),
                  onSubmit: () {},
                ),
              ),
            ),
          ),
        );

        // Under 500px local width, it must NOT use Row side-by-side; it must stack
        expect(find.text('Primary Form Body'), findsOneWidget);
        expect(find.text('Secondary Side Panel'), findsOneWidget);
        expect(
          find.descendant(of: find.byType(Form), matching: find.byType(Row)),
          findsNothing,
        );
        expect(tester.takeException(), isNull);
      },
    );

    testWidgets(
      'AppFormPage renders secondary body in Row when width is >= 640px',
      (WidgetTester tester) async {
        tester.view.physicalSize = const Size(1920, 1080);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        await tester.pumpWidget(
          buildTestApp(
            Center(
              child: SizedBox(
                width: 900,
                child: AppFormPage(
                  title: 'Wide Form',
                  body: const Text('Primary Form Body'),
                  secondaryBody: const Text('Secondary Side Panel'),
                  onSubmit: () {},
                ),
              ),
            ),
          ),
        );

        expect(find.text('Primary Form Body'), findsOneWidget);
        expect(find.text('Secondary Side Panel'), findsOneWidget);
        // Uses Row side-by-side inside Form
        expect(
          find.descendant(of: find.byType(Form), matching: find.byType(Row)),
          findsOneWidget,
        );
        expect(tester.takeException(), isNull);
      },
    );

    testWidgets('AppContent adapts padding based on local container width', (
      WidgetTester tester,
    ) async {
      tester.view.physicalSize = const Size(1600, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      // Narrow 400px container should apply compact padding (16px)
      await tester.pumpWidget(
        buildTestApp(
          const Center(
            child: SizedBox(
              width: 400,
              child: AppContent(child: Text('Content Child')),
            ),
          ),
        ),
      );

      final paddingWidget = tester.widget<Padding>(
        find.ancestor(
          of: find.text('Content Child'),
          matching: find.byType(Padding),
        ),
      );

      expect(
        paddingWidget.padding,
        equals(AppLayoutTokens.pagePaddingDirectionalCompact),
      );
    });
  });
}
