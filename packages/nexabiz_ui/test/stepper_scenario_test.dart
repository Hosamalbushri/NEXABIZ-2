import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nexabiz_ui/src/playground/scenarios/stepper_scenario.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shadcn;

void main() {
  testWidgets('StepperScenario renders 3-step wizard and steps header', (
    tester,
  ) async {
    await tester.pumpWidget(
      const shadcn.ShadcnApp(
        home: Scaffold(body: StepperScenario(isArabic: true)),
      ),
    );
    await tester.pumpAndSettle();

    expect(
      find.text('معالج التهيئة متعدد الخطوات (AppStepper)'),
      findsOneWidget,
    );
    expect(find.text('بيانات المؤسسة'), findsWidgets);
    expect(find.text('السجل التجاري'), findsOneWidget);
    expect(find.text('الرقم الضريبي'), findsOneWidget);
  });
}
