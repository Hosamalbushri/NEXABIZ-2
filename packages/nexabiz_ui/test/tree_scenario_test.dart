import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nexabiz_ui/src/playground/scenarios/tree_scenario.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shadcn;

void main() {
  testWidgets('TreeScenario renders tree nodes and header title', (
    tester,
  ) async {
    await tester.pumpWidget(
      const shadcn.ShadcnApp(
        home: Scaffold(body: TreeScenario(isArabic: true)),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('دليل الحسابات الشجري التفاعلي'), findsOneWidget);
    expect(find.text('إضافة حساب'), findsOneWidget);
  });
}
