import 'package:flutter/material.dart' show Icons;
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nexabiz_ui/nexabiz_ui.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shadcn;

void main() {
  for (final direction in TextDirection.values) {
    for (final width in [280.0, 600.0, 1024.0]) {
      for (final scale in [1.0, 2.0]) {
        testWidgets(
          'quick actions canonical host $direction width $width scale $scale with insets and focus',
          (tester) async {
            tester.view.devicePixelRatio = 1;
            tester.view.physicalSize = Size(width, 600);
            tester.view.viewInsets = const FakeViewPadding(bottom: 180);
            tester.view.viewPadding = const FakeViewPadding(
              top: 24,
              bottom: 20,
            );
            addTearDown(tester.view.resetPhysicalSize);
            addTearDown(tester.view.resetDevicePixelRatio);
            addTearDown(tester.view.resetViewInsets);
            addTearDown(tester.view.resetViewPadding);
            final focus = FocusNode();
            addTearDown(focus.dispose);
            late BuildContext caller;
            Future<String?>? result;
            var actions = 0;
            await tester.pumpWidget(
              NexaBizRootApp(
                builder: (context, child) => MediaQuery(
                  data: MediaQuery.of(
                    context,
                  ).copyWith(textScaler: TextScaler.linear(scale)),
                  child: Directionality(
                    textDirection: direction,
                    child: child!,
                  ),
                ),
                home: Builder(
                  builder: (context) {
                    caller = context;
                    return Focus(
                      focusNode: focus,
                      child: shadcn.Button.primary(
                        onPressed: () =>
                            result = AppQuickActionsPanel.show<String>(
                              context,
                              title: 'Quick tasks',
                              subtitle: 'Choose a task',
                              items: [
                                AppQuickActionItem(
                                  label: 'Create voucher',
                                  description: 'New document',
                                  icon: Icons.add,
                                  onTap: () => actions++,
                                ),
                              ],
                            ),
                        child: const Text('Open'),
                      ),
                    );
                  },
                ),
              ),
            );
            focus.requestFocus();
            await tester.pump();
            await tester.tap(find.text('Open'));
            await tester.pumpAndSettle();
            expect(tester.takeException(), isNull);
            expect(find.byType(AppQuickActionsPanel), findsOneWidget);
            final panelContext = tester.element(
              find.byType(AppQuickActionsPanel),
            );
            expect(
              find.ancestor(
                of: find.byType(AppQuickActionsPanel),
                matching: find.byType(shadcn.SheetWrapper),
              ),
              findsOneWidget,
            );
            expect(Directionality.of(panelContext), direction);
            expect(find.text('Quick tasks'), findsOneWidget);
            expect(find.text('Choose a task'), findsOneWidget);
            expect(find.text('Create voucher'), findsOneWidget);
            expect(find.text('New document'), findsOneWidget);
            final bottom = tester
                .getBottomRight(
                  find
                      .ancestor(
                        of: find.byType(AppQuickActionsPanel),
                        matching: find.byType(SingleChildScrollView),
                      )
                      .first,
                )
                .dy;
            expect(bottom, lessThanOrEqualTo(600 - 180));
            // The shell closes from its original caller context, outside the overlay.
            AppQuickActionsPanel.close(caller);
            await tester.pumpAndSettle();
            expect(tester.takeException(), isNull);
            expect(await result, isNull);
            expect(find.byType(AppQuickActionsPanel), findsNothing);
            expect(focus.hasFocus, isTrue);
            expect(actions, 0);
            await tester.pumpWidget(const SizedBox());
          },
        );
      }
    }
  }

  testWidgets(
    'quick actions returns typed result, dismisses barrier and invokes action once',
    (tester) async {
      late BuildContext caller;
      Future<int?>? result;
      var count = 0;
      await tester.pumpWidget(
        NexaBizRootApp(
          home: Builder(
            builder: (context) {
              caller = context;
              return shadcn.Button.primary(
                onPressed: () {
                  result = AppQuickActionsPanel.show<int>(
                    context,
                    title: 'Actions',
                    items: [
                      AppQuickActionItem(
                        label: 'Execute',
                        icon: Icons.add,
                        onTap: () => count++,
                      ),
                    ],
                  );
                },
                child: const Text('Open'),
              );
            },
          ),
        ),
      );
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      shadcn.closeDrawer<int>(
        tester.element(find.byType(AppQuickActionsPanel)),
        42,
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(await result, 42);
      result = AppQuickActionsPanel.show<int>(
        caller,
        title: 'Actions',
        items: [
          AppQuickActionItem(
            label: 'Execute',
            icon: Icons.add,
            onTap: () => count++,
          ),
        ],
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      await tester.tap(find.text('Execute'));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(count, 1);
      expect(await result, isNull);
      result = AppQuickActionsPanel.show<int>(caller, items: []);
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      await tester.tapAt(const Offset(10, 10));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(find.byType(AppQuickActionsPanel), findsNothing);
      expect(await result, isNull);
    },
  );

  testWidgets(
    'quick-action close control completes once and separate invocations remain independent',
    (tester) async {
      late BuildContext caller;
      await tester.pumpWidget(
        NexaBizRootApp(
          home: Builder(
            builder: (context) {
              caller = context;
              return const Text('Page');
            },
          ),
        ),
      );
      final first = AppQuickActionsPanel.show<String>(
        caller,
        title: 'First panel',
        items: [],
      );
      final second = AppQuickActionsPanel.show<String>(
        caller,
        title: 'Second panel',
        items: [],
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(find.byType(AppQuickActionsPanel), findsNWidgets(2));
      await tester.tap(find.byIcon(shadcn.LucideIcons.x).last);
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(await second, isNull);
      expect(find.byType(AppQuickActionsPanel), findsOneWidget);
      AppQuickActionsPanel.close(caller);
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(await first, isNull);
      expect(find.byType(AppQuickActionsPanel), findsNothing);
    },
  );

  testWidgets(
    'quick actions scrolls tall content above the keyboard without hiding the last action',
    (tester) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = const Size(280, 600);
      tester.view.viewInsets = const FakeViewPadding(bottom: 180);
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetViewInsets);
      late BuildContext caller;
      var calls = 0;
      await tester.pumpWidget(
        NexaBizRootApp(
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(
              context,
            ).copyWith(textScaler: TextScaler.linear(2)),
            child: child!,
          ),
          home: Builder(
            builder: (context) {
              caller = context;
              return const Text('Page');
            },
          ),
        ),
      );
      final result = AppQuickActionsPanel.show<void>(
        caller,
        items: List.generate(
          16,
          (index) => AppQuickActionItem(
            label: 'Action $index',
            description: 'Document',
            icon: Icons.add,
            onTap: () => calls++,
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      await tester.ensureVisible(find.text('Action 15'));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      await tester.tap(find.text('Action 15'));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      await result;
      expect(calls, 1);
      expect(find.byType(AppQuickActionsPanel), findsNothing);
    },
  );
}
