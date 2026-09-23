import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shadcn;
import 'package:nexabiz_ui/src/widgets/app_chip_input.dart';

void main() {
  Widget buildTestableWidget(Widget child) {
    return shadcn.ShadcnApp(
      home: shadcn.Scaffold(
        child: Padding(padding: const EdgeInsets.all(16.0), child: child),
      ),
    );
  }

  testWidgets('AppChipInput: initial externally supplied values rendering', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      buildTestableWidget(
        AppChipInput<String>(
          initialChips: const ['Tag1', 'Tag2'],
          chipBuilder: (context, value) => Text(value),
          onChipSubmitted: (text) => text,
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Tag1'), findsOneWidget);
    expect(find.text('Tag2'), findsOneWidget);
  });

  testWidgets('AppChipInput: parent replaces initialChips on rebuild', (
    WidgetTester tester,
  ) async {
    List<String> currentChips = ['Alpha', 'Beta'];

    await tester.pumpWidget(
      StatefulBuilder(
        builder: (context, setState) {
          return buildTestableWidget(
            Column(
              children: [
                AppChipInput<String>(
                  initialChips: currentChips,
                  chipBuilder: (context, value) => Text(value),
                  onChipSubmitted: (text) => text,
                ),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      currentChips = ['Gamma'];
                    });
                  },
                  child: const Text('Update'),
                ),
              ],
            ),
          );
        },
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Alpha'), findsOneWidget);
    expect(find.text('Beta'), findsOneWidget);

    await tester.tap(find.text('Update'));
    await tester.pumpAndSettle();

    expect(find.text('Gamma'), findsOneWidget);
    expect(find.text('Alpha'), findsNothing);
  });

  testWidgets('AppChipInput: parent clears values on rebuild', (
    WidgetTester tester,
  ) async {
    List<String> currentChips = ['One', 'Two'];

    await tester.pumpWidget(
      StatefulBuilder(
        builder: (context, setState) {
          return buildTestableWidget(
            Column(
              children: [
                AppChipInput<String>(
                  initialChips: currentChips,
                  chipBuilder: (context, value) => Text(value),
                  onChipSubmitted: (text) => text,
                ),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      currentChips = [];
                    });
                  },
                  child: const Text('Clear'),
                ),
              ],
            ),
          );
        },
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('One'), findsOneWidget);

    await tester.tap(find.text('Clear'));
    await tester.pumpAndSettle();

    expect(find.text('One'), findsNothing);
    expect(find.text('Two'), findsNothing);
  });

  testWidgets(
    'AppChipInput: caller-owned controller survives widget disposal',
    (WidgetTester tester) async {
      final controller = shadcn.ChipEditingController<String>();
      controller.chips = ['External1'];

      bool showWidget = true;

      await tester.pumpWidget(
        StatefulBuilder(
          builder: (context, setState) {
            return buildTestableWidget(
              Column(
                children: [
                  if (showWidget)
                    AppChipInput<String>(
                      controller: controller,
                      chipBuilder: (context, value) => Text(value),
                      onChipSubmitted: (text) => text,
                    ),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        showWidget = false;
                      });
                    },
                    child: const Text('Hide'),
                  ),
                ],
              ),
            );
          },
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('External1'), findsOneWidget);

      await tester.tap(find.text('Hide'));
      await tester.pumpAndSettle();

      expect(find.text('External1'), findsNothing);
      // Controller must remain active and non-disposed
      expect(() => controller.chips, returnsNormally);
      expect(controller.chips, contains('External1'));

      controller.dispose();
    },
  );
}
