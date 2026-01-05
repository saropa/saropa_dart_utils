import 'package:flutter_test/flutter_test.dart';
import 'package:saropa_dart_utils/double/double_extensions.dart';

void main() {
  group('DoubleExtensions', () {
    group('hasDecimals', () {
      test('returns true for decimal values', () {
        expect(15.5.hasDecimals, isTrue);
        expect(0.1.hasDecimals, isTrue);
        expect(100.001.hasDecimals, isTrue);
      });

      test('returns false for whole numbers', () {
        expect(15.0.hasDecimals, isFalse);
        expect(0.0.hasDecimals, isFalse);
        expect(100.00.hasDecimals, isFalse);
      });

      test('handles negative numbers', () {
        expect((-15.5).hasDecimals, isTrue);
        expect((-15.0).hasDecimals, isFalse);
      });
    });

    group('toPercentage', () {
      test('converts decimal to percentage', () {
        expect(0.5.toPercentage(), equals('50%'));
        expect(1.0.toPercentage(), equals('100%'));
        expect(0.0.toPercentage(), equals('0%'));
      });

      test('rounds down by default', () {
        expect(0.999.toPercentage(), equals('99%'));
        expect(0.756.toPercentage(), equals('75%'));
      });

      test('respects decimal places with roundDown', () {
        expect(0.756.toPercentage(decimalPlaces: 1), equals('75.6%'));
        expect(0.7567.toPercentage(decimalPlaces: 2), equals('75.67%'));
      });

      test('rounds normally when roundDown is false', () {
        expect(0.999.toPercentage(roundDown: false), equals('100%'));
        expect(0.995.toPercentage(roundDown: false), equals('100%'));
      });

      test('handles values over 100%', () {
        expect(1.5.toPercentage(), equals('150%'));
        expect(2.0.toPercentage(), equals('200%'));
      });

      test('handles negative percentages', () {
        expect((-0.5).toPercentage(), equals('-50%'));
      });

      test('removes trailing zeros', () {
        expect(0.5.toPercentage(decimalPlaces: 2), equals('50%'));
        expect(0.505.toPercentage(decimalPlaces: 2), equals('50.5%'));
      });
    });

    group('formatDouble', () {
      test('formats with specified decimal places', () {
        expect(15.0.formatDouble(2), equals('15.00'));
        expect(15.123.formatDouble(2), equals('15.12'));
        expect(15.126.formatDouble(2), equals('15.13'));
      });

      test('removes trailing zeros when showTrailingZeros is false', () {
        expect(15.0.formatDouble(2, showTrailingZeros: false), equals('15'));
        expect(15.5.formatDouble(2, showTrailingZeros: false), equals('15.5'));
        expect(15.05.formatDouble(2, showTrailingZeros: false), equals('15.05'));
      });

      test('keeps trailing zeros when showTrailingZeros is true', () {
        expect(15.0.formatDouble(2, showTrailingZeros: true), equals('15.00'));
        expect(15.5.formatDouble(2, showTrailingZeros: true), equals('15.50'));
      });

      test('handles zero decimal places', () {
        expect(15.6.formatDouble(0), equals('16'));
        expect(15.4.formatDouble(0), equals('15'));
      });

      test('handles negative numbers', () {
        expect((-15.5).formatDouble(2), equals('-15.50'));
        expect((-15.0).formatDouble(2, showTrailingZeros: false), equals('-15'));
      });
    });

    group('forceBetween', () {
      test('returns value when within range', () {
        expect(5.0.forceBetween(0.0, 10.0), equals(5.0));
        expect(0.0.forceBetween(0.0, 10.0), equals(0.0));
        expect(10.0.forceBetween(0.0, 10.0), equals(10.0));
      });

      test('clamps to minimum when below range', () {
        expect((-5.0).forceBetween(0.0, 10.0), equals(0.0));
        expect((-100.0).forceBetween(0.0, 10.0), equals(0.0));
      });

      test('clamps to maximum when above range', () {
        expect(15.0.forceBetween(0.0, 10.0), equals(10.0));
        expect(100.0.forceBetween(0.0, 10.0), equals(10.0));
      });

      test('works with negative ranges', () {
        expect(0.0.forceBetween(-10.0, -5.0), equals(-5.0));
        expect((-7.0).forceBetween(-10.0, -5.0), equals(-7.0));
        expect((-15.0).forceBetween(-10.0, -5.0), equals(-10.0));
      });
    });

    group('toPrecision', () {
      test('truncates to specified precision', () {
        expect(3.14159.toPrecision(2), equals(3.14));
        expect(3.149.toPrecision(2), equals(3.14));
        expect(3.999.toPrecision(2), equals(3.99));
      });

      test('handles zero precision', () {
        expect(3.9.toPrecision(0), equals(3.0));
        expect(3.1.toPrecision(0), equals(3.0));
      });

      test('handles negative numbers', () {
        expect((-3.149).toPrecision(2), equals(-3.14));
      });

      test('returns same value when precision matches', () {
        expect(3.14.toPrecision(2), equals(3.14));
      });
    });

    group('formatPrecision', () {
      test('removes decimals for whole numbers', () {
        expect(15.0.formatPrecision(), equals('15'));
        expect(15.00.formatPrecision(), equals('15'));
      });

      test('keeps decimals for non-whole numbers', () {
        expect(15.5.formatPrecision(), equals('15.50'));
        expect(15.12.formatPrecision(), equals('15.12'));
      });

      test('respects custom precision', () {
        expect(15.123.formatPrecision(precision: 1), equals('15.1'));
        expect(15.123.formatPrecision(precision: 3), equals('15.123'));
      });

      test('handles negative numbers', () {
        expect((-15.0).formatPrecision(), equals('-15'));
        expect((-15.5).formatPrecision(), equals('-15.50'));
      });
    });
  });
}
