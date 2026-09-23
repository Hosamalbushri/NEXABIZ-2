import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nexabiz_ui/nexabiz_ui.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shadcn;

void main() {
  testWidgets('AppFormRow lays out children side by side with equal flex', (
    tester,
  ) async {
    await tester.pumpWidget(
      shadcn.ShadcnApp(
        home: Scaffold(
          body: AppFormRow(
            children: const [
              AppTextField(label: 'Field 1'),
              AppTextField(label: 'Field 2'),
            ],
          ),
        ),
      ),
    );

    expect(find.text('Field 1'), findsOneWidget);
    expect(find.text('Field 2'), findsOneWidget);

    final firstSize = tester.getSize(find.byType(AppTextField).first);
    final secondSize = tester.getSize(find.byType(AppTextField).last);

    expect(firstSize.width, equals(secondSize.width));
  });
}
