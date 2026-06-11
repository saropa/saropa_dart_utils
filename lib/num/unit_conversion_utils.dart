import 'dart:math';

import 'package:meta/meta.dart';

import '../double/double_extensions.dart';

/// Inches in one foot. Used to decompose fractional feet into feet + inches.
const int _inchesPerFoot = 12;

/// Maximum decimal places [double.toStringAsFixed] accepts before it throws.
/// Mirrors the clamp inside [DoubleExtensions.formatDouble] so the internal
/// carry check below uses the same rounding the formatter will ultimately apply.
const int _maxDecimalPlaces = 20;

/// Exact length conversions between metric (meters) and imperial (feet),
/// plus human-readable string formatters.
///
/// The [convertMetersToFeet] / [convertFeetToMeters] primitives are the
/// bulletproof core: zero dependencies, no opinions about formatting or
/// locale. NaN and infinity inputs PROPAGATE through them unchanged — the
/// multiplication/division contract of IEEE-754 doubles — so callers that must
/// reject non-finite input should guard before calling.
///
/// The `*ToString` formatters are a thin English-only convenience. Apps that
/// localize unit names should format the raw converted [double] themselves
/// rather than parse these strings.
abstract final class LengthConversionUtils {
  /// Meters → feet multiplier (1 m = 3.280839895 ft). Full precision, defined
  /// once so the factor is reviewed and tested in a single place.
  static const double conversionFactor = 3.280839895;

  /// Converts [meters] to feet.
  ///
  /// NaN/infinity propagate. Negative values are allowed and scale linearly.
  ///
  /// Example:
  /// ```dart
  /// LengthConversionUtils.convertMetersToFeet(1); // 3.280839895
  /// ```
  @useResult
  static double convertMetersToFeet(double meters) => meters * conversionFactor;

  /// Converts [feet] to meters.
  ///
  /// NaN/infinity propagate. Negative values are allowed and scale linearly.
  ///
  /// Example:
  /// ```dart
  /// LengthConversionUtils.convertFeetToMeters(3.280839895); // 1.0
  /// ```
  @useResult
  static double convertFeetToMeters(double feet) => feet / conversionFactor;

  /// Formats [feet] as a human-readable string.
  ///
  /// With [showInches] (default) the fractional part is rendered as inches,
  /// e.g. `"5 feet 6 inches"` or `"5 ft 6 in"` with [useAbbreviations]. Without
  /// it, a single decimal value is shown, e.g. `"5.5 feet"`.
  ///
  /// Contract for edge cases:
  /// - Non-finite input (NaN/∞) skips the inches decomposition (which would
  ///   throw on `floor()`) and renders the value alone, e.g. `"NaN feet"`.
  /// - Rounding inches can reach 12 at the chosen precision; this carries into
  ///   whole feet so the output is never `"5 feet 12 inches"`.
  /// - Negative heights render with a leading sign on the feet, e.g.
  ///   `"-5 feet 6 inches"`, rather than letting `floor()` push inches positive.
  ///
  /// Example:
  /// ```dart
  /// LengthConversionUtils.feetToString(5.5); // '5 feet 6 inches'
  /// LengthConversionUtils.feetToString(5.5, useAbbreviations: true); // '5 ft 6 in'
  /// LengthConversionUtils.feetToString(5.5, showInches: false); // '5.5 feet'
  /// ```
  @useResult
  static String feetToString(
    double feet, {
    bool useAbbreviations = false,
    bool showInches = true,
    int decimalPlaces = 2,
  }) {
    final String ftLabel = useAbbreviations ? 'ft' : 'feet';

    // NaN and infinity have no integer floor and would throw in the inches
    // decomposition. Render the value alone instead; the formatter handles them.
    if (!showInches || !feet.isFinite) {
      return '${feet.formatDouble(decimalPlaces, showTrailingZeros: false)} $ftLabel';
    }

    return _feetInchesString(
      feet,
      useAbbreviations: useAbbreviations,
      decimalPlaces: decimalPlaces,
    );
  }

  /// Renders finite [feet] as `"<feet> ft <inches> in"` with carry + sign
  /// handling. Split out of [feetToString] to keep each function small and to
  /// isolate the boundary logic that the public contract depends on.
  @useResult
  static String _feetInchesString(
    double feet, {
    required bool useAbbreviations,
    required int decimalPlaces,
  }) {
    final bool isNegative = feet.isNegative;
    final double absFeet = feet.abs();
    int wholeFeet = absFeet.floor();

    // Round inches the same way formatDouble will, then test the 12-inch
    // boundary: 5.999 ft rounds to 12.00 in, which must become 6 ft 0 in.
    final int places = decimalPlaces.clamp(0, _maxDecimalPlaces);
    final num scale = pow(10, places);
    final double rawInches = (absFeet - wholeFeet) * _inchesPerFoot;
    double inches = (rawInches * scale).round() / scale;
    if (inches >= _inchesPerFoot) {
      wholeFeet += 1;
      inches = 0;
    }

    final String sign = isNegative ? '-' : '';
    final String ftLabel = useAbbreviations ? 'ft' : 'feet';
    final String inLabel = useAbbreviations ? 'in' : 'inches';
    return '$sign$wholeFeet $ftLabel '
        '${inches.formatDouble(decimalPlaces, showTrailingZeros: false)} $inLabel';
  }

  /// Formats [meters] as `"1.78 meters"` or `"1.78 m"` with [useAbbreviations].
  ///
  /// Non-finite input is rendered by [DoubleExtensions.formatDouble]
  /// (`"NaN meters"`, `"∞ meters"`).
  ///
  /// Example:
  /// ```dart
  /// LengthConversionUtils.metersToString(1.78); // '1.78 meters'
  /// ```
  @useResult
  static String metersToString(
    double meters, {
    bool useAbbreviations = false,
    int decimalPlaces = 2,
  }) =>
      '${meters.formatDouble(decimalPlaces, showTrailingZeros: false)} '
      '${useAbbreviations ? 'm' : 'meters'}';
}

/// Exact weight conversions between metric (kilograms) and imperial (pounds),
/// plus human-readable string formatters.
///
/// As with [LengthConversionUtils], the `convert*` primitives are the
/// dependency-free core and propagate NaN/infinity; the `*ToString` formatters
/// are an English-only convenience.
abstract final class WeightConversionUtils {
  /// Kilograms → pounds multiplier (1 kg = 2.2046226218 lb). Full precision,
  /// defined once.
  static const double conversionFactor = 2.2046226218;

  /// Converts [kilograms] to pounds.
  ///
  /// NaN/infinity propagate. Negative values are allowed and scale linearly.
  ///
  /// Example:
  /// ```dart
  /// WeightConversionUtils.convertKilogramsToPounds(1); // 2.2046226218
  /// ```
  @useResult
  static double convertKilogramsToPounds(double kilograms) => kilograms * conversionFactor;

  /// Converts [pounds] to kilograms.
  ///
  /// NaN/infinity propagate. Negative values are allowed and scale linearly.
  ///
  /// Example:
  /// ```dart
  /// WeightConversionUtils.convertPoundsToKilograms(2.2046226218); // 1.0
  /// ```
  @useResult
  static double convertPoundsToKilograms(double pounds) => pounds / conversionFactor;

  /// Formats [pounds] as `"80 pounds"` or `"80 lbs"` with [useAbbreviations].
  ///
  /// Example:
  /// ```dart
  /// WeightConversionUtils.poundsToString(80); // '80 pounds'
  /// ```
  @useResult
  static String poundsToString(
    double pounds, {
    bool useAbbreviations = false,
    int decimalPlaces = 2,
  }) =>
      '${pounds.formatDouble(decimalPlaces, showTrailingZeros: false)} '
      '${useAbbreviations ? 'lbs' : 'pounds'}';

  /// Formats [kilograms] as `"80 kilograms"` or `"80 kg"` with [useAbbreviations].
  ///
  /// Example:
  /// ```dart
  /// WeightConversionUtils.kilogramsToString(80); // '80 kilograms'
  /// ```
  @useResult
  static String kilogramsToString(
    double kilograms, {
    bool useAbbreviations = false,
    int decimalPlaces = 2,
  }) =>
      '${kilograms.formatDouble(decimalPlaces, showTrailingZeros: false)} '
      '${useAbbreviations ? 'kg' : 'kilograms'}';
}
