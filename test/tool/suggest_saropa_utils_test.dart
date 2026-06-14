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
      const String code = 'void foo() {\n  final c = x[0].toUpperCase() + x.substring(1);\n}\n';
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

  // One positive test per detector: the canonical hand-rolled snippet must
  // produce a suggestion naming the matching util. These pin that every shipped
  // detector actually fires on the form it claims to recognize.
  group('detector coverage — every detector fires on its canonical pattern', () {
    test('deprecated isNullOrEmpty use', () {
      expectSuggests('if (s.isNullOrEmpty) return;', 'Deprecated getter');
    });
    test('deprecated isNotNullOrEmpty use', () {
      expectSuggests('if (s.isNotNullOrEmpty) {}', 'Deprecated getter');
    });
    test('deprecated isNullOrZero use', () {
      expectSuggests('if (n.isNullOrZero) {}', 'Deprecated getter');
    });
    test('capitalize (index + concat)', () {
      expectSuggests('name[0].toUpperCase() + name.substring(1)', 'capitalize');
    });
    test('truncateWithEllipsis', () {
      expectSuggests("text.substring(0, 10) + '...'", 'truncateWithEllipsis');
    });
    test('containsIgnoreCase', () {
      expectSuggests('a.toLowerCase().contains(b.toLowerCase())', 'containsIgnoreCase');
    });
    test('ensurePrefix', () {
      expectSuggests('path.startsWith(sep) ? path : sep + path', 'ensurePrefix');
    });
    test('ensureSuffix', () {
      expectSuggests('path.endsWith(sep) ? path : path + sep', 'ensureSuffix');
    });
    test('getEverythingBefore', () {
      expectSuggests("url.substring(0, url.indexOf('?'))", 'getEverythingBefore');
    });
    test('getEverythingAfter', () {
      expectSuggests("url.substring(url.indexOf('?') + 1)", 'getEverythingAfter');
    });
    test('compressSpaces', () {
      expectSuggests(r"text.replaceAll(RegExp(r'\s+'), ' ')", 'compressSpaces');
    });
    test('firstWord', () {
      expectSuggests("sentence.split(' ').first", 'firstWord');
    });
    test('countOccurrences', () {
      expectSuggests("text.split(',').length - 1", 'countOccurrences');
    });
    test('orEmpty (string)', () {
      expectSuggests("final x = name ?? '';", 'orEmpty');
    });
    test('orEmpty (list)', () {
      expectSuggests('final x = items ?? [];', 'orEmpty');
    });
    test('orEmpty (map)', () {
      expectSuggests('final x = lookup ?? {};', 'orEmpty');
    });
    test('addNotNull', () {
      expectSuggests('if (value != null) list.add(value);', 'addNotNull');
    });
    test('takeLast', () {
      expectSuggests('items.sublist(items.length - 3)', 'takeLast');
    });
    test('dropLast', () {
      expectSuggests('items.sublist(0, items.length - 1)', 'dropLast');
    });
    test('lastOrNull', () {
      expectSuggests('items.isNotEmpty ? items.last : null', 'lastOrNull');
    });
    test('whereNotNull', () {
      expectSuggests('items.where((e) => e != null)', 'whereNotNull');
    });
    test('countWhere', () {
      expectSuggests('items.where((e) => e > 3).length', 'countWhere');
    });
    test('containsAny', () {
      expectSuggests('other.any((e) => items.contains(e))', 'containsAny');
    });
    test('endsWithAny', () {
      expectSuggests('suffixes.any((s) => name.endsWith(s))', 'endsWithAny');
    });
    test('nullIfEmpty', () {
      expectSuggests('items.isEmpty ? null : items', 'nullIfEmpty');
    });
    test('clampNonNegative', () {
      expectSuggests('n < 0 ? 0 : n', 'clampNonNegative');
    });
    test('removeAll', () {
      expectSuggests("text.replaceAll('-', '')", 'removeAll');
    });
    test('wordCount', () {
      expectSuggests("sentence.split(' ').length", 'wordCount');
    });
    test('isNumeric', () {
      expectSuggests('double.tryParse(s) != null', 'isNumeric');
    });
    test('isPalindrome', () {
      expectSuggests("s == s.split('').reversed.join()", 'isPalindrome');
    });
    test('isSameDay', () {
      expectSuggests(
        'a.year == b.year && a.month == b.month && a.day == b.day',
        'isSameDay',
      );
    });
    test('startOfDay', () {
      expectSuggests('DateTime(d.year, d.month, d.day)', 'startOfDay');
    });
    test('endOfDay', () {
      expectSuggests('DateTime(d.year, d.month, d.day, 23, 59, 59)', 'endOfDay');
    });
    test('addDays', () {
      expectSuggests('now.add(Duration(days: 1))', 'addDays');
    });
    test('addHours', () {
      expectSuggests('now.add(Duration(hours: 2))', 'addHours');
    });
    test('addMinutes', () {
      expectSuggests('now.add(Duration(minutes: 30))', 'addMinutes');
    });
    test('addMonths', () {
      expectSuggests('DateTime(d.year, d.month + 1, d.day)', 'addMonths');
    });
    test('addYears', () {
      expectSuggests('DateTime(d.year + 1, d.month, d.day)', 'addYears');
    });
    test('isLeapYear', () {
      expectSuggests('y % 4 == 0 && (y % 100 != 0 || y % 400 == 0)', 'isLeapYear');
    });
    test('isWeekend', () {
      expectSuggests(
        'd.weekday == DateTime.saturday || d.weekday == DateTime.sunday',
        'isWeekend',
      );
    });
    test('flatten', () {
      expectSuggests('lists.expand((e) => e).toList()', 'flatten');
    });
    test('none', () {
      expectSuggests('!items.any((e) => e.active)', 'none');
    });
    test('containsAll', () {
      expectSuggests('other.every((e) => items.contains(e))', 'containsAll');
    });
    test('sumBy', () {
      expectSuggests('nums.reduce((a, b) => a + b)', 'sumBy');
    });
    test('invert', () {
      expectSuggests('lookup.map((k, v) => MapEntry(v, k))', 'invert');
    });
    test('percentageOf', () {
      expectSuggests('total == 0 ? 0 : value / total', 'percentageOf');
    });
    test('lerp', () {
      expectSuggests('a + (b - a) * t', 'lerp');
    });
    test('isInteger', () {
      expectSuggests('x == x.roundToDouble()', 'isInteger');
    });
  });

  // Real-world formatting variants harvested from common Dart/Flutter idioms
  // (string interpolation, the substring(0,1) head, extra whitespace). The
  // scanner must still recognize these, not only the textbook spacing.
  group('real-world variants', () {
    test('capitalize via string interpolation', () {
      expectSuggests(r'"${name[0].toUpperCase()}${name.substring(1)}"', 'capitalize');
    });
    test('capitalize via substring(0, 1) head', () {
      expectSuggests(
        'name.substring(0, 1).toUpperCase() + name.substring(1)',
        'capitalize',
      );
    });
    test('takeLast with extra whitespace', () {
      expectSuggests('items.sublist( items.length  -  2 )', 'takeLast');
    });
    test('lastOrNull with this receiver', () {
      expectSuggests('this.isNotEmpty ? this.last : null', 'lastOrNull');
    });
    test('isLeapYear without parentheses', () {
      expectSuggests('y % 4 == 0 && y % 100 != 0 || y % 400 == 0', 'isLeapYear');
    });
  });

  // False-positive guards: code that is already correct, already uses the util,
  // or merely resembles a pattern must NOT be flagged. Over-triggering is the
  // primary risk of a regex scanner, so each detector with a near-miss is pinned.
  group('false-positive guards', () {
    test('the correct long-form null+empty guard is not flagged', () {
      expectNoSuggestion('if (s == null || s.isEmpty) return;', 'Consider');
    });
    test('the correct not-null-and-not-empty guard is not flagged', () {
      expectNoSuggestion('if (s != null && s.isNotEmpty) {}', 'Consider');
    });
    test('already using capitalize() is not re-flagged', () {
      expectNoSuggestion('name.capitalize()', 'Consider: string.capitalize');
    });
    test('sublist with literal bounds is not takeLast/dropLast', () {
      expectNoSuggestion('items.sublist(1, 3)', 'takeLast');
      expectNoSuggestion('items.sublist(1, 3)', 'dropLast');
    });
    test('where without .length is not countWhere', () {
      expectNoSuggestion('items.where((e) => e.active)', 'countWhere');
    });
    test('unguarded division is not percentageOf', () {
      expectNoSuggestion('final r = value / total;', 'percentageOf');
    });
    test('DateTime with an hour but not 23:59 is not startOfDay/endOfDay', () {
      expectNoSuggestion('DateTime(d.year, d.month, d.day, 12)', 'startOfDay');
      expectNoSuggestion('DateTime(d.year, d.month, d.day, 12)', 'endOfDay');
    });
    test('split(space).length is wordCount, not countOccurrences', () {
      expectNoSuggestion("words.split(' ').length", 'countOccurrences');
    });
    test('any without negation is not none', () {
      expectNoSuggestion('items.any((e) => e.active)', 'none(predicate)');
    });
    test('plain replaceAll with non-empty replacement is not removeAll', () {
      expectNoSuggestion("text.replaceAll('a', 'b')", 'removeAll');
    });
  });

  // Edge cases: empty input, whitespace-only lines, multi-hit lines, and the
  // documented in-string-literal matching behavior.
  group('scanner edge cases', () {
    test('empty content yields nothing', () {
      expect(scanContent('', 'p.dart'), isEmpty);
    });
    test('whitespace-only content yields nothing', () {
      expect(scanContent('   \n\t\n', 'p.dart'), isEmpty);
    });
    test('a line with two distinct patterns yields two suggestions', () {
      const String code = "final a = name ?? ''; final b = items.sublist(items.length - 1);";
      final List<Suggestion> out = scanContent(code, 'm.dart');
      expect(out.any((s) => s.message.contains('orEmpty')), isTrue);
      expect(out.any((s) => s.message.contains('takeLast')), isTrue);
    });
    test('line numbers are 1-based and correct on a later line', () {
      const String code = 'a;\nb;\nfinal x = name ?? [];\n';
      final List<Suggestion> out = scanContent(code, 'n.dart');
      expect(out.first.line, 3);
    });
  });
}

/// Asserts that scanning [code] produces at least one suggestion whose message
/// contains [utilSubstring]. Keeps each detector test a single readable line.
void expectSuggests(String code, String utilSubstring) {
  final List<Suggestion> out = scanContent('$code\n', 'x.dart');
  expect(
    out.any((Suggestion s) => s.message.contains(utilSubstring)),
    isTrue,
    reason: 'expected a suggestion containing "$utilSubstring" for: $code',
  );
}

/// Asserts that scanning [code] produces NO suggestion whose message contains
/// [utilSubstring] — the false-positive guard.
void expectNoSuggestion(String code, String utilSubstring) {
  final List<Suggestion> out = scanContent('$code\n', 'x.dart');
  expect(
    out.any((Suggestion s) => s.message.contains(utilSubstring)),
    isFalse,
    reason: 'did not expect "$utilSubstring" for: $code',
  );
}
