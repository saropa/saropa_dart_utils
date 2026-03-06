/// In-memory inverted index for small datasets — roadmap #456.
library;

/// Builds term -> list of document indices containing that term.
Map<String, List<int>> buildInvertedIndex(List<String> documents) {
  final Map<String, List<int>> index = <String, List<int>>{};
  for (int i = 0; i < documents.length; i++) {
    final List<String> terms = documents[i]
        .toLowerCase()
        .split(RegExp(r'[^a-z0-9]+'))
        .where((s) => s.length > 0)
        .toSet()
        .toList();
    for (final String t in terms) {
      index.putIfAbsent(t, () => []).add(i);
    }
  }
  return index;
}
