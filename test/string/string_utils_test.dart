import 'package:flutter_test/flutter_test.dart';
import 'package:saropa_dart_utils/string/string_utils.dart';
// import 'package:test/test.dart';

void main() {
  group('StringExtensions', () {
    test('removeStart', () {
      expect('www.saropa.com'.removeStart('www.'), equals('saropa.com'));
      expect('saropa.com'.removeStart('www.'), equals('saropa.com'));
      expect(null.removeStart('www.'), isNull);
      expect(''.removeStart('www.'), isEmpty);
    });

    test('isNullOrEmpty', () {
      expect(null.isNullOrEmpty, isTrue);
      expect(''.isNullOrEmpty, isTrue);
      expect('Saropa'.isNullOrEmpty, isFalse);
    });

    test('notNullOrEmpty', () {
      expect(null.notNullOrEmpty, isFalse);
      expect(''.notNullOrEmpty, isFalse);
      expect('Saropa'.notNullOrEmpty, isTrue);
    });

    test('encloseInParentheses', () {
      expect('Saropa'.encloseInParentheses(), equals('(Saropa)'));
      expect(''.encloseInParentheses(wrapEmpty: true), equals('()'));
      expect(null.encloseInParentheses(), isNull);
    });

    test('wrapWith', () {
      expect('Saropa'.wrapWith(before: '(', after: ')'), equals('(Saropa)'));
      expect('Saropa'.wrapWith(before: 'Prefix-'), equals('Prefix-Saropa'));
      expect('Saropa'.wrapWith(after: '-Suffix'), equals('Saropa-Suffix'));
      expect(null.wrapWith(before: '(', after: ')'), isNull);
    });

    test('removeConsecutiveSpaces', () {
      expect(
        '  Saropa   has   multiple   spaces  '.removeConsecutiveSpaces(),
        equals('Saropa has multiple spaces'),
      );
      expect(
        '  Saropa   '.removeConsecutiveSpaces(trim: false),
        equals(' Saropa '),
      );
      expect(null.removeConsecutiveSpaces(), isEmpty);
    });

    test('compressSpaces', () {
      expect(
        '  Saropa   has   multiple   spaces  '.compressSpaces(),
        equals('Saropa has multiple spaces'),
      );
      expect('  Saropa   '.compressSpaces(trim: false), equals(' Saropa '));
      expect(null.compressSpaces(), isEmpty);
    });
  });
}
