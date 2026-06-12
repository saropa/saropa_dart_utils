/// Outlier detection by MAD / Z-score — roadmap #467.
library;

import 'robust_stats_utils.dart' show median, medianAbsoluteDeviation;

/// Flags indices where the raw deviation in MAD units, `|x - median| / MAD`,
/// exceeds [threshold]. `MAD == 0` is treated as no outliers.
///
/// This compares the unscaled ratio, NOT the Iglewicz-Hoaglin modified z-score
/// `0.6745 * (x - median) / MAD`. The two differ by the 0.6745 consistency
/// constant, so the conventional modified-z cutoff of 3.5 corresponds to a raw
/// MAD-unit [threshold] of `3.5 / 0.6745 ≈ 5.19` here. The default of 3.5 is
/// therefore more aggressive than the literal modified-z 3.5; pass `5.19` to
/// match the textbook modified z-score behavior.
/// Audited: 2026-06-12 11:26 EDT
Set<int> outlierIndicesByMAD(List<num> values, {double threshold = 3.5}) {
  // Median and MAD (not mean/stddev) are used so the spread estimate is itself
  // robust — a few extreme outliers cannot inflate the scale and mask each other.
  final double medianVal = median(values);
  final double madVal = medianAbsoluteDeviation(values);
  // MAD of zero means over half the values are identical: there is no spread to
  // measure against and dividing by it would be infinity/NaN, so flag nothing.
  // NaN guards the empty-input case.
  if (madVal == 0 || madVal.isNaN) return <int>{};
  final Set<int> out = <int>{};
  // Flag each index whose distance from the median, in raw MAD units, exceeds
  // the threshold. Note this omits the 0.6745 modified-z constant (see the
  // doc comment): the default 3.5 is a raw-MAD cutoff, not the modified-z 3.5.
  for (int i = 0; i < values.length; i++) {
    if ((values[i] - medianVal).abs() / madVal > threshold) out.add(i);
  }
  return out;
}
