import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:nexabiz_ui/nexabiz_ui.dart';

void main() {
  group('Page Architecture Contract Tests', () {
    test('Rule A: Canonical Page APIs are publicly exported in nexabiz_ui', () {
      // Verify all 8 canonical page classes can be referenced via public barrel
      expect(AppPage, isNotNull);
      expect(AppListPage, isNotNull);
      expect(AppFormPage, isNotNull);
      expect(AppDetailsPage, isNotNull);
      expect(AppTablePage, isNotNull);
      expect(AppDashboardPage, isNotNull);
      expect(AppSettingsPage, isNotNull);
      expect(AppMasterDetailPage, isNotNull);
    });

    test('Rule D: removed legacy page implementation files stay absent', () {
      const paths = [
        'lib/src/presentation/patterns/app_page_shell.dart',
        'lib/src/presentation/patterns/app_list_page_pattern.dart',
        'lib/src/presentation/patterns/app_form_page_pattern.dart',
        'lib/src/presentation/patterns/app_detail_page_pattern.dart',
        'lib/src/presentation/scaffolds/module_list_scaffold.dart',
        'lib/src/presentation/scaffolds/module_form_scaffold.dart',
      ];

      for (final path in paths) {
        final local = File(path);
        final workspace = File('packages/nexabiz_ui/$path');
        expect(local.existsSync() || workspace.existsSync(), isFalse);
      }
    });
  });
}
