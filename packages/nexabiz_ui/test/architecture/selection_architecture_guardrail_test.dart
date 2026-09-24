import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:nexabiz_ui/nexabiz_ui.dart';

void main() {
  group('Phase 05 Selection Architecture Guardrail Tests', () {
    test('Rule 1: AppSelectOption is the sole canonical option model', () {
      const option = AppSelectOption<int>(
        value: 10,
        label: 'Ten',
        subtitle: 'Number 10',
        keywords: ['digit', '١٠'],
      );

      // Value identity and query matching
      expect(option.matchesQuery('ten'), isTrue);
      expect(option.matchesQuery('TEN'), isTrue);
      expect(option.matchesQuery('number'), isTrue);
      expect(option.matchesQuery('digit'), isTrue);
      expect(
        option.matchesQuery('10'),
        isTrue,
      ); // Arabic digit normalization in keywords
      expect(option.matchesQuery('xyz'), isFalse);
    });

    test(
      'Rule 3: Zero Material visual selection controls in selection widgets',
      () {
        final selectionFiles = [
          'packages/nexabiz_ui/lib/src/widgets/app_select_field.dart',
          'packages/nexabiz_ui/lib/src/widgets/app_searchable_select.dart',
          'packages/nexabiz_ui/lib/src/widgets/app_multi_select_field.dart',
          'packages/nexabiz_ui/lib/src/widgets/app_async_autocomplete_field.dart',
          'packages/nexabiz_ui/lib/src/widgets/app_selection_foundation.dart',
        ];

        final forbiddenPatterns = [
          'package:flutter/material.dart',
          'DropdownButton',
          'DropdownMenu',
          'Autocomplete<',
          'InkWell',
          'ListTile',
        ];

        for (final path in selectionFiles) {
          final file = File(path);
          final content = file.existsSync()
              ? file.readAsStringSync()
              : File(
                  path.replaceFirst('packages/nexabiz_ui/', ''),
                ).readAsStringSync();

          for (final pattern in forbiddenPatterns) {
            expect(
              content.contains(pattern),
              isFalse,
              reason: '$path contains forbidden Material pattern: $pattern',
            );
          }

          expect(
            RegExp(
              r'(?<!shadcn\.)CircularProgressIndicator\(',
            ).hasMatch(content),
            isFalse,
            reason: '$path must use shadcn.CircularProgressIndicator',
          );
        }
      },
    );

    test(
      'Rule 4: All form-style selection widgets instantiate AppFieldShell',
      () {
        final formSelectionFiles = [
          'packages/nexabiz_ui/lib/src/widgets/app_select_field.dart',
          'packages/nexabiz_ui/lib/src/widgets/app_searchable_select.dart',
          'packages/nexabiz_ui/lib/src/widgets/app_multi_select_field.dart',
          'packages/nexabiz_ui/lib/src/widgets/app_async_autocomplete_field.dart',
        ];

        for (final path in formSelectionFiles) {
          final file = File(path);
          final content = file.existsSync()
              ? file.readAsStringSync()
              : File(
                  path.replaceFirst('packages/nexabiz_ui/', ''),
                ).readAsStringSync();

          final usesShell = content.contains('AppFieldShell(');
          expect(
            usesShell,
            isTrue,
            reason: '$path must compose AppFieldShell for form presentation',
          );
        }
      },
    );
  });
}
