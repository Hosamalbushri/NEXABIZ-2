import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nexabiz_ui/nexabiz_ui.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shadcn;

void main() {
  Widget buildTestableWidget(Widget child, {Size size = const Size(800, 600), double textScaleFactor = 1.0}) {
    return MediaQuery(
      data: MediaQueryData(
        size: size,
        textScaler: TextScaler.linear(textScaleFactor),
      ),
      child: shadcn.ShadcnApp(
        home: shadcn.Scaffold(
          child: SizedBox(
            width: size.width,
            height: size.height,
            child: child,
          ),
        ),
      ),
    );
  }

  group('Guardrail 15 — Page Presentation States Contract Tests', () {
    testWidgets('AppListPage handles Loading presentation state', (WidgetTester tester) async {
      await tester.pumpWidget(
        buildTestableWidget(
          AppListPage<String>(
            title: 'Test List',
            isLoading: true,
            items: const [],
            contentBuilder: (context, items) => const SizedBox(),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 100));
      expect(find.byType(AppListPage<String>), findsOneWidget);
    });

    testWidgets('AppListPage handles Error presentation state', (WidgetTester tester) async {
      await tester.pumpWidget(
        buildTestableWidget(
          AppListPage<String>(
            title: 'Test List',
            errorText: 'Failed to load items',
            items: const [],
            contentBuilder: (context, items) => const SizedBox(),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byType(AppListPage<String>), findsOneWidget);
    });

    testWidgets('AppListPage handles Empty presentation state', (WidgetTester tester) async {
      await tester.pumpWidget(
        buildTestableWidget(
          AppListPage<String>(
            title: 'Test List',
            items: const [],
            emptyTitle: 'No items available',
            contentBuilder: (context, items) => const SizedBox(),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byType(AppListPage<String>), findsOneWidget);
    });

    testWidgets('AppListPage handles Loaded presentation state', (WidgetTester tester) async {
      await tester.pumpWidget(
        buildTestableWidget(
          AppListPage<String>(
            title: 'Test List',
            items: const ['Item 1', 'Item 2'],
            contentBuilder: (context, items) => Column(
              children: items.map((e) => Text(e)).toList(),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Item 1'), findsOneWidget);
      expect(find.text('Item 2'), findsOneWidget);
    });
  });

  group('Guardrail 16 — Responsive Viewport Contract Tests (360, 600, 800, 1200, 1440px)', () {
    final viewports = [
      const Size(360, 640),   // Compact Mobile
      const Size(600, 900),   // Mobile / Small Tablet
      const Size(800, 1024),  // Tablet Medium
      const Size(1200, 800),  // Desktop Expanded
      const Size(1440, 900),  // Wide Desktop
    ];

    for (final size in viewports) {
      testWidgets('AppPage renders without overflow on ${size.width}x${size.height}', (WidgetTester tester) async {
        await tester.pumpWidget(
          buildTestableWidget(
            const AppPage(
              header: Text('Responsive Title'),
              child: Column(
                children: [
                  Text('Content Row 1'),
                  Text('Content Row 2'),
                ],
              ),
            ),
            size: size,
          ),
        );
        await tester.pumpAndSettle();

        expect(tester.takeException(), isNull);
        expect(find.text('Responsive Title'), findsOneWidget);
      });

      testWidgets('AppFormPage renders without overflow on ${size.width}x${size.height}', (WidgetTester tester) async {
        await tester.pumpWidget(
          buildTestableWidget(
            AppFormPage(
              title: 'Form Title',
              body: const Column(
                children: [
                  Text('Form Field 1'),
                  Text('Form Field 2'),
                ],
              ),
              onSubmit: () {},
            ),
            size: size,
          ),
        );
        await tester.pumpAndSettle();

        expect(tester.takeException(), isNull);
        expect(find.text('Form Title'), findsOneWidget);
      });
    }
  });

  group('Guardrail 17 — Text Scaling Usability Contract Tests (1.0, 1.3, 1.5)', () {
    final textScales = [1.0, 1.3, 1.5];

    for (final scale in textScales) {
      testWidgets('AppButton remains usable at text scale $scale', (WidgetTester tester) async {
        await tester.pumpWidget(
          buildTestableWidget(
            AppButton(
              onPressed: () {},
              label: 'Scaled Action Button',
            ),
            textScaleFactor: scale,
          ),
        );
        await tester.pumpAndSettle();

        expect(tester.takeException(), isNull);
        expect(find.text('Scaled Action Button'), findsOneWidget);
      });

      testWidgets('AppCard remains usable at text scale $scale', (WidgetTester tester) async {
        await tester.pumpWidget(
          buildTestableWidget(
            const AppCard(
              child: Column(
                children: [
                  Text('Card Title'),
                  Text('Card Body Content'),
                ],
              ),
            ),
            textScaleFactor: scale,
          ),
        );
        await tester.pumpAndSettle();

        expect(tester.takeException(), isNull);
        expect(find.text('Card Title'), findsOneWidget);
      });
    }
  });
}
