import 'package:flutter_test/flutter_test.dart';
import 'package:saropa_dart_utils/num/num_factorial_utils.dart';
import 'package:saropa_dart_utils/num/num_lerp_utils.dart';
import 'package:saropa_dart_utils/num/num_modulo_utils.dart';
import 'package:saropa_dart_utils/num/num_prime_utils.dart';

void main() {
  group('isPrime', () {
    test('2 is prime', () => expect(isPrime(2), isTrue));
    test('4 is not prime', () => expect(isPrime(4), isFalse));
  });
  group('primeFactors', () {
    test('12 = 2*2*3', () => expect(primeFactors(12), <int>[2, 2, 3]));
  });
  group('factorial', () {
    test('5! = 120', () => expect(factorial(5), 120));
    test('negative returns null', () => expect(factorial(-1), isNull));
  });
  group('modulo', () {
    test('-1 mod 7 = 6', () => expect(modulo(-1, 7), 6));
  });
  group('lerp', () {
    test('lerp 0,10,0.5 = 5', () => expect(lerp(0, 10, 0.5), 5));
  });
  group('inverseLerp', () {
    test('inverse 5 in 0..10 = 0.5', () => expect(inverseLerp(0, 10, 5), 0.5));
  });
  group('mapRange', () {
    test('map 5 from 0-10 to 0-100', () => expect(mapRange(5, 0, 10, 0, 100), 50));
  });
}
