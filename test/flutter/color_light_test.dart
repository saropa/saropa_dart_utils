import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:saropa_dart_utils/flutter/color_extensions.dart';

void main() {
  const Color opaqueBlue = Color(0xFF2196F3);

  group('ColorLightExtensions.darken', () {
    group('out-of-range amounts return unchanged', () {
      test('should return same color when amount is 0', () {
        expect(opaqueBlue.darken(0), equals(opaqueBlue));
      });

      test('should return same color when amount is negative', () {
        expect(opaqueBlue.darken(-0.5), equals(opaqueBlue));
      });

      test('should return same color when amount is greater than 1', () {
        expect(opaqueBlue.darken(1.5), equals(opaqueBlue));
      });

      // NaN must short-circuit; otherwise (lightness - NaN) yields a NaN color.
      test('should return same color when amount is NaN', () {
        expect(opaqueBlue.darken(double.nan), equals(opaqueBlue));
      });

      test('should return same color when amount is positive infinity', () {
        expect(opaqueBlue.darken(double.infinity), equals(opaqueBlue));
      });

      test('should return same color when amount is negative infinity', () {
        expect(opaqueBlue.darken(double.negativeInfinity), equals(opaqueBlue));
      });
    });

    group('valid amounts adjust lightness', () {
      test('should darken a color by the given amount', () {
        final HSLColor original = HSLColor.fromColor(opaqueBlue);
        final HSLColor darkened = HSLColor.fromColor(opaqueBlue.darken(0.2));
        expect(darkened.lightness, lessThan(original.lightness));
      });

      // amount == 1.0 is inclusive (isBetween is inclusive), so it must apply.
      test('should produce lightness 0 when darkening by 1', () {
        final HSLColor darkened = HSLColor.fromColor(opaqueBlue.darken(1));
        expect(darkened.lightness, equals(0.0));
      });

      // A tiny epsilon passes the guards and is a near no-op, not a no-op.
      test('should barely change for a tiny epsilon amount', () {
        final HSLColor original = HSLColor.fromColor(opaqueBlue);
        final HSLColor darkened = HSLColor.fromColor(opaqueBlue.darken(1e-12));
        expect(darkened.lightness, closeTo(original.lightness, 1e-9));
      });

      test('should preserve hue when darkening', () {
        final HSLColor original = HSLColor.fromColor(opaqueBlue);
        final HSLColor darkened = HSLColor.fromColor(opaqueBlue.darken(0.3));
        expect(darkened.hue, closeTo(original.hue, 0.5));
      });

      test('should preserve saturation when darkening', () {
        final HSLColor original = HSLColor.fromColor(opaqueBlue);
        final HSLColor darkened = HSLColor.fromColor(opaqueBlue.darken(0.3));
        expect(darkened.saturation, closeTo(original.saturation, 0.01));
      });

      test('should preserve alpha when darkening', () {
        const Color color = Color.fromARGB(128, 33, 150, 243);
        expect(color.darken(0.2).a, closeTo(color.a, 0.01));
      });
    });

    group('boundary and degenerate inputs', () {
      // Pure black is already lightness 0: darkening cannot go lower.
      test('should keep pure black black', () {
        expect(HSLColor.fromColor(const Color(0xFF000000).darken(0.5)).lightness, equals(0.0));
      });

      // Grayscale has undefined hue; ensure no NaN leaks into the result.
      test('should not produce NaN for grayscale input', () {
        final Color darkened = Colors.grey.darken(0.2);
        expect(darkened.r.isNaN, isFalse);
        expect(darkened.g.isNaN, isFalse);
        expect(darkened.b.isNaN, isFalse);
      });

      // Fully transparent alpha must survive the HSL roundtrip.
      test('should preserve fully transparent alpha', () {
        const Color transparent = Color.fromARGB(0, 33, 150, 243);
        expect(transparent.darken(0.3).a, closeTo(0.0, 0.01));
      });
    });
  });

  group('ColorLightExtensions.lighten', () {
    group('out-of-range amounts return unchanged', () {
      test('should return same color when amount is 0', () {
        expect(opaqueBlue.lighten(0), equals(opaqueBlue));
      });

      test('should return same color when amount is negative', () {
        expect(opaqueBlue.lighten(-0.5), equals(opaqueBlue));
      });

      test('should return same color when amount is greater than 1', () {
        expect(opaqueBlue.lighten(1.5), equals(opaqueBlue));
      });

      test('should return same color when amount is NaN', () {
        expect(opaqueBlue.lighten(double.nan), equals(opaqueBlue));
      });

      test('should return same color when amount is positive infinity', () {
        expect(opaqueBlue.lighten(double.infinity), equals(opaqueBlue));
      });
    });

    group('valid amounts adjust lightness', () {
      late HSLColor original;

      // Shared baseline for every lightness comparison below; recomputed per
      // test via setUp so no mutable state leaks between cases.
      setUp(() {
        original = HSLColor.fromColor(opaqueBlue);
      });

      // The three lightening-by-the-same-amount cases re-create one HSL baseline,
      // but tests below seed different inputs, so this is per-group arrange, not a
      // hoistable shared fixture. A known false positive fixed upstream in
      // saropa_lints 13.12.4 (raises the duplicate threshold when a file-level
      // setUp already exists); the project pins 13.12.3, so that fix has not
      // arrived. Keep explicit per the project's clarity-over-DRY testing rule.
      // ignore: prefer_setup_teardown
      test('should lighten a color by the given amount', () {
        final HSLColor lightened = HSLColor.fromColor(opaqueBlue.lighten(0.2));
        expect(lightened.lightness, greaterThan(original.lightness));
      });

      test('should produce lightness 1 when lightening by 1', () {
        final HSLColor lightened = HSLColor.fromColor(opaqueBlue.lighten(1));
        expect(lightened.lightness, equals(1.0));
      });

      test('should preserve hue when lightening', () {
        final HSLColor lightened = HSLColor.fromColor(opaqueBlue.lighten(0.2));
        expect(lightened.hue, closeTo(original.hue, 0.5));
      });

      test('should preserve saturation when lightening', () {
        final HSLColor lightened = HSLColor.fromColor(opaqueBlue.lighten(0.2));
        expect(lightened.saturation, closeTo(original.saturation, 0.01));
      });

      test('should preserve alpha when lightening', () {
        const Color color = Color.fromARGB(128, 33, 150, 243);
        expect(color.lighten(0.2).a, closeTo(color.a, 0.01));
      });
    });

    group('boundary and degenerate inputs', () {
      // Pure white is already lightness 1: lightening cannot go higher.
      test('should keep pure white white', () {
        expect(HSLColor.fromColor(const Color(0xFFFFFFFF).lighten(0.5)).lightness, equals(1.0));
      });

      test('should not produce NaN for grayscale input', () {
        final Color lightened = Colors.grey.lighten(0.2);
        expect(lightened.r.isNaN, isFalse);
        expect(lightened.g.isNaN, isFalse);
        expect(lightened.b.isNaN, isFalse);
      });
    });
  });

  group('darken/lighten relationship', () {
    test('darken then lighten by the same amount restores lightness', () {
      final HSLColor original = HSLColor.fromColor(opaqueBlue);
      final HSLColor modified = HSLColor.fromColor(opaqueBlue.darken(0.1).lighten(0.1));
      expect(modified.lightness, closeTo(original.lightness, 0.01));
    });

    // Clamp at the boundary means the pair is NOT a true inverse near 0/1:
    // darkening past 0 loses information, so lightening back overshoots.
    test('is not a true inverse at the lightness floor', () {
      final HSLColor original = HSLColor.fromColor(opaqueBlue);
      final HSLColor modified = HSLColor.fromColor(opaqueBlue.darken(1).lighten(0.1));
      expect(modified.lightness, isNot(closeTo(original.lightness, 0.01)));
    });
  });
}
