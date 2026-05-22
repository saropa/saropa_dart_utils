import 'package:flutter_test/flutter_test.dart';
import 'package:saropa_dart_utils/niche/random_string_utils.dart';

void main() {
  group('randomAlphanumeric', () {
    test('produces the requested length', () {
      expect(randomAlphanumeric(10), hasLength(10));
      expect(randomAlphanumeric(1), hasLength(1));
    });

    test('length 0 returns empty string', () {
      expect(randomAlphanumeric(0), '');
    });

    test('default uses lowercase letters and digits only', () {
      final String s = randomAlphanumeric(200);
      expect(RegExp(r'^[a-z0-9]+$').hasMatch(s), isTrue);
    });

    test('uppercase flag uses uppercase letters and digits only', () {
      final String s = randomAlphanumeric(200, isUppercase: true);
      expect(RegExp(r'^[A-Z0-9]+$').hasMatch(s), isTrue);
    });
  });
}
