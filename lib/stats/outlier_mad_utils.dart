/// Outlier detection by MAD / Z-score — roadmap #467.
library;

import 'robust_stats_utils.dart' show median, medianAbsoluteDeviation;

/// Flags indices where |x - median| / MAD > [threshold]. MAD=0 treated as no outliers.
Set<int> outlierIndicesByMAD(List<num> values, {double threshold = 3.5}) {
  final double medianVal = median(values);
  final double madVal = medianAbsoluteDeviation(values);
  if (madVal == 0 || madVal.isNaN) return <int>{};
  final Set<int> out = <int>{};
  for (int i = 0; i < values.length; i++) {
    if ((values[i] - medianVal).abs() / madVal > threshold) out.add(i);
  }
  return out;
}
