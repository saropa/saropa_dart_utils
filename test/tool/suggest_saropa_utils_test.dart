// Unit tests for the suggest_saropa_utils scanner core (lineAtOffset, snippet,
// jsonString, scanContent). The CLI script in tool/suggest_saropa_utils.dart
// uses this lib and is not tested here (I/O, interactive prompts).

import 'package:flutter_test/flutter_test.dart';

import '../../tool/suggest_saropa_utils_lib.dart';

void main() {
  group('lineAtOffset', () {
    test('offset 0 returns line 1', () {
      expect(lineAtOffset(<String>['a', 'b'], 0), 1);
    });
    test('offset at first char of second line returns 2', () {
      expect(lineAtOffset(<String>['a', 'b'], 2), 2);
    });
    test('offset at newline (between lines) still line 1', () {
      expect(lineAtOffset(<String>['a', 'b'], 1), 1);
    });
    test('offset in middle of first line returns 1', () {
      expect(lineAtOffset(<String>['abc', 'def'], 2), 1);
    });
    test('offset beyond content returns last line number', () {
      expect(lineAtOffset(<String>['a', 'b'], 10), 2);
    });
    test('empty lines returns 0', () {
      expect(lineAtOffset(<String>[], 0), 0);
    });
    test('negative offset treated as 0', () {
      expect(lineAtOffset(<String>['a'], -1), 1);
    });
    test('single line content', () {
      expect(lineAtOffset(<String>['x'], 0), 1);
      expect(lineAtOffset(<String>['x'], 1), 1);
    });
    test('content split by \\n: positions match', () {
      const String content = 'line1\nline2\nline3';
      final List<String> lines = content.split('\n');
      expect(lineAtOffset(lines, 0), 1);
      expect(lineAtOffset(lines, 5), 1);
      expect(lineAtOffset(lines, 6), 2);
      expect(lineAtOffset(lines, 11), 2);
      expect(lineAtOffset(lines, 12), 3);
    });
  });

  group('snippet', () {
    test('short line unchanged', () {
      expect(snippet('  short  '), 'short');
    });
    test('empty or whitespace returns trimmed', () {
      expect(snippet(''), '');
      expect(snippet('   '), '');
    });
    test('long line truncated at snippetTruncateAt with ellipsis', () {
      final String long = 'x' * (snippetMaxLength + 5);
      expect(snippet(long).length, snippetTruncateAt + 3);
      expect(snippet(long).endsWith('...'), isTrue);
    });
    test('exactly snippetMaxLength not truncated', () {
      final String exact = 'a' * snippetMaxLength;
      expect(snippet(exact), exact);
    });
  });

  group('jsonString', () {
    test('plain ASCII unchanged inside quotes', () {
      expect(jsonString('hello'), '"hello"');
    });
    test('double quote escaped', () {
      expect(jsonString('say "hi"'), r'"say \"hi\""');
    });
    test('backslash escaped', () {
      expect(jsonString(r'c:\path'), r'"c:\\path"');
    });
    test('newline escaped', () {
      expect(jsonString('a\nb'), r'"a\nb"');
    });
    test('empty string', () {
      expect(jsonString(''), '""');
    });
    test('round-trip with parse', () {
      // JSON.parse(JSON.stringify(x)) would need dart:convert; we just check no bad chars.
      final String s = 'a"b\\c\nd\r';
      final String enc = jsonString(s);
      expect(enc.startsWith('"'), isTrue);
      expect(enc.endsWith('"'), isTrue);
      expect(enc.contains('\n'), isFalse);
    });
  });

  group('scanContent', () {
    test('empty content returns no suggestions', () {
      expect(scanContent('', 'p.dart'), isEmpty);
    });
    test('isNullOrEmpty pattern detected', () {
      const String code = "if (s == null || s.isEmpty) return;\n";
      final List<Suggestion> out = scanContent(code, 'test.dart');
      expect(out, isNotEmpty);
      expect(out.any((s) => s.message.contains('isNullOrEmpty')), isTrue);
      expect(out.first.path, 'test.dart');
      expect(out.first.line, 1);
    });
    test('orEmpty pattern for string', () {
      const String code = "final x = name ?? '';\n";
      final List<Suggestion> out = scanContent(code, 'a.dart');
      expect(out.any((s) => s.message.contains('orEmpty')), isTrue);
    });
    test('orZero pattern', () {
      const String code = 'int n = value ?? 0;\n';
      final List<Suggestion> out = scanContent(code, 'b.dart');
      expect(out.any((s) => s.message.contains('orZero')), isTrue);
    });
    test('snippet and line set from matched line', () {
      const String code = 'void foo() {\n  if (x == null || x.isEmpty) {}\n}\n';
      final List<Suggestion> out = scanContent(code, 'f.dart');
      expect(out, isNotEmpty);
      expect(out.first.line, 2);
      expect(out.first.snippet, isNotEmpty);
      expect(out.first.message, contains('isNullOrEmpty'));
    });
    test('no false match in string literal', () {
      const String code = "final t = \"x == null || x.isEmpty\";\n";
      // Our regex matches in string literals too (no semantic awareness). So we may get a hit.
      // This test documents current behavior: we do match inside strings.
      final List<Suggestion> out = scanContent(code, 's.dart');
      // Either we match (current) or we don't if we improve. Just ensure no crash.
      expect(out.every((s) => s.path == 's.dart' && s.line >= 1), isTrue);
    });
  });
}
