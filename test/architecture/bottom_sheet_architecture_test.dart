import 'dart:io';
import 'package:flutter_test/flutter_test.dart';

const _forbiddenApis = {
  'showModalBottomSheet',
  'showCupertinoModalPopup',
  'CupertinoActionSheet',
};

// No analyzer package is available in this project's dependency graph. This
// lexical check recognizes calls, generic calls, explicit import/export show
// combinators, and tear-offs/type references; it discards comments and string
// text but inspects string interpolation expressions. It does not resolve names:
// a local function with the same name is conservatively rejected, and an API
// hidden behind a differently named re-export cannot be identified here.
Set<String> _forbiddenUsages(String source) {
  final tokens = _DartCodeTokens(source).read();
  final found = <String>{};
  bool directive = false;
  bool showing = false;
  for (var i = 0; i < tokens.length; i++) {
    final token = tokens[i];
    if (token == 'import' || token == 'export') directive = true;
    if (token == ';') {
      directive = false;
      showing = false;
    }
    if (directive && token == 'show') showing = true;
    if (directive && token == 'hide') showing = false;
    if (!_forbiddenApis.contains(token)) continue;
    if (directive) {
      if (showing) found.add(token);
      continue;
    }
    final next = i + 1 < tokens.length ? tokens[i + 1] : '';
    // '<' includes generic invocations and generic function tear-offs.
    if (next == '(' ||
        next == '<' ||
        {';', ',', ')', ']', '}', '?', '='}.contains(next)) {
      found.add(token);
    }
  }
  return found;
}

class _DartCodeTokens {
  final String source;
  final List<String> _tokens = [];
  int _index = 0;

  _DartCodeTokens(this.source);

  List<String> read() {
    _code();
    return _tokens;
  }

  bool _identifier(String character) =>
      RegExp(r'[a-zA-Z0-9_$]').hasMatch(character);

  void _code({bool interpolation = false}) {
    var braces = 0;
    while (_index < source.length) {
      if (source.startsWith('//', _index)) {
        final newline = source.indexOf('\n', _index);
        _index = newline < 0 ? source.length : newline + 1;
        continue;
      }
      if (source.startsWith('/*', _index)) {
        _index += 2;
        var depth = 1;
        while (_index < source.length && depth > 0) {
          if (source.startsWith('/*', _index)) {
            depth++;
            _index += 2;
          } else if (source.startsWith('*/', _index)) {
            depth--;
            _index += 2;
          } else {
            _index++;
          }
        }
        continue;
      }
      final character = source[_index];
      if (character == 'r' &&
          _index + 1 < source.length &&
          (source[_index + 1] == "'" || source[_index + 1] == '"')) {
        _index++;
        _string(raw: true);
      } else if (character == "'" || character == '"') {
        _string();
      } else if (interpolation && character == '}' && braces == 0) {
        _index++;
        return;
      } else if (_identifier(character)) {
        final start = _index++;
        while (_index < source.length && _identifier(source[_index])) {
          _index++;
        }
        _tokens.add(source.substring(start, _index));
      } else {
        if (character == '{') braces++;
        if (character == '}') braces--;
        if (character.trim().isNotEmpty) _tokens.add(character);
        _index++;
      }
    }
  }

  void _string({bool raw = false}) {
    final quote = source[_index];
    final triple = '$quote$quote$quote';
    final delimiter = source.startsWith(triple, _index) ? triple : quote;
    _index += delimiter.length;
    while (_index < source.length) {
      if (source.startsWith(delimiter, _index)) {
        _index += delimiter.length;
        return;
      }
      if (!raw && source[_index] == '\\') {
        _index += 2;
        continue;
      }
      if (!raw && source.startsWith(r'${', _index)) {
        _index += 2;
        _code(interpolation: true);
        continue;
      }
      _index++;
    }
  }
}

void main() {
  group('NexaBiz Bottom Sheet Architecture Guardrail Tests', () {
    for (final source in [
      'showModalBottomSheet(context: context, builder: builder);',
      'material.showModalBottomSheet<void>(context: context, builder: builder);',
      'showModalBottomSheet /* explanatory comment */ (context: context);',
      "import 'package:flutter/material.dart' show showModalBottomSheet;",
      'final opener = material.showModalBottomSheet;',
      r'''final text = '${showModalBottomSheet(context: context)}';''',
    ]) {
      test('rejects actual Material bottom sheet usage: $source', () {
        expect(_forbiddenUsages(source), contains('showModalBottomSheet'));
      });
    }

    test('ignores prose, comments, documentation and string literals', () {
      const source = r"""
// Never call showModalBottomSheet(...).
/// Documentation: showModalBottomSheet is forbidden.
/* showModalBottomSheet(context: context); /* nested */ */
const prose = 'Absolutely NO Material showModalBottomSheet.';
const codeExample = 'showModalBottomSheet(context: context);';
const escaped = 'quote: \' showModalBottomSheet(...)';
const raw = r'${showModalBottomSheet(...)}';
const multiline = '''showModalBottomSheet(...)
showCupertinoModalPopup(...)
CupertinoActionSheet(...)''';
""";
      expect(_forbiddenUsages(source), isEmpty);
    });

    test('retains the prohibition on Cupertino sheet APIs', () {
      expect(
        _forbiddenUsages('showCupertinoModalPopup(context: context);'),
        contains('showCupertinoModalPopup'),
      );
      expect(
        _forbiddenUsages('const CupertinoActionSheet();'),
        contains('CupertinoActionSheet'),
      );
    });

    test('permits imports that explicitly hide forbidden APIs', () {
      expect(
        _forbiddenUsages(
          "import 'package:flutter/material.dart' hide showModalBottomSheet;",
        ),
        isEmpty,
      );
    });
    test(
      'Ensures zero Material showModalBottomSheet calls exist in presentation code',
      () {
        final libDir = Directory('lib');

        final violations = <String>[];

        void scanDirectory(Directory dir) {
          if (!dir.existsSync()) return;
          for (final entity in dir.listSync(recursive: true)) {
            if (entity is File && entity.path.endsWith('.dart')) {
              for (final symbol in _forbiddenUsages(
                entity.readAsStringSync(),
              )) {
                violations.add('${entity.path}: forbidden API usage $symbol');
              }
            }
          }
        }

        scanDirectory(libDir);
        final packagesDir = Directory('packages');
        if (packagesDir.existsSync()) {
          for (final package in packagesDir.listSync().whereType<Directory>()) {
            scanDirectory(Directory('${package.path}/lib'));
          }
        }

        expect(
          violations,
          isEmpty,
          reason:
              'Forbidden bottom sheet APIs found! Reusable presentation code MUST compose shadcn_flutter bottom sheets exclusively.',
        );
      },
    );
  });
}
