/// Feature scaling/encoding (bucketization, one-hot) — roadmap #589.
library;

/// One-hot: [value] in [categories] -> list of 0/1 of length [categories].
List<int> oneHot(Object? value, List<Object?> categories) {
  return categories.map((Object? c) => c == value ? 1 : 0).toList();
}

/// Bucketize numeric value into bin index for [edges] (sorted boundaries).
int bucketize(num value, List<num> edges) {
  for (int i = 0; i < edges.length; i++) {
    if (value < edges[i]) return i;
  }
  return edges.length;
}
