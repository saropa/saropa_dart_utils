/// Weighted interval scheduling (max weight, DP) — roadmap #446.
library;

/// Interval with weight.
class WeightedIntervalUtils {
  const WeightedIntervalUtils(int start, int end, int weight)
    : _start = start,
      _end = end,
      _weight = weight;
  final int _start;

  int get start => _start;
  final int _end;

  int get end => _end;
  final int _weight;

  int get weight => _weight;

  @override
  String toString() => 'WeightedIntervalUtils(start: $_start, end: $_end, weight: $_weight)';
}

/// Returns the maximum total weight of non-overlapping intervals (DP by end time).
int maxWeightIntervals(List<WeightedIntervalUtils> intervals) {
  if (intervals.isEmpty) return 0;
  final List<WeightedIntervalUtils> sorted = List<WeightedIntervalUtils>.of(intervals)
    ..sort((a, b) => a.end.compareTo(b.end));
  final List<int> dp = List.filled(sorted.length + 1, 0);
  for (int i = 1; i <= sorted.length; i++) {
    final WeightedIntervalUtils cur = sorted[i - 1];
    int j = i - 1;
    while (j > 0 && sorted[j - 1].end > cur.start) j--;
    final int w = (j > 0 ? dp[j] : 0) + cur.weight;
    dp[i] = dp[i - 1] > w ? dp[i - 1] : w;
  }
  return dp[sorted.length];
}
