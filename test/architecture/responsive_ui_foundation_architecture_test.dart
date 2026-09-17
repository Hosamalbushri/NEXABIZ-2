import 'dart:io';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('NexaBiz Responsive UI Foundation Architecture Guardrails', () {
    final rootDir = Directory.current;

    test('All layout containers originate from packages/nexabiz_ui', () {
      final libDir = Directory('${rootDir.path}/lib');
      if (!libDir.existsSync()) return;

      final files = libDir
          .listSync(recursive: true)
          .whereType<File>()
          .where((f) => f.path.endsWith('.dart'));

      for (final file in files) {
        final content = file.readAsStringSync();
        // Disallow custom screen-width MediaQuery checks in feature pages
        final hasArbitraryWidthCheck = RegExp(r'MediaQuery\.of\(context\)\.size\.width\s*[<>]=?\s*\d+').hasMatch(content);
        expect(
          hasArbitraryWidthCheck,
          isFalse,
          reason: 'File ${file.path} contains arbitrary MediaQuery width check. Use AppBreakpoints or AppResponsive instead.',
        );
      }
    });

    test('No unauthorized external UI library imports exist', () {
      final uiDir = Directory('${rootDir.path}/packages/nexabiz_ui');
      if (!uiDir.existsSync()) return;

      final files = uiDir
          .listSync(recursive: true)
          .whereType<File>()
          .where((f) => f.path.endsWith('.dart'));

      for (final file in files) {
        final content = file.readAsStringSync();
        expect(
          content.contains('package:flutter_material/'),
          isFalse,
          reason: 'File ${file.path} imports unauthorized UI package.',
        );
      }
    });
  });
}
