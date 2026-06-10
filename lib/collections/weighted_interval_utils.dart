/// Weighted interval scheduling (max weight, DP) — roadmap #446.
library;

/// Interval with weight.
class WeightedIntervalUtils {
  /// Creates an interval spanning [start] to [end] with the given [weight].
  const WeightedIntervalUtils(int start, int end, int weight)
    : _start = start,
      _end = end,
      _weight = weight;
  final int _start;

  /// Start of the interval.
  int get start => _start;
  final int _end;

  /// End of the interval.
  int get end => _end;
  final int _weight;

  /// Weight (value) contributed when this interval is selected.
  int get weight => _weight;

  @override
  String toString() => 'WeightedIntervalUtils(start: $_start, end: $_end, weight: $_weight)';
}

/// Returns the maximum total weight of non-overlapping intervals (DP by end time).
int maxWeightIntervals(List<WeightedIntervalUtils> intervals) {
  if (intervals.isEmpty) return 0;
  // Sort by end time so that for any interval, every compatible (earlier-ending,
  // non-overlapping) interval sits to its left — the precondition that makes the
  // linear back-scan below correct.
  final List<WeightedIntervalUtils> sorted = List<WeightedIntervalUtils>.of(intervals)
    ..sort((a, b) => a.end.compareTo(b.end));
  // Each dp entry holds the best achievable weight using only the first i
  // intervals; the entry at index zero is the empty-selection base case, so dp
  // is sized one larger than the input and indexed from one.
  final List<int> dp = List.filled(sorted.length + 1, 0);
  for (int i = 1; i <= sorted.length; i++) {
    final WeightedIntervalUtils cur = sorted[i - 1];
    // Walk left to the nearest interval that ends at or before the current
    // interval's start; the index reached counts the intervals compatible with
    // taking the current one. Linear scan (not binary search) keeps the code
    // simple; cost is quadratic worst case, fine for the small interval sets
    // this utility targets.
    int j = i - 1;
    while (j > 0 && sorted[j - 1].end > cur.start) {
      j--;
    }
    // Choose the better of skipping the current interval or taking it (its
    // weight plus the best weight among the compatible intervals to its left).
    final int w = (j > 0 ? dp[j] : 0) + cur.weight;
    dp[i] = dp[i - 1] > w ? dp[i - 1] : w;
  }
  return dp[sorted.length];
}
