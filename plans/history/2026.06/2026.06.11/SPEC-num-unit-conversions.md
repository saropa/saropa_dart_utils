# SPEC: Physical unit conversions (length + weight) — for inclusion

**Status:** Proposed (harvested from Saropa Contacts)
**Proposed location:** `lib/num/unit_conversion_utils.dart` (new)
**Portability:** Pure Dart. The `*ToString` formatters call `double.formatDouble`
(already in the library, `lib/double/double_extensions.dart`); the raw `convert*`
functions have zero dependencies.

---

## Purpose

Exact metric ↔ imperial conversions for length (meters ↔ feet) and weight
(kilograms ↔ pounds), plus human-readable string formatters. General-purpose, not
proprietary — any app showing height/weight/distance needs them. The conversion
factors are full-precision constants in one place (the value of a shared library:
the factor is reviewed and tested once, not re-typed per consumer).

Suggest grouping under one `UnitConversionUtils` (or split `LengthUnits` /
`WeightUnits`), and treating the English-name formatters as a thin convenience —
the `convert*` primitives are the bulletproof core.

---

## Source (verbatim from Saropa Contacts)

```dart
abstract final class LengthConversionUtils {
  static const double conversionFactor = 3.280839895; // meters -> feet

  static double convertMetersToFeet(double meters) => meters * conversionFactor;
  static double convertFeetToMeters(double feet) => feet / conversionFactor;

  /// "5 feet 10.5 inches" / "5 ft 10.5 in" / "1.78 meters" / "1.78 m".
  static String feetToString(double feet,
      {bool useAbbreviations = false, bool showInches = true, int decimalPlaces = 2}) {
    if (showInches) {
      final int wholeFeet = feet.floor();
      final double inches = (feet - wholeFeet) * 12;
      return '$wholeFeet ${useAbbreviations ? 'ft' : 'feet'} '
          '${inches.formatDouble(decimalPlaces, showTrailingZeros: false)} '
          '${useAbbreviations ? 'in' : 'inches'}';
    }
    return '${feet.formatDouble(decimalPlaces, showTrailingZeros: false)} '
        '${useAbbreviations ? 'ft' : 'feet'}';
  }

  static String metersToString(double meters,
          {bool useAbbreviations = false, int decimalPlaces = 2}) =>
      '${meters.formatDouble(decimalPlaces, showTrailingZeros: false)} '
      '${useAbbreviations ? 'm' : 'meters'}';
}

abstract final class WeightConversionUtils {
  static const double conversionFactor = 2.2046226218; // kg -> lbs

  static double convertKilogramsToPounds(double kilograms) => kilograms * conversionFactor;
  static double convertPoundsToKilograms(double pounds) => pounds / conversionFactor;

  static String poundsToString(double pounds,
          {bool useAbbreviations = false, int decimalPlaces = 2}) =>
      '${pounds.formatDouble(decimalPlaces, showTrailingZeros: false)} '
      '${useAbbreviations ? 'lbs' : 'pounds'}';

  static String kilogramsToString(double kilograms,
          {bool useAbbreviations = false, int decimalPlaces = 2}) =>
      '${kilograms.formatDouble(decimalPlaces, showTrailingZeros: false)} '
      '${useAbbreviations ? 'kg' : 'kilograms'}';
}
```

---

## Proposed test cases (Contacts had none — write these for massive coverage)

```dart
group('LengthConversionUtils', () {
  test('round-trips within float tolerance', () {
    expect(LengthConversionUtils.convertFeetToMeters(
        LengthConversionUtils.convertMetersToFeet(1.78)), closeTo(1.78, 1e-9));
  });
  test('known values', () {
    expect(LengthConversionUtils.convertMetersToFeet(1), closeTo(3.280839895, 1e-9));
    expect(LengthConversionUtils.convertFeetToMeters(3.280839895), closeTo(1, 1e-9));
  });
  test('zero and negative', () {
    expect(LengthConversionUtils.convertMetersToFeet(0), 0);
    expect(LengthConversionUtils.convertMetersToFeet(-2), closeTo(-6.56167979, 1e-6));
  });
  test('feetToString with/without inches + abbreviations', () {
    expect(LengthConversionUtils.feetToString(5.5), '5 feet 6 inches');
    expect(LengthConversionUtils.feetToString(5.5, useAbbreviations: true), '5 ft 6 in');
    expect(LengthConversionUtils.feetToString(5.5, showInches: false), '5.5 feet');
  });
});

group('WeightConversionUtils', () {
  test('round-trips', () {
    expect(WeightConversionUtils.convertPoundsToKilograms(
        WeightConversionUtils.convertKilogramsToPounds(80)), closeTo(80, 1e-9));
  });
  test('known values', () {
    expect(WeightConversionUtils.convertKilogramsToPounds(1), closeTo(2.2046226218, 1e-9));
  });
});
```

---

## Bulletproofing gaps to add

- **NaN / infinity** inputs — define + test the contract (propagate? throw?).
- **Very large / very small** magnitudes — precision at extremes.
- **`feetToString` rounding at the 12-inch boundary** — `feetToString(5.999...)`
  must not render `5 feet 12 inches` (carry into feet). Add a guard + test.
- **Negative in `feetToString`** — `floor()` of a negative pushes inches positive;
  decide the display contract for negative heights (probably reject / clamp).
- **`decimalPlaces == 0`** and large values.
- **i18n of unit names** — the English `feet/inches/pounds/kilograms` literals are
  the opinionated part; consider injecting names (like `DateFormatNames`) or
  returning a structured value and leaving formatting to the caller.

---

## Finish Report (2026-06-11)

### Scope

(A) Flutter/Dart app code — new `lib/num/unit_conversion_utils.dart` + test + barrel
export + CHANGELOG + CODE_INDEX. No extension (B) or docs-only (C) surface.

### What shipped

`LengthConversionUtils` and `WeightConversionUtils` (abstract final classes, the
two-class split kept verbatim from the spec because the proposed tests reference
those exact names). Dependency-free `convert*` primitives; `*ToString` formatters
delegating decimal rendering to the existing `DoubleExtensions.formatDouble`.

### Deep review notes

- **Logic & safety**: `feetToString` had three real edge cases, all closed:
  (1) `floor()` throws on NaN/∞ in Dart, so the inches path is guarded by
  `!feet.isFinite` and falls back to the single-value form; (2) the 12-inch carry
  is computed by rounding inches to the chosen precision (numeric `pow`-based
  round, not string round-trip — `double.parse` tripped `prefer_try_parse_for_dynamic_data`)
  then testing `>= 12`; (3) negatives format on the magnitude with a re-applied
  sign so `floor()` of a negative can't push inches positive.
- **Architecture**: reuses `formatDouble` rather than re-implementing decimal
  trimming; conversion factors are single-source consts. The `_feetInchesString`
  private helper keeps `feetToString` small and isolates the boundary logic.
- **Contract for non-finite `convert*`**: propagate (IEEE-754 multiply/divide),
  documented in dartdoc rather than throwing — matches the "bulletproof
  dependency-free core" framing.
- **i18n gap**: NOT closed. Kept English literals; dartdoc directs localizing
  callers to format the raw `convert*` output. Building name injection is a larger
  API surface I did not add unprompted. This is the one spec "bulletproofing gap"
  intentionally left as a documented limitation rather than implemented.
- **Parameter count**: `feetToString` has 4 named params, exceeding the project
  ≤3 guideline. Kept the spec's verbatim public signature. Flagged to the user as
  an open decision (fold into an options object vs. leave as-specced).

### Testing

- Audit: grepped `test/` for `ConversionUtils`, `convertMeters`, `feetToString`,
  `unit_conversion` — no pre-existing tests referenced any touched symbol (new
  file, additive barrel export). Nothing to update.
- New test `test/num/unit_conversion_utils_test.dart`: 19 tests covering
  round-trips, known values, zero/negative, NaN/∞ propagation, large/small
  magnitudes, the 12-inch carry (both default and `decimalPlaces: 0`), non-carry,
  negative formatting, whole-feet, and non-finite string fallback.
- `flutter test test/num/unit_conversion_utils_test.dart` → **19/19 pass**.
- `flutter analyze lib/num/unit_conversion_utils.dart test/num/unit_conversion_utils_test.dart`
  → **No issues found**. `flutter analyze lib/saropa_dart_utils.dart` (barrel,
  catches export collisions) → **No issues found**.

### Maintenance

- CHANGELOG: new `[Unreleased]` section added.
- CODE_INDEX: new "Unit Conversion Capabilities" table.
- README verified — no updates needed (README does not enumerate per-utility APIs).
- ROADMAP_TO_700 reviewed — no unit-conversion line item to remove.

### Files

- Added: `lib/num/unit_conversion_utils.dart`, `test/num/unit_conversion_utils_test.dart`
- Modified: `lib/saropa_dart_utils.dart`, `CHANGELOG.md`, `CODE_INDEX.md`
- This plan: appended report + archived to `plans/history/2026.06/2026.06.11/`.

### Outstanding

- i18n name injection (documented limitation, not a bug).
- `feetToString` 4-param signature — user decision pending.
