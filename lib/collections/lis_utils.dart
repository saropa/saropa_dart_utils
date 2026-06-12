/// Longest increasing subsequence (LIS) with reconstruction (roadmap #441).
library;

/// Returns length of LIS of [list] using comparable order, and optionally
/// the indices of one such subsequence (reconstruction).
/// Audited: 2026-06-12 11:26 EDT
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
/// Audited: 2026-06-12 11:26 EDT
List<int> lisIndices<T extends Comparable<Object>>(List<T> list) {
  if (list.isEmpty) return <int>[];
  // Quadratic dynamic program. For each position, the dp list holds the length
  // of the longest increasing subsequence ending there, and the prev list holds
  // the index of the element chosen just before it so the sequence can be
  // reconstructed; a negative prev marks a starting element.
  final List<int> dp = List.filled(list.length, 1);
  final List<int> prev = List.filled(list.length, -1);
  for (int i = 1; i < list.length; i++) {
    // Extend the best earlier subsequence whose last element is < list[i].
    for (int j = 0; j < i; j++) {
      if (list[j].compareTo(list[i]) < 0 && dp[j] + 1 > dp[i]) {
        dp[i] = dp[j] + 1;
        prev[i] = j;
      }
    }
  }
  // The overall LIS ends at the index with the largest dp value.
  int maxIdx = 0;
  for (int i = 1; i < dp.length; i++) {
    if (dp[i] > dp[maxIdx]) maxIdx = i;
  }
  // Walk the prev chain back from that end, then reverse to natural order.
  final List<int> out = <int>[];
  for (int i = maxIdx; i >= 0; i = prev[i]) {
    out.add(i);
    if (prev[i] < 0) break;
  }
  return out.reversed.toList();
}
