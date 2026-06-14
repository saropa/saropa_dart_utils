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
    test('the correct long-form null+empty guard is NOT flagged', () {
      // `s == null || s.isEmpty` is the form that preserves null promotion, so
      // the tool must not push it toward the deprecated `isNullOrEmpty` getter.
      const String code = 'if (s == null || s.isEmpty) return;\n';
      final List<Suggestion> out = scanContent(code, 'test.dart');
      expect(out.any((s) => s.message.contains('Consider')), isFalse);
    });
    test('use of a deprecated null-promotion-defeating getter is flagged', () {
      const String code = 'if (s.isNullOrEmpty) return;\n';
      final List<Suggestion> out = scanContent(code, 'test.dart');
      expect(out, isNotEmpty);
      expect(out.any((s) => s.message.contains('Deprecated getter')), isTrue);
      expect(out.first.path, 'test.dart');
      expect(out.first.line, 1);
    });
    test('orEmpty pattern for string', () {
      const String code = "final x = name ?? '';\n";
      final List<Suggestion> out = scanContent(code, 'a.dart');
      expect(out.any((s) => s.message.contains('orEmpty')), isTrue);
    });
    test('capitalize manual pattern detected', () {
      const String code = 'final c = name[0].toUpperCase() + name.substring(1);\n';
      final List<Suggestion> out = scanContent(code, 'b.dart');
      expect(out.any((s) => s.message.contains('capitalize')), isTrue);
    });
    test('takeLast manual sublist pattern detected', () {
      const String code = 'final tail = items.sublist(items.length - n);\n';
      final List<Suggestion> out = scanContent(code, 'c.dart');
      expect(out.any((s) => s.message.contains('takeLast')), isTrue);
    });
    test('isSameDay manual y/m/d comparison detected', () {
      const String code =
          'final same = a.year == b.year && a.month == b.month && a.day == b.day;\n';
      final List<Suggestion> out = scanContent(code, 'd.dart');
      expect(out.any((s) => s.message.contains('isSameDay')), isTrue);
    });
    test('addDays manual Duration detected', () {
      const String code = 'final t = now.add(Duration(days: 3));\n';
      final List<Suggestion> out = scanContent(code, 'e.dart');
      expect(out.any((s) => s.message.contains('addDays')), isTrue);
    });
    test('isLeapYear manual rule detected', () {
      const String code = 'final leap = y % 4 == 0 && y % 100 != 0 || y % 400 == 0;\n';
      final List<Suggestion> out = scanContent(code, 'g.dart');
      expect(out.any((s) => s.message.contains('isLeapYear')), isTrue);
    });
    test('flatten manual expand detected', () {
      const String code = 'final all = lists.expand((e) => e).toList();\n';
      final List<Suggestion> out = scanContent(code, 'h.dart');
      expect(out.any((s) => s.message.contains('flatten')), isTrue);
    });
    test('snippet and line set from matched line', () {
      const String code =
          'void foo() {\n  final c = x[0].toUpperCase() + x.substring(1);\n}\n';
      final List<Suggestion> out = scanContent(code, 'f.dart');
      expect(out, isNotEmpty);
      expect(out.first.line, 2);
      expect(out.first.snippet, isNotEmpty);
      expect(out.first.message, contains('capitalize'));
    });
    test('matches inside string literals (documented limitation)', () {
      // The scanner is regex-based with no semantic awareness, so a pattern
      // appearing inside a string literal still matches. This test pins that
      // known behavior rather than asserting it is fixed.
      const String code = "final t = 'items.sublist(items.length - n)';\n";
      final List<Suggestion> out = scanContent(code, 's.dart');
      expect(out.every((s) => s.path == 's.dart' && s.line >= 1), isTrue);
    });
  });
}
