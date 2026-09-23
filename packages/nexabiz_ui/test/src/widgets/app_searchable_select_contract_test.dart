import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shadcn;
import 'package:nexabiz_ui/src/widgets/app_searchable_select.dart';

void main() {
  Widget buildTestableWidget(Widget child) {
    return shadcn.ShadcnApp(
      home: shadcn.Scaffold(
        child: Padding(padding: const EdgeInsets.all(16.0), child: child),
      ),
    );
  }

  testWidgets('AppSearchableSelect: initial selection rendering', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      buildTestableWidget(
        AppSearchableSelect<String>(
          items: const ['Item 1', 'Item 2', 'Item 3'],
          value: 'Item 2',
          itemBuilder: (context, item) => Text(item),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Item 2'), findsOneWidget);
  });

  testWidgets('AppSearchableSelect: parent changes selected value', (
    WidgetTester tester,
  ) async {
    String? selectedValue = 'Item 1';

    await tester.pumpWidget(
      StatefulBuilder(
        builder: (context, setState) {
          return buildTestableWidget(
            Column(
              children: [
                AppSearchableSelect<String>(
                  items: const ['Item 1', 'Item 2', 'Item 3'],
                  value: selectedValue,
                  itemBuilder: (context, item) => Text(item),
                ),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      selectedValue = 'Item 3';
                    });
                  },
                  child: const Text('Change Value'),
                ),
              ],
            ),
          );
        },
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Item 1'), findsOneWidget);

    await tester.tap(find.text('Change Value'));
    await tester.pumpAndSettle();

    expect(find.text('Item 3'), findsOneWidget);
  });

  testWidgets('AppSearchableSelect: parent clears selected value', (
    WidgetTester tester,
  ) async {
    String? selectedValue = 'Item 1';

    await tester.pumpWidget(
      StatefulBuilder(
        builder: (context, setState) {
          return buildTestableWidget(
            Column(
              children: [
                AppSearchableSelect<String>(
                  items: const ['Item 1', 'Item 2'],
                  value: selectedValue,
                  hint: 'Select item',
                  itemBuilder: (context, item) => Text(item),
                ),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      selectedValue = null;
                    });
                  },
                  child: const Text('Clear Value'),
                ),
              ],
            ),
          );
        },
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Item 1'), findsOneWidget);

    await tester.tap(find.text('Clear Value'));
    await tester.pumpAndSettle();

    expect(find.text('Select item'), findsOneWidget);
  });

  testWidgets('AppSearchableSelect: items and value update simultaneously', (
    WidgetTester tester,
  ) async {
    List<String> itemList = ['Apple', 'Banana'];
    String? selectedValue = 'Apple';

    await tester.pumpWidget(
      StatefulBuilder(
        builder: (context, setState) {
          return buildTestableWidget(
            Column(
              children: [
                AppSearchableSelect<String>(
                  items: itemList,
                  value: selectedValue,
                  placeholder: const Text('Select item'),
                  itemBuilder: (context, item) => Text(item),
                ),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      itemList = ['Cherry', 'Date'];
                      selectedValue = 'Cherry';
                    });
                  },
                  child: const Text('Update Items'),
                ),
              ],
            ),
          );
        },
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Apple'), findsOneWidget);

    await tester.tap(find.text('Update Items'));
    await tester.pumpAndSettle();

    expect(find.text('Cherry'), findsOneWidget);
    expect(find.text('Apple'), findsNothing);
  });
}
