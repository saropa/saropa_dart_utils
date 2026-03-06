import 'package:flutter_test/flutter_test.dart';
import 'package:saropa_dart_utils/num/math_utils.dart';

void main() {
  group('gcd', () {
    test('basic', () => expect(gcd(12, 8), 4));
    test('coprime', () => expect(gcd(7, 5), 1));
  });
  group('lcm', () {
    test('basic', () => expect(lcm(12, 8), 24));
  });
}
