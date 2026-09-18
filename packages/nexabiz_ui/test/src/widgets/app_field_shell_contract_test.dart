import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shadcn;
import 'package:nexabiz_ui/src/widgets/app_field_shell.dart';

void main() {
  Widget buildTestableWidget(Widget child) {
    return shadcn.ShadcnApp(
      home: shadcn.Scaffold(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: child,
        ),
      ),
    );
  }

  testWidgets('AppFieldShell: parent-driven update of label and errorText',
      (WidgetTester tester) async {
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
}
