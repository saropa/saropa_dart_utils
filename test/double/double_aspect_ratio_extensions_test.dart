import 'package:flutter_test/flutter_test.dart';
import 'package:saropa_dart_utils/double/double_aspect_ratio_extensions.dart';

void main() {
  group('DoubleAspectRatioExtensions.toAspectRatio', () {
    // Spec sample cases — written against the source's
    // (simplifiedDenominator, simplifiedNumerator) tuple order.
    group('spec sample cases', () {
      test('simplifies a 3:2 decimal (1.5)', () {
        // 1500/1000 reduced by GCD 500 -> (2, 3) in source order.
        expect(1.5.toAspectRatio(), (2, 3));
      });

      test('simplifies a quarter step (1.25)', () {
        // 1250/1000 reduced by GCD 250 -> (4, 5) in source order.
        expect(1.25.toAspectRatio(), (4, 5));
      });

      test('whole number returns (1, value)', () {
        expect(3.0.toAspectRatio(), (1, 3));
      });

      test('one returns (1, 1)', () {
        expect(1.0.toAspectRatio(), (1, 1));
      });

      test('non-canonical 16:9 reduces the truncated 3-dp fraction', () {
        // 1.7777... -> 1777/1000, GCD 1 -> (1000, 1777) in source order.
        // Confirms the method does NOT recover the canonical 9:16 pair.
        expect((16 / 9).toAspectRatio(), (1000, 1777));
      });
    });

    // Bulletproofing gaps from the spec — each as a separate, explicit case.
    group('whole-number branch', () {
      test('zero takes the whole-number branch -> (1, 0)', () {
        // hasDecimals is false for 0.0, so the integral path applies.
        expect(0.0.toAspectRatio(), (1, 0));
      });

      test('negative whole is NOT rejected -> (1, -2)', () {
        // Only the fractional GCD path rejects negatives; whole numbers pass
        // straight through (1, toInt()).
        expect((-2.0).toAspectRatio(), (1, -2));
      });

      test('large magnitude whole -> (1, value)', () {
        expect(1.0e9.toAspectRatio(), (1, 1000000000));
      });
    });

    group('negative fractional input returns null', () {
      test('negative fractional -> null via GCD rejection', () {
        // numerator = -1500; findGreatestCommonDenominator rejects negative
        // args, so the only realistic null path fires here.
        expect((-1.5).toAspectRatio(), isNull);
      });
    });

    group('non-finite input returns null', () {
      test('NaN -> null (would otherwise throw on toInt())', () {
        expect(double.nan.toAspectRatio(), isNull);
      });

      test('positive infinity -> null', () {
        expect(double.infinity.toAspectRatio(), isNull);
      });

      test('negative infinity -> null', () {
        expect(double.negativeInfinity.toAspectRatio(), isNull);
      });
    });

    group('precision floor and truncation semantics', () {
      test('sub-millis precision rounds down to whole -> (1, 1)', () {
        // 1.0004 * 1000 = 1000.4 -> toInt() 1000 -> GCD 1000 -> (1, 1).
        expect(1.0004.toAspectRatio(), (1, 1));
      });

      test('truncates toward zero, never up: 1.0009 -> 1000 not 1001', () {
        // Pins that (this * 1000).toInt() truncates rather than rounds.
        expect(1.0009.toAspectRatio(), (1, 1));
      });

      test('just below 2.0 keeps the truncated fraction', () {
        // 1.9999 -> 1999/1000, GCD 1 -> (1000, 1999).
        expect(1.9999.toAspectRatio(), (1000, 1999));
      });

      test('smallest representable 3-dp fraction -> (1000, 1)', () {
        // 0.001 -> 1/1000, GCD 1 -> (1000, 1).
        expect(0.001.toAspectRatio(), (1000, 1));
      });
    });

    group('floating-point representation', () {
      // These lock the representation-dependent result on this Dart runtime.
      // The spec predicted 0.3 -> 299; on this runtime 0.3 * 1000 == 300.0
      // exactly, so the real reduced pair is (10, 3). Tests pin the ACTUAL
      // behavior, not the predicted value.
      test('0.3 -> (10, 3) (300/1000 reduced by GCD 100)', () {
        expect(0.3.toAspectRatio(), (10, 3));
      });

      test('0.1 -> (10, 1) (100/1000 reduced by GCD 100)', () {
        expect(0.1.toAspectRatio(), (10, 1));
      });
    });

    group('GCD recursion depth is never the failure path here', () {
      test('large numerator still reduces (depth guard not hit)', () {
        // Denominator is fixed at 1000, so Euclid terminates in a handful of
        // steps regardless of numerator size; the maxDepth (500) null branch
        // is unreachable from this call site. A representative fractional value
        // must therefore yield a non-null pair.
        final result = 1.997.toAspectRatio();
        expect(result, isNotNull);
        // 1997/1000, GCD 1 -> (1000, 1997).
        expect(result, (1000, 1997));
      });
    });

    group('tuple-order regression guard', () {
      test('order is (denominator-side, value-side), not swapped', () {
        // If a future refactor flips the returned tuple, this fails loudly.
        // 1.5 -> 1500/1000 reduced by GCD 500: value-side reduces to 3,
        // denominator-side reduces to 2, returned as (2, 3).
        final result = 1.5.toAspectRatio();
        expect(result, isNotNull);
        expect(result!.$1, 2, reason: 'first element is the denominator-side');
        expect(result.$2, 3, reason: 'second element is the value-side');
      });
    });
  });
}
