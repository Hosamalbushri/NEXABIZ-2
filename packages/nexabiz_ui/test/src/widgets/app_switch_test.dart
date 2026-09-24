import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nexabiz_ui/nexabiz_ui.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shadcn;

void main() {
  Widget buildTestableWidget({
    required Widget child,
    TextDirection textDirection = TextDirection.ltr,
  }) {
    return shadcn.ShadcnApp(
      locale: textDirection == TextDirection.rtl
          ? const Locale('ar')
          : const Locale('en'),
      home: Directionality(
        textDirection: textDirection,
        child: shadcn.Scaffold(child: Center(child: child)),
      ),
    );
  }

  group('AppSwitch & Directional Navigation Tests', () {
    testWidgets('AppSwitch in LTR: renders normally without Transform.flip', (
      WidgetTester tester,
    ) async {
      bool currentValue = false;

      await tester.pumpWidget(
        buildTestableWidget(
          textDirection: TextDirection.ltr,
          child: AppSwitch(
            value: currentValue,
            onChanged: (val) => currentValue = val,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(AppSwitch), findsOneWidget);
      expect(find.byType(shadcn.Switch), findsOneWidget);
      expect(find.byType(Transform), findsNothing);
    });

    testWidgets('AppSwitch in RTL: applies Transform.flip horizontally', (
      WidgetTester tester,
    ) async {
      bool currentValue = true;

      await tester.pumpWidget(
        buildTestableWidget(
          textDirection: TextDirection.rtl,
          child: AppSwitch(
            value: currentValue,
            onChanged: (val) => currentValue = val,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(AppSwitch), findsOneWidget);
      expect(find.byType(shadcn.Switch), findsOneWidget);
      expect(find.byType(Transform), findsOneWidget);

      final transformFinder = find.byType(Transform);
      final transform = tester.widget<Transform>(transformFinder);
      expect(transform.transform.entry(0, 0), equals(-1.0));
    });

    testWidgets('AppSwitch: toggles value when tapped', (
      WidgetTester tester,
    ) async {
      bool currentValue = false;

      await tester.pumpWidget(
        StatefulBuilder(
          builder: (context, setState) {
            return buildTestableWidget(
              textDirection: TextDirection.rtl,
              child: AppSwitch(
                value: currentValue,
                onChanged: (val) {
                  setState(() => currentValue = val);
                },
              ),
            );
          },
        ),
      );
      await tester.pumpAndSettle();

      expect(currentValue, isFalse);
      await tester.tap(find.byType(AppSwitch));
      await tester.pumpAndSettle();
      expect(currentValue, isTrue);
    });

    testWidgets('AppIcons.chevronForward returns directional chevron', (
      WidgetTester tester,
    ) async {
      IconData? ltrChevron;
      IconData? rtlChevron;

      await tester.pumpWidget(
        buildTestableWidget(
          textDirection: TextDirection.ltr,
          child: Builder(
            builder: (context) {
              ltrChevron = AppIcons.chevronForward(context);
              return const SizedBox();
            },
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.pumpWidget(
        buildTestableWidget(
          textDirection: TextDirection.rtl,
          child: Builder(
            builder: (context) {
              rtlChevron = AppIcons.chevronForward(context);
              return const SizedBox();
            },
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(ltrChevron, equals(AppIcons.chevronRight));
      expect(rtlChevron, equals(AppIcons.chevronLeft));
    });
  });
}
