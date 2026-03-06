import 'package:flutter_test/flutter_test.dart';
import 'package:saropa_dart_utils/string/string_regex_extensions.dart';

void main() {
  group('escapeForRegex', () {
    test('empty', () => expect(''.escapeForRegex(), ''));
    test('dollar and dot', () {
      final String s = r'$10.00'.escapeForRegex();
      expect(RegExp(s).hasMatch(r'$10.00'), isTrue);
    });
    test('plus', () => expect('a+b'.escapeForRegex(), r'a\+b'));
    test('parentheses', () => expect('(x)'.escapeForRegex(), r'\(x\)'));
    test('replacement never interpolates null', () {
      // Before fix: '\\${m[0]}' could produce r'\null'. After: m.group(0) ?? ''.
      final String result = r'.*+?^${}()|[]\'.escapeForRegex();
      expect(result.contains(r'\null'), isFalse);
    });
    test('input word null escapes to literal null', () {
      // False positive: input "null" is not special chars; output may contain "null".
      expect('null'.escapeForRegex(), equals('null'));
    });
    test('escaped pattern matches original round-trip', () {
      const String raw = r'C:\path\to$file (v1.0)?';
      final String escaped = raw.escapeForRegex();
      expect(RegExp(escaped).hasMatch(raw), isTrue);
    });
  });
}
