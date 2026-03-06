import 'package:flutter_test/flutter_test.dart';
import 'package:saropa_dart_utils/string/string_wildcard_extensions.dart';

void main() {
  group('wildcardMatch', () {
    test('empty pattern', () {
      expect(''.wildcardMatch(''), isTrue);
      expect('a'.wildcardMatch(''), isFalse);
    });
    test('exact', () {
      expect('hello'.wildcardMatch('hello'), isTrue);
      expect('hello'.wildcardMatch('hell'), isFalse);
    });
    test('star suffix', () {
      expect('hello.txt'.wildcardMatch('*.txt'), isTrue);
      expect('file.txt'.wildcardMatch('*.txt'), isTrue);
      expect('file.log'.wildcardMatch('*.txt'), isFalse);
    });
    test('question mark', () {
      expect('file'.wildcardMatch('f?le'), isTrue);
      expect('fle'.wildcardMatch('f?le'), isFalse);
    });
    test('star in middle', () {
      expect('ab'.wildcardMatch('a*b'), isTrue);
      expect('a123b'.wildcardMatch('a*b'), isTrue);
    });
  });
}
