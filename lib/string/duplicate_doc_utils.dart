/// Near-duplicate document detector via fingerprints — roadmap #438.
library;

import 'text_similarity_utils.dart';

/// Returns true if [a] and [b] are near-duplicates (cosine similarity >= [threshold]).
bool isNearDuplicate(String a, String b, {double threshold = 0.85}) =>
    textSimilarity(a, b) >= threshold;

/// Groups [documents] into near-duplicate clusters (greedy).
List<List<int>> clusterNearDuplicates(List<String> documents, {double threshold = 0.85}) {
  final List<List<int>> clusters = [];
  final List<bool> used = List.filled(documents.length, false);
  for (int i = 0; i < documents.length; i++) {
    if (used[i]) continue;
    final List<int> cluster = [i];
    used[i] = true;
    for (int j = i + 1; j < documents.length; j++) {
      if (used[j]) continue;
      if (textSimilarity(documents[i], documents[j]) >= threshold) {
        cluster.add(j);
        used[j] = true;
      }
    }
    clusters.add(cluster);
  }
  return clusters;
}
