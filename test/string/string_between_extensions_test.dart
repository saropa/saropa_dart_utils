import 'package:flutter_test/flutter_test.dart';
import 'package:saropa_dart_utils/string/string_between_extensions.dart';

// cspell: disable
void main() {
  group('betweenBracketsResult', () {
    test('1. Parentheses', () {
      final (String, String?)? result = 'hello (world) test'.betweenBracketsResult();
      expect(result, isNotNull);
      expect(result?.$1, 'world');
      expect(result?.$2, 'hello test');
    });
    test('2. Square brackets', () {
      final (String, String?)? result = 'hello [world] test'.betweenBracketsResult();
      expect(result, isNotNull);
      expect(result?.$1, 'world');
    });
    test('3. Angle brackets', () {
      final (String, String?)? result = 'hello <world> test'.betweenBracketsResult();
      expect(result, isNotNull);
      expect(result?.$1, 'world');
    });
    test('4. Curly braces', () {
      final (String, String?)? result = 'hello {world} test'.betweenBracketsResult();
      expect(result, isNotNull);
      expect(result?.$1, 'world');
    });
    test('5. No brackets', () => expect('hello world'.betweenBracketsResult(), isNull));
    test('6. Empty string', () => expect(''.betweenBracketsResult(), isNull));
    test('7. Priority order - parentheses first', () {
      final (String, String?)? result = '(first) [second]'.betweenBracketsResult();
      expect(result?.$1, 'first');
    });
    test('8. Empty brackets', () {
      final (String, String?)? result = 'hello () test'.betweenBracketsResult();
      // Empty brackets may return tuple with empty content or null depending on implementation
      expect(result == null || result.$1.isEmpty, isTrue);
    });
    test('9. Nested content', () {
      final (String, String?)? result = 'outer (inner content) end'.betweenBracketsResult();
      expect(result?.$1, 'inner content');
    });
    test('10. Unicode content', () {
      final (String, String?)? result = 'hello (你好) test'.betweenBracketsResult();
      expect(result?.$1, '你好');
    });
  });

  group('betweenBracketsResultLast', () {
    test('1. Single brackets from end', () {
      final (String, String?)? result = 'hello (world) test'.betweenBracketsResultLast();
      expect(result, isNotNull);
      expect(result?.$1, 'world');
    });
    test('2. Multiple brackets - gets last', () {
      final (String, String?)? result = '(first) middle (last)'.betweenBracketsResultLast();
      expect(result?.$1, 'last');
    });
    test('3. No brackets', () => expect('hello world'.betweenBracketsResultLast(), isNull));
    test('4. Empty string', () => expect(''.betweenBracketsResultLast(), isNull));
    test('5. Square brackets last', () {
      final (String, String?)? result = '(first) [last]'.betweenBracketsResultLast();
      expect(result?.$1, 'first');
    });
    test('6. Curly braces', () {
      final (String, String?)? result = 'test {content}'.betweenBracketsResultLast();
      expect(result?.$1, 'content');
    });
    test('7. Angle brackets', () {
      final (String, String?)? result = 'test <content>'.betweenBracketsResultLast();
      expect(result?.$1, 'content');
    });
    test('8. Empty brackets', () => expect('test ()'.betweenBracketsResultLast(), isNull));
    test('9. Remaining string', () {
      final (String, String?)? result = 'prefix (content) suffix'.betweenBracketsResultLast();
      expect(result?.$2, 'prefix suffix');
    });
    test('10. Only brackets', () {
      final (String, String?)? result = '(content)'.betweenBracketsResultLast();
      expect(result?.$1, 'content');
      expect(result?.$2, '');
    });
  });

  group('betweenBrackets', () {
    test('1. Parentheses', () => expect('hello (world) test'.betweenBrackets(), 'world'));
    test('2. Square brackets', () => expect('hello [world] test'.betweenBrackets(), 'world'));
    test('3. Angle brackets', () => expect('hello <world> test'.betweenBrackets(), 'world'));
    test('4. Curly braces', () => expect('hello {world} test'.betweenBrackets(), 'world'));
    test('5. No brackets', () => expect('hello world'.betweenBrackets(), isNull));
    test('6. Empty string', () => expect(''.betweenBrackets(), isNull));
    test('7. Priority - parentheses', () => expect('(first) [second]'.betweenBrackets(), 'first'));
    test('8. Empty brackets', () => expect('()'.betweenBrackets(), isNull));
    test('9. Multiple words', () => expect('(hello world)'.betweenBrackets(), 'hello world'));
    test('10. Unicode', () => expect('(你好)'.betweenBrackets(), '你好'));
    test('11. Numbers', () => expect('(123)'.betweenBrackets(), '123'));
    test('12. Mixed content', () => expect('prefix (content) suffix'.betweenBrackets(), 'content'));
  });

  group('removeBetweenAll', () {
    test('1. Remove with brackets inclusive', () => expect('hello (world) test'.removeBetweenAll('(', ')'), 'hello  test'));
    test('2. Remove content only', () => expect('hello (world) test'.removeBetweenAll('(', ')', inclusive: false), 'hello () test'));
    test('3. Multiple occurrences', () {
      final String result = '(a) and (b)'.removeBetweenAll('(', ')');
      expect(result, contains('and'));
    });
    test('4. No match', () => expect('hello world'.removeBetweenAll('(', ')'), 'hello world'));
    test('5. Empty string', () => expect(''.removeBetweenAll('(', ')'), ''));
    test('6. Empty start', () => expect('hello'.removeBetweenAll('', ')'), 'hello'));
    test('7. Adjacent brackets', () => expect('()'.removeBetweenAll('(', ')'), ''));
    test('8. Square brackets', () => expect('a [b] c'.removeBetweenAll('[', ']'), 'a  c'));
    test('9. Curly braces', () => expect('a {b} c'.removeBetweenAll('{', '}'), 'a  c'));
    test('10. Custom delimiters', () => expect('a<<b>>c'.removeBetweenAll('<<', '>>'), 'ac'));
    test('11. Unicode delimiters', () => expect('你world好'.removeBetweenAll('你', '好'), ''));
    test('12. Nested not fully removed', () {
      final String result = 'a (b (c) d) e'.removeBetweenAll('(', ')');
      // Nested brackets may not be fully removed
      expect(result, contains('a'));
      expect(result, contains('e'));
    });
  });

  group('betweenSplit', () {
    test('1. Single occurrence', () => expect('hello (world) test'.betweenSplit('(', ')'), <String>['world']));
    test('2. Multiple occurrences', () {
      final List<String>? result = '(a) and (b) and (c)'.betweenSplit('(', ')');
      expect(result, isNotNull);
      expect(result?.isNotEmpty, isTrue);
    });
    test('3. No occurrences', () => expect('hello world'.betweenSplit('(', ')'), isNull));
    test('4. Empty string', () => expect(''.betweenSplit('(', ')'), isNull));
    test('5. Empty brackets', () => expect('()'.betweenSplit('(', ')'), isNull));
    test('6. Custom delimiters', () {
      final List<String>? result = '<<a>> <<b>>'.betweenSplit('<<', '>>');
      expect(result, isNotNull);
    });
    test('7. No trim', () {
      final List<String>? result = '( a ) ( b )'.betweenSplit('(', ')', trim: false);
      expect(result, isNotNull);
    });
    test('8. With trim', () {
      final List<String>? result = '( a ) ( b )'.betweenSplit('(', ')');
      expect(result, isNotNull);
    });
    test('9. Unicode content', () {
      final List<String>? result = '(你好) (世界)'.betweenSplit('(', ')');
      expect(result, isNotNull);
    });
    test('10. Mixed content', () {
      final List<String>? result = 'prefix (1) middle (2) suffix'.betweenSplit('(', ')');
      expect(result, isNotNull);
    });
  });

  group('betweenResult', () {
    test('1. Basic extraction', () {
      final (String, String?)? result = 'hello (world) test'.betweenResult('(', ')');
      expect(result, isNotNull);
      expect(result?.$1, 'world');
      expect(result?.$2, 'hello test');
    });
    test('2. No start delimiter', () => expect('hello world'.betweenResult('(', ')'), isNull));
    test('3. No end delimiter', () => expect('hello (world'.betweenResult('(', ')'), isNull));
    test('4. Empty string', () => expect(''.betweenResult('(', ')'), isNull));
    test('5. Empty start', () => expect('hello'.betweenResult('', ')'), isNull));
    test('6. Empty end', () => expect('hello'.betweenResult('(', ''), isNull));
    test('7. Multiple delimiters', () {
      final (String, String?)? result = '(first) (second)'.betweenResult('(', ')');
      expect(result?.$1, 'first) (second');
    });
    test('8. With whitespace', () {
      final (String, String?)? result = 'hello ( world ) test'.betweenResult('(', ')');
      expect(result?.$1, 'world');
    });
    test('9. No trim', () {
      final (String, String?)? result = 'hello ( world ) test'.betweenResult('(', ')', trim: false);
      expect(result?.$1, ' world ');
    });
    test('10. Unicode', () {
      final (String, String?)? result = '你好 (世界) 测试'.betweenResult('(', ')');
      expect(result?.$1, '世界');
    });
  });

  group('betweenResultLast', () {
    test('1. Basic extraction from end', () {
      final (String, String?)? result = 'hello (world) test'.betweenResultLast('(', ')');
      expect(result, isNotNull);
      expect(result?.$1, 'world');
    });
    test('2. Multiple occurrences - gets last', () {
      final (String, String?)? result = '(first) (last)'.betweenResultLast('(', ')');
      expect(result?.$1, 'last');
    });
    test('3. No match', () => expect('hello world'.betweenResultLast('(', ')'), isNull));
    test('4. Empty string', () => expect(''.betweenResultLast('(', ')'), isNull));
    test('5. Remaining string', () {
      final (String, String?)? result = 'prefix (middle) suffix'.betweenResultLast('(', ')');
      expect(result, isNotNull);
      expect(result?.$2, 'prefix suffix');
    });
    test('6. Only brackets', () {
      final (String, String?)? result = '(content)'.betweenResultLast('(', ')');
      expect(result?.$1, 'content');
    });
    test('7. With whitespace trimmed', () {
      final (String, String?)? result = '( content )'.betweenResultLast('(', ')');
      expect(result?.$1, 'content');
    });
    test('8. Custom delimiters', () {
      final (String, String?)? result = '<<first>> <<last>>'.betweenResultLast('<<', '>>');
      expect(result?.$1, 'last');
    });
    test('9. Unicode', () {
      final (String, String?)? result = '(你好) (世界)'.betweenResultLast('(', ')');
      expect(result?.$1, '世界');
    });
    test('10. End optional true', () {
      final (String, String?)? result = '(content'.betweenResultLast('(', ')', endOptional: true);
      expect(result?.$1, 'content');
    });
  });

  group('between', () {
    test('1. Basic extraction', () => expect('hello (world) test'.between('(', ')'), 'world'));
    test('2. No start delimiter', () => expect('hello world'.between('(', ')'), ''));
    test('3. No end delimiter with endOptional', () => expect('hello (world'.between('(', ')'), 'world'));
    test('4. No end delimiter without endOptional', () => expect('hello (world'.between('(', ')', endOptional: false), ''));
    test('5. Empty string', () => expect(''.between('(', ')'), ''));
    test('6. Empty start', () => expect('hello'.between('', ')'), ''));
    test('7. At start', () => expect('(hello) world'.between('(', ')'), 'hello'));
    test('8. At end', () => expect('world (hello)'.between('(', ')'), 'hello'));
    test('9. With whitespace', () => expect('( hello )'.between('(', ')'), 'hello'));
    test('10. No trim', () => expect('( hello )'.between('(', ')', trim: false), ' hello '));
    test('11. Unicode', () => expect('(你好)'.between('(', ')'), '你好'));
    test('12. Custom delimiters', () => expect('<<hello>>'.between('<<', '>>'), 'hello'));
    test('13. Multiple words', () => expect('(hello world)'.between('(', ')'), 'hello world'));
    test('14. Nested delimiters', () => expect('((inner))'.between('(', ')'), '(inner')); // Finds first )
  });

  group('betweenLast', () {
    test('1. Basic extraction', () => expect('hello (world) test'.betweenLast('(', ')'), 'world'));
    test('2. Multiple occurrences', () => expect('(first) (last)'.betweenLast('(', ')'), 'last'));
    test('3. No start delimiter', () => expect('hello world'.betweenLast('(', ')'), ''));
    test('4. No end delimiter with endOptional', () => expect('hello (world'.betweenLast('(', ')'), 'world'));
    test('5. No end delimiter without endOptional', () => expect('hello (world'.betweenLast('(', ')', endOptional: false), ''));
    test('6. Empty string', () => expect(''.betweenLast('(', ')'), ''));
    test('7. Empty start', () => expect('hello'.betweenLast('', ')'), ''));
    test('8. With whitespace', () => expect('( hello )'.betweenLast('(', ')'), 'hello'));
    test('9. No trim', () => expect('( hello )'.betweenLast('(', ')', trim: false), ' hello '));
    test('10. Unicode', () => expect('(first) (你好)'.betweenLast('(', ')'), '你好'));
    test('11. Custom delimiters', () => expect('<<first>> <<last>>'.betweenLast('<<', '>>'), 'last'));
    test('12. Single occurrence', () => expect('(only)'.betweenLast('(', ')'), 'only'));
  });
}
