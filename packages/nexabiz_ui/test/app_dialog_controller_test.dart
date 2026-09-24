import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nexabiz_ui/nexabiz_ui.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shadcn;

void main() {
  testWidgets('AppDialogController closes the exact active dialog', (
    tester,
  ) async {
    final controller = AppDialogController();

    await tester.pumpWidget(
      shadcn.ShadcnApp(
        home: Scaffold(
          body: Builder(
            builder: (context) {
              return AppButton(
                label: 'Open',
                onPressed: () {
                  unawaited(
                    AppDialog.show<void>(
                      context: context,
                      controller: controller,
                      title: 'Controlled dialog',
                      showActions: false,
                      child: const Text('Body'),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ),
    );

    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();
    expect(controller.isAttached, isTrue);
    expect(find.text('Controlled dialog'), findsOneWidget);

    await controller.close();
    await tester.pumpAndSettle();
    expect(controller.isAttached, isFalse);
    expect(find.text('Controlled dialog'), findsNothing);
  });
}
