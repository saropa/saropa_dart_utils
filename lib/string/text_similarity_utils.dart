/// Text similarity score (cosine similarity over TF vectors) — roadmap #437.
library;

import 'dart:math' show pow, sqrt;

/// Term frequencies for a list of tokens (e.g. words).
Map<String, int> termFrequencies(List<String> tokens) {
  final Map<String, int> tf = <String, int>{};
  for (final String t in tokens) {
    tf[t] = (tf[t] ?? 0) + 1;
  }
  return tf;
}

/// Cosine similarity between two term-frequency maps (0.0 to 1.0).
double cosineSimilarity(Map<String, int> a, Map<String, int> b) {
  if (a.isEmpty || b.isEmpty) return 0.0;
  double dot = 0.0;
  double normA = 0.0;
  double normB = 0.0;
  final Set<String> keys = <String>{...a.keys, ...b.keys};
  for (final String term in keys) {
    final int countA = a[term] ?? 0;
    final int countB = b[term] ?? 0;
    dot += countA * countB;
    normA += pow(countA, 2).toDouble();
    normB += pow(countB, 2).toDouble();
  }
  if (normA == 0 || normB == 0) return 0.0;
  final double denom = sqrt(normA) * sqrt(normB);
  final double sim = dot / denom;
  return sim.clamp(0.0, 1.0);
}

/// Tokenizes [s] by splitting on non-letters and lowercasing; returns TF map.
Map<String, int> textToTf(String s) {
  final List<String> tokens = s
      .toLowerCase()
      .split(RegExp(r'[^a-z0-9]+'))
      .where((String x) => x.isNotEmpty)
      .toList();
  return termFrequencies(tokens);
}

/// Returns cosine similarity of [a] and [b] when treated as bags of words.
double textSimilarity(String a, String b) => cosineSimilarity(textToTf(a), textToTf(b));
