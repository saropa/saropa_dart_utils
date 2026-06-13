/// Gini coefficient — inequality measure in [0, 1] (roadmap #573).
///
/// The Gini coefficient summarizes how unevenly a quantity (income, traffic,
/// load) is distributed: 0 is perfect equality (every value identical) and it
/// approaches 1 as a single member holds everything.
library;

/// Gini coefficient of [values], a number in [0, 1].
///
/// Uses the rank-weighted form on the ascending-sorted values:
///
///   G = sum_i (2*i - n - 1) * x_i  /  (n * sum(x))
///
/// where i is the 1-based rank. Returns:
/// - NaN for an empty list (no distribution to measure).
/// - 0 when every value is zero (the total is zero, so inequality is
///   conventionally defined as none rather than dividing by zero).
///
/// Negative values are not meaningful for an inequality share and would make
/// the result fall outside [0, 1], so they are rejected with an assertion.
///
/// Example:
/// ```dart
/// giniCoefficient(<num>[1, 1, 1, 1]); // 0.0 (perfect equality)
/// giniCoefficient(<num>[0, 0, 0, 10]); // -> (n-1)/n
/// ```
/// Audited: 2026-06-12 11:26 EDT
double giniCoefficient(List<num> values) {
  // Empty input has no distribution; NaN signals "undefined" per house convention.
  if (values.isEmpty) return double.nan;
  // A negative share is undefined for inequality and breaks the [0,1] range.
  // Enforced in release (an assert strips): a negative value would silently
  // produce an out-of-range coefficient instead of signaling bad input.
  if (values.any((num v) => v < 0)) {
    throw ArgumentError.value(values, 'values', 'must all be non-negative');
  }
  final List<double> sorted = values.map((num v) => v.toDouble()).toList()..sort();
  final int n = sorted.length;
  double total = 0;
  double weighted = 0;
  for (int i = 0; i < n; i++) {
    final double x = sorted[i];
    total += x;
    // Rank weight (2*rank - n - 1) with rank = i + 1; ascending order makes
    // small values carry negative weight and large values positive weight.
    weighted += (2 * (i + 1) - n - 1) * x;
  }
  // All-zero total: define inequality as zero rather than dividing by zero.
  if (total == 0) return 0;
  return weighted / (n * total);
}
