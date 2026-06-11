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
