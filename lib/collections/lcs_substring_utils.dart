/// Longest common substring (not subsequence) for two lists/strings (roadmap #442).
library;

/// Returns the length of the longest common substring of [a] and [b].
int longestCommonSubstringLength(String a, String b) {
  if (a.isEmpty || b.isEmpty) return 0;
  int maxLen = 0;
  final List<List<int>> dp = List.generate(a.length + 1, (_) => List.filled(b.length + 1, 0));
  for (int i = 1; i <= a.length; i++) {
    for (int j = 1; j <= b.length; j++) {
      if (a[i - 1] == b[j - 1]) {
        dp[i][j] = dp[i - 1][j - 1] + 1;
        if (dp[i][j] > maxLen) maxLen = dp[i][j];
      }
    }
  }
  return maxLen;
}

/// Returns one longest common substring of [a] and [b] (empty if none).
String longestCommonSubstring(String a, String b) {
  if (a.isEmpty || b.isEmpty) return '';
  int maxLen = 0;
  int endA = 0;
  // dp[i][j] holds the length of the common substring ending exactly at a[i-1]
  // and b[j-1]; it only grows on a match, so a mismatch leaves the cell at 0,
  // which restarts the run (substring, not subsequence).
  final List<List<int>> dp = List.generate(a.length + 1, (_) => List.filled(b.length + 1, 0));
  for (int i = 1; i <= a.length; i++) {
    for (int j = 1; j <= b.length; j++) {
      if (a[i - 1] == b[j - 1]) {
        dp[i][j] = dp[i - 1][j - 1] + 1;
        // Remember where the best run ends in `a` so the substring can be sliced
        // out afterward; the length alone cannot locate it.
        if (dp[i][j] > maxLen) {
          maxLen = dp[i][j];
          endA = i;
        }
      }
    }
  }
  if (maxLen == 0) return '';
  // endA is one past the last matched char; backing up by maxLen yields the start.
  final int start = endA - maxLen;
  final int end = endA;
  if (start < 0 || end > a.length) return '';
  return String.fromCharCodes(a.codeUnits.sublist(start, end));
}
