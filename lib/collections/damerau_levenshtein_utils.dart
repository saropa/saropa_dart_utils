/// Edit distance with transpositions (Damerau–Levenshtein) — roadmap #443.
library;

/// Returns Damerau–Levenshtein distance (insert, delete, substitute, transpose).
int damerauLevenshteinDistance(String a, String b) {
  final int aLen = a.length;
  final int bLen = b.length;
  if (aLen == 0) return bLen;
  if (bLen == 0) return aLen;
  // Optimal string alignment variant: every cell reads only the current row and
  // the row immediately above (the transposition term uses prevRow[j-2], still
  // that same prior row), so two rolling rows give O(bLen) space rather than
  // the full O(aLen*bLen) matrix.
  final List<int> prevRow = List.filled(bLen + 1, 0);
  final List<int> currRow = List.filled(bLen + 1, 0);
  // Base case: transforming an empty prefix of `a` into b[0..j) costs j insertions.
  for (int j = 0; j <= bLen; j++) {
    prevRow[j] = j;
  }
  const int col0 = 0;
  for (int i = 1; i <= aLen; i++) {
    currRow[col0] = i;
    for (int j = 1; j <= bLen; j++) {
      final int cost = a[i - 1] == b[j - 1] ? 0 : 1;
      // The three classic edits: insertion (left+1), deletion (up+1),
      // substitution/match (diagonal+cost).
      int best = currRow[j - 1] + 1;
      if (prevRow[j] + 1 < best) best = prevRow[j] + 1;
      if (prevRow[j - 1] + cost < best) best = prevRow[j - 1] + cost;
      // Transposition of two adjacent characters: only valid when the last two
      // chars of each prefix are swapped (a[i-1]==b[j-2] && a[i-2]==b[j-1]).
      // Skipped when i==1 or j==1 since there is no second-prior char to swap.
      if (i > 1 && j > 1 && a[i - 1] == b[j - 2] && a[i - 2] == b[j - 1]) {
        final int transCost = prevRow[j - 2] + 1;
        if (transCost < best) best = transCost;
      }
      currRow[j] = best;
    }
    for (int k = 0; k <= bLen; k++) {
      prevRow[k] = currRow[k];
    }
  }
  return prevRow[bLen];
}
