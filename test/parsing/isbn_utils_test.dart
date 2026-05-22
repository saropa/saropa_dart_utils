import 'package:flutter_test/flutter_test.dart';
import 'package:saropa_dart_utils/parsing/isbn_utils.dart';

void main() {
  group('isValidIsbn10', () {
    test('valid plain digits', () => expect(isValidIsbn10('0306406152'), isTrue));

    test('invalid check digit', () => expect(isValidIsbn10('0306406153'), isFalse));

    test('valid with X check digit', () => expect(isValidIsbn10('097522980X'), isTrue));

    test('valid with hyphens stripped', () => expect(isValidIsbn10('0-306-40615-2'), isTrue));

    test('valid with spaces stripped', () => expect(isValidIsbn10('0 306 40615 2'), isTrue));

    test('lowercase x accepted (uppercased internally)', () {
      expect(isValidIsbn10('097522980x'), isTrue);
    });

    test('wrong length too short', () => expect(isValidIsbn10('030640615'), isFalse));

    test('wrong length too long', () => expect(isValidIsbn10('03064061521'), isFalse));

    test('non-digit character invalid', () => expect(isValidIsbn10('03064A6152'), isFalse));

    test('empty string invalid', () => expect(isValidIsbn10(''), isFalse));

    test('X in non-final position invalid', () => expect(isValidIsbn10('X306406152'), isFalse));
  });

  group('isValidIsbn13', () {
    test('valid with hyphens', () => expect(isValidIsbn13('978-0-306-40615-7'), isTrue));

    test('valid plain digits', () => expect(isValidIsbn13('9780306406157'), isTrue));

    test('invalid check digit', () => expect(isValidIsbn13('978-0-306-40615-0'), isFalse));

    test('valid with spaces', () => expect(isValidIsbn13('978 0 306 40615 7'), isTrue));

    test('wrong length too short', () => expect(isValidIsbn13('978030640615'), isFalse));

    test('wrong length too long', () => expect(isValidIsbn13('97803064061577'), isFalse));

    test('non-digit character invalid', () => expect(isValidIsbn13('97803064061X7'), isFalse));

    test('empty string invalid', () => expect(isValidIsbn13(''), isFalse));

    test(
      'X check digit not allowed in ISBN-13',
      () => expect(isValidIsbn13('978030640615X'), isFalse),
    );
  });
}
