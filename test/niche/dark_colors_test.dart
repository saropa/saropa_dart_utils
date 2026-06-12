import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:saropa_dart_utils/niche/color_utils.dart';
import 'package:saropa_dart_utils/niche/dark_colors.dart';

void main() {
  // The map is the single source of truth for the palette; every test below
  // pulls from `DarkColorsUtils.darkColorMap` rather than restating hex literals,
  // so a swatch edit only has to land in one place.
  group('DarkColorsUtils.darkColorMap', () {
    // --- Sample tests from the spec --------------------------------------

    test('contains an entry for every DarkColors value', () {
      for (final DarkColors c in DarkColors.values) {
        expect(
          DarkColorsUtils.darkColorMap.containsKey(c),
          isTrue,
          reason: 'missing entry for $c',
        );
      }
    });

    test('has exactly DarkColors.values.length entries', () {
      expect(
        DarkColorsUtils.darkColorMap,
        hasLength(DarkColors.values.length),
      );
    });

    test('every color is fully opaque (alpha 0xFF)', () {
      for (final Color color in DarkColorsUtils.darkColorMap.values) {
        // toARGB32() is the non-deprecated stable ARGB-int form; the top byte
        // is the alpha channel, which must be 0xFF for every swatch.
        expect((color.toARGB32() >> 24) & 0xFF, 0xFF);
      }
    });

    test('known anchor values are exact', () {
      expect(
        DarkColorsUtils.darkColorMap[DarkColors.Red],
        const Color(0xFFD32F2F),
      );
      expect(
        DarkColorsUtils.darkColorMap[DarkColors.Black],
        const Color(0xFF212121),
      );
      expect(
        DarkColorsUtils.darkColorMap[DarkColors.Blue],
        const Color(0xFF1976D2),
      );
    });

    test('all colors are distinct', () {
      final Set<int> seen = <int>{};
      for (final Color color in DarkColorsUtils.darkColorMap.values) {
        expect(
          seen.add(color.toARGB32()),
          isTrue,
          reason: 'duplicate color $color',
        );
      }
    });

    // --- Bulletproofing gaps ---------------------------------------------

    // Keyset equality catches BOTH a missing entry and a stray key the moment
    // the enum changes shape, which the count check alone cannot.
    test('keyset equals DarkColors.values exactly (no orphan keys/values)', () {
      expect(
        DarkColorsUtils.darkColorMap.keys.toSet(),
        DarkColors.values.toSet(),
      );
    });

    // The count invariant guards against silent drift when a new enum value is
    // added without a matching map entry (or vice versa).
    test('count invariant: length equals DarkColors.values.length', () {
      expect(
        DarkColorsUtils.darkColorMap.length,
        DarkColors.values.length,
      );
    });

    // Repeats the alpha check independently so the "all 20 opaque" guarantee
    // is asserted as its own named failure, not only inside the sample test.
    test('alpha is 0xFF for all 20 swatches', () {
      expect(DarkColorsUtils.darkColorMap, hasLength(20));
      for (final MapEntry<DarkColors, Color> entry in DarkColorsUtils.darkColorMap.entries) {
        expect(
          (entry.value.toARGB32() >> 24) & 0xFF,
          0xFF,
          reason: '${entry.key} is not fully opaque',
        );
      }
    });

    // A copy/paste typo collapsing two swatches into the same ARGB int is a real
    // palette failure mode; assert all 20 ints are unique.
    test('distinctness: all 20 ARGB ints are unique', () {
      final Set<int> argb = DarkColorsUtils.darkColorMap.values
          .map((Color c) => c.toARGB32())
          .toSet();
      expect(argb, hasLength(DarkColorsUtils.darkColorMap.length));
    });

    // Cross-check via the library's own color math that no swatch has drifted
    // toward white. The floor is 1.5, NOT a WCAG 3.0 UI-contrast bar: the palette
    // is the named Material 700 set, and Material's own yellow/amber/lime 700
    // swatches measure below 3.0 against white (Yellow 0xFFFBC02D is the lowest
    // at ~1.66). The contract here is fidelity to those named constants, so this
    // check guards the WHITE-DRIFT failure mode — a swatch accidentally edited
    // toward near-white — not a WCAG legibility guarantee. 1.5 clears all 20 with
    // margin while still catching a value pushed close to 0xFFFFFFFF.
    test('contrast against white is at least 1.5 for every swatch', () {
      for (final MapEntry<DarkColors, Color> entry in DarkColorsUtils.darkColorMap.entries) {
        // hexToRgb reads the low 24 bits, so passing the full ARGB int is safe.
        final List<int> rgb = hexToRgb(entry.value.toARGB32());
        final double ratio = contrastRatio(
          rgb[0],
          rgb[1],
          rgb[2],
          255,
          255,
          255,
        );
        expect(
          ratio,
          greaterThanOrEqualTo(1.5),
          reason: '${entry.key} ($ratio) has drifted toward white',
        );
      }
    });

    // Guards against a future nullable-map refactor: every value must look up
    // non-null so call sites can dereference without a null branch.
    test('lookup of every value returns non-null', () {
      for (final DarkColors c in DarkColors.values) {
        expect(
          DarkColorsUtils.darkColorMap[c],
          isNotNull,
          reason: 'null lookup for $c',
        );
      }
    });

    // Pin the brightest members explicitly — they sit closest to the contrast
    // floor, so a shift in any of them is the most likely silent regression.
    test('boundary swatches are pinned exactly', () {
      expect(
        DarkColorsUtils.darkColorMap[DarkColors.Black],
        const Color(0xFF212121),
      );
      expect(
        DarkColorsUtils.darkColorMap[DarkColors.Yellow],
        const Color(0xFFFBC02D),
      );
      expect(
        DarkColorsUtils.darkColorMap[DarkColors.Lime],
        const Color(0xFFAFB42B),
      );
      expect(
        DarkColorsUtils.darkColorMap[DarkColors.Amber],
        const Color(0xFFFFA000),
      );
    });
  });

  group('DarkColors enum stability', () {
    // Index-stability is contractual: some callers persist a swatch by `.index`,
    // so a count change or reorder would silently corrupt that stored data.
    test('has exactly 20 values', () {
      expect(DarkColors.values, hasLength(20));
    });

    test('Red is index 0 and Black is index 19', () {
      expect(DarkColors.Red.index, 0);
      expect(DarkColors.Black.index, 19);
    });

    // Lock the full order so any reordering — not just the two anchors — fails.
    test('value order is stable end to end', () {
      expect(DarkColors.values, <DarkColors>[
        DarkColors.Red,
        DarkColors.Pink,
        DarkColors.Purple,
        DarkColors.DeepPurple,
        DarkColors.Indigo,
        DarkColors.Blue,
        DarkColors.LightBlue,
        DarkColors.Cyan,
        DarkColors.Teal,
        DarkColors.Green,
        DarkColors.LightGreen,
        DarkColors.Lime,
        DarkColors.Yellow,
        DarkColors.Amber,
        DarkColors.Orange,
        DarkColors.DeepOrange,
        DarkColors.Brown,
        DarkColors.Grey,
        DarkColors.BlueGrey,
        DarkColors.Black,
      ]);
    });
  });
}
