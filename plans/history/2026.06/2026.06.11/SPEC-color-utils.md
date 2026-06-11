# SPEC: ColorStringExtensions.toColor, ColorHexExtension.toHex, ColorLightExtensions.darken/lighten, ColorContrastExtensions.readableOn — for inclusion

**Status:** Proposed (from Saropa Contacts)
**Proposed location:** lib/niche/color_utils.dart (extend the existing file) or a new `lib/flutter/color_extensions.dart`
**Portability:** Flutter — depends on `dart:ui` `Color` / `flutter/material.dart` (`HSLColor`, `Color`). NOT pure Dart. No external packages beyond `flutter`. (Uses `removeAll`, `isNotBetween`, `isZeroOrNegative` which are themselves saropa_dart_utils extensions — see note below.)

## Purpose — what it does + why it is general-purpose (not proprietary)

Flutter `Color` <-> hex-string conversion plus HSL lightness adjustment and a WCAG-contrast convergence helper. All four are generic UI color math with no contact-domain, app-format, or Saropa-specific coupling:

- `String.toColor()` — parses a 6- or 8-digit hex string (with or without a leading `#`, case-insensitive, trims whitespace) into a Flutter `Color`. 6-digit input is treated as `RRGGBB` and forced to full opacity (`0xFF` alpha). Returns `null` for empty, wrong-length, or non-hex input.
- `Color.toHex({bool includeAlpha = true})` — formats a `Color` as `#AARRGGBB` (or `#RRGGBB` when `includeAlpha: false`), uppercase, zero-padded.
- `Color.darken(double amount)` / `Color.lighten(double amount)` — adjust HSL lightness by `amount` (0..1), preserving hue/saturation/alpha. `amount` outside the valid range (`<= 0` for lighten / `== 0` or out-of-`[0,1]` for darken) returns the color unchanged.
- `Color.readableOn(Color background, {minRatio = 4.5, step = 0.04, maxSteps = 16})` — iteratively darkens (light bg) or lightens (dark bg) the foreground until it meets a target WCAG contrast ratio against `background`, capped by `maxSteps` so an unreachable target returns best-effort instead of spinning.

### Overlap with the installed library (1.4.1)

`lib/niche/color_utils.dart` already ships INT-based color math, NOT `Color`-based:

- `hexToRgb(int)` -> `List<int>` (unpack channels)
- `rgbToHex(int r, int g, int b)` -> `int` (pack to `0xAARRGGBB`)
- `luminance(int r, int g, int b)` -> `double` (WCAG relative luminance)
- `contrastRatio(int r1,g1,b1, r2,g2,b2)` -> `double` (WCAG ratio)

**Verdict: partial-overlap, mostly additive.** The library has NO Flutter `Color` type anywhere in these functions and NO string<->Color parsing/formatting. What this util adds:

1. **Flutter `Color` <-> hex STRING** (`toColor` / `toHex`) — the library only has `int` <-> `List<int>` packing, never a `#RRGGBB` string parser/formatter. Net-new.
2. **HSL lightness adjust** (`darken` / `lighten`) on a `Color`. Net-new — no HSL math in the library.
3. **`readableOn`** — convergence-to-contrast-target helper returning a `Color`. The library's `contrastRatio` computes a ratio but does NOT adjust a color to reach one. Net-new; internally it could reuse the library's `luminance`/`contrastRatio` if a `Color`-channel bridge were added, but the public API is new.

The private `_wcagContrast(Color, Color)` helper in this util DUPLICATES the library's `contrastRatio` math (it uses `Color.computeLuminance()`, which already applies sRGB gamma). On inclusion, keep `_wcagContrast` as the `Color`-typed convenience but note the library already owns the int-channel version.

## Source (from Saropa Contacts) — verbatim, debug logging stripped

```dart
import 'package:flutter/material.dart';
import 'package:saropa_dart_utils/saropa_dart_utils.dart'; // removeAll, isNotBetween, isZeroOrNegative

extension ColorStringExtensions on String {
  Color? toColor() {
    if (isEmpty) {
      return null;
    }

    // https://stackoverflow.com/questions/49835146/how-to-convert-flutter-color-to-string-and-back-to-a-color
    final String hexColor = removeAll('#').trim();
    switch (hexColor.length) {
      case 6:
        // convert 6 digit hex (no alpha channel) to 8 digit
        final int? parse = int.tryParse('0xFF$hexColor');
        if (parse == null) {
          return null;
        }

        return Color(parse);
      case 8:
        // Renamed from 'parse' to avoid shadowing the case-6 local of the same name.
        final int? parseHex8 = int.tryParse('0x$hexColor');
        if (parseHex8 == null) {
          return null;
        }

        return Color(parseHex8);
    }

    return null;
  }
}

extension ColorHexExtension on Color {
  /// Converts [Color] to hex string with format '#AARRGGBB' or '#RRGGBB'.
  ///
  /// - [includeAlpha] if true, includes alpha channel (8 chars), otherwise 6 chars
  ///
  /// ```dart
  /// final String hex = Colors.blue.toHex(); // '#FF2196F3'
  /// final String hexNoAlpha = Colors.blue.toHex(includeAlpha: false); // '#2196F3'
  /// ```
  String toHex({bool includeAlpha = true}) {
    if (includeAlpha) {
      return '#${(a * 255).round().toRadixString(16).padLeft(2, '0').toUpperCase()}'
          '${(r * 255).round().toRadixString(16).padLeft(2, '0').toUpperCase()}'
          '${(g * 255).round().toRadixString(16).padLeft(2, '0').toUpperCase()}'
          '${(b * 255).round().toRadixString(16).padLeft(2, '0').toUpperCase()}';
    }

    return '#${(r * 255).round().toRadixString(16).padLeft(2, '0').toUpperCase()}'
        '${(g * 255).round().toRadixString(16).padLeft(2, '0').toUpperCase()}'
        '${(b * 255).round().toRadixString(16).padLeft(2, '0').toUpperCase()}';
  }
}

extension ColorLightExtensions on Color {
  ///  darken Color
  ///
  /// - [amount] must be between 0 and 1
  ///
  /// ```dart
  /// final Color darkBlue  = darken(Colors.blue, .3);
  /// ```
  Color darken(double amount) {
    // nothing to do!
    if (amount == 0) {
      return this;
    }

    if (amount.isNotBetween(0, 1)) {
      // [amount] must be between 0 and 1 -> return unchanged
      return this;
    }

    // The use of HSL is particularly advantageous for lightness adjustments compared to direct RGB manipulation.
    // ref: https://stackoverflow.com/questions/58360989/programmarally-lighten-or-darken-a-hex-color-in-dart
    final HSLColor hsl = HSLColor.fromColor(this);

    // note the minus -
    final HSLColor hslDark = hsl.withLightness((hsl.lightness - amount).clamp(0, 1));

    return hslDark.toColor();
  }

  ///  lighten Color
  ///
  /// - [amount] must be between 0 and 1
  ///
  /// ```dart
  /// final Color lightRed = lighten(Colors.red);
  /// ```
  Color lighten(double amount) {
    if (amount.isZeroOrNegative) {
      // nothing to do!
      return this;
    }

    if (amount.isNotBetween(0, 1)) {
      // [amount] must be between 0 and 1 -> return unchanged
      return this;
    }

    // ref: https://stackoverflow.com/questions/58360989/programmarally-lighten-or-darken-a-hex-color-in-dart
    final HSLColor hsl = HSLColor.fromColor(this);

    // note the plus +
    final HSLColor hslLight = hsl.withLightness((hsl.lightness + amount).clamp(0, 1));

    return hslLight.toColor();
  }
}

extension ColorContrastExtensions on Color {
  /// Adjusts this color's lightness until it reaches at least [minRatio]
  /// WCAG contrast against [background], so it stays legible as text or
  /// icons drawn on a tinted surface. Darkens the foreground when
  /// [background] is light and lightens it when dark -- so one call works
  /// in both light and dark mode.
  ///
  /// [step] is the per-iteration HSL lightness delta; [maxSteps] caps the
  /// loop so a pathological pair that can never reach the target (e.g.
  /// mid-grey on mid-grey) returns the best effort instead of spinning.
  Color readableOn(
    Color background, {
    double minRatio = 4.5,
    double step = 0.04,
    int maxSteps = 16,
  }) {
    // Light background -> push the foreground darker; dark background ->
    // push it lighter. Split at 0.45 rather than the 0.5 luminance
    // midpoint because a mid background reads as "light" to the eye a
    // touch before the math midpoint.
    final bool darkenToward = background.computeLuminance() > 0.45;
    Color result = this;
    for (int i = 0; i < maxSteps; i++) {
      if (_wcagContrast(result, background) >= minRatio) {
        return result;
      }
      result = darkenToward ? result.darken(step) : result.lighten(step);
    }
    return result;
  }
}

/// WCAG 2.x contrast ratio between two opaque colors: (L1 + 0.05) / (L2 +
/// 0.05) with L1 the lighter luminance. [Color.computeLuminance] already
/// applies the sRGB gamma expansion, so it IS the WCAG relative luminance --
/// no need to reimplement the channel math.
double _wcagContrast(Color a, Color b) {
  final double la = a.computeLuminance() + 0.05;
  final double lb = b.computeLuminance() + 0.05;
  return la > lb ? la / lb : lb / la;
}
```

### Excluded members + why

- **`debug(...)` / `debugException(...)` / `DebugLevels.Warning` calls** — Saropa app logging (Crashlytics-backed). Stripped from every method above. The out-of-range guards retain their early-return behavior; only the log line is removed. On inclusion, either drop silently (current behavior is already "return unchanged") or throw `ArgumentError` (see Bulletproofing gaps).
- **`import 'package:saropa/utils/_dev/debug.dart'`** — app-internal logging import; removed.
- Dependency note: `removeAll`, `isNotBetween`, `isZeroOrNegative` are saropa_dart_utils extensions already in this package — fine to keep, but verify they exist in the target version (they do as of 1.4.x: `String.removeAll`, `num.isNotBetween`, `num.isZeroOrNegative`).

Nothing proprietary remains — no contact logic, no app formats, no Font Awesome, no l10n.

## Test cases — existing tests (from Saropa Contacts), verbatim

Source: `d:/src/contacts/test/lib/utils/primitive/color_utils_test.dart`. (The `// ignore: prefer_setup_teardown` block and its FP comment are project-lint artifacts; drop on inclusion.)

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:saropa/utils/primitive/color_utils.dart';

void main() {
  group('ColorHexExtension.toHex', () {
    group('with alpha (default)', () {
      test('returns correct hex for opaque blue', () {
        expect(Colors.blue.toHex(), '#FF2196F3');
      });
      test('returns correct hex for opaque red', () {
        expect(Colors.red.toHex(), '#FFF44336');
      });
      test('returns correct hex for opaque green', () {
        expect(Colors.green.toHex(), '#FF4CAF50');
      });
      test('returns correct hex for opaque white', () {
        expect(Colors.white.toHex(), '#FFFFFFFF');
      });
      test('returns correct hex for opaque black', () {
        expect(Colors.black.toHex(), '#FF000000');
      });
      test('returns correct hex for semi-transparent color', () {
        const Color color = Color.fromARGB(128, 255, 0, 0);
        expect(color.toHex(), '#80FF0000');
      });
      test('returns correct hex for fully transparent color', () {
        const Color color = Color.fromARGB(0, 255, 128, 64);
        expect(color.toHex(), '#00FF8040');
      });
      test('returns correct hex for custom color', () {
        const Color color = Color.fromARGB(255, 18, 52, 86);
        expect(color.toHex(), '#FF123456');
      });
    });

    group('without alpha', () {
      test('returns correct hex for blue without alpha', () {
        expect(Colors.blue.toHex(includeAlpha: false), '#2196F3');
      });
      test('returns correct hex for red without alpha', () {
        expect(Colors.red.toHex(includeAlpha: false), '#F44336');
      });
      test('returns correct hex for green without alpha', () {
        expect(Colors.green.toHex(includeAlpha: false), '#4CAF50');
      });
      test('returns correct hex for white without alpha', () {
        expect(Colors.white.toHex(includeAlpha: false), '#FFFFFF');
      });
      test('returns correct hex for black without alpha', () {
        expect(Colors.black.toHex(includeAlpha: false), '#000000');
      });
      test('returns correct hex for custom color without alpha', () {
        const Color color = Color.fromARGB(255, 171, 205, 239);
        expect(color.toHex(includeAlpha: false), '#ABCDEF');
      });
    });

    group('edge cases', () {
      test('handles low RGB values correctly (pads with zeros)', () {
        const Color color = Color.fromARGB(255, 0, 1, 15);
        expect(color.toHex(), '#FF00010F');
        expect(color.toHex(includeAlpha: false), '#00010F');
      });
      test('handles low alpha value correctly', () {
        const Color color = Color.fromARGB(1, 0, 0, 0);
        expect(color.toHex(), '#01000000');
      });
    });
  });

  group('ColorStringExtensions.toColor', () {
    test('returns null for empty string', () {
      expect(''.toColor(), isNull);
    });
    test('parses 6-digit hex without hash', () {
      final Color? color = '2196F3'.toColor();
      expect(color, isNotNull);
      expect(color, equals(const Color(0xFF2196F3)));
    });
    test('parses 6-digit hex with hash', () {
      final Color? color = '#2196F3'.toColor();
      expect(color, isNotNull);
      expect(color, equals(const Color(0xFF2196F3)));
    });
    test('parses 8-digit hex without hash', () {
      final Color? color = 'FF2196F3'.toColor();
      expect(color, isNotNull);
      expect(color, equals(const Color(0xFF2196F3)));
    });
    test('parses 8-digit hex with hash', () {
      final Color? color = '#FF2196F3'.toColor();
      expect(color, isNotNull);
      expect(color, equals(const Color(0xFF2196F3)));
    });
    test('parses semi-transparent color', () {
      final Color? color = '#80FF0000'.toColor();
      expect(color, isNotNull);
      expect(color, equals(const Color(0x80FF0000)));
    });
    test('returns null for invalid hex', () {
      expect('GGGGGG'.toColor(), isNull);
    });
    test('returns null for wrong length', () {
      expect('12345'.toColor(), isNull);
      expect('1234567'.toColor(), isNull);
      expect('123456789'.toColor(), isNull);
    });
    test('handles lowercase hex', () {
      final Color? color = '#abcdef'.toColor();
      expect(color, isNotNull);
      expect(color, equals(const Color(0xFFABCDEF)));
    });
    test('handles whitespace with hash', () {
      final Color? color = ' #2196F3 '.toColor();
      expect(color, isNotNull);
      expect(color, equals(const Color(0xFF2196F3)));
    });
  });

  group('roundtrip conversion', () {
    test('toHex and toColor roundtrip preserves color with alpha', () {
      const Color original = Color.fromARGB(200, 100, 150, 200);
      final String hex = original.toHex();
      final Color? restored = hex.toColor();
      expect(restored, equals(original));
    });
    test('toHex and toColor roundtrip preserves opaque color', () {
      const Color original = Color(0xFF9C27B0); // purple value
      final String hex = original.toHex();
      final Color? restored = hex.toColor();
      expect(restored, equals(original));
    });
    test('toHex without alpha and toColor roundtrip adds full opacity', () {
      const Color original = Color.fromARGB(128, 100, 150, 200);
      final String hex = original.toHex(includeAlpha: false);
      final Color? restored = hex.toColor();
      expect(restored, equals(const Color.fromARGB(255, 100, 150, 200)));
    });
  });

  group('ColorLightExtensions.darken', () {
    test('returns same color when amount is 0', () {
      const Color color = Color(0xFF2196F3);
      expect(color.darken(0), equals(color));
    });
    test('returns same color when amount is negative', () {
      const Color color = Color(0xFF2196F3);
      expect(color.darken(-0.5), equals(color));
    });
    test('returns same color when amount is greater than 1', () {
      const Color color = Color(0xFF2196F3);
      expect(color.darken(1.5), equals(color));
    });
    test('darkens a color by given amount', () {
      const Color color = Color(0xFF2196F3);
      final Color darkened = color.darken(0.2);
      final HSLColor originalHsl = HSLColor.fromColor(color);
      final HSLColor darkenedHsl = HSLColor.fromColor(darkened);
      expect(darkenedHsl.lightness, lessThan(originalHsl.lightness));
    });
    test('darkening by 1 produces very dark color', () {
      const Color color = Color(0xFF2196F3);
      final Color darkened = color.darken(1.0);
      final HSLColor darkenedHsl = HSLColor.fromColor(darkened);
      expect(darkenedHsl.lightness, equals(0.0));
    });
    test('preserves hue when darkening', () {
      const Color color = Color(0xFF2196F3);
      final Color darkened = color.darken(0.3);
      final HSLColor originalHsl = HSLColor.fromColor(color);
      final HSLColor darkenedHsl = HSLColor.fromColor(darkened);
      expect(darkenedHsl.hue, closeTo(originalHsl.hue, 0.5));
    });
    test('preserves saturation when darkening', () {
      const Color color = Color(0xFF2196F3);
      final Color darkened = color.darken(0.3);
      final HSLColor originalHsl = HSLColor.fromColor(color);
      final HSLColor darkenedHsl = HSLColor.fromColor(darkened);
      expect(darkenedHsl.saturation, closeTo(originalHsl.saturation, 0.01));
    });
    test('preserves alpha when darkening', () {
      const Color color = Color.fromARGB(128, 33, 150, 243);
      final Color darkened = color.darken(0.2);
      expect(darkened.a, closeTo(color.a, 0.01));
    });
  });

  group('ColorLightExtensions.lighten', () {
    late Color opaqueBlue;
    setUp(() {
      opaqueBlue = const Color(0xFF2196F3);
    });
    test('returns same color when amount is 0', () {
      expect(opaqueBlue.lighten(0), equals(opaqueBlue));
    });
    test('returns same color when amount is negative', () {
      expect(opaqueBlue.lighten(-0.5), equals(opaqueBlue));
    });
    test('returns same color when amount is greater than 1', () {
      expect(opaqueBlue.lighten(1.5), equals(opaqueBlue));
    });
    test('lightens a color by given amount', () {
      final Color lightened = opaqueBlue.lighten(0.2);
      final HSLColor originalHsl = HSLColor.fromColor(opaqueBlue);
      final HSLColor lightenedHsl = HSLColor.fromColor(lightened);
      expect(lightenedHsl.lightness, greaterThan(originalHsl.lightness));
    });
    test('lightening by 1 produces very light color', () {
      final Color lightened = opaqueBlue.lighten(1.0);
      final HSLColor lightenedHsl = HSLColor.fromColor(lightened);
      expect(lightenedHsl.lightness, equals(1.0));
    });
    test('preserves hue when lightening', () {
      final Color lightened = opaqueBlue.lighten(0.2);
      final HSLColor originalHsl = HSLColor.fromColor(opaqueBlue);
      final HSLColor lightenedHsl = HSLColor.fromColor(lightened);
      // Note: at extreme lightness, hue becomes undefined
      expect(lightenedHsl.hue, closeTo(originalHsl.hue, 0.5));
    });
    test('preserves saturation when lightening', () {
      final Color lightened = opaqueBlue.lighten(0.2);
      final HSLColor originalHsl = HSLColor.fromColor(opaqueBlue);
      final HSLColor lightenedHsl = HSLColor.fromColor(lightened);
      expect(lightenedHsl.saturation, closeTo(originalHsl.saturation, 0.01));
    });
    test('preserves alpha when lightening', () {
      const Color alphaColor = Color.fromARGB(128, 33, 150, 243);
      final Color lightened = alphaColor.lighten(0.2);
      expect(lightened.a, closeTo(alphaColor.a, 0.01));
    });
    test('darken and lighten are inverse operations', () {
      final Color modified = opaqueBlue.darken(0.1).lighten(0.1);
      final HSLColor originalHsl = HSLColor.fromColor(opaqueBlue);
      final HSLColor modifiedHsl = HSLColor.fromColor(modified);
      expect(modifiedHsl.lightness, closeTo(originalHsl.lightness, 0.01));
    });
  });

  group('ColorContrastExtensions.readableOn', () {
    double contrast(Color a, Color b) {
      final double la = a.computeLuminance() + 0.05;
      final double lb = b.computeLuminance() + 0.05;
      return la > lb ? la / lb : lb / la;
    }
    const Color gold = Color.fromRGBO(207, 181, 59, 1);
    const Color cream = Color.fromRGBO(245, 243, 235, 1);
    const Color darkPanel = Color.fromRGBO(28, 28, 30, 1);

    test('darkens a light accent until it meets contrast on a light panel', () {
      final Color readable = gold.readableOn(cream);
      expect(contrast(gold, cream) < 4.5, isTrue);
      expect(contrast(readable, cream) >= 4.5, isTrue);
      expect(readable.computeLuminance() < gold.computeLuminance(), isTrue);
    });
    test('leaves an already-readable color effectively unchanged', () {
      expect(contrast(gold, darkPanel) >= 4.5, isTrue);
      final Color readable = gold.readableOn(darkPanel);
      expect(readable.computeLuminance(), closeTo(gold.computeLuminance(), 0.001));
    });
    test('lightens a dark accent until it meets contrast on a dark panel', () {
      const Color darkNavy = Color.fromRGBO(20, 30, 60, 1);
      final Color readable = darkNavy.readableOn(darkPanel);
      expect(contrast(readable, darkPanel) >= 4.5, isTrue);
      expect(readable.computeLuminance() > darkNavy.computeLuminance(), isTrue);
    });
    test('returns best effort without throwing for an unreachable target', () {
      const Color midGrey = Color.fromRGBO(128, 128, 128, 1);
      final Color readable = midGrey.readableOn(midGrey, maxSteps: 4);
      expect(readable, isA<Color>());
    });
  });
}
```

## Bulletproofing gaps — concrete edge cases to add for massive coverage

### `toColor` (string -> Color)
- **3-digit shorthand** (`#ABC`) — currently returns `null` (only 6/8 handled). Decide: support `RGB` -> `RRGGBB` expansion, or document the null and test it.
- **Whitespace WITHOUT hash** (`'  2196F3  '`) — `removeAll('#')` then `.trim()` covers it, but add an explicit test (existing test only covers ` #2196F3 `).
- **Internal whitespace** (`'21 96 F3'`) — `int.tryParse` fails -> `null`; assert.
- **`0x` prefix already present** (`'0xFF2196F3'`) — 10 chars after `#` removal -> falls through to `null`; assert (the parser prepends its own `0x`).
- **Leading `+`/`-`** (`'-196F3'`, `'+196F3'`) — `int.tryParse('0xFF-196F3')` behavior; assert null.
- **Mixed case `0X`, unicode look-alikes** — full-width digits (e.g. `String.fromCharCode(0xFF11)` for fullwidth `1`), Arabic-Indic digits `String.fromCharCode(0x0660)`; `int.tryParse` rejects -> assert null.
- **Multiple hashes** (`'##2196F3'`, `'2196#F3'`) — `removeAll('#')` strips all -> parses to blue; assert the (perhaps surprising) success so behavior is locked.
- **All-zero / all-F** (`'000000'`, `'FFFFFFFF'`) -> opaque black / opaque white.
- **Tab / newline whitespace** (`'\t2196F3\n'`) — `.trim()` handles standard whitespace; non-breaking space `String.fromCharCode(0x00A0)` is NOT trimmed by Dart `.trim()` (it IS, actually — Dart trims Unicode whitespace incl. ` `); add a test to lock current behavior either way.
- **Very long all-hex string** (e.g. 16 chars) -> `null` (length not 6/8).

### `toHex` (Color -> string)
- **Rounding boundary** — channels are stored as doubles in modern Flutter `Color`; `(channel * 255).round()` can flip at `.5`. Test a `Color.from(alpha:, red:, green:, blue:)` with fractional channel values (e.g. `0.5`) to lock the rounding direction.
- **Wide-gamut / out-of-sRGB `Color`** — `Color.from(..., colorSpace: ColorSpace.displayP3)` channels may exceed 1.0; `(>1 * 255).round()` overflows past `FF` and `toRadixString(16)` yields 3 hex digits, breaking the `#AARRGGBB` width. Add a clamp on inclusion and a test for a >1.0 channel.
- **Exactly 255 vs 254.5** boundary per channel.
- Confirm output is ALWAYS uppercase and exactly 7 (`#RRGGBB`) or 9 (`#AARRGGBB`) chars — length assertion.

### `darken` / `lighten`
- **`amount` = NaN** — `NaN == 0` is false, `NaN.isNotBetween(0,1)` true -> returns unchanged; assert (prevents `(lightness - NaN).clamp` producing NaN color).
- **`amount` = double.infinity / -infinity** — out-of-range guard returns unchanged; assert.
- **`amount` exactly 1.0** — boundary; `isNotBetween` is exclusive or inclusive? Verify and lock (existing tests use `1.0` and expect lightness 0.0/1.0, so inclusive — assert explicitly).
- **`amount` = tiny epsilon** (`1e-12`) — passes guards, near no-op; assert color barely changes.
- **Pure black `darken`** (already lightness 0) -> stays black. **Pure white `lighten`** -> stays white.
- **Fully transparent color** (`Color.fromARGB(0, ...)`) — alpha preserved through HSL roundtrip; assert.
- **Grayscale input** (saturation 0) — hue is undefined; ensure no NaN leaks (HSLColor handles it, but lock with a test on `Colors.grey.darken(0.2)`).
- **Inverse-operation precision** at extremes (darken to 0 then lighten 0.1) — clamp means it is NOT a true inverse near the boundary; document.

### `readableOn`
- **`minRatio` = 21.0** (max possible) on a non-black/white pair -> unreachable, must return best-effort within `maxSteps`, no throw.
- **`minRatio` <= 1.0** — any color already satisfies; returns `this` on first iteration unchanged.
- **`maxSteps` = 0** — loop body never runs; returns `this` unchanged; assert (no off-by-one).
- **`maxSteps` negative** — `for (i=0; i<negative; …)` never runs -> returns `this`; assert.
- **`step` = 0** — never converges, burns all `maxSteps`, returns `this`; assert termination (no infinite loop).
- **`step` = NaN / negative** — propagates into `darken`/`lighten`, which guard it out, so `result` never changes -> best-effort `this` after `maxSteps`; assert no throw.
- **`background` exactly at luminance 0.45 boundary** — `> 0.45` is false -> lightens; pick a color landing exactly on 0.45 and lock the branch.
- **Identical fg == bg** — contrast 1.0, can never reach 4.5; best-effort return, no spin.
- **Semi-transparent fg/bg** — `computeLuminance()` ignores alpha; document that contrast is computed as if opaque (matches WCAG-on-opaque assumption) and add a test asserting alpha of the result is preserved from `this`.

### Cross-cutting
- **`null` safety** — `toColor` is on a non-null `String` receiver; add a `String?` convenience (`'..'?.toColor()`) usage test if a nullable extension is desired.
- **Determinism** — same inputs always same output (no `Random`, no clock); trivially true but worth a property-style test.
- **Decide guard semantics on inclusion**: out-of-range `amount` currently returns unchanged silently (app logged a warning). For a "bulletproof library" the alternatives are (a) keep silent-unchanged (lenient) or (b) throw `ArgumentError.value`. Recommend lenient + documented, matching the existing `clamp`-everywhere style; add tests asserting the lenient contract so it cannot regress.
```
