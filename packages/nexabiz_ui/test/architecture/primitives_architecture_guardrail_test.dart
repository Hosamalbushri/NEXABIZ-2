import 'dart:io';

import 'package:flutter/material.dart' show Icons, Scaffold;
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nexabiz_ui/nexabiz_ui.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shadcn;

void main() {
  group('Canonical UI Primitives Architecture Guardrails', () {
    const primitiveFiles = [
      'packages/nexabiz_ui/lib/src/widgets/app_button.dart',
      'packages/nexabiz_ui/lib/src/widgets/app_icon_button.dart',
      'packages/nexabiz_ui/lib/src/widgets/app_card.dart',
      'packages/nexabiz_ui/lib/src/widgets/app_surface.dart',
      'packages/nexabiz_ui/lib/src/widgets/app_separator.dart',
      'packages/nexabiz_ui/lib/src/widgets/app_radio.dart',
      'packages/nexabiz_ui/lib/src/widgets/app_checkbox.dart',
      'packages/nexabiz_ui/lib/src/widgets/app_switch.dart',
      'packages/nexabiz_ui/lib/src/widgets/app_status_badge.dart',
      'packages/nexabiz_ui/lib/src/widgets/app_icon_avatar.dart',
      'packages/nexabiz_ui/lib/src/widgets/app_tooltip.dart',
      'packages/nexabiz_ui/lib/src/widgets/app_view_mode_toggle.dart',
    ];

    test('primitives must not import domain layers or business models', () {
      final domainKeywords = [
        'package:nexabiz/features',
        'domain/',
        'customers/',
        'accounting/',
        'inventory/',
        'sales/',
        'purchases/',
      ];

      for (final path in primitiveFiles) {
        final file = File(path);
        expect(file.existsSync(), isTrue, reason: 'File $path must exist');
        final content = file.readAsStringSync();

        for (final keyword in domainKeywords) {
          expect(
            content.contains(keyword),
            isFalse,
            reason: '$path should not depend on domain keyword "$keyword"',
          );
        }
      }
    });

    test('primitives must not use Material visual authority controls', () {
      final bannedVisualRegexes = [
        RegExp(r'\bElevatedButton\b'),
        RegExp(r'\bTextButton\b'),
        RegExp(r'\bOutlinedButton\b'),
        RegExp(r'\bMaterialButton\b'),
        RegExp(
          r'(?<!shadcn\.)Theme\.of\(context\)',
        ), // Must use shadcn.Theme.of(context)
      ];

      for (final path in primitiveFiles) {
        final file = File(path);
        expect(file.existsSync(), isTrue, reason: 'File $path must exist');
        final content = file.readAsStringSync();

        for (final regex in bannedVisualRegexes) {
          expect(
            regex.hasMatch(content),
            isFalse,
            reason:
                '$path should not contain Material visual pattern "${regex.pattern}"',
          );
        }
      }
    });
  });

  group('Canonical Primitive Widget & Token Integration Tests', () {
    testWidgets('AppSeparator renders horizontal and vertical lines', (
      tester,
    ) async {
      await tester.pumpWidget(
        shadcn.ShadcnApp(
          theme: AppTheme.light(),
          home: const Scaffold(
            body: Column(
              children: [
                AppSeparator(thickness: 2.0),
                AppSeparator.vertical(length: 40.0),
                AppDivider(height: 16.0, thickness: 1.0),
              ],
            ),
          ),
        ),
      );

      expect(find.byType(AppSeparator), findsNWidgets(3));
      expect(find.byType(AppDivider), findsOneWidget);
    });

    testWidgets('AppRadio and AppRadioGroup enforce mutual exclusion', (
      tester,
    ) async {
      String? selected = 'option1';

      await tester.pumpWidget(
        shadcn.ShadcnApp(
          theme: AppTheme.light(),
          home: StatefulBuilder(
            builder: (context, setState) {
              return Scaffold(
                body: AppRadioGroup<String>(
                  value: selected,
                  onChanged: (val) => setState(() => selected = val),
                  children: const [
                    AppRadio(value: 'option1', label: 'Option 1'),
                    AppRadio(value: 'option2', label: 'Option 2'),
                  ],
                ),
              );
            },
          ),
        ),
      );

      expect(find.text('Option 1'), findsOneWidget);
      expect(find.text('Option 2'), findsOneWidget);

      await tester.tap(find.text('Option 2'));
      await tester.pumpAndSettle();

      expect(selected, equals('option2'));
    });

    testWidgets('AppTooltip renders child and wraps with shadcn tooltip', (
      tester,
    ) async {
      await tester.pumpWidget(
        shadcn.ShadcnApp(
          theme: AppTheme.light(),
          home: const Scaffold(
            body: AppTooltip(
              message: 'Action tooltip',
              child: Text('Hover target'),
            ),
          ),
        ),
      );

      expect(find.text('Hover target'), findsOneWidget);
      expect(find.byType(AppTooltip), findsOneWidget);
    });

    testWidgets('AppButton has Semantics with button: true', (tester) async {
      await tester.pumpWidget(
        shadcn.ShadcnApp(
          theme: AppTheme.light(),
          home: Scaffold(
            body: AppButton(label: 'Submit Order', onPressed: () {}),
          ),
        ),
      );

      final semantics = tester.getSemantics(find.byType(AppButton));
      expect(semantics.label, contains('Submit Order'));
      expect(semantics.flagsCollection.isButton, isTrue);
    });

    testWidgets('AppIconButton has Semantics and handles tap', (tester) async {
      bool tapped = false;

      await tester.pumpWidget(
        shadcn.ShadcnApp(
          theme: AppTheme.light(),
          home: Scaffold(
            body: AppIconButton(
              icon: Icons.refresh_rounded,
              tooltip: 'Refresh Data',
              onPressed: () => tapped = true,
            ),
          ),
        ),
      );

      final semantics = tester.getSemantics(find.byType(AppIconButton));
      expect(semantics.label, contains('Refresh Data'));
      expect(semantics.flagsCollection.isButton, isTrue);

      await tester.tap(find.byType(AppIconButton));
      await tester.pumpAndSettle();
      expect(tapped, isTrue);
    });

    testWidgets('AppIconAvatar renders with semantic tone', (tester) async {
      await tester.pumpWidget(
        shadcn.ShadcnApp(
          theme: AppTheme.light(),
          home: const Scaffold(
            body: Column(
              children: [
                AppIconAvatar(
                  icon: Icons.check_circle_rounded,
                  tone: AppIconAvatarTone.success,
                  semanticLabel: 'Success status',
                ),
                AppIconAvatar(
                  icon: Icons.warning_rounded,
                  tone: AppIconAvatarTone.warning,
                ),
                AppIconAvatar(
                  icon: Icons.info_rounded,
                  tone: AppIconAvatarTone.info,
                ),
              ],
            ),
          ),
        ),
      );

      expect(find.byType(AppIconAvatar), findsNWidgets(3));
    });

    testWidgets(
      'AppViewModeToggle switches view selection without Material Theme',
      (tester) async {
        String selectedMode = 'list';

        await tester.pumpWidget(
          shadcn.ShadcnApp(
            theme: AppTheme.light(),
            home: StatefulBuilder(
              builder: (context, setState) {
                return Scaffold(
                  body: AppViewModeToggle<String>(
                    selected: selectedMode,
                    onChanged: (val) => setState(() => selectedMode = val),
                    options: const [
                      AppViewModeOption(
                        value: 'list',
                        icon: Icons.list_rounded,
                        tooltip: 'List View',
                      ),
                      AppViewModeOption(
                        value: 'grid',
                        icon: Icons.grid_view_rounded,
                        tooltip: 'Grid View',
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        );

        expect(find.byType(AppViewModeToggle<String>), findsOneWidget);
        expect(find.byIcon(Icons.list_rounded), findsOneWidget);
        expect(find.byIcon(Icons.grid_view_rounded), findsOneWidget);

        await tester.tap(find.byIcon(Icons.grid_view_rounded));
        await tester.pumpAndSettle();

        expect(selectedMode, equals('grid'));
      },
    );
  });
}
