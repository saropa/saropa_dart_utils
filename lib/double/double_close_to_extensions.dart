import 'dart:math';

import 'package:meta/meta.dart';

/// Tolerance-based floating-point comparison.
extension DoubleCloseToExtensions on double {
  /// Returns `true` if this value is within tolerance of [other].
  ///
  /// Direct `==` on doubles is unreliable: `0.1 + 0.2 == 0.3` is `false` because
  /// binary floating point cannot represent those decimals exactly. This
  /// compares with a tolerance instead, so accumulated rounding error does not
  /// register as inequality.
  ///
  /// The tolerance is the larger of [absoluteTolerance] (a fixed floor, which
  /// makes comparisons against `0.0` meaningful — a relative tolerance alone
  /// collapses to zero there) and [relativeTolerance] scaled by the magnitude
  /// of the inputs (so the same call works for both tiny and very large
  /// numbers). Defaults follow the common `1e-9` convention.
  ///
  /// `NaN` is never close to anything, including another `NaN`. Two infinities
  /// of the same sign are close; opposite signs are not.
  ///
  /// Example:
  /// ```dart
  /// (0.1 + 0.2).isCloseTo(0.3); // true
  /// 1.0.isCloseTo(1.5);         // false
  /// 0.0.isCloseTo(1e-12);       // true (absolute floor)
  /// ```
  @useResult
  bool isCloseTo(
    double other, {
    double relativeTolerance = 1e-9,
    double absoluteTolerance = 1e-12,
  }) {
    // Exact match (covers same-sign infinity) without computing a difference
    // that would be NaN for inf - inf.
    if (this == other) {
      return true;
    }

    // NaN and any remaining infinity case cannot be "close": a finite tolerance
    // can never bridge them.
    if (isNaN || other.isNaN || isInfinite || other.isInfinite) {
      return false;
    }

    final double diff = (this - other).abs();
    final double scaled = relativeTolerance * max(abs(), other.abs());
    return diff <= max(absoluteTolerance, scaled);
  }
}
