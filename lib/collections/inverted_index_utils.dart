/// In-memory inverted index for small datasets — roadmap #456.
library;

/// Builds term -> list of document indices containing that term.
Map<String, List<int>> buildInvertedIndex(List<String> documents) {
  // Build a term -> document-indices map (a search index). Each document is
  // lower-cased and tokenized on non-alphanumeric runs; toSet() dedupes so a
  // term repeated within one document still lists that document only once.
  final Map<String, List<int>> index = <String, List<int>>{};
  for (int i = 0; i < documents.length; i++) {
    final List<String> terms = documents[i]
        .toLowerCase()
        .split(RegExp(r'[^a-z0-9]+'))
        .where((s) => s.length > 0)
        .toSet()
        .toList();
    // Append this document's index under each of its unique terms.
    for (final String t in terms) {
      index.putIfAbsent(t, () => <int>[]).add(i);
    }
  }
  return index;
}
