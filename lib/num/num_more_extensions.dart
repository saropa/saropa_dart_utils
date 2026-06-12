import 'dart:math' as math;
import 'package:meta/meta.dart';

/// Number More: clamp non-negative, isInteger, round half up, truncate decimals, percentage, degrees/radians, etc. Roadmap #311-325.
extension NumMoreExtensions on num {
  /// Returns this number rounded to the nearest int, with negatives clamped to `0`.
  ///
  /// Example:
  /// ```dart
  /// 3.6.clampNonNegative(); // 4
  /// (-2).clampNonNegative(); // 0
  /// ```
  /// Audited: 2026-06-12 11:26 EDT
  @useResult
  int clampNonNegative() => this < 0 ? 0 : round();

  /// Returns `true` if this number has no fractional part.
  ///
  /// `true` for any `int`, and for a `double` whose value equals its rounded
  /// value (e.g. `2.0`).
  /// Audited: 2026-06-12 11:26 EDT
  @useResult
  bool get isInteger => this is int || (this is double && this == roundToDouble());

  /// Truncates this number to [places] decimal places without rounding.
  ///
  /// Digits beyond [places] are dropped toward zero.
  ///
  /// Example:
  /// ```dart
  /// 3.14159.truncateToDecimals(2); // 3.14
  /// ```
  /// Audited: 2026-06-12 11:26 EDT
  @useResult
  double truncateToDecimals(int places) {
    final double f = math.pow(10, places).toDouble();
    return (this * f).truncate() / f;
  }

  /// Returns the fractional change from [from] to this value.
  ///
  /// Returns `0` when [from] is zero to avoid division by zero. Multiply by
  /// `100` for a percentage.
  ///
  /// Example:
  /// ```dart
  /// 150.percentageChangeFrom(100); // 0.5 (a 50% increase)
  /// ```
  /// Audited: 2026-06-12 11:26 EDT
  @useResult
  double percentageChangeFrom(num from) => from == 0 ? 0 : (this - from) / from;

  /// Returns this value as a fraction of [total].
  ///
  /// Returns `0` when [total] is zero to avoid division by zero. Multiply by
  /// `100` for a percentage.
  ///
  /// Example:
  /// ```dart
  /// 25.percentageOf(200); // 0.125
  /// ```
  /// Audited: 2026-06-12 11:26 EDT
  @useResult
  double percentageOf(num total) => total == 0 ? 0 : this / total;
}

/// Converts an angle in degrees ([deg]) to radians.
/// Audited: 2026-06-12 11:26 EDT
double degreesToRadians(double deg) => deg * math.pi / 180;

/// Converts an angle in radians ([rad]) to degrees.
/// Audited: 2026-06-12 11:26 EDT
double radiansToDegrees(double rad) => rad * 180 / math.pi;

/// Normalizes [degrees] into the range `[0, 360)`.
///
/// Negative inputs wrap around, so `-90` becomes `270`.
///
/// Example:
/// ```dart
/// normalizeAngle360(450); // 90.0
/// normalizeAngle360(-90); // 270.0
/// ```
/// Audited: 2026-06-12 11:26 EDT
double normalizeAngle360(double degrees) {
  double d = degrees % 360;
  if (d < 0) d += 360;
  return d;
}

/// Normalizes [degrees] into the range `(-180, 180]`.
///
/// Useful for shortest-rotation calculations where the sign indicates
/// direction.
///
/// Example:
/// ```dart
/// normalizeAngle180(270); // -90.0
/// ```
/// Audited: 2026-06-12 11:26 EDT
double normalizeAngle180(double degrees) {
  double d = degrees % 360;
  if (d > 180) d -= 360;
  if (d < -180) d += 360;
  return d;
}

/// Returns the sum of the decimal digits of [n].
///
/// The sign of [n] is ignored; negatives use their absolute value.
///
/// Example:
/// ```dart
/// digitSum(123); // 6
/// digitSum(-49); // 13
/// ```
/// Audited: 2026-06-12 11:26 EDT
int digitSum(int n) {
  int remaining = n.abs();
  int s = 0;
  while (remaining > 0) {
    s += remaining % 10;
    remaining ~/= 10;
  }
  return s;
}

/// Returns `true` if [n] is a positive power of two (`1, 2, 4, 8, …`).
///
/// Returns `false` for zero and negative numbers.
/// Audited: 2026-06-12 11:26 EDT
bool isPowerOfTwo(int n) => n > 0 && (n & (n - 1)) == 0;

/// Returns the smallest power of two greater than or equal to [n].
///
/// Returns `1` for any [n] less than or equal to zero.
///
/// Example:
/// ```dart
/// nextPowerOfTwo(17); // 32
/// ```
/// Audited: 2026-06-12 11:26 EDT
int nextPowerOfTwo(int n) {
  if (n <= 0) return 1;
  int v = n - 1;
  // Smear the highest set bit down into every lower bit, then add 1. Dart ints
  // are 64-bit, so the shift chain MUST reach 32: stopping at 16 (the 32-bit
  // recipe) leaves inputs above 2^32 with an unfilled high half and a wrong
  // result.
  v |= v >> 1;
  v |= v >> 2;
  v |= v >> 4;
  v |= v >> 8;
  v |= v >> 16;
  v |= v >> 32;
  return v + 1;
}

/// Returns the integer square root of [n] (the floor of its real square root).
///
/// Returns `0` for any [n] less than or equal to zero.
///
/// Example:
/// ```dart
/// isqrt(17); // 4
/// isqrt(16); // 4
/// ```
/// Audited: 2026-06-12 11:26 EDT
int isqrt(int n) {
  if (n <= 0) return 0;
  int x = n;
  int y = (x + 1) >> 1;
  while (y < x) {
    x = y;
    y = (x + n ~/ x) >> 1;
  }
  return x;
}
