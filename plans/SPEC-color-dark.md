# SPEC: DarkColors enum + DarkColorsUtils.darkColorMap — for inclusion

**Status:** Proposed (from Saropa Contacts)
**Proposed location:** lib/niche/dark_colors.dart (sits alongside the existing `niche/color_utils.dart`)
**Portability:** Flutter — depends on `package:flutter/material.dart` for `Color`. NOT pure Dart. No external packages.

## Purpose — what it does + why it is general-purpose (not proprietary)

`DarkColors` is a 20-value enum naming the Material design "700-ish" dark color
swatches (Red, Pink, Purple, DeepPurple, Indigo, Blue, LightBlue, Cyan, Teal,
Green, LightGreen, Lime, Yellow, Amber, Orange, DeepOrange, Brown, Grey,
BlueGrey, Black). `DarkColorsUtils.darkColorMap` maps each enum value to a fixed
`Color` (the Material 700 swatch hex, e.g. `Red -> 0xFFD32F2F`).

It is a general-purpose, brand-agnostic palette of legible-on-light dark colors,
useful anywhere a caller wants a deterministic, named, high-contrast color
(category tagging, avatar backgrounds, chart series, label coloring). The values
are the standard Material palette, contain no Saropa branding, and reference no
contact-domain logic. The only app-specific trace is a `// NOTE: used by coaches`
comment, which is dropped here.

## Source (from Saropa Contacts) — general-purpose members, verbatim

No debug/DebugType logging, l10n, or app-specific code is present in this file;
nothing to strip beyond the `// NOTE: used by coaches` comment.

```dart
import 'package:flutter/material.dart';

enum DarkColors {
  Red,
  Pink,
  Purple,
  DeepPurple,
  Indigo,
  Blue,
  LightBlue,
  Cyan,
  Teal,
  Green,
  LightGreen,
  Lime,
  Yellow,
  Amber,
  Orange,
  DeepOrange,
  Brown,
  Grey,
  BlueGrey,
  Black,
}

abstract final class DarkColorsUtils {
  static const Map<DarkColors, Color> darkColorMap = <DarkColors, Color>{
    DarkColors.Red: Color(0xFFD32F2F),
    DarkColors.Pink: Color(0xFFC2185B),
    DarkColors.Purple: Color(0xFF7B1FA2),
    DarkColors.DeepPurple: Color(0xFF512DA8),
    DarkColors.Indigo: Color(0xFF303F9F),
    DarkColors.Blue: Color(0xFF1976D2),
    DarkColors.LightBlue: Color(0xFF0288D1),
    DarkColors.Cyan: Color(0xFF0097A7),
    DarkColors.Teal: Color(0xFF00796B),
    DarkColors.Green: Color(0xFF388E3C),
    DarkColors.LightGreen: Color(0xFF689F38),
    DarkColors.Lime: Color(0xFFAFB42B),
    DarkColors.Yellow: Color(0xFFFBC02D),
    DarkColors.Amber: Color(0xFFFFA000),
    DarkColors.Orange: Color(0xFFF57C00),
    DarkColors.DeepOrange: Color(0xFFE64A19),
    DarkColors.Brown: Color(0xFF5D4037),
    DarkColors.Grey: Color(0xFF616161),
    DarkColors.BlueGrey: Color(0xFF455A64),
    DarkColors.Black: Color(0xFF212121),
  };
}
```

### Excluded members + why

- `// NOTE: used by coaches` — app-internal usage note; not relevant to a general
  utility. Dropped.
- Nothing else is proprietary. The enum and the map are fully general.

## Overlap with installed library (saropa_dart_utils 1.4.1)

The library already ships **color math** in `lib/niche/color_utils.dart`
(`hexToRgb`, `rgbToHex`, `luminance`, `contrastRatio`) and hex parsing in
`lib/parsing/hex_color_utils.dart`. It does NOT ship any **named palette** of
`Color` constants. There is no `DarkColors` enum and no `darkColorMap`.

Library already has color-conversion/contrast math; this util adds a named,
constant palette (a data table, not math). **Net-new, no duplication.** Place it
beside the existing color math under `lib/niche/`.

Because the existing `color_utils.dart` is pure Dart (no Flutter import) while
this palette requires `Color` from Flutter, it MUST be a separate file
(`niche/dark_colors.dart`) so the pure-Dart math is not forced to take a Flutter
dependency.

## Test cases — none exist in Saropa Contacts; proposed cases

No `*_test.dart` references `DarkColors`/`DarkColorsUtils` in the Contacts repo.
Proposed (Flutter test — needs `flutter_test`, since `Color` is a Flutter type):

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:saropa_dart_utils/niche/dark_colors.dart';

void main() {
  group('DarkColorsUtils.darkColorMap', () {
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
      expect(DarkColorsUtils.darkColorMap, hasLength(DarkColors.values.length));
    });

    test('every color is fully opaque (alpha 0xFF)', () {
      for (final Color color in DarkColorsUtils.darkColorMap.values) {
        // ignore: deprecated_member_use -- .value is the stable ARGB int form
        expect((color.value >> 24) & 0xFF, 0xFF);
      }
    });

    test('known anchor values are exact', () {
      expect(DarkColorsUtils.darkColorMap[DarkColors.Red], const Color(0xFFD32F2F));
      expect(DarkColorsUtils.darkColorMap[DarkColors.Black], const Color(0xFF212121));
      expect(DarkColorsUtils.darkColorMap[DarkColors.Blue], const Color(0xFF1976D2));
    });

    test('all colors are distinct', () {
      final Set<int> seen = <int>{};
      for (final Color color in DarkColorsUtils.darkColorMap.values) {
        // ignore: deprecated_member_use -- .value is the stable ARGB int form
        expect(seen.add(color.value), isTrue, reason: 'duplicate color $color');
      }
    });
  });
}
```

## Bulletproofing gaps — concrete edge cases for massive coverage

- **Completeness (no orphan keys/values):** assert the map's keyset equals
  `DarkColors.values.toSet()` exactly — catches both a missing entry AND a stray
  key if the enum ever shrinks.
- **Count invariant:** `darkColorMap.length == DarkColors.values.length` (already
  proposed) guards against silent drift when an enum value is added without a map
  entry.
- **Alpha = 0xFF for all 20:** every swatch must be fully opaque so callers can
  rely on it for backgrounds without surprise transparency.
- **Distinctness:** all 20 ARGB ints unique — a copy/paste typo collapsing two
  swatches is a real failure mode for a palette.
- **Contrast guarantee (ties into existing `color_utils.dart`):** for each color,
  assert `contrastRatio(r,g,b, 255,255,255) >= 3.0` — these are "dark" colors
  meant to read on light backgrounds; cross-check using the library's own
  `hexToRgb` + `contrastRatio`. This is the strongest semantic test: it verifies
  the palette actually IS dark, not just that the constants exist.
- **Lookup of every value returns non-null:** `darkColorMap[c]` is non-null for
  all `c` (guards against a future nullable-map refactor).
- **Boundary swatches:** explicitly pin `Black` (`0xFF212121`) and the lightest
  members (`Yellow` `0xFFFBC02D`, `Lime` `0xFFAFB42B`, `Amber` `0xFFFFA000`) so a
  shift in the brightest entries — the ones closest to failing the contrast
  floor — is caught.
- **Enum stability:** assert `DarkColors.values.length == 20` and that
  `DarkColors.Red.index == 0` / `DarkColors.Black.index == 19`, so a reordering
  that would silently change any persisted-by-index data is flagged.
- **Const-ness:** confirm the map and its `Color` values are compile-time const
  (the type `Map<DarkColors, Color>` with `const` literal); no runtime gaps,
  null, NaN, infinity, locale, or DST concerns apply — this is a static data
  table, so the coverage burden is completeness + distinctness + contrast, not
  numeric/temporal edges.
```
