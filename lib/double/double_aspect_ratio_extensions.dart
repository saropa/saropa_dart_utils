import 'package:meta/meta.dart';
import 'package:saropa_dart_utils/double/double_extensions.dart';
import 'package:saropa_dart_utils/int/int_utils.dart';

/// Quantization scale for [DoubleAspectRatioExtensions.toAspectRatio]: the
/// fractional part is captured to three decimal places by multiplying by this
/// factor before reduction.
const int _aspectRatioScale = 1000;

/// Extension method for converting a decimal ratio into a simplified integer
/// aspect-ratio pair.
///
/// Lives in its own file (separate from [DoubleExtensions]) so the core
/// formatting extension stays within the project's per-file size limit; it
/// reuses [DoubleExtensions.hasDecimals] and
/// [IntUtils.findGreatestCommonDenominator].
extension DoubleAspectRatioExtensions on double {
  /// Converts this decimal ratio into a GCD-simplified integer pair, or `null`
  /// when no pair can be derived.
  ///
  /// Useful for turning a measured ratio such as an image's `width / height`
  /// into a compact integer pair for display (e.g. `1.5` → `(2, 3)`). The
  /// fractional part is quantized to three decimal places (`× 1000`) and the
  /// resulting `numerator / 1000` fraction is reduced by its greatest common
  /// denominator via [IntUtils.findGreatestCommonDenominator].
  ///
  /// Tuple order is `(simplifiedDenominator, simplifiedNumerator)` — the
  /// reduced `1000`-side first, the reduced value-side second. This matches the
  /// original Saropa Contacts behavior and is locked by tests; it is NOT
  /// `(width, height)` in the intuitive sense, so callers must not assume the
  /// first element is the width.
  ///
  /// Documented limits and edge behavior:
  /// - **Whole numbers** skip quantization and return `(1, toInt())` — `3.0`
  ///   yields `(1, 3)`, i.e. `1:3`, not `3:1`.
  /// - **3-decimal quantization is lossy and truncating** (toward zero), so
  ///   canonical small ratios are NOT recovered: `16 / 9` (`1.7777…`) reduces
  ///   the truncated `1777 / 1000`, giving `(1000, 1777)`, not `(9, 16)`.
  /// - **Negative fractional** input yields `null`: the GCD helper rejects the
  ///   negative numerator, so e.g. `-1.5` returns `null`. Negative whole
  ///   numbers take the whole-number branch and are NOT rejected (`-2.0` →
  ///   `(1, -2)`).
  /// - **NaN / ±Infinity** yield `null`. Without this guard the whole-number
  ///   branch would call `toInt()` on a non-finite value and throw
  ///   `UnsupportedError`; returning `null` keeps the method total.
  ///
  /// Example:
  /// ```dart
  /// 1.5.toAspectRatio();        // (2, 3)
  /// 1.25.toAspectRatio();       // (4, 5)
  /// 3.0.toAspectRatio();        // (1, 3)
  /// (16 / 9).toAspectRatio();   // (1000, 1777) — truncated, not (9, 16)
  /// (-1.5).toAspectRatio();     // null
  /// double.nan.toAspectRatio(); // null
  /// ```
  @useResult
  (int, int)? toAspectRatio() {
    // Guard non-finite input first: the whole-number branch below truncates via
    // toInt(), which throws UnsupportedError on NaN/Infinity. Returning null
    // keeps this a total function instead of leaking that throw to callers.
    if (isNaN || isInfinite) {
      return null;
    }

    // Whole numbers carry no fractional part to quantize; emit (1, value) so the
    // integral path stays distinct from the GCD-reduced fractional path.
    if (!hasDecimals) {
      return (1, toInt());
    }

    // Capture the ratio as a fraction at three decimal places. toInt() truncates
    // toward zero, so this is a deliberate precision floor, not rounding.
    final int numerator = (this * _aspectRatioScale).toInt();
    const int denominator = _aspectRatioScale;

    // Reduce numerator/denominator by their GCD. The helper returns null for a
    // negative numerator (negative fractional input) and on its depth guard;
    // propagate that null rather than emitting an unreduced or wrong pair.
    final int? commonDivisor = IntUtils.findGreatestCommonDenominator(
      numerator,
      denominator,
    );
    if (commonDivisor == null) {
      return null;
    }

    final int simplifiedNumerator = numerator ~/ commonDivisor;
    final int simplifiedDenominator = denominator ~/ commonDivisor;

    // Order preserved from the source: denominator-side first, value-side
    // second. Intentionally NOT (width, height); a regression test pins this.
    return (simplifiedDenominator, simplifiedNumerator);
  }
}
