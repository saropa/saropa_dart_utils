import 'package:flutter_test/flutter_test.dart';
import 'package:saropa_dart_utils/num/num_range_extensions.dart';

void main() {
  group('isBetween', () {
    test('Result should be true', () {
      // valid data
      expect(0.5.isBetween(0, 10), isTrue);
      expect(0.5.isBetween(0, 1), isTrue);
      expect(5.isBetween(1, 10), isTrue);
    });

    test('Result should be true (ON RANGE)', () {
      // ON range
      expect(0.isBetween(0, 10), isTrue);
      expect(10.isBetween(1, 10), isTrue);
    });

    test('Result should be false', () {
      // OUT OF range
      expect(1.isBetween(2, 10), isFalse);
      expect(10.isBetween(1, 9), isFalse);
    });
  });

  group('isNotBetween', () {
    test('Result should be false', () {
      // valid data
      expect(0.5.isNotBetween(0, 10), isFalse);
      expect(0.5.isNotBetween(0, 1), isFalse);
      expect(5.isNotBetween(1, 10), isFalse);
    });

    test('Result should be false (ON RANGE)', () {
      // ON range
      expect(0.isNotBetween(0, 10), isFalse);
      expect(10.isNotBetween(1, 10), isFalse);
    });

    test('Result should be true', () {
      // OUT OF range
      expect(1.isNotBetween(2, 10), isTrue);
      expect(10.isNotBetween(1, 9), isTrue);
    });
  });
}
