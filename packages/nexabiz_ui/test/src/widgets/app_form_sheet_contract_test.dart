import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shadcn;
import 'package:nexabiz_ui/src/widgets/app_form_sheet.dart';

void main() {
  Widget buildTestableWidget(Widget child) {
    return shadcn.ShadcnApp(
      home: shadcn.Scaffold(
        child: Padding(padding: const EdgeInsets.all(16.0), child: child),
      ),
    );
  }

  testWidgets('AppFormSheet: renders form child and handles submit', (
    WidgetTester tester,
  ) async {
    bool submitted = false;

    await tester.pumpWidget(
      buildTestableWidget(
        AppFormSheet(
          title: 'Sheet Form',
          onSubmit: (context, values) {
            submitted = true;
          },
          child: const Text('Form Body'),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Sheet Form'), findsOneWidget);
    expect(find.text('Form Body'), findsOneWidget);

    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    expect(submitted, isTrue);
  });

  testWidgets(
    'AppFormSheet: respects custom localized submit and cancel labels',
    (WidgetTester tester) async {
      bool submitted = false;

      await tester.pumpWidget(
        buildTestableWidget(
          AppFormSheet(
            title: 'استمارة',
            submitLabel: 'حفظ',
            cancelLabel: 'إلغاء',
            onSubmit: (context, values) {
              submitted = true;
            },
            child: const Text('محتوى'),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('استمارة'), findsOneWidget);
      expect(find.text('محتوى'), findsOneWidget);
      expect(find.text('حفظ'), findsOneWidget);
      expect(find.text('إلغاء'), findsOneWidget);

      await tester.tap(find.text('حفظ'));
      await tester.pumpAndSettle();

      expect(submitted, isTrue);
    },
  );

  testWidgets(
    'AppFormSheet: unmounting during async submit does not throw context exception',
    (WidgetTester tester) async {
      final completer = Completer<void>();
      bool showSheet = true;

      await tester.pumpWidget(
        StatefulBuilder(
          builder: (context, setState) {
            return buildTestableWidget(
              Column(
                children: [
                  if (showSheet)
                    AppFormSheet(
                      title: 'Async Sheet',
                      onSubmit: (context, values) async {
                        await completer.future;
                      },
                      child: const Text('Async Body'),
                    ),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        showSheet = false;
                      });
                    },
                    child: const Text('Unmount Sheet'),
                  ),
                ],
              ),
            );
          },
        ),
      );
      await tester.pumpAndSettle();

      // Trigger submit
      await tester.tap(find.text('Save'));
      await tester.pump(); // Submit starts async operation

      // Unmount sheet while submission is pending
      await tester.tap(find.text('Unmount Sheet'));
      await tester.pumpAndSettle();

      // Complete async operation post unmount
      completer.complete();
      await tester.pumpAndSettle();

      // Verify no exception occurred
      expect(tester.takeException(), isNull);
    },
  );
}
