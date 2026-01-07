import 'package:flutter_test/flutter_test.dart';
import 'package:saropa_dart_utils/num/num_range_extensions.dart';

void main() {
  group('isBetween', () {
    test('Result should be true', () {
      // valid data
      expect(0.5.isBetween(0, 10), true);
      expect(0.5.isBetween(0, 1), true);
      expect(5.isBetween(1, 10), true);
    });

    test('Result should be true (ON RANGE)', () {
      // ON range
      expect(0.isBetween(0, 10), true);
      expect(10.isBetween(1, 10), true);
    });

    test('Result should be false', () {
      // OUT OF range
      expect(1.isBetween(2, 10), false);
      expect(10.isBetween(1, 9), false);
    });
  });

  group('isNotBetween', () {
    test('Result should be false', () {
      // valid data
      expect(0.5.isNotBetween(0, 10), false);
      expect(0.5.isNotBetween(0, 1), false);
      expect(5.isNotBetween(1, 10), false);
    });

    test('Result should be false (ON RANGE)', () {
      // ON range
      expect(0.isNotBetween(0, 10), false);
      expect(10.isNotBetween(1, 10), false);
    });

    test('Result should be true', () {
      // OUT OF range
      expect(1.isNotBetween(2, 10), true);
      expect(10.isNotBetween(1, 9), true);
    });
  });
}
