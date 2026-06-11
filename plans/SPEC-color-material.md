# SPEC: ColorUtils (materialColors, getWhiteContrastColor, getColor) + MaterialShade — for inclusion

**Status:** Proposed (from Saropa Contacts)
**Proposed location:** `lib/flutter/material_color_utils.dart` (Flutter-dependent; do not place under the pure-Dart `parsing/` or `niche/` color helpers)
**Portability:** Flutter — depends on `package:flutter/material.dart` (`Color`, `MaterialColor`, `Colors`, `Color.alphaBlend`). NOT pure Dart. No other external packages.

## Purpose — what it does + why it is general-purpose (not proprietary)

A small set of Flutter `MaterialColor` helpers with no app-domain knowledge:

- `ColorUtils.materialColors` — the canonical ordered list of the 19 primary Flutter `MaterialColor`s (`Colors.red` … `Colors.blueGrey`). Useful anywhere code wants to index into a fixed palette (charts, avatars, tag coloring, deterministic per-index color assignment).
- `ColorUtils.getWhiteContrastColor(int number)` — maps any integer (including negatives) deterministically to one of 100 distinct colors that are guaranteed to contrast against white, by blending a primary and secondary color from a fixed 10-color palette. General-purpose deterministic "color from a number" generator.
- `ColorUtils.getColor(MaterialShade shade, MaterialColor color)` — typed accessor that returns the swatch entry for a given shade enum (`shade50`…`shade900`) from a `MaterialColor`, replacing the stringly/int-indexed `color[500]!` with an exhaustive `switch`.
- `MaterialShade` enum + `MaterialShadeName` extension (`value`, `onShade`, `displayName`, `displayNameAnnotated`) + `MaterialShadeLevels` (`shades`, `lightShades`, `darkShades`, `randomShade`) — a typed model of Material Design swatch shade levels (50–900), the integer values, the readable-on color (black for 50–400, white for 500–900), and light/dark shade groupings.

None of this references contacts, Saropa formats, Font Awesome, l10n, or analytics. It is pure Material Design palette plumbing.

### Excluded members + why

- **`debug.dart` import + `debugException(error, stack)` call** (inside `getWhiteContrastColor`'s catch) — EXCLUDED: app-specific Crashlytics/debug reporting. Stripped from the quoted source below; the catch returns `Colors.grey` silently. For a bulletproof library version, prefer the input-validating approach in Bulletproofing gaps over a swallow-all try/catch.
- **`MaterialShadeLevels.randomShade` dependency on `package:saropa/utils/primitive/generate_random/random_list.dart`** (`shades.randomItem(seed)`) — the `randomItem` extension is a separate Saropa util. If `MaterialShadeLevels.randomShade` is included, it must depend on the harvested `randomItem` extension (covered by its own spec) or be reimplemented with `dart:math`. Quoted below with that dependency noted.

## Source (from Saropa Contacts) — general-purpose members, verbatim (debug logging stripped)

```dart
import 'package:flutter/material.dart';

/// An enumeration of the available MaterialColor shades.
enum MaterialShade {
  shade50,
  shade100,
  shade200,
  shade300,
  shade400,
  shade500,
  shade600,
  shade700,
  shade800,
  shade900,
}

extension MaterialShadeName on MaterialShade {
  int get value => switch (this) {
    MaterialShade.shade50 => 50,
    MaterialShade.shade100 => 100,
    MaterialShade.shade200 => 200,
    MaterialShade.shade300 => 300,
    MaterialShade.shade400 => 400,
    MaterialShade.shade500 => 500,
    MaterialShade.shade600 => 600,
    MaterialShade.shade700 => 700,
    MaterialShade.shade800 => 800,
    MaterialShade.shade900 => 900,
  };

  Color get onShade => switch (this) {
    MaterialShade.shade50 ||
    MaterialShade.shade100 ||
    MaterialShade.shade200 ||
    MaterialShade.shade300 ||
    MaterialShade.shade400 => Colors.black,
    MaterialShade.shade500 ||
    MaterialShade.shade600 ||
    MaterialShade.shade700 ||
    MaterialShade.shade800 ||
    MaterialShade.shade900 => Colors.white,
  };

  String get displayName => 'Shade $value';

  String get displayNameAnnotated => switch (this) {
    MaterialShade.shade50 => 'Shade 50 (Lightest)',
    MaterialShade.shade500 => 'Shade 500 (Middle)',
    MaterialShade.shade900 => 'Shade 900 (Darkest)',
    MaterialShade.shade100 ||
    MaterialShade.shade200 ||
    MaterialShade.shade300 ||
    MaterialShade.shade400 ||
    MaterialShade.shade600 ||
    MaterialShade.shade700 ||
    MaterialShade.shade800 => displayName,
  };
}

abstract final class MaterialShadeLevels {
  // NOTE: `randomItem` is a Saropa list extension (random_list.dart). Include
  // the harvested `randomItem` extension or reimplement with dart:math.
  static int? randomShade({bool? isLightBackground, int? seed}) {
    if (isLightBackground == null) {
      return shades.randomItem(seed);
    }

    if (isLightBackground) {
      return darkShades.randomItem(seed);
    }

    return lightShades.randomItem(seed);
  }

  // List of color intensities (light then dark).
  static const List<int> shades = <int>[
    ...lightShades,
    ...darkShades,
  ];

  // List of color intensities based on the background mode.
  static const List<int> lightShades = <int>[50, 100, 200, 300, 400];

  static const List<int> darkShades = <int>[500, 600, 700, 800, 900];
}

abstract final class ColorUtils {
  /// Create a list of all primary MaterialColors
  ///
  /// NOTE: using list for indexing (instead of set)
  ///
  static const List<MaterialColor> materialColors = <MaterialColor>[
    Colors.red,
    Colors.pink,
    Colors.purple,
    Colors.deepPurple,
    Colors.indigo,
    Colors.blue,
    Colors.lightBlue,
    Colors.cyan,
    Colors.teal,
    Colors.green,
    Colors.lightGreen,
    Colors.lime,
    Colors.yellow,
    Colors.amber,
    Colors.orange,
    Colors.deepOrange,
    Colors.brown,
    Colors.grey,
    Colors.blueGrey,
  ];

  /// This function generates a distinct, non-random color for each number
  /// from 1 to 99. These colors are chosen to contrast with white by
  /// ensuring that at least one of the RGB components is always low.
  ///
  static Color getWhiteContrastColor(int number) {
    // Use the modulus operator to ensure the number is always between 0 and
    // 99. This includes NEGATIVE numbers.
    number = number % 100;

    // Map the numbers 0-99 to distinct primary and secondary colors.
    const List<Color> colors = <Color>[
      Colors.red,
      Colors.green,
      Colors.blue,
      Colors.yellow,
      Colors.orange,
      Colors.purple,
      Colors.brown,
      Colors.pink,
      Colors.cyan,
      Colors.lime,
    ];

    // Calculate the primary and secondary color indices based on the number.
    final int primaryIndex = number ~/ 10;
    final int secondaryIndex = number % 10;

    // Create the color by blending the primary and secondary colors.
    final Color primaryColor = colors[primaryIndex];
    final Color secondaryColor = colors[secondaryIndex];

    return Color.alphaBlend(secondaryColor.withValues(alpha: 0.5), primaryColor);
  }

  /// Gets the color with the specified [MaterialShade] from the given
  /// [MaterialColor].
  static Color getColor(MaterialShade shade, final MaterialColor color) => switch (shade) {
    MaterialShade.shade50 => color[50]!,
    MaterialShade.shade100 => color[100]!,
    MaterialShade.shade200 => color[200]!,
    MaterialShade.shade300 => color[300]!,
    MaterialShade.shade400 => color[400]!,
    MaterialShade.shade500 => color[500]!,
    MaterialShade.shade600 => color[600]!,
    MaterialShade.shade700 => color[700]!,
    MaterialShade.shade800 => color[800]!,
    MaterialShade.shade900 => color[900]!,
  };
}
```

> **Note on `getWhiteContrastColor` and negative numbers:** Dart's `%` on a
> negative operand returns a non-negative result (e.g. `-1 % 100 == 99`), so the
> doc comment's "1 to 99" claim is incomplete but the code IS safe for negatives.
> `number == 0` → `primaryIndex == 0`, `secondaryIndex == 0` → red
> blended onto red. Library version should fix the doc to say "any int" and keep
> the modulo. The only unsafe path is `int` extremes (see gaps).

## Overlap with installed library (saropa_dart_utils 1.4.1)

The library ships two color helpers, both **pure-Dart, int/RGB-based**, NOT Material/Flutter:

- `lib/parsing/hex_color_utils.dart` → `parseHexColor(String)` → `int?` (`#RGB`/`#RRGGBB`/`#AARRGGBB` parsing).
- `lib/niche/color_utils.dart` → `hexToRgb`, `rgbToHex`, `luminance`, `contrastRatio` (WCAG luminance/contrast math on int channels).

**No overlap.** Those operate on hex strings and `int` RGB channels for parsing and WCAG math. This util operates on Flutter `MaterialColor`/`Color` swatches and shade-level enums — a different domain (palette plumbing vs. color parsing/contrast math). Library already has hex/RGB/contrast; this util adds the Material swatch list, the deterministic int→Color generator, the `MaterialShade` enum model, and the typed swatch accessor. **Net-new.**

(Note: the library's `contrastRatio` could later back a bulletproof rewrite of `getWhiteContrastColor` that asserts the chosen color genuinely contrasts white — see gaps — but they don't duplicate today.)

## Test cases — no existing tests in Saropa Contacts; proposed cases

No `material_color_test.dart` or `ColorUtils`/`getWhiteContrastColor`/`getColor` test group exists under `d:/src/contacts/test`. (The only color-test files there cover `AvatarColorUtils` and `DominantColorUtils`, which are different, app-specific utilities.) Proposed coverage:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ColorUtils.materialColors', () {
    test('has the expected 19 primary swatches in order', () {
      expect(ColorUtils.materialColors, hasLength(19));
      expect(ColorUtils.materialColors.first, equals(Colors.red));
      expect(ColorUtils.materialColors.last, equals(Colors.blueGrey));
    });

    test('contains no duplicates', () {
      expect(ColorUtils.materialColors.toSet(), hasLength(19));
    });
  });

  group('ColorUtils.getColor', () {
    test('returns the exact swatch entry for each shade', () {
      expect(ColorUtils.getColor(MaterialShade.shade50, Colors.blue),
          equals(Colors.blue[50]));
      expect(ColorUtils.getColor(MaterialShade.shade500, Colors.blue),
          equals(Colors.blue[500]));
      expect(ColorUtils.getColor(MaterialShade.shade900, Colors.blue),
          equals(Colors.blue[900]));
    });

    test('shade500 equals the base MaterialColor value', () {
      // Material swatches define shade500 as the primary tone.
      expect(ColorUtils.getColor(MaterialShade.shade500, Colors.red),
          equals(Colors.red));
    });
  });

  group('ColorUtils.getWhiteContrastColor', () {
    test('is deterministic for the same input', () {
      expect(ColorUtils.getWhiteContrastColor(42),
          equals(ColorUtils.getWhiteContrastColor(42)));
    });

    test('maps negatives via non-negative modulo (no RangeError)', () {
      // -1 % 100 == 99 in Dart; must not throw.
      expect(() => ColorUtils.getWhiteContrastColor(-1), returnsNormally);
      expect(ColorUtils.getWhiteContrastColor(-1),
          equals(ColorUtils.getWhiteContrastColor(99)));
    });

    test('wraps modulo 100', () {
      expect(ColorUtils.getWhiteContrastColor(100),
          equals(ColorUtils.getWhiteContrastColor(0)));
      expect(ColorUtils.getWhiteContrastColor(142),
          equals(ColorUtils.getWhiteContrastColor(42)));
    });

    test('every input 0..99 yields a fully opaque color', () {
      for (int i = 0; i < 100; i++) {
        expect(ColorUtils.getWhiteContrastColor(i).a, equals(1.0));
      }
    });
  });

  group('MaterialShade', () {
    test('value returns the integer level', () {
      expect(MaterialShade.shade50.value, equals(50));
      expect(MaterialShade.shade900.value, equals(900));
    });

    test('onShade is black for light shades, white for dark shades', () {
      expect(MaterialShade.shade400.onShade, equals(Colors.black));
      expect(MaterialShade.shade500.onShade, equals(Colors.white));
    });

    test('displayName and annotated variants', () {
      expect(MaterialShade.shade300.displayName, equals('Shade 300'));
      expect(MaterialShade.shade50.displayNameAnnotated,
          equals('Shade 50 (Lightest)'));
      expect(MaterialShade.shade500.displayNameAnnotated,
          equals('Shade 500 (Middle)'));
      expect(MaterialShade.shade900.displayNameAnnotated,
          equals('Shade 900 (Darkest)'));
      expect(MaterialShade.shade300.displayNameAnnotated,
          equals('Shade 300'));
    });
  });

  group('MaterialShadeLevels', () {
    test('shades is lightShades followed by darkShades', () {
      expect(MaterialShadeLevels.shades,
          equals(<int>[50, 100, 200, 300, 400, 500, 600, 700, 800, 900]));
      expect(MaterialShadeLevels.lightShades, hasLength(5));
      expect(MaterialShadeLevels.darkShades, hasLength(5));
    });

    test('randomShade with seed is deterministic', () {
      expect(MaterialShadeLevels.randomShade(seed: 7),
          equals(MaterialShadeLevels.randomShade(seed: 7)));
    });
  });
}
```

## Bulletproofing gaps — concrete edge cases to add for massive coverage

- **Int extremes / overflow:** `getWhiteContrastColor(-9223372036854775808)` (`int` min) and `(9223372036854775807)` (`int` max). `intMin % 100` in Dart is `-8` on the VM for `int.minValue`? Verify: actually `(-9223372036854775808) % 100 == 92` (non-negative). Add explicit tests at both extremes asserting `returnsNormally` and indices stay in `0..9`. This is the one path that could throw a `RangeError` if the modulo assumption is ever wrong on a given platform (JS web `int` is double-backed — test under `dart2js`/web semantics too, where `%` on huge values can lose precision and land out of `0..99`).
- **Web (`dart2js`) number semantics:** on web, `int` is a JS double; very large `number` values may not be exactly representable, so `number % 100` and `~/ 10` can drift. Add a web-targeted test (or clamp/normalize input) confirming `primaryIndex` and `secondaryIndex` always land in `0..9`. Recommended hardening: `number = number.remainder(100).abs()` or `number = ((number % 100) + 100) % 100` to make the non-negative invariant explicit and platform-independent.
- **Zero:** `getWhiteContrastColor(0)` → both indices 0 → red-on-red blend. Assert exact expected `Color` value so a palette reorder is caught.
- **Boundary indices:** inputs `9`, `10`, `90`, `99` exercise `primaryIndex`/`secondaryIndex` boundaries (0→9, 1→0, 9→0, 9→9). Assert each is within range and distinct where expected.
- **Contrast invariant (the documented purpose):** the doc claims results "contrast with white." Add a test using the library's own `contrastRatio` (lib/niche/color_utils.dart) to assert `contrastRatio(result, white) >= someThreshold` for all `0..99`. This converts the comment into a verified property and catches future palette edits that break the contrast promise.
- **`getColor` swatch completeness:** for EVERY swatch in `ColorUtils.materialColors` and EVERY `MaterialShade`, assert `getColor(shade, swatch)` is non-null and equals `swatch[shade.value]`. Catches a Material SDK swatch that ever lacks a level (the `!` would throw).
- **`getColor` with a custom `MaterialColor`:** construct a `MaterialColor` missing a shade key and confirm behavior (currently throws on `color[X]!`). Decide and test: should the library return nullable / fall back, rather than throw? Recommend a `getColorOrNull` variant for non-standard swatches.
- **`materialColors` immutability:** assert the `const` list cannot be mutated (attempting `.add` throws `UnsupportedError`) so callers can't corrupt the shared palette.
- **`MaterialShade.value` vs `MaterialShadeLevels.shades` consistency:** assert `MaterialShade.values.map((s) => s.value).toList()` equals `MaterialShadeLevels.shades` so the enum and the int list never diverge.
- **`onShade` partition completeness:** assert every `MaterialShade` returns exactly black or white, and the black set is exactly `{50,100,200,300,400}` (lightShades) and white set is exactly `{500,600,700,800,900}` (darkShades) — ties `onShade` to the `lightShades`/`darkShades` split.
- **`randomShade` distribution + nullability:** with `isLightBackground: true` every result ∈ `darkShades`; with `false` ∈ `lightShades`; with `null` ∈ `shades`. Run many seeds to confirm it never returns a value outside the expected set and never returns `null` for a non-empty list. (If `randomItem` can return `null` on empty, document why these lists are never empty.)
- **Alpha/opacity:** every `getWhiteContrastColor` result must be fully opaque (`alpha == 0xFF` / `.a == 1.0`); `Color.alphaBlend` over an opaque base guarantees this — assert it so a future change to a translucent base is caught.
- **Locale-independence:** `displayName` / `displayNameAnnotated` are hardcoded English (`'Shade 500 (Middle)'`). Document that these are debug/diagnostic labels, NOT localized UI strings, in the dartdoc so consumers don't ship them as user-facing copy.
