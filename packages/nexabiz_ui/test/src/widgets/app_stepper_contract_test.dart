import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shadcn;
import 'package:nexabiz_ui/src/widgets/app_stepper.dart';

void main() {
  Widget buildTestableWidget(Widget child) {
    return shadcn.ShadcnApp(
      home: shadcn.Scaffold(
        child: Padding(padding: const EdgeInsets.all(16.0), child: child),
      ),
    );
  }

  testWidgets('AppStepper: internal controller step navigation', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      buildTestableWidget(
        AppStepper(
          steps: [
            AppStepItem(
              title: const Text('Step 1'),
              contentBuilder: (context) => const Text('Content 1'),
            ),
            AppStepItem(
              title: const Text('Step 2'),
              contentBuilder: (context) => const Text('Content 2'),
            ),
          ],
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Content 1'), findsOneWidget);

    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();

    expect(find.text('Content 2'), findsOneWidget);
  });

  testWidgets('AppStepper: caller-owned controller survives widget disposal', (
    WidgetTester tester,
  ) async {
    final controller = shadcn.StepperController(currentStep: 0);
    bool showStepper = true;

    await tester.pumpWidget(
      StatefulBuilder(
        builder: (context, setState) {
          return buildTestableWidget(
            Column(
              children: [
                if (showStepper)
                  AppStepper(
                    controller: controller,
                    steps: [
                      AppStepItem(
                        title: const Text('Step 1'),
                        contentBuilder: (context) => const Text('Content 1'),
                      ),
                      AppStepItem(
                        title: const Text('Step 2'),
                        contentBuilder: (context) => const Text('Content 2'),
                      ),
                    ],
                  ),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      showStepper = false;
                    });
                  },
                  child: const Text('Remove Stepper'),
                ),
              ],
            ),
          );
        },
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Content 1'), findsOneWidget);

    await tester.tap(find.text('Remove Stepper'));
    await tester.pumpAndSettle();

    // Verify caller-owned controller survives disposal
    expect(() => controller.nextStep(), returnsNormally);

    controller.dispose();
  });

  testWidgets(
    'AppStepper: step jump on currentStep update with controller change',
    (WidgetTester tester) async {
      int activeStep = 0;

      await tester.pumpWidget(
        StatefulBuilder(
          builder: (context, setState) {
            return buildTestableWidget(
              Column(
                children: [
                  AppStepper(
                    currentStep: activeStep,
                    steps: [
                      AppStepItem(
                        title: const Text('Step 1'),
                        contentBuilder: (context) => const Text('Content 1'),
                      ),
                      AppStepItem(
                        title: const Text('Step 2'),
                        contentBuilder: (context) => const Text('Content 2'),
                      ),
                    ],
                  ),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        activeStep = 1;
                      });
                    },
                    child: const Text('Go to Step 2'),
                  ),
                ],
              ),
            );
          },
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Content 1'), findsOneWidget);

      await tester.tap(find.text('Go to Step 2'));
      await tester.pumpAndSettle();

      expect(find.text('Content 2'), findsOneWidget);
    },
  );
}
