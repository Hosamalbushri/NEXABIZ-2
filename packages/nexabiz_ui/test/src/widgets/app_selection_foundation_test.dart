import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nexabiz_ui/nexabiz_ui.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shadcn;

void main() {
  Widget buildHarness(
    Widget child, {
    TextDirection textDirection = TextDirection.ltr,
    double textScaleFactor = 1.0,
  }) {
    return Directionality(
      textDirection: textDirection,
      child: MediaQuery(
        data: MediaQueryData(textScaler: TextScaler.linear(textScaleFactor)),
        child: shadcn.ShadcnApp(
          home: shadcn.Scaffold(
            child: Padding(padding: const EdgeInsets.all(16.0), child: child),
          ),
        ),
      ),
    );
  }

  group('Phase 05 Selection Architecture Behavior Tests', () {
    testWidgets('AppSelectField: single selection and callback', (
      tester,
    ) async {
      String? selectedValue;

      await tester.pumpWidget(
        buildHarness(
          AppSelectField<String>(
            label: 'Currency',
            value: null,
            items: const [
              AppSelectOption(value: 'SAR', label: 'Saudi Riyal'),
              AppSelectOption(value: 'USD', label: 'US Dollar'),
            ],
            onChanged: (val) => selectedValue = val,
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Trigger button should display default or hint
      expect(find.text('Select option...'), findsOneWidget);

      // Tap trigger to open popup
      await tester.tap(find.text('Select option...'));
      await tester.pumpAndSettle();

      expect(find.text('Saudi Riyal'), findsOneWidget);
      expect(find.text('US Dollar'), findsOneWidget);

      // Select US Dollar
      await tester.tap(find.text('US Dollar'));
      await tester.pumpAndSettle();

      expect(selectedValue, equals('USD'));
    });

    testWidgets(
      'AppSelectField: canonical field supports an initial selection',
      (tester) async {
        String? selected;

        await tester.pumpWidget(
          buildHarness(
            AppSelectField<String>(
              label: 'Currency',
              value: 'SAR',
              items: const [
                AppSelectOption(value: 'SAR', label: 'Saudi Riyal'),
                AppSelectOption(value: 'EUR', label: 'Euro'),
              ],
              onChanged: (val) => selected = val,
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('Saudi Riyal'), findsOneWidget);
        expect(find.text('Currency'), findsOneWidget);

        await tester.tap(find.text('Saudi Riyal'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Euro'));
        await tester.pumpAndSettle();

        expect(selected, equals('EUR'));
      },
    );

    testWidgets(
      'AppSelectField: error state renders message and does not crash',
      (tester) async {
        await tester.pumpWidget(
          buildHarness(
            AppSelectField<String>(
              label: 'Account',
              errorText: 'Selection is required',
              items: const [AppSelectOption(value: '1', label: 'Account 1')],
              onChanged: (_) {},
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('Selection is required'), findsOneWidget);
      },
    );

    testWidgets('AppSearchableSelect: search filtering and no results state', (
      tester,
    ) async {
      String? selected;

      await tester.pumpWidget(
        buildHarness(
          AppSearchableSelect<String>(
            label: 'Country Search',
            items: const ['Saudi Arabia', 'United States', 'United Kingdom'],
            itemBuilder: (context, item) => Text(item),
            onChanged: (val) => selected = val,
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Open popup
      await tester.tap(find.text('Select...'));
      await tester.pumpAndSettle();

      expect(find.text('Saudi Arabia'), findsOneWidget);
      expect(find.text('United States'), findsOneWidget);

      // Enter search query
      await tester.enterText(find.byType(shadcn.TextField), 'Arabia');
      await tester.pumpAndSettle();

      expect(find.text('Saudi Arabia'), findsOneWidget);
      expect(find.text('United States'), findsNothing);

      // Select filtered item
      await tester.tap(find.text('Saudi Arabia'));
      await tester.pumpAndSettle();

      expect(selected, equals('Saudi Arabia'));
    });

    testWidgets(
      'AppMultiSelectField: multi-select selection and order preservation',
      (tester) async {
        Iterable<String>? selected;

        await tester.pumpWidget(
          buildHarness(
            AppMultiSelectField<String>(
              label: 'Tags',
              items: const ['Alpha', 'Beta', 'Gamma'],
              itemLabelBuilder: (item) => item,
              value: const ['Alpha'],
              onChanged: (val) => selected = val,
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('Tags'), findsOneWidget);
        expect(find.text('Alpha'), findsOneWidget);
        expect(selected, isNull);
      },
    );

    testWidgets(
      'AppAsyncAutocompleteField: race condition protection (stale query rejection)',
      (tester) async {
        final completerA = Completer<List<String>>();
        final completerB = Completer<List<String>>();

        int callCount = 0;

        await tester.pumpWidget(
          buildHarness(
            AppAsyncAutocompleteField<String>(
              label: 'Async Autocomplete',
              debounceDuration: Duration.zero,
              fetchOptions: (query) {
                callCount++;
                if (query == 'first') {
                  return completerA.future;
                } else {
                  return completerB.future;
                }
              },
              itemBuilder: (context, item) => Text(item),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Initiate Query 1 ('first')
        await tester.enterText(find.byType(shadcn.TextField), 'first');
        await tester.pump();
        expect(callCount, equals(1));

        // Quickly initiate Query 2 ('second') before Query 1 completes
        await tester.enterText(find.byType(shadcn.TextField), 'second');
        await tester.pump();
        expect(callCount, equals(2));

        // Query 2 completes first
        completerB.complete(['Result Second']);
        await tester.pumpAndSettle();

        expect(find.text('Result Second'), findsOneWidget);

        // Query 1 completes late (stale result)
        completerA.complete(['Result First (Stale)']);
        await tester.pumpAndSettle();

        // Query 1's results MUST be rejected and Result Second must remain
        expect(find.text('Result First (Stale)'), findsNothing);
        expect(find.text('Result Second'), findsOneWidget);
      },
    );

    testWidgets('AppSelectField: RTL layout and text scaling 200%', (
      tester,
    ) async {
      await tester.pumpWidget(
        buildHarness(
          AppSelectField<String>(
            label: 'العملة المختارة',
            hint: 'اختر العملة...',
            items: const [
              AppSelectOption(
                value: 'SAR',
                label: 'ريال سعودي مع اسم طويل جداً لتجربة تجاوز النص',
                subtitle: 'عملة المملكة العربية السعودية الرسمية',
              ),
            ],
            onChanged: (_) {},
          ),
          textDirection: TextDirection.rtl,
          textScaleFactor: 2.0,
        ),
      );
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.text('العملة المختارة'), findsOneWidget);
    });
  });
}
