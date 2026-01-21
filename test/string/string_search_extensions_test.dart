import 'package:flutter_test/flutter_test.dart';
import 'package:saropa_dart_utils/string/string_between_extensions.dart';
import 'package:saropa_dart_utils/string/string_search_extensions.dart';

// cspell: disable
void main() {
  group('isEqualsAny', () {
    test(
      '1. Match found case sensitive',
      () => expect('hello'.isEqualsAny(<String>['hi', 'hello', 'hey']), isTrue),
    );
    test(
      '2. No match case sensitive',
      () => expect('Hello'.isEqualsAny(<String>['hello']), isFalse),
    );
    test(
      '3. Match found case insensitive',
      () => expect('Hello'.isEqualsAny(<String>['hello'], isCaseSensitive: false), isTrue),
    );
    test('4. Empty list', () => expect('hello'.isEqualsAny(<String>[]), isFalse));
    test('5. Null list', () => expect('hello'.isEqualsAny(null), isFalse));
    test('6. Empty string', () => expect(''.isEqualsAny(<String>['a']), isFalse));
    test(
      '7. Multiple potential matches',
      () => expect('test'.isEqualsAny(<String>['Test', 'TEST', 'test']), isTrue),
    );
    test(
      '8. Case insensitive multiple',
      () => expect('TEST'.isEqualsAny(<String>['test'], isCaseSensitive: false), isTrue),
    );
    test('9. Unicode match', () => expect('你好'.isEqualsAny(<String>['hello', '你好']), isTrue));
    test(
      '10. Partial no match',
      () => expect('hello'.isEqualsAny(<String>['hel', 'llo']), isFalse),
    );
    test('11. Single item list', () => expect('test'.isEqualsAny(<String>['test']), isTrue));
    test('12. Whitespace string', () => expect(' '.isEqualsAny(<String>[' ']), isTrue));
  });

  group('isContainsDigits', () {
    test('1. Contains single digit', () => expect('abc1def'.isContainsDigits(), isTrue));
    test('2. Contains multiple digits', () => expect('a1b2c3'.isContainsDigits(), isTrue));
    test('3. Only digits', () => expect('12345'.isContainsDigits(), isTrue));
    test('4. No digits', () => expect('abcdef'.isContainsDigits(), isFalse));
    test('5. Empty string', () => expect(''.isContainsDigits(), isFalse));
    test('6. Digit at start', () => expect('1abc'.isContainsDigits(), isTrue));
    test('7. Digit at end', () => expect('abc9'.isContainsDigits(), isTrue));
    test('8. Special chars no digits', () => expect('!@#\$%'.isContainsDigits(), isFalse));
    test('9. Unicode with digit', () => expect('你好1'.isContainsDigits(), isTrue));
    test('10. Space and letters', () => expect('hello world'.isContainsDigits(), isFalse));
  });

  group('isContainsAnyInList', () {
    test(
      '1. Contains one item',
      () => expect('hello world'.isContainsAnyInList(<String>['world']), isTrue),
    );
    test(
      '2. Contains none',
      () => expect('hello'.isContainsAnyInList(<String>['x', 'y', 'z']), isFalse),
    );
    test(
      '3. Case sensitive no match',
      () => expect('Hello'.isContainsAnyInList(<String>['hello']), isFalse),
    );
    test(
      '4. Case insensitive match',
      () => expect('Hello'.isContainsAnyInList(<String>['hello'], isCaseSensitive: false), isTrue),
    );
    test('5. Empty list', () => expect('hello'.isContainsAnyInList(<String>[]), isFalse));
    test('6. Null list', () => expect('hello'.isContainsAnyInList(null), isFalse));
    test('7. Empty string', () => expect(''.isContainsAnyInList(<String>['a']), isFalse));
    test(
      '8. Multiple matches',
      () => expect('hello world'.isContainsAnyInList(<String>['hello', 'world']), isTrue),
    );
    test('9. Partial match', () => expect('testing'.isContainsAnyInList(<String>['test']), isTrue));
    test('10. Unicode content', () => expect('你好世界'.isContainsAnyInList(<String>['世界']), isTrue));
    test(
      '11. Case insensitive unicode',
      () => expect('HELLO'.isContainsAnyInList(<String>['hello'], isCaseSensitive: false), isTrue),
    );
    test('12. Single item list', () => expect('abc'.isContainsAnyInList(<String>['b']), isTrue));
  });

  group('isContainedInAny', () {
    test(
      '1. String is contained in list item',
      () => expect('test'.isContainedInAny(<String>['testing', 'other']), isTrue),
    );
    test(
      '2. Not contained in any',
      () => expect('xyz'.isContainedInAny(<String>['abc', 'def']), isFalse),
    );
    test(
      '3. Case sensitive no match',
      () => expect('Test'.isContainedInAny(<String>['testing']), isFalse),
    );
    test(
      '4. Case insensitive match',
      () => expect('Test'.isContainedInAny(<String>['testing'], isCaseSensitive: false), isTrue),
    );
    test('5. Empty list', () => expect('hello'.isContainedInAny(<String>[]), isFalse));
    test('6. Null list', () => expect('hello'.isContainedInAny(null), isFalse));
    test('7. Empty string', () => expect(''.isContainedInAny(<String>['a']), isFalse));
    test('8. Exact match', () => expect('hello'.isContainedInAny(<String>['hello']), isTrue));
    test(
      '9. Multiple potential containers',
      () => expect('a'.isContainedInAny(<String>['abc', 'def', 'ghi']), isTrue),
    );
    test('10. Unicode', () => expect('好'.isContainedInAny(<String>['你好世界']), isTrue));
  });

  group('isContainsCaseInsensitive', () {
    test(
      '1. Match with different case',
      () => expect('Hello World'.isContainsCaseInsensitive('WORLD'), isTrue),
    );
    test(
      '2. Match with same case',
      () => expect('Hello World'.isContainsCaseInsensitive('World'), isTrue),
    );
    test('3. No match', () => expect('Hello'.isContainsCaseInsensitive('xyz'), isFalse));
    test('4. Empty find', () => expect('Hello'.isContainsCaseInsensitive(''), isFalse));
    test('5. Null find', () => expect('Hello'.isContainsCaseInsensitive(null), isFalse));
    test('6. Empty string', () => expect(''.isContainsCaseInsensitive('a'), isFalse));
    test('7. Partial match', () => expect('testing'.isContainsCaseInsensitive('TEST'), isTrue));
    test('8. At start', () => expect('Hello World'.isContainsCaseInsensitive('hel'), isTrue));
    test('9. At end', () => expect('Hello World'.isContainsCaseInsensitive('RLD'), isTrue));
    test(
      '10. Mixed case search in mixed case text',
      () => expect('HeLLo WoRLd'.isContainsCaseInsensitive('hello'), isTrue),
    );
  });

  group('isContainsNullable', () {
    test(
      '1. Contains case sensitive',
      () => expect('Hello World'.isContainsNullable('World'), isTrue),
    );
    test('2. Does not contain', () => expect('Hello'.isContainsNullable('xyz'), isFalse));
    test('3. Case sensitive no match', () => expect('Hello'.isContainsNullable('HELLO'), isFalse));
    test(
      '4. Case insensitive match',
      () => expect('Hello'.isContainsNullable('HELLO', isCaseSensitive: false), isTrue),
    );
    test('5. Null find', () => expect('Hello'.isContainsNullable(null), isFalse));
    test('6. Empty find', () => expect('Hello'.isContainsNullable(''), isFalse));
    test('7. Empty string', () => expect(''.isContainsNullable('a'), isFalse));
    test('8. Partial match', () => expect('testing'.isContainsNullable('est'), isTrue));
    test(
      '9. Case insensitive partial',
      () => expect('Testing'.isContainsNullable('EST', isCaseSensitive: false), isTrue),
    );
    test('10. Unicode content', () => expect('你好世界'.isContainsNullable('世界'), isTrue));
  });

  group('isMatchAny', () {
    test(
      '1. Contains match type',
      () => expect('hello world'.isMatchAny(<String>['world']), isTrue),
    );
    test(
      '2. StartsWith match type',
      () => expect(
        'hello world'.isMatchAny(<String>['hello'], matchType: SearchMatchType.startsWith),
        isTrue,
      ),
    );
    test(
      '3. Exact match type',
      () => expect('hello'.isMatchAny(<String>['hello'], matchType: SearchMatchType.exact), isTrue),
    );
    test('4. Contains no match', () => expect('hello'.isMatchAny(<String>['xyz']), isFalse));
    test(
      '5. StartsWith no match',
      () => expect(
        'hello'.isMatchAny(<String>['world'], matchType: SearchMatchType.startsWith),
        isFalse,
      ),
    );
    test(
      '6. Exact no match',
      () => expect(
        'hello world'.isMatchAny(<String>['hello'], matchType: SearchMatchType.exact),
        isFalse,
      ),
    );
    test(
      '7. Case insensitive contains',
      () => expect('Hello'.isMatchAny(<String>['HELLO'], isCaseSensitive: false), isTrue),
    );
    test('8. Empty list', () => expect('hello'.isMatchAny(<String>[]), isFalse));
    test('9. Null list', () => expect('hello'.isMatchAny(null), isFalse));
    test('10. Empty string', () => expect(''.isMatchAny(<String>['a']), isFalse));
  });

  group('isStartsWithAny', () {
    test(
      '1. Starts with one',
      () => expect('hello world'.isStartsWithAny(<String>['hello', 'hi']), isTrue),
    );
    test(
      '2. Does not start with any',
      () => expect('hello'.isStartsWithAny(<String>['world', 'test']), isFalse),
    );
    test(
      '3. Case sensitive no match',
      () => expect('Hello'.isStartsWithAny(<String>['hello']), isFalse),
    );
    test(
      '4. Case insensitive match',
      () => expect('Hello'.isStartsWithAny(<String>['hello'], isCaseSensitive: false), isTrue),
    );
    test('5. Empty list', () => expect('hello'.isStartsWithAny(<String>[]), isFalse));
    test('6. Null list', () => expect('hello'.isStartsWithAny(null), isFalse));
    test('7. Empty string', () => expect(''.isStartsWithAny(<String>['a']), isFalse));
    test('8. Single char prefix', () => expect('abc'.isStartsWithAny(<String>['a', 'b']), isTrue));
    test('9. Full string match', () => expect('test'.isStartsWithAny(<String>['test']), isTrue));
    test('10. Unicode prefix', () => expect('你好世界'.isStartsWithAny(<String>['你好']), isTrue));
  });

  group('getRepeatableLetter', () {
    test('1. Uppercase first letter', () => expect('apple'.getRepeatableLetter(), 'A'));
    test('2. Already uppercase', () => expect('Apple'.getRepeatableLetter(), 'A'));
    test('3. Number first', () => expect('123abc'.getRepeatableLetter(), '1'));
    test('4. Symbol first', () => expect('@test'.getRepeatableLetter(), '@'));
    test('5. Empty string', () => expect(''.getRepeatableLetter(), ''));
    test('6. Whitespace only', () => expect('   '.getRepeatableLetter(), ''));
    test('7. Leading whitespace', () => expect('  hello'.getRepeatableLetter(), 'H'));
    test('8. Single letter', () => expect('z'.getRepeatableLetter(), 'Z'));
    test('9. Unicode first', () => expect('你好'.getRepeatableLetter(), '你'));
    test('10. Mixed content', () => expect('Hello World'.getRepeatableLetter(), 'H'));
    test('11. Lowercase z', () => expect('zoo'.getRepeatableLetter(), 'Z'));
    test('12. Tab then letter', () => expect('\thello'.getRepeatableLetter(), 'H'));
  });

  group('isNotContains', () {
    test('1. Does not contain', () => expect('hello'.isNotContains('xyz'), isTrue));
    test('2. Contains returns false', () => expect('hello'.isNotContains('ell'), isFalse));
    test('3. Empty find', () => expect('hello'.isNotContains(''), isFalse));
    test('4. Null find', () => expect('hello'.isNotContains(null), isFalse));
    test('5. Empty string', () => expect(''.isNotContains('a'), isFalse));
    test('6. Exact match', () => expect('test'.isNotContains('test'), isFalse));
    test('7. Case sensitive', () => expect('Hello'.isNotContains('hello'), isTrue));
    test('8. At start', () => expect('hello'.isNotContains('hel'), isFalse));
    test('9. At end', () => expect('hello'.isNotContains('llo'), isFalse));
    test('10. Unicode', () => expect('hello'.isNotContains('你'), isTrue));
  });

  group('isContainsConditional', () {
    test(
      '1. Condition true, contains',
      () => expect('hello world'.isContainsConditional('world', condition: true), isTrue),
    );
    test(
      '2. Condition true, not contains',
      () => expect('hello'.isContainsConditional('world', condition: true), isFalse),
    );
    test(
      '3. Condition false, not contains',
      () => expect('hello'.isContainsConditional('world', condition: false), isTrue),
    );
    test(
      '4. Condition false, contains',
      () => expect('hello world'.isContainsConditional('world', condition: false), isFalse),
    );
    test(
      '5. Empty find',
      () => expect('hello'.isContainsConditional('', condition: true), isFalse),
    );
    test(
      '6. Null find',
      () => expect('hello'.isContainsConditional(null, condition: true), isFalse),
    );
    test('7. Empty string', () => expect(''.isContainsConditional('a', condition: true), isFalse));
    test(
      '8. Exact match true',
      () => expect('test'.isContainsConditional('test', condition: true), isTrue),
    );
    test(
      '9. Exact match false',
      () => expect('test'.isContainsConditional('test', condition: false), isFalse),
    );
    test(
      '10. Partial match',
      () => expect('testing'.isContainsConditional('test', condition: true), isTrue),
    );
  });

  group('isContainsAnyWord', () {
    test(
      '1. Contains whole word',
      () => expect('hello world test'.isContainsAnyWord(<String>['world']), isTrue),
    );
    test(
      '2. Partial word no match',
      () => expect('testing'.isContainsAnyWord(<String>['test']), isFalse),
    );
    test(
      '3. Multiple search items',
      () => expect('hello world'.isContainsAnyWord(<String>['xyz', 'world']), isTrue),
    );
    test(
      '4. No matches',
      () => expect('hello'.isContainsAnyWord(<String>['world', 'test']), isFalse),
    );
    test('5. Empty list', () => expect('hello'.isContainsAnyWord(<String>[]), isFalse));
    test('6. Null list', () => expect('hello'.isContainsAnyWord(null), isFalse));
    test('7. Empty string', () => expect(''.isContainsAnyWord(<String>['a']), isFalse));
    test(
      '8. Case sensitive',
      () => expect(
        'Hello World'.isContainsAnyWord(<String>['WORLD'], isCaseSensitive: true),
        isFalse,
      ),
    );
    test(
      '9. Case insensitive',
      () => expect(
        'Hello World'.isContainsAnyWord(<String>['WORLD'], isCaseSensitive: false),
        isTrue,
      ),
    );
    test(
      '10. Word at start',
      () => expect('hello world'.isContainsAnyWord(<String>['hello']), isTrue),
    );
    test(
      '11. Word at end',
      () => expect('hello world'.isContainsAnyWord(<String>['world']), isTrue),
    );
    test(
      '12. Single letter word',
      () => expect('I am here'.isContainsAnyWord(<String>['I']), isTrue),
    );
  });

  group('isContainsWord', () {
    test(
      '1. Contains whole word',
      () => expect('hello world test'.isContainsWord('world'), isTrue),
    );
    test('2. Partial word no match', () => expect('testing'.isContainsWord('test'), isFalse));
    test('3. Word at start', () => expect('hello world'.isContainsWord('hello'), isTrue));
    test('4. Word at end', () => expect('hello world'.isContainsWord('world'), isTrue));
    test('5. Empty find', () => expect('hello'.isContainsWord(''), isFalse));
    test('6. Null find', () => expect('hello'.isContainsWord(null), isFalse));
    test('7. Empty string', () => expect(''.isContainsWord('a'), isFalse));
    test(
      '8. Case sensitive no match',
      () => expect('Hello World'.isContainsWord('WORLD', isCaseSensitive: true), isFalse),
    );
    test(
      '9. Case insensitive match',
      () => expect('Hello World'.isContainsWord('WORLD', isCaseSensitive: false), isTrue),
    );
    test(
      '10. Word with hyphen',
      () => expect('well-known fact'.isContainsWord('well-known'), isTrue),
    );
    test('11. Single word string', () => expect('test'.isContainsWord('test'), isTrue));
    test('12. Word boundary respected', () => expect('contest'.isContainsWord('test'), isFalse));
  });

  group('isNotStartsWith', () {
    test('1. Does not start with', () => expect('hello'.isNotStartsWith('world'), isTrue));
    test('2. Starts with returns false', () => expect('hello'.isNotStartsWith('hel'), isFalse));
    test('3. Empty find', () => expect('hello'.isNotStartsWith(''), isFalse));
    test('4. Null find', () => expect('hello'.isNotStartsWith(null), isFalse));
    test('5. Empty string', () => expect(''.isNotStartsWith('a'), isFalse));
    test('6. Exact match', () => expect('test'.isNotStartsWith('test'), isFalse));
    test('7. Case sensitive', () => expect('Hello'.isNotStartsWith('hello'), isTrue));
    test('8. Longer prefix', () => expect('hi'.isNotStartsWith('hello'), isTrue));
    test('9. Single char', () => expect('abc'.isNotStartsWith('a'), isFalse));
    test('10. Unicode', () => expect('hello'.isNotStartsWith('你'), isTrue));
  });

  group('isStartsWithConditional', () {
    test(
      '1. Positive search, starts with',
      () => expect('hello world'.isStartsWithConditional('hello', isPositiveSearch: true), isTrue),
    );
    test(
      '2. Positive search, not starts with',
      () => expect('hello'.isStartsWithConditional('world', isPositiveSearch: true), isFalse),
    );
    test(
      '3. Negative search, not starts with',
      () => expect('hello'.isStartsWithConditional('world', isPositiveSearch: false), isTrue),
    );
    test(
      '4. Negative search, starts with',
      () =>
          expect('hello world'.isStartsWithConditional('hello', isPositiveSearch: false), isFalse),
    );
    test(
      '5. Empty find',
      () => expect('hello'.isStartsWithConditional('', isPositiveSearch: true), isFalse),
    );
    test(
      '6. Null find',
      () => expect('hello'.isStartsWithConditional(null, isPositiveSearch: true), isFalse),
    );
    test(
      '7. Empty string',
      () => expect(''.isStartsWithConditional('a', isPositiveSearch: true), isFalse),
    );
    test(
      '8. Exact match positive',
      () => expect('test'.isStartsWithConditional('test', isPositiveSearch: true), isTrue),
    );
    test(
      '9. Exact match negative',
      () => expect('test'.isStartsWithConditional('test', isPositiveSearch: false), isFalse),
    );
    test(
      '10. Case sensitive',
      () => expect('Hello'.isStartsWithConditional('hello', isPositiveSearch: true), isFalse),
    );
  });

  group('between', () {
    test('1. Result should NOT be empty', () {
      expect('www.website.com'.between('www.', '.com'), 'website');
      expect('www.website.com'.between('.', '.'), 'website');
    });
    test('2. Result should be empty', () {
      expect('www..com'.between('www.', '.com'), '');
    });
    test('3. String test with missing end', () {
      expect('www.website.com'.between('www.', '.com2'), 'website.com');
      expect('www.website.com'.between('www.', '.com2', endOptional: false), '');
    });
  });

  group('removeBetweenAll', () {
    // cspell: ignore wwwcom
    test('1. Result should NOT be empty', () {
      expect('www.website.com'.removeBetweenAll('.', '.'), 'wwwcom');
      expect('[www.website.com]'.removeBetweenAll('www.', '.com'), '[]');
      expect('[www.website.com]'.removeBetweenAll('www.', '.com', inclusive: false), '[www..com]');
      expect('www.website.com'.removeBetweenAll('www.', '.com', inclusive: false), 'www..com');
    });
    test('2. Result should be empty', () {
      expect(''.removeBetweenAll('www.', '.com'), '');
      expect('..'.removeBetweenAll('.', '.'), '');
      expect('www..com'.removeBetweenAll('www.', '.com'), '');
      expect('www.website.com'.removeBetweenAll('www.', '.com'), '');
    });
    test('3. String test with missing end', () {
      expect('www.website.com'.removeBetweenAll('www.', '.com2'), 'www.website.com');
    });
  });

  group('betweenResult', () {
    test('1. Simple case with no nesting', () {
      expect('(test)'.betweenResult('(', ')'), equals(('test', '')));
    });
    test('2. Nested delimiters', () {
      expect('(a(test)b)'.betweenResult('(', ')'), equals(('a(test)b', '')));
    });
    test('3. Multiple nested delimiters', () {
      expect('((a)(test)(b))'.betweenResult('(', ')'), equals(('(a)(test)(b)', '')));
    });
    test('4. Deeply nested delimiters', () {
      expect('((((test))))'.betweenResult('(', ')'), equals(('(((test)))', '')));
    });
    test('5. Unbalanced nested delimiters (favoring outer)', () {
      expect('((a(test)b)'.betweenResult('(', ')'), equals(('(a(test)b', '')));
    });
    test('6. Using square brackets', () {
      expect('[test]'.betweenResult('[', ']'), equals(('test', '')));
    });
    test('7. Using curly braces', () {
      expect('{test}'.betweenResult('{', '}'), equals(('test', '')));
    });
    test('8. Using angle brackets', () {
      expect('<test>'.betweenResult('<', '>'), equals(('test', '')));
    });
    test('9. Using mixed delimiters', () {
      expect('(test]'.betweenResult('(', ']'), equals(('test', '')));
    });
    test('10. Empty input string', () {
      expect(''.betweenResult('(', ')'), isNull);
    });
    test('11. Empty start delimiter', () {
      expect('test)'.betweenResult('', ')'), isNull);
    });
    test('12. Empty end delimiter', () {
      expect('(test'.betweenResult('(', ''), isNull);
    });
    test('13. Empty start and end delimiters', () {
      expect('test'.betweenResult('', ''), isNull);
    });
    test('14. Start delimiter not found', () {
      expect('test)'.betweenResult('(', ')'), isNull);
    });
    test('15. End delimiter not found', () {
      expect('(test'.betweenResult('(', ')'), isNull);
    });
    test('16. Start delimiter after end delimiter', () {
      expect(')test('.betweenResult('(', ')'), isNull);
    });
    test('17. Whitespace around delimiters', () {
      expect(' ( test ) '.betweenResult('(', ')'), equals(('test', '')));
    });
    test('18. Whitespace inside delimiters', () {
      expect('(  test  )'.betweenResult('(', ')'), equals(('test', '')));
    });
    test('19. Whitespace inside delimiters (trim:false)', () {
      expect('(  test  )'.betweenResult('(', ')', trim: false), equals(('  test  ', '')));
    });
    test('20. Whitespace outside delimiters', () {
      expect('  (test)  '.betweenResult('(', ')'), equals(('test', '')));
    });
    test('21. No whitespace', () {
      expect('(test)'.betweenResult('(', ')'), equals(('test', '')));
    });
    test('22. Trim set to false (outer whitespace)', () {
      expect('  (test)  '.betweenResult('(', ')', trim: false), equals(('test', '    ')));
    });
    test('23. Real-world example with URL and description', () {
      expect(
        'https://www.usfa.fema.gov/ (Federal Emergency Management Agency (FEMA))'.betweenResult(
          '(',
          ')',
        ),
        equals(('Federal Emergency Management Agency (FEMA)', 'https://www.usfa.fema.gov/')),
      );
    });
  });
}
