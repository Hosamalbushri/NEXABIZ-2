import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nexabiz_ui/nexabiz_ui.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shadcn;

void main() {
  group('Phase 09 Architecture Guardrails: Static Code Inspection', () {
    final libSrc = Directory('packages/nexabiz_ui/lib/src');

    test(
      'GUARD-01: Zero isRtl string selection ternaries in production code',
      () {
        final isRtlTernaryRe = RegExp(r'isRtl\s*\?\s*[\x27\x22]');
        final violations = <String>[];

        for (final entity in libSrc.listSync(recursive: true)) {
          if (entity is File && entity.path.endsWith('.dart')) {
            final lines = entity.readAsLinesSync();
            for (var i = 0; i < lines.length; i++) {
              if (isRtlTernaryRe.hasMatch(lines[i])) {
                violations.add('${entity.path}:${i + 1}: ${lines[i].trim()}');
              }
            }
          }
        }

        expect(
          violations,
          isEmpty,
          reason:
              'Language must not be inferred from text directionality via isRtl: $violations',
        );
      },
    );

    test(
      'GUARD-02: Zero hardcoded Arabic literals in UI components and layouts',
      () {
        final arabicRe = RegExp(r'[\u0600-\u06FF]');
        final violations = <String>[];

        for (final entity in libSrc.listSync(recursive: true)) {
          if (entity is File && entity.path.endsWith('.dart')) {
            // Exclude localization authority and playground demo
            if (entity.path.contains('/localization/') ||
                entity.path.contains('/playground/')) {
              continue;
            }
            final lines = entity.readAsLinesSync();
            for (var i = 0; i < lines.length; i++) {
              final line = lines[i].trim();
              // Ignore comments
              if (line.startsWith('//') ||
                  line.startsWith('/*') ||
                  line.startsWith('*')) {
                continue;
              }
              if (arabicRe.hasMatch(line)) {
                violations.add('${entity.path}:${i + 1}: $line');
              }
            }
          }
        }

        expect(
          violations,
          isEmpty,
          reason:
              'All UI components must source Arabic strings via NexaBizUiLocalizations: $violations',
        );
      },
    );

    test(
      'GUARD-03: Directional geometry in Sidebar, Tree, and Editable Table',
      () {
        final sidebarFile = File(
          'packages/nexabiz_ui/lib/src/widgets/app_sidebar.dart',
        );
        final treeFile = File(
          'packages/nexabiz_ui/lib/src/widgets/app_tree.dart',
        );
        final tableFile = File(
          'packages/nexabiz_ui/lib/src/widgets/app_editable_table_shell.dart',
        );

        expect(sidebarFile.existsSync(), isTrue);
        expect(treeFile.existsSync(), isTrue);
        expect(tableFile.existsSync(), isTrue);

        final sidebarContent = sidebarFile.readAsStringSync();
        expect(sidebarContent, contains('BorderDirectional'));
        expect(sidebarContent, isNot(contains('Border(right:')));

        final treeContent = treeFile.readAsStringSync();
        expect(treeContent, contains('EdgeInsetsDirectional.only(start:'));

        final tableContent = tableFile.readAsStringSync();
        expect(tableContent, contains('AlignmentDirectional.centerStart'));
      },
    );
  });

  group('Phase 09 Architecture Guardrails: Decoupling RTL != Arabic', () {
    testWidgets(
      'Non-Arabic RTL (Hebrew, Farsi) falls back to English, NOT Arabic',
      (tester) async {
        await tester.pumpWidget(
          shadcn.ShadcnApp(
            home: Localizations(
              locale: const Locale('he'),
              delegates: const [
                NexaBizUiLocalizations.delegate,
                DefaultWidgetsLocalizations.delegate,
                DefaultMaterialLocalizations.delegate,
              ],
              child: Directionality(
                textDirection: TextDirection.rtl,
                child: Builder(
                  builder: (context) {
                    final loc = NexaBizUiLocalizations.of(context);
                    return Scaffold(
                      body: Column(
                        children: [
                          Text(loc.save, key: const ValueKey('save_label')),
                          Text(loc.cancel, key: const ValueKey('cancel_label')),
                          Text(
                            loc.searchHint,
                            key: const ValueKey('search_hint'),
                          ),
                          AppFormActions(onSubmit: () {}, onCancel: () {}),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // In Hebrew RTL, UI tokens must be English, not Arabic
        expect(find.text('Save'), findsWidgets);
        expect(find.text('Cancel'), findsWidgets);
        expect(find.text('Search...'), findsOneWidget);
        expect(find.text('حفظ'), findsNothing);
        expect(find.text('إلغاء'), findsNothing);
      },
    );

    testWidgets('Arabic RTL renders Arabic strings properly', (tester) async {
      await tester.pumpWidget(
        shadcn.ShadcnApp(
          home: Localizations(
            locale: const Locale('ar'),
            delegates: const [
              NexaBizUiLocalizations.delegate,
              DefaultWidgetsLocalizations.delegate,
              DefaultMaterialLocalizations.delegate,
            ],
            child: Directionality(
              textDirection: TextDirection.rtl,
              child: Builder(
                builder: (context) {
                  final loc = NexaBizUiLocalizations.of(context);
                  return Scaffold(
                    body: Column(
                      children: [
                        Text(loc.save, key: const ValueKey('save_label')),
                        Text(loc.cancel, key: const ValueKey('cancel_label')),
                        AppFormActions(onSubmit: () {}, onCancel: () {}),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('حفظ'), findsWidgets);
      expect(find.text('إلغاء'), findsWidgets);
      expect(find.text('Save'), findsNothing);
    });

    testWidgets(
      'Non-English LTR (French) renders cleanly with English fallback',
      (tester) async {
        await tester.pumpWidget(
          shadcn.ShadcnApp(
            home: Localizations(
              locale: const Locale('fr'),
              delegates: const [
                NexaBizUiLocalizations.delegate,
                DefaultWidgetsLocalizations.delegate,
                DefaultMaterialLocalizations.delegate,
              ],
              child: Directionality(
                textDirection: TextDirection.ltr,
                child: Builder(
                  builder: (context) {
                    final loc = NexaBizUiLocalizations.of(context);
                    return Text(loc.confirm);
                  },
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('Confirm'), findsOneWidget);
      },
    );
  });

  group('Phase 09 Architecture Guardrails: Accessibility Hardening', () {
    testWidgets(
      'AppIconButton enforces min 48px touch target and specific accessible name',
      (tester) async {
        await tester.pumpWidget(
          shadcn.ShadcnApp(
            locale: const Locale('en'),
            localizationsDelegates: const [
              NexaBizUiLocalizations.delegate,
              DefaultWidgetsLocalizations.delegate,
              DefaultMaterialLocalizations.delegate,
            ],
            home: Scaffold(
              body: Center(
                child: AppIconButton(
                  icon: Icons.add,
                  onPressed: () {},
                  semanticLabel: 'Add invoice',
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Minimum touch target 48x48
        final buttonSize = tester.getSize(find.byType(AppIconButton));
        expect(buttonSize.width, greaterThanOrEqualTo(48.0));
        expect(buttonSize.height, greaterThanOrEqualTo(48.0));

        // Caller-supplied semantics label exists on AppIconButton Semantics.
        final semanticsFinder = find.descendant(
          of: find.byType(AppIconButton),
          matching: find.byWidgetPredicate(
            (w) => w is Semantics && w.properties.label == 'Add invoice',
          ),
        );
        expect(semanticsFinder, findsOneWidget);
      },
    );

    testWidgets(
      'AppFieldShell required field announces Required and error banner has liveRegion',
      (tester) async {
        await tester.pumpWidget(
          shadcn.ShadcnApp(
            locale: const Locale('en'),
            localizationsDelegates: const [
              NexaBizUiLocalizations.delegate,
              DefaultWidgetsLocalizations.delegate,
              DefaultMaterialLocalizations.delegate,
            ],
            home: const Scaffold(
              body: AppFieldShell(
                label: 'Account Code',
                required: true,
                errorText: 'Account code is invalid',
                child: SizedBox(height: 24),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Asterisk text has semanticsLabel 'Required'
        final asteriskText = tester.widget<Text>(find.text('*'));
        expect(asteriskText.semanticsLabel, 'Required');

        // Error message is inside Semantics with liveRegion
        final liveRegionSemantics = tester
            .widgetList<Semantics>(
              find.descendant(
                of: find.byType(AppFieldShell),
                matching: find.byType(Semantics),
              ),
            )
            .where((s) => s.properties.liveRegion == true);

        expect(liveRegionSemantics, isNotEmpty);
      },
    );

    testWidgets('Form & Fields withstand 200% text scale without overflow', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(800, 1200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        shadcn.ShadcnApp(
          locale: const Locale('en'),
          localizationsDelegates: const [
            NexaBizUiLocalizations.delegate,
            DefaultWidgetsLocalizations.delegate,
            DefaultMaterialLocalizations.delegate,
          ],
          home: MediaQuery(
            data: const MediaQueryData(
              size: Size(800, 1200),
              textScaler: TextScaler.linear(2.0),
            ),
            child: Scaffold(
              body: AppForm(
                title: 'Financial Voucher Entry',
                subtitle: 'Enter balanced debit and credit entries',
                children: [
                  const AppFieldShell(
                    label: 'Voucher Number',
                    required: true,
                    helperText: 'Auto-generated sequence',
                    child: SizedBox(height: 48),
                  ),
                  AppFormActions(onSubmit: () {}, onCancel: () {}),
                ],
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
    });
  });
}
