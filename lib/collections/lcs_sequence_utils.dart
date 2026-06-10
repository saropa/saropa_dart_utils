/// Longest common subsequence (LCS) of two lists. Roadmap #69.
///
/// A subsequence keeps relative order but allows gaps (unlike a substring,
/// which must be contiguous — see `lcs_substring_utils.dart`). LCS is the
/// basis of diff tooling: the elements NOT in the LCS are exactly the
/// insertions and deletions between the two sequences.
library;

/// Returns one longest common subsequence of [a] and [b], compared with `==`.
///
/// When several subsequences share the maximum length, one of them is
/// returned (the one favored by the standard bottom-up backtrack). Returns an
/// empty list when either input is empty or nothing is shared.
///
/// Runs in O(a.length * b.length) time and space.
///
/// Example:
/// ```dart
/// longestCommonSubsequence(['a','b','c','d'], ['b','d']); // ['b', 'd']
/// longestCommonSubsequence([1,2,3], [4,5]); // []
/// ```
List<T> longestCommonSubsequence<T>(List<T> a, List<T> b) {
  if (a.isEmpty || b.isEmpty) {
    return <T>[];
  }

  final int n = a.length;
  final int m = b.length;

  // dp[i][j] = LCS length of a[i..] and b[j..]. The extra row/column of zeros
  // at n and m removes the need for bounds checks in the recurrence.
  final List<List<int>> dp = List<List<int>>.generate(
    n + 1,
    (_) => List<int>.filled(m + 1, 0),
  );
  for (int i = n - 1; i >= 0; i--) {
    for (int j = m - 1; j >= 0; j--) {
      if (a[i] == b[j]) {
        dp[i][j] = dp[i + 1][j + 1] + 1;
      } else {
        final int down = dp[i + 1][j];
        final int right = dp[i][j + 1];
        dp[i][j] = down > right ? down : right;
      }
    }
  }

  // Walk the table from the top-left, taking a matched element whenever the
  // characters are equal and otherwise stepping toward the larger subproblem.
  final List<T> result = <T>[];
  int i = 0;
  int j = 0;
  while (i < n && j < m) {
    if (a[i] == b[j]) {
      result.add(a[i]);
      i++;
      j++;
    } else if (dp[i + 1][j] >= dp[i][j + 1]) {
      i++;
    } else {
      j++;
    }
  }
  return result;
}

/// Returns the length of the longest common subsequence of [a] and [b].
///
/// Cheaper than [longestCommonSubsequence] when only the length (e.g. a
/// similarity score) is needed: O(min(a, b)) space instead of the full table.
int longestCommonSubsequenceLength<T>(List<T> a, List<T> b) {
  if (a.isEmpty || b.isEmpty) {
    return 0;
  }

  // Only two rows of the DP table are ever live at once, since each row depends
  // solely on the row below it. Keep a rolling pair instead of the full table
  // for linear space. Here prev is the already-computed lower row and curr is
  // the row being filled.
  List<int> prev = List<int>.filled(b.length + 1, 0);
  List<int> curr = List<int>.filled(b.length + 1, 0);
  // Fill from the bottom-right so each cell reads already-computed neighbors.
  for (int i = a.length - 1; i >= 0; i--) {
    for (int j = b.length - 1; j >= 0; j--) {
      // On a match the LCS grows by one over the diagonal (row i+1, col j+1).
      if (a[i] == b[j]) {
        curr[j] = prev[j + 1] + 1;
      } else {
        // No match: carry the better of dropping a[i] (down) or b[j] (right).
        final int down = prev[j];
        final int right = curr[j + 1];
        curr[j] = down > right ? down : right;
      }
    }
    // Row i becomes the "previous" row for row i-1; reuse the old prev buffer
    // as the next scratch row to avoid reallocating each iteration.
    final List<int> swap = prev;
    prev = curr;
    curr = swap;
  }
  return prev[0];
}
