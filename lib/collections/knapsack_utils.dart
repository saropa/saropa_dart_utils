/// 0/1 Knapsack solver with reconstruction — roadmap #444.
library;

/// Item with weight and value.
class KnapsackUtils {
  const KnapsackUtils(int weight, int value) : _weight = weight, _value = value;
  final int _weight;

  /// Item weight (cost).
  int get weight => _weight;
  final int _value;

  /// Item value (profit).
  int get value => _value;

  @override
  String toString() => 'KnapsackItem(weight: $_weight, value: $_value)';
}

/// Solves the 0/1 knapsack: (max value, indices of chosen items). [items] and [capacity] must be non-negative.
(int value, List<int> indices) knapsack01(List<KnapsackUtils> items, int capacity) {
  if (capacity <= 0 || items.isEmpty) return (0, <int>[]);
  final int n = items.length;
  final List<List<int>> dp = List.generate(n + 1, (_) => List.filled(capacity + 1, 0));
  for (int i = 1; i <= n; i++) {
    final int w = items[i - 1].weight;
    final int v = items[i - 1].value;
    for (int c = 0; c <= capacity; c++) {
      dp[i][c] = dp[i - 1][c];
      if (w <= c && dp[i - 1][c - w] + v > dp[i][c]) {
        dp[i][c] = dp[i - 1][c - w] + v;
      }
    }
  }
  final List<int> chosen = <int>[];
  int c = capacity;
  for (int i = n; i > 0 && c > 0; i--) {
    if (dp[i][c] != dp[i - 1][c]) {
      chosen.add(i - 1);
      c -= items[i - 1].weight;
    }
  }
  return (dp[n][capacity], chosen.reversed.toList());
}
