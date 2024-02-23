import 'package:flutter_test/flutter_test.dart';
import 'package:saropa_dart_utils/string/string_utils.dart';

void main() {
  group('nullIfEmpty', () {
    test('returns null when string is empty', () {
      expect(''.nullIfEmpty(), isNull);
    });

    test('returns null when string contains only spaces and trimFirst is true',
        () {
      expect('   '.nullIfEmpty(), isNull);
    });

    test(
        'returns string itself when string contains only spaces and trimFirst '
        'is false', () {
      expect('   '.nullIfEmpty(trimFirst: false), equals('   '));
    });

    test('returns string itself when string is not empty', () {
      expect('Hello'.nullIfEmpty(), equals('Hello'));
    });

    test(
        'returns trimmed string when string has leading/trailing spaces and trimFirst is true',
        () {
      expect('  Hello  '.nullIfEmpty(), equals('Hello'));
    });
  });

  group('removeStart', () {
    test('returns null when start string is empty', () {
      final result = 'Hello, World!'.removeStart('');
      expect(result, isNull);
    });

    test(
        'returns original string when start string is not a prefix '
        '(case sensitive)', () {
      final result = 'Hello, World!'.removeStart('hello');
      expect(result, equals('Hello, World!'));
    });

    test(
        'returns string without start string when start string is a prefix '
        '(case sensitive)', () {
      final result = 'Hello, World!'.removeStart('Hello');
      expect(result, equals(', World!'));
    });

    test(
        'returns original string when start string is not a prefix '
        '(case insensitive)', () {
      final result =
          'Hello, World!'.removeStart('WORLD', isCaseSensitive: false);
      expect(result, equals('Hello, World!'));
    });

    test(
        'returns string without start string when start string is a prefix '
        '(case insensitive)', () {
      final result =
          'Hello, World!'.removeStart('HELLO', isCaseSensitive: false);
      expect(result, equals(', World!'));
    });
  });

  group('removeConsecutiveSpaces', () {
    test('returns empty string when input string is null or empty', () {
      final result = ''.removeConsecutiveSpaces();
      expect(result, equals(null));
    });

    test('returns string with consecutive spaces removed and trimmed', () {
      final result = '  Hello,   World!  '.removeConsecutiveSpaces();
      expect(result, equals('Hello, World!'));
    });

    test('returns string with consecutive spaces removed and not trimmed', () {
      final result = '  Hello,   World!  '.removeConsecutiveSpaces(trim: false);
      expect(result, equals(' Hello, World! '));
    });
  });

  group('compressSpaces', () {
    test('returns empty string when input string is null or empty', () {
      final result = ''.compressSpaces();
      expect(result, equals(null));
    });

    test('returns string with consecutive spaces removed and trimmed', () {
      final result = '  Hello,   World!  '.compressSpaces();
      expect(result, equals('Hello, World!'));
    });

    test('returns string with consecutive spaces removed and not trimmed', () {
      final result = '  Hello,   World!  '.compressSpaces(trim: false);
      expect(result, equals(' Hello, World! '));
    });
  });

  group('wrapWith', () {
    test('returns null when input string is empty', () {
      final result = ''.wrapWith(before: 'Hello', after: 'World');
      expect(result, isNull);
    });

    test('returns original string when before and after are null', () {
      final result = 'Hello, World!'.wrapWith();
      expect(result, equals('Hello, World!'));
    });

    test('returns string wrapped with before and after when they are not null',
        () {
      final result =
          'Hello, World!'.wrapWith(before: 'Start: ', after: ' :End');
      expect(result, equals('Start: Hello, World! :End'));
    });

    test('returns string wrapped with before when after is null', () {
      final result = 'Hello, World!'.wrapWith(before: 'Start: ');
      expect(result, equals('Start: Hello, World!'));
    });

    test('returns string wrapped with after when before is null', () {
      final result = 'Hello, World!'.wrapWith(after: ' :End');
      expect(result, equals('Hello, World! :End'));
    });
  });

  group('encloseInParentheses', () {
    test('returns null when input string is empty and wrapEmpty is false', () {
      final result = ''.encloseInParentheses();
      expect(result, isNull);
    });

    test(
        'returns empty parentheses when input string is empty and '
        'wrapEmpty is true', () {
      final result = ''.encloseInParentheses(wrapEmpty: true);
      expect(result, equals('()'));
    });

    test(
        'returns string enclosed in parentheses when input string is not empty',
        () {
      final result = 'Hello, World!'.encloseInParentheses();
      expect(result, equals('(Hello, World!)'));
    });
  });
}
