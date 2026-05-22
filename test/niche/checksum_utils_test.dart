import 'package:flutter_test/flutter_test.dart';
import 'package:saropa_dart_utils/niche/checksum_utils.dart';

void main() {
  group('additiveChecksum', () {
    test('sums code units', () {
      // 'AB' -> 65 + 66 = 131.
      expect(additiveChecksum('AB'), 131);
    });

    test('single character is its code unit', () {
      expect(additiveChecksum('A'), 65);
    });

    test('empty string is 0', () {
      expect(additiveChecksum(''), 0);
    });

    test('order-independent (same characters, different order)', () {
      expect(additiveChecksum('abc'), additiveChecksum('cba'));
    });

    test('digits sum to their code units', () {
      // '0' is 48, '1' is 49 -> 97.
      expect(additiveChecksum('01'), 97);
    });
  });
}
