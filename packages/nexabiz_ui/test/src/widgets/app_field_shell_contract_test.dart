import 'package:flutter/material.dart';
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

  group('AppFieldShell Contract Tests', () {
    testWidgets('AppFieldShell: parent-driven update of label and errorText', (
      WidgetTester tester,
    ) async {
      String? error;

      await tester.pumpWidget(
        StatefulBuilder(
          builder: (context, setState) {
            return buildTestableWidget(
              Column(
                children: [
                  AppFieldShell(
                    label: 'Test Label',
                    errorText: error,
                    child: const Text('Input Area'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        error = 'Validation Error';
                      });
                    },
                    child: const Text('Set Error'),
                  ),
                ],
              ),
            );
          },
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Test Label'), findsOneWidget);
      expect(find.text('Validation Error'), findsNothing);

      await tester.tap(find.text('Set Error'));
      await tester.pumpAndSettle();

      expect(find.text('Validation Error'), findsOneWidget);
    });

    testWidgets('AppFieldShell: renders required asterisk and description', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        buildTestableWidget(
          const AppFieldShell(
            label: 'Tax Identification Number',
            required: true,
            description: 'Enter your 15-digit VAT registration number',
            helperText: 'Must match ZATCA registration records',
            child: Text('TIN Input'),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Tax Identification Number'), findsOneWidget);
      expect(find.text('*'), findsOneWidget);
      expect(
        find.text('Enter your 15-digit VAT registration number'),
        findsOneWidget,
      );
      expect(
        find.text('Must match ZATCA registration records'),
        findsOneWidget,
      );
      expect(find.text('TIN Input'), findsOneWidget);
    });

    testWidgets('AppFieldShell: borderless mode renders child without frame', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        buildTestableWidget(
          const AppFieldShell(
            label: 'Volume',
            borderless: true,
            child: Text('Unframed Control'),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Volume'), findsOneWidget);
      expect(find.text('Unframed Control'), findsOneWidget);
      expect(find.byType(AnimatedContainer), findsNothing);
    });

    testWidgets('AppFieldShell: triggers onClear callback when tapped', (
      WidgetTester tester,
    ) async {
      var cleared = false;

      await tester.pumpWidget(
        buildTestableWidget(
          AppFieldShell(
            label: 'Clearable Field',
            onClear: () => cleared = true,
            child: const Text('Value inside'),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byIcon(shadcn.LucideIcons.circleX), findsOneWidget);
      await tester.tap(find.byIcon(shadcn.LucideIcons.circleX));
      await tester.pumpAndSettle();

      expect(cleared, isTrue);
    });

    testWidgets(
      'AppTextField: inner shadcn field suppresses FocusOutline and inner decoration',
      (WidgetTester tester) async {
        final controller = TextEditingController();
        final focusNode = FocusNode();

        await tester.pumpWidget(
          buildTestableWidget(
            AppTextField(
              controller: controller,
              focusNode: focusNode,
              label: 'Email',
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Verify FocusOutlineTheme suppresses border
        final focusOutlineThemeFinder = find.byType(
          shadcn.ComponentTheme<shadcn.FocusOutlineTheme>,
        );
        expect(focusOutlineThemeFinder, findsOneWidget);

        // Focus the field
        focusNode.requestFocus();
        await tester.pumpAndSettle();

        // Find shadcn TextField's FocusOutline
        final focusOutlineFinder = find.byType(shadcn.FocusOutline);
        expect(focusOutlineFinder, findsOneWidget);

        final focusOutline = tester.widget<shadcn.FocusOutline>(
          focusOutlineFinder,
        );
        expect(focusOutline.focused, isTrue);

        // Verify that the inner TextField has decoration with no border and no background color
        final textFieldFinder = find.byType(shadcn.TextField);
        expect(textFieldFinder, findsOneWidget);
        final textField = tester.widget<shadcn.TextField>(textFieldFinder);
        expect(textField.decoration, equals(const BoxDecoration()));
      },
    );
  });
}
