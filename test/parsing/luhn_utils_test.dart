import 'package:flutter_test/flutter_test.dart';
import 'package:saropa_dart_utils/parsing/luhn_utils.dart';

void main() {
  group('luhnCheck', () {
    test('valid Visa test number', () => expect(luhnCheck('4532015112830366'), isTrue));

    test('invalid when last digit altered', () => expect(luhnCheck('4532015112830367'), isFalse));

    test('valid simple example', () => expect(luhnCheck('79927398713'), isTrue));

    test('invalid simple example', () => expect(luhnCheck('79927398710'), isFalse));

    test('non-digit separators stripped then validated', () {
      expect(luhnCheck('4532-0151-1283-0366'), isTrue);
    });

    test('spaces stripped then validated', () {
      expect(luhnCheck('4532 0151 1283 0366'), isTrue);
    });

    test('empty string invalid', () => expect(luhnCheck(''), isFalse));

    test('single digit too short', () => expect(luhnCheck('5'), isFalse));

    test('two-digit valid (18)', () => expect(luhnCheck('18'), isTrue));

    test('two-digit invalid (12)', () => expect(luhnCheck('12'), isFalse));

    test('all non-digits invalid (under min length)', () => expect(luhnCheck('abcd'), isFalse));
  });
}
