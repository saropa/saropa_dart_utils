/// Outlier detection by MAD / Z-score — roadmap #467.
library;

import 'robust_stats_utils.dart' show median, medianAbsoluteDeviation;

/// Flags indices where |x - median| / MAD > [threshold]. MAD=0 treated as no outliers.
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
  // Flag each index whose distance from the median, in MAD units, exceeds the
  // threshold (default 3.5, the conventional modified z-score cutoff).
  for (int i = 0; i < values.length; i++) {
    if ((values[i] - medianVal).abs() / madVal > threshold) out.add(i);
  }
  return out;
}
