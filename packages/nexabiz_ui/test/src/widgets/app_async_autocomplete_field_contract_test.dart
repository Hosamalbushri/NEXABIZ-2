import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nexabiz_ui/nexabiz_ui.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shadcn;

void main() {
  Widget buildTestableWidget(Widget child) {
    return shadcn.ShadcnApp(
      home: shadcn.Scaffold(
        child: Padding(padding: const EdgeInsets.all(16.0), child: child),
      ),
    );
  }

  group('AppAsyncAutocompleteField Contract Tests', () {
    testWidgets('renders AppFieldShell with label and placeholder', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        buildTestableWidget(
          AppAsyncAutocompleteField<String>(
            label: 'Customer Search',
            hint: 'Type a customer name...',
            fetchOptions: (query) => ['Customer A', 'Customer B'],
            itemBuilder: (context, option) => Text(option),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(AppFieldShell), findsOneWidget);
      expect(find.text('Customer Search'), findsOneWidget);
      expect(find.text('Type a customer name...'), findsOneWidget);
    });

    testWidgets('triggers async search on query and selects item', (
      WidgetTester tester,
    ) async {
      String? selected;

      await tester.pumpWidget(
        buildTestableWidget(
          AppAsyncAutocompleteField<String>(
            label: 'Search Field',
            hint: 'Search...',
            debounceDuration: const Duration(milliseconds: 50),
            fetchOptions: (query) async {
              if (query == 'Alpha') return ['Alpha 1', 'Alpha 2'];
              return [];
            },
            onSelected: (val) => selected = val,
            itemBuilder: (context, option) => Text(option),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Enter query
      await tester.enterText(find.byType(shadcn.TextField), 'Alpha');
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pumpAndSettle();

      expect(find.text('Alpha 1'), findsOneWidget);
      expect(find.text('Alpha 2'), findsOneWidget);

      // Tap suggestion
      await tester.tap(find.text('Alpha 1'));
      await tester.pumpAndSettle();

      expect(selected, 'Alpha 1');
      // Suggestion overlay should close
      expect(find.text('Alpha 2'), findsNothing);
    });

    testWidgets('displays errorText and helperText via AppFieldShell', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        buildTestableWidget(
          AppAsyncAutocompleteField<String>(
            label: 'Search',
            errorText: 'Invalid search input',
            fetchOptions: (_) => [],
            itemBuilder: (_, opt) => Text(opt),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Invalid search input'), findsOneWidget);
    });
  });
}
