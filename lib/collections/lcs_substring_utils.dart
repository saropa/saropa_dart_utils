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
  final List<List<int>> dp = List.generate(a.length + 1, (_) => List.filled(b.length + 1, 0));
  for (int i = 1; i <= a.length; i++) {
    for (int j = 1; j <= b.length; j++) {
      if (a[i - 1] == b[j - 1]) {
        dp[i][j] = dp[i - 1][j - 1] + 1;
        if (dp[i][j] > maxLen) {
          maxLen = dp[i][j];
          endA = i;
        }
      }
    }
  }
  if (maxLen == 0) return '';
  final int start = endA - maxLen;
  final int end = endA;
  if (start < 0 || end > a.length) return '';
  return String.fromCharCodes(a.codeUnits.sublist(start, end));
}
