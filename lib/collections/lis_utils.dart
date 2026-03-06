/// Longest increasing subsequence (LIS) with reconstruction (roadmap #441).
library;

/// Returns length of LIS of [list] using comparable order, and optionally
/// the indices of one such subsequence (reconstruction).
int lisLength<T extends Comparable<Object>>(List<T> list) {
  if (list.isEmpty) return 0;
  final List<int> dp = List.filled(list.length, 1);
  for (int i = 1; i < list.length; i++) {
    for (int j = 0; j < i; j++) {
      if (list[j].compareTo(list[i]) < 0 && dp[j] + 1 > dp[i]) {
        dp[i] = dp[j] + 1;
      }
    }
  }
  return dp.fold<int>(0, (int a, int b) => a > b ? a : b);
}

/// Returns one LIS as a list of indices into [list].
List<int> lisIndices<T extends Comparable<Object>>(List<T> list) {
  if (list.isEmpty) return <int>[];
  final List<int> dp = List.filled(list.length, 1);
  final List<int> prev = List.filled(list.length, -1);
  for (int i = 1; i < list.length; i++) {
    for (int j = 0; j < i; j++) {
      if (list[j].compareTo(list[i]) < 0 && dp[j] + 1 > dp[i]) {
        dp[i] = dp[j] + 1;
        prev[i] = j;
      }
    }
  }
  int maxIdx = 0;
  for (int i = 1; i < dp.length; i++) {
    if (dp[i] > dp[maxIdx]) maxIdx = i;
  }
  final List<int> out = <int>[];
  for (int i = maxIdx; i >= 0; i = prev[i]) {
    out.add(i);
    if (prev[i] < 0) break;
  }
  return out.reversed.toList();
}
