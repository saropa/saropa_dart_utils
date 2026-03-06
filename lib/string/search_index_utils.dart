/// Simple in-memory search index (term frequency scoring) — roadmap #407.
library;

import 'text_similarity_utils.dart';

/// In-memory document index: add docs, search by query (TF scoring).
class SearchIndexUtils {
  final List<String> _docs = [];
  final List<Map<String, int>> _tfs = [];

  /// Adds [text] as a document to the index.
  void addDocument(String text) {
    _docs.add(text);
    _tfs.add(textToTf(text));
  }

  /// Returns up to [limit] hits as (documentIndex, score), sorted by score descending.
  /// Each record is (index, score) with index the document index and score the TF similarity.
  List<(int, double)> search(String query, {int limit = 10}) {
    final Map<String, int> qTf = textToTf(query);
    final List<(int, double)> results = List.filled(_tfs.length, (0, 0.0));
    int count = 0;
    for (final MapEntry<int, Map<String, int>> entry in _tfs.asMap().entries) {
      final double score = cosineSimilarity(qTf, entry.value);
      if (score > 0) {
        results[count++] = (entry.key, score);
      }
    }
    final List<(int, double)> trimmed = results.sublist(0, count);
    trimmed.sort((a, b) {
      final (_, aScore) = a;
      final (_, bScore) = b;
      return bScore.compareTo(aScore);
    });
    return trimmed.take(limit).toList();
  }

  /// Number of documents in the index.
  int get length => _docs.length;

  /// Returns the document at [i].
  String getDocument(int i) => _docs[i];

  @override
  String toString() => 'SearchIndexUtils(length: ${_docs.length})';
}
