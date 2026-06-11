import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:saropa_dart_utils/flutter/color_extensions.dart';

void main() {
  // Local copy of the WCAG contrast formula so assertions are independent of
  // the private helper under test.
  double contrast(Color a, Color b) {
    final double la = a.computeLuminance() + 0.05;
    final double lb = b.computeLuminance() + 0.05;
    return la > lb ? la / lb : lb / la;
  }

  const Color gold = Color.fromRGBO(207, 181, 59, 1);
  const Color cream = Color.fromRGBO(245, 243, 235, 1);
  const Color darkPanel = Color.fromRGBO(28, 28, 30, 1);

  group('ColorContrastExtensions.readableOn', () {
    group('convergence direction', () {
      test('should darken a light accent until it is readable on a light panel', () {
        final Color readable = gold.readableOn(cream);
        expect(contrast(gold, cream) < 4.5, isTrue);
        expect(contrast(readable, cream) >= 4.5, isTrue);
        expect(readable.computeLuminance() < gold.computeLuminance(), isTrue);
      });

      test('should leave an already-readable color effectively unchanged', () {
        expect(contrast(gold, darkPanel) >= 4.5, isTrue);
        final Color readable = gold.readableOn(darkPanel);
        expect(readable.computeLuminance(), closeTo(gold.computeLuminance(), 0.001));
      });

      test('should lighten a dark accent until it is readable on a dark panel', () {
        const Color darkNavy = Color.fromRGBO(20, 30, 60, 1);
        final Color readable = darkNavy.readableOn(darkPanel);
        expect(contrast(readable, darkPanel) >= 4.5, isTrue);
        expect(readable.computeLuminance() > darkNavy.computeLuminance(), isTrue);
      });
    });

    group('best-effort termination without throwing', () {
      test('should return a Color for an unreachable target', () {
        const Color midGray = Color.fromRGBO(128, 128, 128, 1);
        expect(midGray.readableOn(midGray, maxSteps: 4), isA<Color>());
      });

      // minRatio 21 on a non-black/white pair is unreachable; must cap, not spin.
      test('should cap at maxSteps for an unreachable minRatio of 21', () {
        final Color readable = gold.readableOn(cream, minRatio: 21);
        expect(readable, isA<Color>());
      });

      // Identical fg/bg has contrast 1.0 and can never reach 4.5.
      test('should not spin when foreground equals background', () {
        expect(gold.readableOn(gold), isA<Color>());
      });
    });

    group('trivially satisfied targets return this unchanged', () {
      // Any color already clears a minRatio <= 1.0 on the first iteration.
      test('should return this on the first iteration for minRatio 1.0', () {
        expect(gold.readableOn(cream, minRatio: 1), equals(gold));
      });
    });

    group('loop-bound guards', () {
      // maxSteps 0: loop body never runs -> this unchanged (no off-by-one).
      test('should return this when maxSteps is 0', () {
        expect(gold.readableOn(cream, maxSteps: 0), equals(gold));
      });

      // Negative maxSteps: for(i=0; i<negative;) never enters -> this.
      test('should return this when maxSteps is negative', () {
        expect(gold.readableOn(cream, maxSteps: -3), equals(gold));
      });
    });

    group('no-op step values still terminate', () {
      // step 0: darken/lighten(0) is a no-op, so it never converges but must
      // exit after maxSteps with this color.
      test('should terminate and return this when step is 0', () {
        expect(gold.readableOn(cream, step: 0), equals(gold));
      });

      // step NaN: guarded out by darken/lighten -> no change, best-effort this.
      test('should terminate and return this when step is NaN', () {
        expect(gold.readableOn(cream, step: double.nan), equals(gold));
      });

      test('should terminate and return this when step is negative', () {
        expect(gold.readableOn(cream, step: -0.04), equals(gold));
      });
    });

    group('0.45 luminance split', () {
      // The branch splits at > 0.45: a background just above pushes the
      // foreground darker, just below pushes it lighter. A mid-gray foreground
      // makes the direction observable. Grayscale luminance ~0.216 sits below
      // 0.45 (lightens) and ~0.527 sits above (darkens) -- bracket the split.
      test('should lighten the foreground against a background below 0.45', () {
        const Color bgBelow = Color.fromRGBO(120, 120, 120, 1);
        const Color fg = Color.fromRGBO(110, 110, 110, 1);
        expect(bgBelow.computeLuminance() < 0.45, isTrue);
        final Color readable = fg.readableOn(bgBelow, maxSteps: 2);
        expect(readable.computeLuminance() >= fg.computeLuminance(), isTrue);
      });

      test('should darken the foreground against a background above 0.45', () {
        const Color bgAbove = Color.fromRGBO(200, 200, 200, 1);
        const Color fg = Color.fromRGBO(190, 190, 190, 1);
        expect(bgAbove.computeLuminance() > 0.45, isTrue);
        final Color readable = fg.readableOn(bgAbove, maxSteps: 2);
        expect(readable.computeLuminance() <= fg.computeLuminance(), isTrue);
      });
    });

    group('alpha and luminance assumptions', () {
      // computeLuminance ignores alpha; the result keeps this color's alpha.
      test('should preserve the foreground alpha in the result', () {
        const Color semiGold = Color.fromRGBO(207, 181, 59, 0.5);
        expect(semiGold.readableOn(cream).a, closeTo(semiGold.a, 0.02));
      });
    });
  });
}
