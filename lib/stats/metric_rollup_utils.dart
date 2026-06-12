/// Metric roll-up (daily → weekly → monthly) — roadmap #587.
library;

/// Aggregates [dailyValues] (list of 7 or 30 values) into one value by [op].
/// Audited: 2026-06-12 11:26 EDT
double rollupDailyToPeriod(List<double> dailyValues, double Function(List<double>) op) {
  if (dailyValues.isEmpty) return double.nan;
  return op(dailyValues);
}

/// Sum of list.
/// Audited: 2026-06-12 11:26 EDT
double rollupSum(List<double> values) => values.fold(0.0, (a, b) => a + b);

/// Average of list.
/// Audited: 2026-06-12 11:26 EDT
double rollupAvg(List<double> values) =>
    values.isEmpty ? double.nan : rollupSum(values) / values.length;
