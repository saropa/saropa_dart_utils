# SPEC: MaterialShade, MaterialShadeName, MaterialShadeLevels — for inclusion

**Status:** Proposed (from Saropa Contacts)
**Proposed location:** lib/color/material_shade.dart
**Portability:** Flutter — depends on `package:flutter/material.dart` for the `Color` type (`onShade` returns `Colors.black` / `Colors.white`). The `value` / `displayName` / `displayNameAnnotated` members and the `MaterialShadeLevels` integer lists are pure Dart, but the enum lives alongside `onShade`, so the file as a whole is Flutter-scoped. No external packages beyond Flutter. (The `randomShade` helper originally pulled an app-internal `RandomList.randomItem`; this spec replaces that with the library's existing `Iterable.randomElement` — see Source notes.)

## Purpose — what it does + why it is general-purpose (not proprietary)

Material Design swatches (`MaterialColor`) expose ten fixed shade intensities keyed by the integers `50, 100, 200, 300, 400, 500, 600, 700, 800, 900`. This utility models those intensities as a type-safe `MaterialShade` enum and adds the standard derived facts every consumer re-derives by hand:

- **`value`** — the raw shade integer used to index a `MaterialColor` (`Colors.blue[shade.value]`).
- **`onShade`** — the readable foreground color (black on the light 50–400 band, white on the dark 500–900 band), matching Material's accessibility-contrast convention so callers don't recompute luminance.
- **`displayName`** / **`displayNameAnnotated`** — UI labels (`"Shade 500"`, with `(Lightest)` / `(Middle)` / `(Darkest)` annotations on the band endpoints).
- **`MaterialShadeLevels`** — the canonical light-band (`50–400`) and dark-band (`500–900`) integer lists plus a combined list, and a seeded random-shade picker.

This is general-purpose Material Design knowledge — the shade ladder is a Flutter framework constant, not a Saropa concept. Nothing here references contacts, app formats, icons, l10n, or telemetry.

### Excluded members + why

- **`MaterialShadeLevels.randomShade({bool? isLightBackground, int? seed})`** as originally written depended on the app-internal `RandomList.randomItem` extension (`import 'package:saropa/utils/primitive/generate_random/random_list.dart'`). That import is proprietary and not portable. The behavior itself (pick a random shade integer, optionally constrained to the light or dark band) IS general-purpose, so it is RETAINED but rewritten to call the library's existing `Iterable<T>.randomElement({int? seed})` (`lib/iterable/iterable_extensions.dart`). See Source.

Nothing else excluded — no contact-domain logic, Font Awesome maps, AppLocalizations, or `debug()` / Crashlytics reporting were present in the source.

## Source (from Saropa Contacts) — general-purpose members, verbatim (app import swapped)

The only change from the original is the import: `package:saropa/utils/primitive/generate_random/random_list.dart` (proprietary `randomItem`) replaced with the library's own `randomElement` (and the relevant iterable import). The display strings, enum, `value`, `onShade`, and band lists are verbatim.

```dart
import 'package:flutter/material.dart';
import 'package:saropa_dart_utils/iterable/iterable_extensions.dart';

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

abstract final class MaterialShadeLevels {
  /// Returns a random shade integer.
  ///
  /// - [isLightBackground] null = any shade; true = a DARK shade (readable on
  ///   a light background); false = a LIGHT shade (readable on a dark
  ///   background).
  /// - [seed] makes the pick deterministic for tests.
  static int? randomShade({bool? isLightBackground, int? seed}) {
    if (isLightBackground == null) {
      return shades.randomElement(seed: seed);
    }

    if (isLightBackground) {
      return darkShades.randomElement(seed: seed);
    }

    return lightShades.randomElement(seed: seed);
  }

  // List of color intensities (light band followed by dark band).
  static const List<int> shades = <int>[
    ...lightShades,
    ...darkShades,
  ];

  // List of color intensities based on the background mode.
  static const List<int> lightShades = <int>[50, 100, 200, 300, 400];

  static const List<int> darkShades = <int>[500, 600, 700, 800, 900];
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
```

## Test cases — existing tests verbatim (from Saropa Contacts)

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:saropa/utils/primitive/color/material_shade.dart';

void main() {
  group('MaterialShade.displayNameAnnotated', () {
    test('shade50 is labeled as Lightest', () {
      expect(MaterialShade.shade50.displayNameAnnotated, 'Shade 50 (Lightest)');
    });

    test('shade500 is labeled as Middle', () {
      expect(MaterialShade.shade500.displayNameAnnotated, 'Shade 500 (Middle)');
    });

    test('shade900 is labeled as Darkest', () {
      expect(MaterialShade.shade900.displayNameAnnotated, 'Shade 900 (Darkest)');
    });

    test('intermediate shades have no annotation', () {
      expect(MaterialShade.shade100.displayNameAnnotated, 'Shade 100');
      expect(MaterialShade.shade200.displayNameAnnotated, 'Shade 200');
      expect(MaterialShade.shade300.displayNameAnnotated, 'Shade 300');
      expect(MaterialShade.shade400.displayNameAnnotated, 'Shade 400');
      expect(MaterialShade.shade600.displayNameAnnotated, 'Shade 600');
      expect(MaterialShade.shade700.displayNameAnnotated, 'Shade 700');
      expect(MaterialShade.shade800.displayNameAnnotated, 'Shade 800');
    });
  });

  group('MaterialShade.value', () {
    test('shade values are correct', () {
      expect(MaterialShade.shade50.value, 50);
      expect(MaterialShade.shade100.value, 100);
      expect(MaterialShade.shade500.value, 500);
      expect(MaterialShade.shade900.value, 900);
    });
  });

  group('MaterialShade.displayName', () {
    test('displayName formats correctly', () {
      expect(MaterialShade.shade50.displayName, 'Shade 50');
      expect(MaterialShade.shade500.displayName, 'Shade 500');
      expect(MaterialShade.shade900.displayName, 'Shade 900');
    });
  });
}
```

## Bulletproofing gaps — concrete edge cases to add for massive coverage

The existing tests spot-check a few enum members. For "bulletproof, massive coverage" tighten as follows:

- **Exhaustive `value`** — assert all 10 members map to their integer (50/100/200/300/400/500/600/700/800/900), not just 4. Loop `MaterialShade.values` and assert `value == int.parse(name.replaceAll('shade', ''))` so a future reorder/typo is caught.
- **Exhaustive `displayName`** — assert all 10 produce `'Shade <value>'`; cross-check `displayName == 'Shade ${shade.value}'` for every member.
- **`displayNameAnnotated` completeness** — already covers all 10; add an assertion that EXACTLY three members carry a parenthetical annotation (`shade50`, `shade500`, `shade900`) and the other seven equal `displayName` — guards against an accidental extra annotation.
- **`onShade` (currently untested)** — assert `Colors.black` for `shade50..shade400` and `Colors.white` for `shade500..shade900`. Verify the partition is total and the boundary is exactly between `shade400` and `shade500`.
- **`onShade` is opaque** — assert `onShade.a == 1.0` (alpha) for every member so a future tweak can't introduce a translucent foreground.
- **Band-list integrity** —
  - `lightShades` equals `[50,100,200,300,400]` and `darkShades` equals `[500,600,700,800,900]` exactly (order matters).
  - `shades` equals `lightShades + darkShades` and has length 10 with no duplicates (`shades.toSet().length == 10`).
  - Every integer in `shades` is the `value` of exactly one `MaterialShade` member (round-trip: the lists and the enum never diverge).
  - Lists are `const` / unmodifiable — adding to them throws.
- **`onShade` ↔ band consistency** — every `value` in `lightShades` belongs to a `Colors.black`-`onShade` member; every `value` in `darkShades` to a `Colors.white` member. Locks the two sources of "light vs dark band" together.
- **`randomShade` determinism** — same `seed` returns the same shade across repeated calls (seeded `randomElement` is reproducible).
- **`randomShade` band constraint** — `isLightBackground: true` only ever returns a member of `darkShades`; `isLightBackground: false` only `lightShades`; `null` returns a member of `shades`. Run many seeds (e.g. 0..999) and assert membership for every result — guards the inverted-naming trap (light background wants the DARK, high-contrast shade).
- **`randomShade` distribution** — over many seeds, every shade in the eligible band appears at least once (no value structurally unreachable).
- **`randomShade` null** — document/verify the only path to `null` is an empty source list (not possible with the const lists), so the declared `int?` return is effectively non-null in practice; assert non-null across a seed sweep.
- **Enum stability** — assert `MaterialShade.values.length == 10` and the ordinal order is `shade50 < shade100 < ... < shade900` so `index`-based persistence stays valid.
- **No locale/formatting drift** — `displayName` uses a plain ASCII space and Arabic digits; assert the exact byte string (no thin space ` `, no non-breaking space ` `) so a future "pretty number" change can't silently alter persisted/compared labels.
```
