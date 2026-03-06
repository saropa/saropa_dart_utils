/// Edit distance with transpositions (Damerau–Levenshtein) — roadmap #443.
library;

/// Returns Damerau–Levenshtein distance (insert, delete, substitute, transpose).
int damerauLevenshteinDistance(String a, String b) {
  final int aLen = a.length;
  final int bLen = b.length;
  if (aLen == 0) return bLen;
  if (bLen == 0) return aLen;
  final List<int> prevRow = List.filled(bLen + 1, 0);
  final List<int> currRow = List.filled(bLen + 1, 0);
  for (int j = 0; j <= bLen; j++) prevRow[j] = j;
  const int col0 = 0;
  for (int i = 1; i <= aLen; i++) {
    currRow[col0] = i;
    for (int j = 1; j <= bLen; j++) {
      final int cost = a[i - 1] == b[j - 1] ? 0 : 1;
      int best = currRow[j - 1] + 1;
      if (prevRow[j] + 1 < best) best = prevRow[j] + 1;
      if (prevRow[j - 1] + cost < best) best = prevRow[j - 1] + cost;
      if (i > 1 && j > 1 && a[i - 1] == b[j - 2] && a[i - 2] == b[j - 1]) {
        final int transCost = prevRow[j - 2] + 1;
        if (transCost < best) best = transCost;
      }
      currRow[j] = best;
    }
    for (int k = 0; k <= bLen; k++) prevRow[k] = currRow[k];
  }
  return prevRow[bLen];
}
