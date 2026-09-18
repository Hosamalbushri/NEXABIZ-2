import 'package:flutter/material.dart' show Icons;
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nexabiz_ui/nexabiz_ui.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shadcn;

Widget fieldApp(
  Widget child,
  double width,
  double scale,
  TextDirection direction,
) {
  return NexaBizRootApp(
    home: Builder(
      builder: (context) => MediaQuery(
        data: MediaQuery.of(
          context,
        ).copyWith(textScaler: TextScaler.linear(scale)),
        child: Directionality(
          textDirection: direction,
          child: Align(
            alignment: Alignment.topCenter,
            child: SizedBox(
              width: width,
              child: SingleChildScrollView(child: child),
            ),
          ),
        ),
      ),
    ),
  );
}

void main() {
  const labels = [
    'Account',
    'الحساب',
    'Customer account reference and settlement details',
    'مرجع حساب العميل وتفاصيل التسوية المالية',
  ];
  for (final width in [280.0, 320.0, 360.0, 600.0, 1024.0]) {
    for (final scale in [1.0, 1.3, 2.0]) {
      for (final direction in TextDirection.values) {
        testWidgets(
          'field $width scale $scale $direction wraps labels and retains control width',
          (tester) async {
            // A real expanded viewport is used only for the 1024px matrix entry.
            tester.view.devicePixelRatio = 1;
            tester.view.physicalSize = Size(width, 600);
            addTearDown(tester.view.resetPhysicalSize);
            addTearDown(tester.view.resetDevicePixelRatio);
            for (final label in labels) {
              for (final error in [false, true]) {
                await tester.pumpWidget(
                  fieldApp(
                    AppFieldShell(
                      label: label,
                      required: true,
                      helperText:
                          'Helpful account information / معلومات الحساب',
                      errorText: error
                          ? 'Please verify account information / تحقق من الحساب'
                          : null,
                      prefix: const Icon(Icons.search, size: 18),
                      suffix: const Icon(Icons.check, size: 18),
                      child: const SizedBox(
                        key: ValueKey('control'),
                        height: 24,
                      ),
                    ),
                    width,
                    scale,
                    direction,
                  ),
                );
                await tester.pumpAndSettle();
                expect(tester.takeException(), isNull);
                expect(
                  tester.getSize(find.byKey(const ValueKey('control'))).width,
                  greaterThan(width / 2),
                );
                expect(find.text('*'), findsOneWidget);
                final paragraph = tester.renderObject<RenderParagraph>(
                  find.text(label),
                );
                final boxes = paragraph.getBoxesForSelection(
                  TextSelection(baseOffset: 0, extentOffset: label.length),
                );
                // Wrapping may split words across lines, but never one character per line.
                expect(boxes.length, lessThan(label.length / 2));
                expect(paragraph.didExceedMaxLines, isFalse);
                expect(
                  find.text(
                    error
                        ? 'Please verify account information / تحقق من الحساب'
                        : 'Helpful account information / معلومات الحساب',
                  ),
                  findsOneWidget,
                );
              }
            }
          },
        );
      }
    }
  }

  testWidgets(
    'shell preserves focus, error semantics, disabled and read-only taps',
    (tester) async {
      final focus = FocusNode();
      addTearDown(focus.dispose);
      var taps = 0;
      for (final state in [(true, false), (false, false), (true, true)]) {
        await tester.pumpWidget(
          fieldApp(
            AppFieldShell(
              label: labels.last,
              required: true,
              errorText: 'Invalid account',
              enabled: state.$1,
              readOnly: state.$2,
              focusNode: focus,
              onTap: () => taps++,
              child: const SizedBox(
                key: ValueKey('control'),
                height: 24,
                child: ColoredBox(color: Color(0x00000000)),
              ),
            ),
            280,
            2,
            TextDirection.rtl,
          ),
        );
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        await tester.tap(find.byKey(const ValueKey('control')));
        await tester.pumpAndSettle();
        expect(taps, 1);
        final semantics = tester
            .widgetList<Semantics>(
              find.descendant(
                of: find.byType(AppFieldShell),
                matching: find.byType(Semantics),
              ),
            )
            .firstWhere((s) => s.properties.label == labels.last);
        expect(semantics.properties.enabled, state.$1);
        expect(semantics.properties.readOnly, state.$2);
        expect(semantics.properties.hint, 'Invalid account');
      }
      focus.requestFocus();
      await tester.pump();
      expect(focus.hasFocus, isTrue);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox());
    },
  );

  testWidgets(
    'direct text and select consumers remain editable and selectable',
    (tester) async {
      final controller = TextEditingController();
      addTearDown(controller.dispose);
      await tester.pumpWidget(
        fieldApp(
          AppTextField(
            controller: controller,
            label: labels.last,
            required: true,
          ),
          280,
          2,
          TextDirection.rtl,
        ),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      await tester.enterText(find.byType(shadcn.TextField), 'ABC');
      await tester.pumpAndSettle();
      expect(controller.text, 'ABC');
      expect(tester.takeException(), isNull);
      final focus = FocusNode();
      addTearDown(focus.dispose);
      await tester.pumpWidget(
        fieldApp(
          AppTextField(
            controller: controller,
            focusNode: focus,
            label: labels.last,
          ),
          280,
          2,
          TextDirection.rtl,
        ),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      focus.requestFocus();
      await tester.pumpAndSettle();
      expect(focus.hasFocus, isTrue);
      expect(tester.takeException(), isNull);
      String? selected;
      await tester.pumpWidget(
        fieldApp(
          AppSelectField<String>(
            value: null,
            label: labels[1],
            required: true,
            hint: 'Select',
            items: const [AppSelectItem(value: 'cash', label: 'Cash')],
            onChanged: (value) => selected = value,
          ),
          280,
          2,
          TextDirection.ltr,
        ),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      await tester.tap(find.text('Select'));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      await tester.tap(find.text('Cash'));
      await tester.pumpAndSettle();
      expect(selected, 'cash');
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox());
    },
  );

  testWidgets(
    'search, number and date remain compatible with the field shell change',
    (tester) async {
      final controller = TextEditingController();
      addTearDown(controller.dispose);
      var cleared = 0;
      for (final direction in TextDirection.values) {
        await tester.pumpWidget(
          fieldApp(
            AppSearchField(controller: controller, onClear: () => cleared++),
            280,
            2,
            direction,
          ),
        );
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        await tester.enterText(find.byType(shadcn.TextField), 'ledger');
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        expect(controller.text, 'ledger');
        await tester.tap(find.byIcon(Icons.close_rounded));
        await tester.pumpAndSettle();
        expect(controller.text, isEmpty);
        expect(tester.takeException(), isNull);
        await tester.pumpWidget(
          fieldApp(
            const AppNumberField(label: 'Amount', value: 15),
            280,
            2,
            direction,
          ),
        );
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        expect(find.text('Amount'), findsOneWidget);
        await tester.pumpWidget(
          fieldApp(
            AppDateField(
              label: 'Date',
              hint: 'Date',
              value: null,
              onChanged: (_) {},
            ),
            280,
            2,
            direction,
          ),
        );
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        expect(find.byType(shadcn.DatePicker), findsOneWidget);
      }
      expect(cleared, 2);
      await tester.pumpWidget(const SizedBox());
    },
  );
}
