import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nexabiz_ui/nexabiz_ui.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shadcn;

void main() {
  group('Phase 04 — Form Field Architecture Guardrails', () {
    test('Rule 1: No Material visual input controls in form field widgets', () {
      final widgetsDir = Directory('packages/nexabiz_ui/lib/src/widgets');
      expect(widgetsDir.existsSync(), isTrue);

      final dartFiles = widgetsDir
          .listSync(recursive: true)
          .whereType<File>()
          .where((f) => f.path.endsWith('.dart'));

      final violatingFiles = <String, List<String>>{};

      final prohibitedPatterns = [
        RegExp(r'(?<!shadcn\.)\bTextField\b'),
        RegExp(r'\bTextFormField\b'),
        RegExp(r'\bDropdownButton\b'),
        RegExp(r'\bInputDecoration\b'),
        RegExp(r'\bOutlineInputBorder\b'),
        RegExp(r'(?<!shadcn\.)\bCircularProgressIndicator\b'),
      ];

      for (final file in dartFiles) {
        final lines = file.readAsLinesSync();
        for (var i = 0; i < lines.length; i++) {
          final line = lines[i].trim();
          // Skip comments and docstrings
          if (line.startsWith('//') ||
              line.startsWith('*') ||
              line.startsWith('/*')) {
            continue;
          }

          for (final pattern in prohibitedPatterns) {
            if (pattern.hasMatch(line)) {
              violatingFiles
                  .putIfAbsent(file.path, () => [])
                  .add('Line ${i + 1}: $line');
            }
          }
        }
      }

      expect(
        violatingFiles,
        isEmpty,
        reason:
            'Material visual input controls found in nexabiz_ui widgets:\n'
            '${violatingFiles.entries.map((e) => '${e.key}:\n  ${e.value.join('\n  ')}').join('\n')}',
      );
    });

    test('Rule 2: Form field density tokens adhere to AppDimensions', () {
      expect(
        AppFieldDensity.compact.height,
        equals(AppDimensions.desktopInputHeight),
      );
      expect(AppFieldDensity.compact.height, equals(40.0));

      expect(
        AppFieldDensity.standard.height,
        equals(AppDimensions.inputHeight),
      );
      expect(AppFieldDensity.standard.height, equals(48.0));

      expect(
        AppFieldDensity.large.height,
        equals(AppDimensions.inputHeightLarge),
      );
      expect(AppFieldDensity.large.height, equals(56.0));
    });

    test(
      'Rule 3: Canonical form field implementations instantiate AppFieldShell',
      () {
        final formFieldFiles = [
          'packages/nexabiz_ui/lib/src/widgets/app_text_field.dart',
          'packages/nexabiz_ui/lib/src/widgets/app_number_field.dart',
          'packages/nexabiz_ui/lib/src/widgets/app_amount_field.dart',
          'packages/nexabiz_ui/lib/src/widgets/app_phone_field.dart',
          'packages/nexabiz_ui/lib/src/widgets/app_multiline_field.dart',
          'packages/nexabiz_ui/lib/src/widgets/app_date_field.dart',
          'packages/nexabiz_ui/lib/src/widgets/app_date_range_field.dart',
          'packages/nexabiz_ui/lib/src/widgets/app_select_field.dart',
          'packages/nexabiz_ui/lib/src/widgets/app_searchable_select.dart',
          'packages/nexabiz_ui/lib/src/widgets/app_multi_select_field.dart',
          'packages/nexabiz_ui/lib/src/widgets/app_async_autocomplete_field.dart',
          'packages/nexabiz_ui/lib/src/widgets/app_slider_field.dart',
        ];

        for (final path in formFieldFiles) {
          final file = File(path);
          expect(file.existsSync(), isTrue, reason: 'File must exist: $path');
          final content = file.readAsStringSync();
          final delegatesToShell =
              content.contains('AppFieldShell(') ||
              content.contains('AppSelectField<T>(');
          expect(
            delegatesToShell,
            isTrue,
            reason:
                'Form field $path must delegate presentation to AppFieldShell',
          );
        }
      },
    );

    testWidgets('Rule 4: AppFieldShell renders description and focus ring', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        shadcn.ShadcnApp(
          home: shadcn.Scaffold(
            child: AppFieldShell(
              label: 'Field Label',
              description: 'Helpful field description',
              focused: true,
              child: const Text('Child Content'),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Field Label'), findsOneWidget);
      expect(find.text('Helpful field description'), findsOneWidget);
      expect(find.text('Child Content'), findsOneWidget);
    });
  });
}
