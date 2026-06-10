import 'package:flutter_test/flutter_test.dart';
import 'package:saropa_dart_utils/double/double_close_to_extensions.dart';

void main() {
  group('isCloseTo', () {
    test('treats accumulated rounding error as equal', () {
      expect((0.1 + 0.2).isCloseTo(0.3), isTrue);
    });

    test('distinguishes genuinely different values', () {
      expect(1.0.isCloseTo(1.5), isFalse);
    });

    test('exact equality is close', () {
      expect(2.0.isCloseTo(2.0), isTrue);
    });

    test('comparison against zero uses the absolute floor', () {
      expect(0.0.isCloseTo(1e-13), isTrue);
      expect(0.0.isCloseTo(1e-6), isFalse);
    });

    test('scales tolerance for large magnitudes', () {
      // 1e9 vs 1e9 + 1 differ by 1, well within the relative tolerance.
      expect(1e9.isCloseTo(1e9 + 1), isTrue);
    });

    test('NaN is never close, even to itself', () {
      expect(double.nan.isCloseTo(double.nan), isFalse);
      expect(1.0.isCloseTo(double.nan), isFalse);
    });

    test('same-sign infinity is close', () {
      expect(double.infinity.isCloseTo(double.infinity), isTrue);
    });

    test('opposite-sign infinity is not close', () {
      expect(double.infinity.isCloseTo(double.negativeInfinity), isFalse);
    });

    test('infinity is not close to a finite value', () {
      expect(double.infinity.isCloseTo(1e300), isFalse);
    });

    test('respects a custom tolerance', () {
      expect(1.0.isCloseTo(1.05, absoluteTolerance: 0.1), isTrue);
      expect(1.0.isCloseTo(1.05), isFalse);
    });
  });
}
