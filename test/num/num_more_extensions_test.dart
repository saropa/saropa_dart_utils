import 'dart:math' show pi;

import 'package:flutter_test/flutter_test.dart';
import 'package:saropa_dart_utils/num/num_more_extensions.dart';

void main() {
  group('clampNonNegative', () {
    test('rounds positive to nearest int', () {
      expect(3.6.clampNonNegative(), 4);
      expect(3.4.clampNonNegative(), 3);
    });

    test('negative clamps to 0', () {
      expect((-2).clampNonNegative(), 0);
      expect((-0.1).clampNonNegative(), 0);
    });

    test('zero stays 0', () {
      expect(0.clampNonNegative(), 0);
    });
  });

  group('isInteger', () {
    test('int is always integer', () {
      expect(5.isInteger, isTrue);
      expect((-3).isInteger, isTrue);
    });

    test('whole double is integer', () {
      expect(2.0.isInteger, isTrue);
    });

    test('fractional double is not', () {
      expect(2.5.isInteger, isFalse);
    });
  });

  group('truncateToDecimals', () {
    test('drops digits beyond places without rounding', () {
      expect(3.14159.truncateToDecimals(2), closeTo(3.14, 1e-9));
      expect(3.199.truncateToDecimals(2), closeTo(3.19, 1e-9));
    });

    test('zero places truncates the fraction', () {
      expect(3.99.truncateToDecimals(0), closeTo(3.0, 1e-9));
    });

    test('negative numbers truncate toward zero', () {
      expect((-3.149).truncateToDecimals(1), closeTo(-3.1, 1e-9));
    });
  });

  group('percentageChangeFrom', () {
    test('increase', () {
      expect(150.percentageChangeFrom(100), closeTo(0.5, 1e-9));
    });

    test('decrease', () {
      expect(50.percentageChangeFrom(100), closeTo(-0.5, 1e-9));
    });

    test('from zero returns 0 (no division by zero)', () {
      expect(10.percentageChangeFrom(0), 0);
    });
  });

  group('percentageOf', () {
    test('fraction of total', () {
      expect(25.percentageOf(200), closeTo(0.125, 1e-9));
    });

    test('total zero returns 0', () {
      expect(5.percentageOf(0), 0);
    });
  });

  group('degreesToRadians / radiansToDegrees', () {
    test('180 degrees is pi radians', () {
      expect(degreesToRadians(180), closeTo(pi, 1e-12));
    });

    test('pi radians is 180 degrees', () {
      expect(radiansToDegrees(pi), closeTo(180, 1e-12));
    });

    test('round trip', () {
      expect(radiansToDegrees(degreesToRadians(45)), closeTo(45, 1e-9));
    });
  });

  group('normalizeAngle360', () {
    test('wraps above 360', () {
      expect(normalizeAngle360(450), closeTo(90, 1e-12));
    });

    test('wraps negatives into [0, 360)', () {
      expect(normalizeAngle360(-90), closeTo(270, 1e-12));
    });

    test('exact 360 maps to 0', () {
      expect(normalizeAngle360(360), closeTo(0, 1e-12));
    });
  });

  group('normalizeAngle180', () {
    test('maps 270 to -90', () {
      expect(normalizeAngle180(270), closeTo(-90, 1e-12));
    });

    test('keeps in-range angle', () {
      expect(normalizeAngle180(90), closeTo(90, 1e-12));
    });

    test('180 stays 180 (inclusive upper bound)', () {
      expect(normalizeAngle180(180), closeTo(180, 1e-12));
    });
  });

  group('digitSum', () {
    test('sums decimal digits', () {
      expect(digitSum(123), 6);
    });

    test('ignores sign', () {
      expect(digitSum(-49), 13);
    });

    test('zero', () {
      expect(digitSum(0), 0);
    });
  });

  group('isPowerOfTwo', () {
    test('powers of two are true', () {
      expect(isPowerOfTwo(1), isTrue);
      expect(isPowerOfTwo(2), isTrue);
      expect(isPowerOfTwo(8), isTrue);
    });

    test('non-powers are false', () {
      expect(isPowerOfTwo(6), isFalse);
    });

    test('zero and negatives are false', () {
      expect(isPowerOfTwo(0), isFalse);
      expect(isPowerOfTwo(-2), isFalse);
    });
  });

  group('nextPowerOfTwo', () {
    test('rounds up to next power of two', () {
      expect(nextPowerOfTwo(17), 32);
    });

    test('exact power stays the same', () {
      expect(nextPowerOfTwo(16), 16);
      expect(nextPowerOfTwo(1), 1);
    });

    test('non-positive returns 1', () {
      expect(nextPowerOfTwo(0), 1);
      expect(nextPowerOfTwo(-5), 1);
    });

    test('handles 64-bit inputs above 2^32', () {
      // The bit-smear must reach >> 32 for Dart's 64-bit ints. Without it these
      // large inputs round up wrongly.
      expect(nextPowerOfTwo((1 << 32) + 1), 1 << 33);
      expect(nextPowerOfTwo((1 << 40) + 1), 1 << 41);
      expect(nextPowerOfTwo(1 << 50), 1 << 50);
    });
  });

  group('isqrt', () {
    test('floor of square root', () {
      expect(isqrt(17), 4);
      expect(isqrt(16), 4);
      expect(isqrt(15), 3);
    });

    test('one', () {
      expect(isqrt(1), 1);
    });

    test('non-positive returns 0', () {
      expect(isqrt(0), 0);
      expect(isqrt(-4), 0);
    });
  });
}
