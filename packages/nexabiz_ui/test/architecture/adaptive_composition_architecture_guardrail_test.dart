import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Advanced adaptive composition guardrails', () {
    test('canonical form composition is local and constraint-aware', () {
      final source = _packageFile(
        'lib/src/widgets/app_form.dart',
      ).readAsStringSync();
      final formRow = _classDeclaration(source, 'AppFormRow');

      expect(formRow, contains('LayoutBuilder('));
      expect(formRow, contains('constraints.maxWidth'));
      expect(formRow, contains('AppLayoutTokens.formColumnMinWidth'));
      expect(formRow, contains('fullWidthChildren'));
      expect(formRow, isNot(contains('AppBreakpoints')));
      expect(formRow, isNot(contains('MediaQuery.sizeOf')));
    });

    test('local components do not infer width from the global screen', () {
      const localComponents = <String>[
        'lib/src/widgets/app_form.dart',
        'lib/src/widgets/app_bottom_actions.dart',
        'lib/src/widgets/app_editable_table_shell.dart',
        'lib/src/widgets/app_search_toolbar.dart',
        'lib/src/widgets/app_page_header.dart',
        'lib/src/layout/app_section.dart',
      ];

      for (final path in localComponents) {
        final source = _packageFile(path).readAsStringSync();
        expect(
          RegExp(
            r'MediaQuery(?:\.sizeOf\([^)]*\)|\.of\([^)]*\)\.size)\.width',
          ).hasMatch(source),
          isFalse,
          reason: '$path must use its LayoutBuilder constraints',
        );
      }
    });

    test('form rows in feature code are not rebuilt with field Rows', () {
      final fieldNames = <String>[
        'AppTextField',
        'AppNumberField',
        'AppAmountField',
        'AppSelectField',
        'AppSearchableSelect',
        'AppMultiSelectField',
        'AppDateField',
        'AppDateRangeField',
        'AppPhoneField',
        'AppMultilineField',
        'AppAsyncAutocompleteField',
      ];
      final violations = <String>[];

      for (final file in _dartFiles(Directory('lib'))) {
        final source = file.readAsStringSync();
        for (final row in _constructorInvocations(source, 'Row')) {
          final fieldsInRow = fieldNames
              .where((name) => row.contains('$name('))
              .length;
          if (fieldsInRow > 1) violations.add(file.path);
        }
        for (final formRow in _constructorInvocations(source, 'AppFormRow')) {
          if (formRow.contains('AppBreakpoints') ||
              formRow.contains('MediaQuery')) {
            violations.add(file.path);
          }
        }
      }

      expect(violations, isEmpty);
    });

    test(
      'generic content surfaces expose no fixed content height contract',
      () {
        for (final path in <String>[
          'lib/src/widgets/app_card.dart',
          'lib/src/widgets/app_surface.dart',
          'lib/src/layout/app_section.dart',
        ]) {
          final source = _packageFile(path).readAsStringSync();
          expect(
            RegExp(
              r'\bthis\.height\b|\bfinal\s+double\??\s+height\b',
            ).hasMatch(source),
            isFalse,
            reason: path,
          );
        }
      },
    );

    test('font size is never calculated from available width', () {
      final violations = <String>[];
      for (final file in <File>[
        ..._dartFiles(_packageDirectory('lib')),
        ..._dartFiles(Directory('lib')),
      ]) {
        final source = file.readAsStringSync();
        if (RegExp(
          r'fontSize\s*:[^,;\n]*(?:maxWidth|size\.width|availableWidth)|'
          r'(?:maxWidth|size\.width|availableWidth)[^;\n]*fontSize\s*:',
        ).hasMatch(source)) {
          violations.add(file.path);
        }
      }
      expect(violations, isEmpty);
    });

    test('canonical content text is not shrunk or critically clipped', () {
      for (final path in <String>[
        'lib/src/widgets/app_button.dart',
        'lib/src/widgets/app_form.dart',
        'lib/src/widgets/app_page_header.dart',
        'lib/src/widgets/app_search_toolbar.dart',
        'lib/src/layout/app_section.dart',
      ]) {
        final source = _packageFile(path).readAsStringSync();
        expect(source, isNot(contains('FittedBox(')), reason: path);
        expect(source, isNot(contains('TextOverflow.ellipsis')), reason: path);
      }
    });

    test('unauthorized responsive packages remain absent', () {
      final rootPubspec = File('pubspec.yaml').readAsStringSync();
      final packagePubspec = _packageFile('pubspec.yaml').readAsStringSync();
      for (final dependency in <String>[
        'flutter_screenutil:',
        'responsive_sizer:',
        'sizer:',
      ]) {
        expect(rootPubspec, isNot(contains(dependency)));
        expect(packagePubspec, isNot(contains(dependency)));
      }
    });

    test('duplicate public form layout architectures remain absent', () {
      final library = _dartFiles(
        _packageDirectory('lib'),
      ).map((file) => file.readAsStringSync()).join('\n');
      expect(
        RegExp(
          r'class\s+App(?:FormGrid|FormLayout|AdaptiveForm|ResponsiveForm)\b',
        ).hasMatch(library),
        isFalse,
      );
    });
  });
}

Directory _packageDirectory(String relativePath) {
  final local = Directory(relativePath);
  if (File('pubspec.yaml').readAsStringSync().contains('name: nexabiz_ui')) {
    return local;
  }
  return Directory('packages/nexabiz_ui/$relativePath');
}

File _packageFile(String relativePath) =>
    File('${_packageDirectory('.').path}/$relativePath');

Iterable<File> _dartFiles(Directory directory) sync* {
  if (!directory.existsSync()) return;
  yield* directory
      .listSync(recursive: true)
      .whereType<File>()
      .where((file) => file.path.endsWith('.dart'));
}

String _classDeclaration(String source, String name) {
  final start = source.indexOf('class $name ');
  if (start == -1) return '';
  final nextClass = source.indexOf('\nclass ', start + 1);
  return source.substring(start, nextClass == -1 ? source.length : nextClass);
}

Iterable<String> _constructorInvocations(String source, String name) sync* {
  final marker = '$name(';
  var start = 0;
  while ((start = source.indexOf(marker, start)) != -1) {
    var depth = 0;
    var end = start + marker.length;
    for (; end < source.length; end++) {
      final character = source[end];
      if (character == '(') depth++;
      if (character == ')') {
        if (depth == 0) break;
        depth--;
      }
    }
    yield source.substring(start, end.clamp(start, source.length));
    start = end + 1;
  }
}
