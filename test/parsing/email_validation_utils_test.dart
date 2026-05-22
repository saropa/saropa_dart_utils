import 'package:flutter_test/flutter_test.dart';
import 'package:saropa_dart_utils/parsing/email_validation_utils.dart';

void main() {
  group('isValidEmail', () {
    test('standard address valid', () => expect(isValidEmail('user@example.com'), isTrue));

    test('subdomain valid', () => expect(isValidEmail('a@mail.example.co'), isTrue));

    test('plus and dots in local part valid', () {
      expect(isValidEmail('first.last+tag@example.com'), isTrue);
    });

    test('surrounding whitespace trimmed', () => expect(isValidEmail('  u@h.com  '), isTrue));

    test('empty string invalid', () => expect(isValidEmail(''), isFalse));

    test('whitespace only invalid', () => expect(isValidEmail('   '), isFalse));

    test('missing at sign invalid', () => expect(isValidEmail('not-an-email'), isFalse));

    test('missing domain invalid', () => expect(isValidEmail('user@'), isFalse));

    test('missing local part invalid', () => expect(isValidEmail('@example.com'), isFalse));

    test('missing tld dot still valid (single-label host)', () {
      // The pattern allows a bare host label with no dot.
      expect(isValidEmail('user@localhost'), isTrue);
    });

    test(
      'space inside address invalid',
      () => expect(isValidEmail('user name@example.com'), isFalse),
    );

    test('over 254 characters invalid', () {
      final String long = '${'a' * 250}@e.com';
      expect(long.length > 254, isTrue);
      expect(isValidEmail(long), isFalse);
    });

    test('double at sign invalid', () => expect(isValidEmail('a@@b.com'), isFalse));
  });
}
