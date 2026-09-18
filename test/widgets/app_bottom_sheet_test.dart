import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nexabiz_ui/nexabiz_ui.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shadcn;

void main() {
  group('AppBottomSheet Foundation Widget Tests', () {
    Widget buildTestApp(Widget homeWidget) {
      return NexaBizRootApp(home: homeWidget);
    }

    testWidgets(
      'AppBottomSheet.show opens sheet overlay and displays title & content',
      (tester) async {
        await tester.pumpWidget(
          buildTestApp(
            Builder(
              builder: (context) {
                return shadcn.Button.primary(
                  onPressed: () {
                    AppBottomSheet.show<void>(
                      context: context,
                      title: 'Test Sheet Title',
                      subtitle: 'Test Subtitle',
                      child: const Text('Sheet Content Area'),
                    );
                  },
                  child: const Text('Open Sheet'),
                );
              },
            ),
          ),
        );

        await tester.tap(find.text('Open Sheet'));
        await tester.pumpAndSettle();

        expect(find.text('Test Sheet Title'), findsOneWidget);
        expect(find.text('Test Subtitle'), findsOneWidget);
        expect(find.text('Sheet Content Area'), findsOneWidget);
      },
    );

    testWidgets('AppBottomSheet.close dismisses the sheet overlay', (
      tester,
    ) async {
      await tester.pumpWidget(
        buildTestApp(
          Builder(
            builder: (context) {
              return shadcn.Button.primary(
                onPressed: () {
                  AppBottomSheet.show<void>(
                    context: context,
                    title: 'Dismissible Sheet',
                    child: Builder(
                      builder: (sheetContext) {
                        return shadcn.Button.outline(
                          onPressed: () =>
                              AppBottomSheet.close<void>(sheetContext),
                          child: const Text('Close Button'),
                        );
                      },
                    ),
                  );
                },
                child: const Text('Open Sheet'),
              );
            },
          ),
        ),
      );

      await tester.tap(find.text('Open Sheet'));
      await tester.pumpAndSettle();

      expect(find.text('Dismissible Sheet'), findsOneWidget);

      await tester.tap(find.text('Close Button'));
      await tester.pumpAndSettle();

      expect(find.text('Dismissible Sheet'), findsNothing);
    });

    testWidgets('AppBottomSheet.showSelection returns selected item value', (
      tester,
    ) async {
      String? selectedResult;

      await tester.pumpWidget(
        buildTestApp(
          Builder(
            builder: (context) {
              return shadcn.Button.primary(
                onPressed: () async {
                  selectedResult = await AppBottomSheet.showSelection<String>(
                    context: context,
                    title: 'Select Account',
                    items: const [
                      AppBottomSheetSelectionItem(
                        value: 'ACC-01',
                        label: 'Cash Account',
                      ),
                      AppBottomSheetSelectionItem(
                        value: 'ACC-02',
                        label: 'Bank Account',
                      ),
                    ],
                  );
                },
                child: const Text('Open Selection'),
              );
            },
          ),
        ),
      );

      await tester.tap(find.text('Open Selection'));
      await tester.pumpAndSettle();

      expect(find.text('Select Account'), findsOneWidget);
      expect(find.text('Cash Account'), findsOneWidget);
      expect(find.text('Bank Account'), findsOneWidget);

      await tester.tap(find.text('Bank Account'));
      await tester.pumpAndSettle();

      expect(selectedResult, equals('ACC-02'));
    });

    testWidgets('AppBottomSheet.showConfirmation returns true on confirm', (
      tester,
    ) async {
      bool? confirmedResult;

      await tester.pumpWidget(
        buildTestApp(
          Builder(
            builder: (context) {
              return shadcn.Button.primary(
                onPressed: () async {
                  confirmedResult = await AppBottomSheet.showConfirmation(
                    context: context,
                    title: 'Confirm Action',
                    message: 'Are you sure you want to proceed?',
                    confirmLabel: 'Yes',
                    cancelLabel: 'No',
                  );
                },
                child: const Text('Open Confirmation'),
              );
            },
          ),
        ),
      );

      await tester.tap(find.text('Open Confirmation'));
      await tester.pumpAndSettle();

      expect(find.text('Confirm Action'), findsOneWidget);
      expect(find.text('Are you sure you want to proceed?'), findsOneWidget);

      await tester.tap(find.text('Yes'));
      await tester.pumpAndSettle();

      expect(confirmedResult, isTrue);
    });

    testWidgets('AppBottomSheet supports RTL directional layout', (
      tester,
    ) async {
      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.rtl,
          child: buildTestApp(
            Builder(
              builder: (context) {
                return shadcn.Button.primary(
                  onPressed: () {
                    AppBottomSheet.show<void>(
                      context: context,
                      title: 'عنوان عربى',
                      child: const Text('محتوى بطاقة العمليات'),
                    );
                  },
                  child: const Text('افتح'),
                );
              },
            ),
          ),
        ),
      );

      await tester.tap(find.text('افتح'));
      await tester.pumpAndSettle();

      expect(find.text('عنوان عربى'), findsOneWidget);
      expect(find.text('محتوى بطاقة العمليات'), findsOneWidget);
    });

    testWidgets('AppBottomSheet respects responsive max width constraint', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(1200, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        buildTestApp(
          Builder(
            builder: (context) {
              return shadcn.Button.primary(
                onPressed: () {
                  AppBottomSheet.show<void>(
                    context: context,
                    title: 'Responsive Sheet',
                    child: const Text('Wide Screen Test'),
                  );
                },
                child: const Text('Open Responsive'),
              );
            },
          ),
        ),
      );

      await tester.tap(find.text('Open Responsive'));
      await tester.pumpAndSettle();

      expect(find.byType(AppBottomSheet), findsOneWidget);
      final constrainedBoxFinder = find.descendant(
        of: find.byType(AppBottomSheet),
        matching: find.byType(ConstrainedBox),
      );
      final renderBox = tester.renderObject<RenderBox>(
        constrainedBoxFinder.first,
      );
      expect(renderBox.size.width, lessThanOrEqualTo(AppBreakpoints.mobile));
    });
  });
}
