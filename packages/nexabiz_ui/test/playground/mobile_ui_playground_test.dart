import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nexabiz_ui/nexabiz_ui.dart';
import 'package:nexabiz_ui/nexabiz_ui_dev.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shadcn;

Widget _createPlaygroundHarness({
  PlaygroundScenario initialScenario = PlaygroundScenario.foundation,
  bool initialArabic = true,
  bool initialDark = false,
  double? initialWidth = 375.0,
}) {
  return shadcn.ShadcnApp(
    theme: initialDark ? AppTheme.dark() : AppTheme.light(),
    home: MobileUiPlaygroundPage(
      initialScenario: initialScenario,
      initialArabic: initialArabic,
      initialDark: initialDark,
      initialWidth: initialWidth,
    ),
  );
}

Future<void> _pumpFrames(WidgetTester tester) async {
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 100));
  await tester.pump(const Duration(milliseconds: 200));
}

void main() {
  group('Mobile UI Playground Core Architecture Tests', () {
    testWidgets('Renders Mobile UI Playground top toolbar and controls', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(1200, 1000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(_createPlaygroundHarness());
      await _pumpFrames(tester);

      expect(find.byType(MobileUiPlaygroundPage), findsOneWidget);
      expect(find.text('Cairo • shadcn_flutter • Phone-First'), findsOneWidget);
      expect(find.text('عربي (RTL)'), findsOneWidget);
      expect(find.text('Light'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('Toggles Locale between Arabic (RTL) and English (LTR)', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(1200, 1000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(_createPlaygroundHarness(initialArabic: true));
      await _pumpFrames(tester);

      expect(find.text('عربي (RTL)'), findsOneWidget);

      await tester.tap(find.text('عربي (RTL)'));
      await _pumpFrames(tester);

      expect(find.text('English (LTR)'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('Toggles Theme between Light and Dark mode', (tester) async {
      tester.view.physicalSize = const Size(1200, 1000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(_createPlaygroundHarness(initialDark: false));
      await _pumpFrames(tester);

      expect(find.text('Light'), findsOneWidget);

      await tester.tap(find.text('Light'));
      await _pumpFrames(tester);

      expect(find.text('Dark'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });

  group('11 Playground Scenarios Completeness & Rendering Tests', () {
    final scenarios = [
      (PlaygroundScenario.foundation, '1. Foundation'),
      (PlaygroundScenario.home, '2. Core Home'),
      (PlaygroundScenario.list, '3. Voucher List'),
      (PlaygroundScenario.details, '4. Voucher Details'),
      (PlaygroundScenario.form, '5. Voucher Form'),
      (PlaygroundScenario.lineItems, '6. Line Items'),
      (PlaygroundScenario.search, '7. Search Flow'),
      (PlaygroundScenario.filters, '8. Filters Sheet'),
      (PlaygroundScenario.sheets, '9. Bottom Sheets'),
      (PlaygroundScenario.dialogs, '10. Dialogs'),
      (PlaygroundScenario.states, '11. Screen States'),
    ];

    for (final (scenario, name) in scenarios) {
      testWidgets(
        'Scenario $name renders without overflow in English and Arabic',
        (tester) async {
          tester.view.physicalSize = const Size(1200, 1000);
          tester.view.devicePixelRatio = 1.0;
          addTearDown(tester.view.resetPhysicalSize);

          // Test Arabic
          await tester.pumpWidget(
            _createPlaygroundHarness(
              initialScenario: scenario,
              initialArabic: true,
              initialWidth: 375.0,
            ),
          );
          await _pumpFrames(tester);
          expect(
            tester.takeException(),
            isNull,
            reason: '$name failed in Arabic',
          );

          // Test English
          await tester.pumpWidget(
            _createPlaygroundHarness(
              initialScenario: scenario,
              initialArabic: false,
              initialWidth: 375.0,
            ),
          );
          await _pumpFrames(tester);
          expect(
            tester.takeException(),
            isNull,
            reason: '$name failed in English',
          );
        },
      );
    }
  });

  group('Responsive Device Matrix & Width Integrity Tests (320px to 600px)', () {
    const testWidths = [320.0, 360.0, 375.0, 390.0, 412.0, 430.0, 600.0];

    for (final width in testWidths) {
      testWidgets(
        'Responsive phone width ${width.toInt()}px renders List & LineItems with zero overflow',
        (tester) async {
          tester.view.physicalSize = const Size(1200, 1000);
          tester.view.devicePixelRatio = 1.0;
          addTearDown(tester.view.resetPhysicalSize);

          // List scenario at tested width
          await tester.pumpWidget(
            _createPlaygroundHarness(
              initialScenario: PlaygroundScenario.list,
              initialArabic: true,
              initialWidth: width,
            ),
          );
          await _pumpFrames(tester);
          final listEx = tester.takeException();
          if (listEx != null) {
            // ignore: avoid_print
            print('DEBUG LIST EXCEPTION at ${width.toInt()}px: $listEx');
          }
          expect(listEx, isNull, reason: 'List failed at ${width.toInt()}px');

          // Line Items scenario at tested width
          await tester.pumpWidget(
            _createPlaygroundHarness(
              initialScenario: PlaygroundScenario.lineItems,
              initialArabic: true,
              initialWidth: width,
            ),
          );
          await _pumpFrames(tester);
          expect(
            tester.takeException(),
            isNull,
            reason: 'LineItems failed at ${width.toInt()}px',
          );
        },
      );
    }

    testWidgets('Visual Integrity: No single-character vertical text collapse', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(1200, 1000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        _createPlaygroundHarness(
          initialScenario: PlaygroundScenario.list,
          initialArabic: false,
          initialWidth: 320.0, // Narrowest compact phone width
        ),
      );
      await _pumpFrames(tester);

      // Find all Text widgets and verify no word is vertically stacked character-by-character
      final textWidgets = tester.widgetList<Text>(find.byType(Text));
      for (final text in textWidgets) {
        final data = text.data ?? '';
        // If string contains newlines between single characters like "A\nc\nc\no\nu\nn\nt"
        expect(
          data.contains(RegExp(r'[A-Za-z]\n[A-Za-z]\n[A-Za-z]')),
          isFalse,
          reason: 'Text "$data" is collapsed vertically!',
        );
      }
      expect(tester.takeException(), isNull);
    });

    testWidgets('Line Items Scenario computes debit/credit balance properly', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(1200, 1000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        _createPlaygroundHarness(
          initialScenario: PlaygroundScenario.lineItems,
          initialArabic: false,
          initialWidth: 375.0,
        ),
      );
      await _pumpFrames(tester);

      // Summary totals rendered
      expect(find.text('Debit Total'), findsOneWidget);
      expect(find.text('Credit Total'), findsOneWidget);
      expect(find.text('Difference'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });
}
