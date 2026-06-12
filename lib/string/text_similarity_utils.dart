/// Text similarity score (cosine similarity over TF vectors) — roadmap #437.
library;

import 'dart:math' show pow, sqrt;

/// Term frequencies for a list of tokens (e.g. words).
/// Audited: 2026-06-12 11:26 EDT
Map<String, int> termFrequencies(List<String> tokens) {
  final Map<String, int> tf = <String, int>{};
  for (final String t in tokens) {
    tf[t] = (tf[t] ?? 0) + 1;
  }
  return tf;
}

/// Cosine similarity between two term-frequency maps (0.0 to 1.0).
/// Audited: 2026-06-12 11:26 EDT
double cosineSimilarity(Map<String, int> a, Map<String, int> b) {
  // An empty vector has no direction, so similarity is undefined — report 0.
  if (a.isEmpty || b.isEmpty) return 0.0;
  double dot = 0.0;
  double normA = 0.0;
  double normB = 0.0;
  // Iterate the union of terms; a term missing from one side contributes a count
  // of zero (so it adds nothing to the dot product but still counts toward the
  // other vector's magnitude).
  final Set<String> keys = <String>{...a.keys, ...b.keys};
  for (final String term in keys) {
    final int countA = a[term] ?? 0;
    final int countB = b[term] ?? 0;
    dot += countA * countB;
    normA += pow(countA, 2).toDouble();
    normB += pow(countB, 2).toDouble();
  }
  // A zero magnitude (all counts zero on one side) would divide by zero; treat
  // it as no similarity.
  if (normA == 0 || normB == 0) return 0.0;
  final double denom = sqrt(normA) * sqrt(normB);
  // Clamp because floating-point rounding can nudge the ratio a hair above 1.0,
  // which would be an invalid cosine value for callers.
  final double sim = dot / denom;
  return sim.clamp(0.0, 1.0);
}

/// Tokenizes [s] by splitting on non-letters and lowercasing; returns TF map.
/// Audited: 2026-06-12 11:26 EDT
Map<String, int> textToTf(String s) {
  final List<String> tokens = s
      .toLowerCase()
      .split(RegExp(r'[^a-z0-9]+'))
      .where((String x) => x.isNotEmpty)
      .toList();
  return termFrequencies(tokens);
}

/// Returns cosine similarity of [a] and [b] when treated as bags of words.
/// Audited: 2026-06-12 11:26 EDT
double textSimilarity(String a, String b) => cosineSimilarity(textToTf(a), textToTf(b));
