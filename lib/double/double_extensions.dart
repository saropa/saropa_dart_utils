import 'dart:math';

/// Multiplier to convert decimal to percentage (0.5 * 100 = 50%).
const int _percentageMultiplier = 100;

/// Base for decimal number system and power-of-10 calculations.
const int _base10 = 10;

// Matches trailing zeros after a decimal point (e.g., "15.50" -> "15.5", "15.00" -> "15")
final RegExp _trailingZerosRegex = RegExp(r'0+$');
final RegExp _trailingDecimalPointRegex = RegExp(r'\.$');

/// Extension methods for [double] values providing formatting and conversion utilities.
extension DoubleExtensions on double {
  /// Returns `true` if this double has a non-zero fractional part.
  ///
  /// Example:
  /// ```dart
  /// 15.5.hasDecimals; // true
  /// 15.0.hasDecimals; // false
  /// 15.00.hasDecimals; // false
  /// ```
  bool get hasDecimals => this % 1 != 0;

  /// Formats this double value as a percentage string.
  ///
  /// Multiplies the value by 100 and appends a '%' symbol.
  ///
  /// - [decimalPlaces]: Number of decimal places to include (default: 0).
  /// - [roundDown]: If `true` (default), rounds down to the nearest value.
  ///   If `false`, uses standard rounding.
  ///
  /// Example:
  /// ```dart
  /// 0.5.toPercentage(); // '50%'
  /// 0.756.toPercentage(decimalPlaces: 1); // '75.6%' (rounded down)
  /// 0.756.toPercentage(decimalPlaces: 1, roundDown: false); // '75.6%'
  /// 0.999.toPercentage(); // '99%' (rounded down)
  /// 0.999.toPercentage(roundDown: false); // '100%'
  /// ```
  String toPercentage({int decimalPlaces = 0, bool roundDown = true}) {
    if (!roundDown) {
      return '${(this * _percentageMultiplier).formatDouble(decimalPlaces, showTrailingZeros: false)}%';
    }

    // Calculate the multiplier for the specified number of decimal places
    final num multiplier = pow(_base10, decimalPlaces);

    // Multiply by 100 to convert to percentage and by multiplier to shift decimal
    // Then use floor to round down to the nearest integer value
    final double roundedValue = (this * _percentageMultiplier * multiplier).floor() / multiplier;

    return '${roundedValue.formatDouble(decimalPlaces, showTrailingZeros: false)}%';
  }

  /// Formats this double to a string with a specified number of decimal places.
  ///
  /// Optionally removes trailing zeros after the decimal point when
  /// [showTrailingZeros] is `false`.
  ///
  /// Examples when [showTrailingZeros] is `false`:
  /// - 15.00 → "15"
  /// - 15.50 → "15.5"
  /// - 15.05 → "15.05"
  ///
  /// - [decimalPlaces]: The number of decimal places to format to.
  /// - [showTrailingZeros]: Whether to keep trailing zeros (default: `true`).
  ///
  /// Example:
  /// ```dart
  /// 15.0.formatDouble(2); // '15.00'
  /// 15.0.formatDouble(2, showTrailingZeros: false); // '15'
  /// 15.5.formatDouble(2, showTrailingZeros: false); // '15.5'
  /// 15.05.formatDouble(2, showTrailingZeros: false); // '15.05'
  /// ```
  String formatDouble(int decimalPlaces, {bool showTrailingZeros = true}) {
    final String result = toStringAsFixed(decimalPlaces);

    if (showTrailingZeros || decimalPlaces == 0) {
      return result;
    }

    // Remove trailing zeros, then remove trailing decimal point if present
    return result.replaceAll(_trailingZerosRegex, '').replaceAll(_trailingDecimalPointRegex, '');
  }

  /// Clamps this value to be within the range [from] to [to].
  ///
  /// Returns:
  /// - [from] if this value is less than [from]
  /// - [to] if this value is greater than [to]
  /// - This value if it's within the range
  ///
  /// Example:
  /// ```dart
  /// 5.0.forceBetween(0.0, 10.0); // 5.0
  /// (-5.0).forceBetween(0.0, 10.0); // 0.0
  /// 15.0.forceBetween(0.0, 10.0); // 10.0
  /// ```
  double forceBetween(double from, double to) {
    if (this < from) {
      return from;
    }

    if (this > to) {
      return to;
    }

    return this;
  }

  /// Truncates this double to a given precision after the decimal point.
  ///
  /// Unlike rounding, this always truncates towards zero.
  ///
  /// - [precision]: Number of decimal places to keep.
  ///
  /// Example:
  /// ```dart
  /// 3.14159.toPrecision(2); // 3.14
  /// 3.149.toPrecision(2); // 3.14 (truncated, not rounded)
  /// (-3.149).toPrecision(2); // -3.14
  /// ```
  double toPrecision(int precision) {
    final num multiplier = pow(_base10, precision);

    return (this * multiplier).truncate() / multiplier;
  }

  /// Formats this double with smart decimal handling.
  ///
  /// Shows the value without decimals if it's a whole number,
  /// otherwise shows it with the specified precision.
  ///
  /// - [precision]: Number of decimal places for non-whole numbers (default: 2).
  ///
  /// Example:
  /// ```dart
  /// 15.0.formatPrecision(); // '15'
  /// 15.00.formatPrecision(); // '15'
  /// 15.5.formatPrecision(); // '15.50'
  /// 15.123.formatPrecision(); // '15.12'
  /// ```
  String formatPrecision({int precision = 2}) {
    return toStringAsFixed(2).endsWith('.00') ? toStringAsFixed(0) : toStringAsFixed(precision);
  }
}
