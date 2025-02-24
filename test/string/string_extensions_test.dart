import 'package:flutter_test/flutter_test.dart';
import 'package:saropa_dart_utils/string/string_extensions.dart';

void main() {
  group('StringWordExtensions', () {
    group('words', () {
      test('Empty string returns null', () {
        expect(''.words(), null);
      });

      test('Single word string', () {
        expect('Hello'.words(), ['Hello']);
      });

      test('Multiple words string', () {
        expect('Hello world from Dart'.words(), ['Hello', 'world', 'from', 'Dart']);
      });

      test('String with leading and trailing spaces', () {
        expect('  Hello world  '.words(), ['Hello', 'world']);
      });

      test('String with multiple spaces between words', () {
        expect('Hello   world  from     Dart'.words(), ['Hello', 'world', 'from', 'Dart']);
      });

      test('String with special characters in words', () {
        expect('Word-1 word_2 word#3'.words(), ['Word-1', 'word_2', 'word#3']);
      });

      test('String with numbers as words', () {
        expect('123 456 789'.words(), ['123', '456', '789']);
      });

      test('String with punctuation at word boundaries', () {
        expect('Hello, world!'.words(), ['Hello,', 'world!']); // Punctuation is part of the word if no space after
      });

      test('String with mixed case words', () {
        expect('hELLo wORLd'.words(), ['hELLo', 'wORLd']);
      });

      test('String with Unicode words', () {
        expect('你好 世界'.words(), ['你好', '世界']);
      });
    });
  });
  
  group('nullIfEmpty', () {
    test('returns null when string is empty', () {
      expect(''.nullIfEmpty(), isNull);
    });

    test('returns null when string contains only spaces and trimFirst is true', () {
      expect('   '.nullIfEmpty(), isNull);
    });

    test('returns string itself when string contains only spaces and trimFirst '
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
      },
    );
  });

  group('removeStart', () {
    test('returns input string when start string is empty', () {
      final result = 'Hello, World!'.removeStart('');
      expect(result, 'Hello, World!');
    });

    test('returns original string when start string is not a prefix '
        '(case sensitive)', () {
      final result = 'Hello, World!'.removeStart('hello');
      expect(result, equals('Hello, World!'));
    });

    test('returns string without start string when start string is a prefix '
        '(case sensitive)', () {
      final result = 'Hello, World!'.removeStart('Hello');
      expect(result, equals(', World!'));
    });

    test('returns original string when start string is not a prefix '
        '(case insensitive)', () {
      final result = 'Hello, World!'.removeStart('WORLD', isCaseSensitive: false);
      expect(result, equals('Hello, World!'));
    });

    test('returns string without start string when start string is a prefix '
        '(case insensitive)', () {
      final result = 'Hello, World!'.removeStart('HELLO', isCaseSensitive: false);
      expect(result, equals(', World!'));
    });

    test('When string is empty', () {
      expect(''.removeStart('Hello'), equals(''));
    });

    test('When find is empty', () {
      expect('Hello'.removeStart(''), equals('Hello'));
    });

    test('When string starts with find', () {
      expect('Hello'.removeStart('He'), equals('llo'));
    });

    test('When string does not start with find', () {
      expect('Hello'.removeStart('lo'), equals('Hello'));
    });

    test('When trimFirst is true and string starts with find', () {
      expect(' Hello'.removeStart('Hello', trimFirst: true), equals(null));
    });

    test('When trimFirst is true and string does not start with find', () {
      expect(' Hello'.removeStart('lo', trimFirst: true), equals('Hello'));
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

    test('returns string wrapped with before and after when they are not null', () {
      final result = 'Hello, World!'.wrapWith(before: 'Start: ', after: ' :End');
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

    test('returns empty parentheses when input string is empty and '
        'wrapEmpty is true', () {
      final result = ''.encloseInParentheses(wrapEmpty: true);
      expect(result, equals('()'));
    });

    test('returns string enclosed in parentheses when input string is not empty', () {
      final result = 'Hello, World!'.encloseInParentheses();
      expect(result, equals('(Hello, World!)'));
    });
  });
}
