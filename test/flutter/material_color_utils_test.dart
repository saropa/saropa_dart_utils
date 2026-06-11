import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:saropa_dart_utils/color/material_shade.dart';
import 'package:saropa_dart_utils/flutter/material_color_utils.dart';
import 'package:saropa_dart_utils/niche/color_utils.dart';

// Converts a Flutter Color's normalized 0..1 channel to an 0..255 int so the
// pure-Dart contrastRatio (which takes int channels) can score generated colors.
int _channel255(double normalized) => (normalized * 255).round();

void main() {
  group('ColorUtils.materialColors', () {
    test('should have the expected 19 primary swatches in order', () {
      expect(ColorUtils.materialColors, hasLength(19));
      expect(ColorUtils.materialColors.first, equals(Colors.red));
      expect(ColorUtils.materialColors.last, equals(Colors.blueGrey));
    });

    test('should contain no duplicates', () {
      expect(ColorUtils.materialColors.toSet(), hasLength(19));
    });

    // A const list is unmodifiable, protecting the shared palette from callers.
    test('should be immutable (mutation throws UnsupportedError)', () {
      expect(
        () => ColorUtils.materialColors.add(Colors.red),
        throwsUnsupportedError,
      );
    });
  });

  group('ColorUtils.getColor', () {
    test('should return the exact swatch entry for each shade', () {
      expect(
        ColorUtils.getColor(MaterialShade.shade50, Colors.blue),
        equals(Colors.blue[50]),
      );
      expect(
        ColorUtils.getColor(MaterialShade.shade500, Colors.blue),
        equals(Colors.blue[500]),
      );
      expect(
        ColorUtils.getColor(MaterialShade.shade900, Colors.blue),
        equals(Colors.blue[900]),
      );
    });

    test('should make shade500 equal the base MaterialColor value', () {
      // Material swatches define shade500 as the primary tone. getColor returns
      // the plain Color at [500]; the base swatch's *primary value* is that same
      // tone, exposed as the MaterialColor's .value. Compare values (not objects)
      // because a MaterialColor and the plain Color it wraps are different runtime
      // types, so object equality fails even when the ARGB tone is identical.
      expect(
        ColorUtils.getColor(MaterialShade.shade500, Colors.red).toARGB32(),
        equals(Colors.red.toARGB32()),
      );
    });

    // Catches a Material SDK swatch that ever lacks a level (the `!` would throw).
    test('should be non-null and match swatch[value] for every swatch/shade', () {
      for (final MaterialColor swatch in ColorUtils.materialColors) {
        for (final MaterialShade shade in MaterialShade.values) {
          final Color result = ColorUtils.getColor(shade, swatch);
          expect(result, equals(swatch[shade.value]));
        }
      }
    });

    // Documents/locks the current throwing behavior for a partial custom swatch.
    test('should throw for a custom MaterialColor missing the requested level', () {
      const MaterialColor partial = MaterialColor(
        0xFF000000,
        <int, Color>{500: Color(0xFF000000)},
      );
      expect(
        () => ColorUtils.getColor(MaterialShade.shade50, partial),
        throwsA(isA<TypeError>()),
      );
    });
  });

  group('ColorUtils.getWhiteContrastColor', () {
    test('should be deterministic for the same input', () {
      expect(
        ColorUtils.getWhiteContrastColor(42),
        equals(ColorUtils.getWhiteContrastColor(42)),
      );
    });

    test('should map negatives via non-negative modulo (no RangeError)', () {
      // -1 % 100 == 99 in Dart; must not throw.
      expect(() => ColorUtils.getWhiteContrastColor(-1), returnsNormally);
      expect(
        ColorUtils.getWhiteContrastColor(-1),
        equals(ColorUtils.getWhiteContrastColor(99)),
      );
    });

    test('should wrap modulo 100', () {
      expect(
        ColorUtils.getWhiteContrastColor(100),
        equals(ColorUtils.getWhiteContrastColor(0)),
      );
      expect(
        ColorUtils.getWhiteContrastColor(142),
        equals(ColorUtils.getWhiteContrastColor(42)),
      );
    });

    test('should yield a fully opaque color for every input 0..99', () {
      for (int i = 0; i < 100; i++) {
        expect(ColorUtils.getWhiteContrastColor(i).a, equals(1.0));
      }
    });

    // int min/max are the one path that could throw if the modulo assumption
    // were ever wrong; both must normalize without error.
    test('should not throw at int extremes', () {
      const int intMin = -9223372036854775807 - 1;
      const int intMax = 9223372036854775807;
      expect(() => ColorUtils.getWhiteContrastColor(intMin), returnsNormally);
      expect(() => ColorUtils.getWhiteContrastColor(intMax), returnsNormally);
      expect(ColorUtils.getWhiteContrastColor(intMin).a, equals(1.0));
      expect(ColorUtils.getWhiteContrastColor(intMax).a, equals(1.0));
    });

    // index 0 → both palette indices 0 → red-on-red; assert the exact color so a
    // palette reorder is caught.
    test('should produce a red-on-red blend for input 0', () {
      final Color expected = Color.alphaBlend(
        Colors.red.withValues(alpha: 0.5),
        Colors.red,
      );
      expect(ColorUtils.getWhiteContrastColor(0), equals(expected));
    });

    // Boundary inputs exercise the tens/ones digit split (0↔9, 1↔0, 9↔0, 9↔9).
    test('should keep boundary inputs 9, 10, 90, 99 fully opaque', () {
      for (final int boundary in <int>[9, 10, 90, 99]) {
        expect(
          ColorUtils.getWhiteContrastColor(boundary).a,
          equals(1.0),
          reason: 'input $boundary',
        );
      }
    });

    test('should give distinct results across boundary indices 9 and 10', () {
      // 9 → (0,9), 10 → (1,0): different palette pairs, so different blends.
      expect(
        ColorUtils.getWhiteContrastColor(9),
        isNot(equals(ColorUtils.getWhiteContrastColor(10))),
      );
    });

    // Converts the dartdoc's "contrasts with white" promise into a verified
    // property; a future palette edit that breaks contrast fails here.
    test('should keep a meaningful contrast ratio against white for 0..99', () {
      for (int i = 0; i < 100; i++) {
        final Color color = ColorUtils.getWhiteContrastColor(i);
        final double ratio = contrastRatio(
          _channel255(color.r),
          _channel255(color.g),
          _channel255(color.b),
          255,
          255,
          255,
        );
        // 1.15 floor: the lightest blend (yellow-on-yellow, input 33) scores
        // ~1.22 against white; the margin absorbs alphaBlend rounding without
        // weakening the check to a trivial > 1.0.
        expect(
          ratio,
          greaterThanOrEqualTo(1.15),
          reason: 'input $i had ratio $ratio against white',
        );
      }
    });
  });
}
