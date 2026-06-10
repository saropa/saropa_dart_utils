/// "Did you mean?" over dictionary (Levenshtein) — roadmap #426.
library;

import 'levenshtein_utils.dart';

/// Returns up to [limit] words from [dictionary] closest to [word] by edit distance.
List<String> didYouMean(String word, List<String> dictionary, {int limit = 5}) {
  // Nothing to match against (no query or no dictionary) yields no suggestions.
  if (word.isEmpty || dictionary.isEmpty) return <String>[];
  // Score every candidate by edit distance, then sort ascending so the closest
  // words come first. A full scan plus sort is acceptable for the modest in-app
  // dictionaries this targets; ties keep their dictionary order (stable sort).
  final List<(String, int)> scored = dictionary
      .map((String w) => (w, LevenshteinUtils.distance(word, w)))
      .toList();
  scored.sort((a, b) => a.$2.compareTo(b.$2));
  return scored.take(limit).map((e) => e.$1).toList();
}
