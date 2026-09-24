import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nexabiz_ui/nexabiz_ui.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shadcn;

void main() {
  group('NexaBiz Overlay Architecture Guardrails (Phase 08)', () {
    Widget buildTestApp(
      Widget homeWidget, {
      TextDirection textDirection = TextDirection.ltr,
    }) {
      return Directionality(
        textDirection: textDirection,
        child: NexaBizRootApp(home: Scaffold(body: homeWidget)),
      );
    }

    testWidgets(
      'AppDialog: opens, renders title/content, and closes on close button',
      (tester) async {
        await tester.pumpWidget(
          buildTestApp(
            Builder(
              builder: (context) {
                return AppButton(
                  label: 'Open Dialog',
                  onPressed: () {
                    AppDialog.show<void>(
                      context: context,
                      title: 'System Dialog',
                      child: const Text('Dialog Body Content'),
                    );
                  },
                );
              },
            ),
          ),
        );

        await tester.tap(find.text('Open Dialog'));
        await tester.pumpAndSettle();

        expect(find.text('System Dialog'), findsOneWidget);
        expect(find.text('Dialog Body Content'), findsOneWidget);

        // Close button icon
        final closeButtonFinder = find.byIcon(shadcn.LucideIcons.x);
        expect(closeButtonFinder, findsOneWidget);

        await tester.tap(closeButtonFinder);
        await tester.pumpAndSettle();

        expect(find.text('System Dialog'), findsNothing);
      },
    );

    testWidgets('AppDialog: confirm returns true, cancel returns false', (
      tester,
    ) async {
      bool? dialogResult;

      await tester.pumpWidget(
        buildTestApp(
          Builder(
            builder: (context) {
              return AppButton(
                label: 'Open Prompt',
                onPressed: () async {
                  dialogResult = await AppDialog.confirm(
                    context: context,
                    title: 'Confirm Operation',
                    message: 'Are you sure you want to proceed?',
                  );
                },
              );
            },
          ),
        ),
      );

      // 1. Confirm action
      await tester.tap(find.text('Open Prompt'));
      await tester.pumpAndSettle();

      expect(find.text('Confirm Operation'), findsOneWidget);
      await tester.tap(find.text('Confirm'));
      await tester.pumpAndSettle();

      expect(dialogResult, isTrue);

      // 2. Cancel action
      await tester.tap(find.text('Open Prompt'));
      await tester.pumpAndSettle();

      expect(find.text('Confirm Operation'), findsOneWidget);
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      expect(dialogResult, isFalse);
    });

    testWidgets(
      'AppConfirmationDialog: compatibility wrapper delegates to AppDialog.confirm',
      (tester) async {
        bool onConfirmCalled = false;

        await tester.pumpWidget(
          buildTestApp(
            Builder(
              builder: (context) {
                return AppButton(
                  label: 'Open Compat',
                  onPressed: () {
                    AppConfirmationDialog.show(
                      context,
                      title: 'Compat Title',
                      message: 'Compat Message',
                      onConfirm: () {
                        onConfirmCalled = true;
                      },
                    );
                  },
                );
              },
            ),
          ),
        );

        await tester.tap(find.text('Open Compat'));
        await tester.pumpAndSettle();

        expect(find.text('Compat Title'), findsOneWidget);
        expect(find.text('Compat Message'), findsOneWidget);

        await tester.tap(find.text('Confirm'));
        await tester.pumpAndSettle();

        expect(onConfirmCalled, isTrue);
      },
    );

    testWidgets(
      'AppFormDialog: renders fields, executes onSubmit, and handles spacing',
      (tester) async {
        bool formSubmitted = false;

        await tester.pumpWidget(
          buildTestApp(
            Builder(
              builder: (context) {
                return AppButton(
                  label: 'Open Form Dialog',
                  onPressed: () {
                    AppFormDialog.show<void>(
                      context: context,
                      title: 'Voucher Form Modal',
                      subtitle: 'Enter transaction lines',
                      onSubmit: () {
                        formSubmitted = true;
                        shadcn.closeOverlay(context, null);
                      },
                      children: const [
                        AppTextField(
                          label: 'Reference Number',
                          hint: 'REF-001',
                        ),
                        AppTextField(label: 'Account Code', hint: '1010'),
                      ],
                    );
                  },
                );
              },
            ),
          ),
        );

        await tester.tap(find.text('Open Form Dialog'));
        await tester.pumpAndSettle();

        expect(find.text('Voucher Form Modal'), findsOneWidget);
        expect(find.text('Reference Number'), findsOneWidget);
        expect(find.text('Account Code'), findsOneWidget);

        await tester.tap(find.text('Save'));
        await tester.pumpAndSettle();

        expect(formSubmitted, isTrue);
        expect(find.text('Voucher Form Modal'), findsNothing);
      },
    );

    testWidgets(
      'AppBottomSheet: showSelection displays items and returns selection',
      (tester) async {
        String? selectedValue;

        await tester.pumpWidget(
          buildTestApp(
            Builder(
              builder: (context) {
                return AppButton(
                  label: 'Open Selector',
                  onPressed: () async {
                    selectedValue = await AppBottomSheet.showSelection<String>(
                      context: context,
                      title: 'Select Cost Center',
                      items: const [
                        AppBottomSheetSelectionItem(
                          value: 'CC-1',
                          label: 'Operations',
                        ),
                        AppBottomSheetSelectionItem(
                          value: 'CC-2',
                          label: 'Administration',
                        ),
                      ],
                    );
                  },
                );
              },
            ),
          ),
        );

        await tester.tap(find.text('Open Selector'));
        await tester.pumpAndSettle();

        expect(find.text('Select Cost Center'), findsOneWidget);
        expect(find.text('Operations'), findsOneWidget);
        expect(find.text('Administration'), findsOneWidget);

        await tester.tap(find.text('Administration'));
        await tester.pumpAndSettle();

        expect(selectedValue, equals('CC-2'));
        expect(find.text('Select Cost Center'), findsNothing);
      },
    );

    testWidgets('AppBottomSheet: showConfirmation returns true on confirm', (
      tester,
    ) async {
      bool? confirmed;

      await tester.pumpWidget(
        buildTestApp(
          Builder(
            builder: (context) {
              return AppButton(
                label: 'Open Sheet Confirm',
                onPressed: () async {
                  confirmed = await AppBottomSheet.showConfirmation(
                    context: context,
                    title: 'Confirm Deletion',
                    message: 'Are you sure you want to delete this invoice?',
                  );
                },
              );
            },
          ),
        ),
      );

      await tester.tap(find.text('Open Sheet Confirm'));
      await tester.pumpAndSettle();

      expect(find.text('Confirm Deletion'), findsOneWidget);
      expect(
        find.text('Are you sure you want to delete this invoice?'),
        findsOneWidget,
      );

      await tester.tap(find.text('Confirm'));
      await tester.pumpAndSettle();

      expect(confirmed, isTrue);
    });

    testWidgets(
      'AppDrawerSheet: enforces max width constraints in 1600px desktop window',
      (tester) async {
        tester.view.physicalSize = const Size(1600, 1000);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);

        await tester.pumpWidget(
          buildTestApp(
            Builder(
              builder: (context) {
                return AppButton(
                  label: 'Open Drawer',
                  onPressed: () {
                    AppDrawerSheet.show<void>(
                      context: context,
                      title: 'Filters Drawer',
                      constraints: const BoxConstraints(maxWidth: 420),
                      child: const Text('Filter Controls'),
                    );
                  },
                );
              },
            ),
          ),
        );

        await tester.tap(find.text('Open Drawer'));
        await tester.pumpAndSettle();

        expect(find.text('Filters Drawer'), findsOneWidget);
        expect(find.text('Filter Controls'), findsOneWidget);

        final drawerFinder = find.byType(AppDrawerSheet);
        expect(drawerFinder, findsOneWidget);
        final renderBox = tester.renderObject<RenderBox>(drawerFinder);
        expect(renderBox.size.width, lessThanOrEqualTo(420.0));

        // Close drawer
        final closeFinder = find.byIcon(shadcn.LucideIcons.x);
        await tester.tap(closeFinder);
        await tester.pumpAndSettle();

        expect(find.text('Filters Drawer'), findsNothing);
      },
    );

    testWidgets(
      'Phase 05 Selection Interoperability: AppSelectField opens above AppDialog without z-index clipping',
      (tester) async {
        String? currentSelected = 'USD';

        await tester.pumpWidget(
          buildTestApp(
            StatefulBuilder(
              builder: (context, setState) {
                return AppButton(
                  label: 'Open Dialog With Select',
                  onPressed: () {
                    AppDialog.show<void>(
                      context: context,
                      title: 'Currency Setup',
                      child: StatefulBuilder(
                        builder: (dialogCtx, setDialogState) {
                          return Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              AppSelectField<String>(
                                label: 'Base Currency',
                                value: currentSelected,
                                items: const [
                                  AppSelectOption(
                                    value: 'USD',
                                    label: 'US Dollar (USD)',
                                  ),
                                  AppSelectOption(
                                    value: 'SAR',
                                    label: 'Saudi Riyal (SAR)',
                                  ),
                                  AppSelectOption(
                                    value: 'EUR',
                                    label: 'Euro (EUR)',
                                  ),
                                ],
                                onChanged: (val) {
                                  setDialogState(() {
                                    currentSelected = val;
                                  });
                                },
                              ),
                            ],
                          );
                        },
                      ),
                    );
                  },
                );
              },
            ),
          ),
        );

        await tester.tap(find.text('Open Dialog With Select'));
        await tester.pumpAndSettle();

        expect(find.text('Currency Setup'), findsOneWidget);
        expect(find.text('US Dollar (USD)'), findsOneWidget);

        // Tap select field to open dropdown popover
        await tester.tap(find.text('US Dollar (USD)'));
        await tester.pumpAndSettle();

        // The popover options must be visible and tapable above the dialog surface
        expect(find.text('Saudi Riyal (SAR)'), findsOneWidget);

        await tester.tap(find.text('Saudi Riyal (SAR)'));
        await tester.pumpAndSettle();

        expect(currentSelected, equals('SAR'));
        expect(find.text('Saudi Riyal (SAR)'), findsOneWidget);

        // Dismiss dialog
        await tester.tap(find.text('Cancel'));
        await tester.pumpAndSettle();

        expect(find.text('Currency Setup'), findsNothing);
      },
    );

    testWidgets(
      'RTL Directionality: Dialog renders cleanly in Arabic without overflow',
      (tester) async {
        await tester.pumpWidget(
          buildTestApp(
            Builder(
              builder: (context) {
                return AppButton(
                  label: 'فتح الحوار',
                  onPressed: () {
                    AppDialog.show<void>(
                      context: context,
                      title: 'تأكيد العملية المحاسبية',
                      description:
                          'هل تريد ترحيل قيد اليومية رقم 2026-001 إلى دفتر الأستاذ العام؟',
                      confirmLabel: 'ترحيل',
                      cancelLabel: 'إلغاء',
                      child: const Text('تفاصيل إضافية للعملية'),
                    );
                  },
                );
              },
            ),
            textDirection: TextDirection.rtl,
          ),
        );

        await tester.tap(find.text('فتح الحوار'));
        await tester.pumpAndSettle();

        expect(find.text('تأكيد العملية المحاسبية'), findsOneWidget);
        expect(find.text('ترحيل'), findsOneWidget);
        expect(find.text('إلغاء'), findsOneWidget);

        await tester.tap(find.text('إلغاء'));
        await tester.pumpAndSettle();

        expect(find.text('تأكيد العملية المحاسبية'), findsNothing);
      },
    );

    testWidgets(
      'Accessibility & Text Scaling: Dialog renders at 200% text scale without overflow',
      (tester) async {
        tester.view.physicalSize = const Size(1200, 1400);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);

        await tester.pumpWidget(
          buildTestApp(
            Builder(
              builder: (context) {
                return MediaQuery(
                  data: MediaQuery.of(
                    context,
                  ).copyWith(textScaler: const TextScaler.linear(2.0)),
                  child: Builder(
                    builder: (ctx) {
                      return AppButton(
                        label: 'Open Scaled Dialog',
                        onPressed: () {
                          AppDialog.show<void>(
                            context: ctx,
                            title: 'High Contrast Alert',
                            description:
                                'This is an accessible alert dialog rendered at double font scale factor.',
                            child: const Text('Accessible Content Area'),
                          );
                        },
                      );
                    },
                  ),
                );
              },
            ),
          ),
        );

        await tester.tap(find.text('Open Scaled Dialog'));
        await tester.pumpAndSettle();

        expect(find.text('High Contrast Alert'), findsOneWidget);
        expect(tester.takeException(), isNull);

        await tester.tap(find.text('Cancel'));
        await tester.pumpAndSettle();

        expect(find.text('High Contrast Alert'), findsNothing);
      },
    );

    test(
      'Static Guardrail: AppFormDialog delegates to AppDialog without raw showDialog or Navigator.pop',
      () {
        final fileCandidate1 = File(
          'packages/nexabiz_ui/lib/src/widgets/app_form_dialog.dart',
        );
        final fileCandidate2 = File('lib/src/widgets/app_form_dialog.dart');
        final file = fileCandidate1.existsSync()
            ? fileCandidate1
            : fileCandidate2;
        expect(
          file.existsSync(),
          isTrue,
          reason: 'app_form_dialog.dart must exist',
        );
        final content = file.readAsStringSync();
        expect(
          content.contains('showDialog<T>'),
          isFalse,
          reason:
              'AppFormDialog must delegate to AppDialog.show, not Flutter showDialog',
        );
        expect(
          content.contains('Navigator.of(context).pop'),
          isFalse,
          reason: 'AppFormDialog must not call raw Navigator.pop',
        );
      },
    );
  });
}
