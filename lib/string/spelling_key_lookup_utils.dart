/// Spelling-tolerant key lookup (canonical → variants) — roadmap #416.
library;

import 'levenshtein_utils.dart';

/// Lookup that returns canonical key if [query] matches any variant within [maxDistance].
/// Audited: 2026-06-12 11:26 EDT
String? lookupWithVariants(
  String query,
  Map<String, List<String>> canonicalToVariants, {
  int maxDistance = 2,
}) {
  final String queryLower = query.trim().toLowerCase();
  // Resolve a (possibly misspelled) query to its canonical key. For each entry,
  // try cheapest matches first: exact canonical, exact variant, then a fuzzy
  // (edit-distance) variant match within maxDistance. First hit wins, so entry
  // order decides ties between equally-close candidates.
  for (final MapEntry<String, List<String>> entry in canonicalToVariants.entries) {
    if (entry.key.toLowerCase() == queryLower) return entry.key;
    for (final String variant in entry.value) {
      if (variant.toLowerCase() == queryLower) return entry.key;
      if (LevenshteinUtils.distance(variant.toLowerCase(), queryLower) <= maxDistance) {
        return entry.key;
      }
    }
  }
  return null;
}
