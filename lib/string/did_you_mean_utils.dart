/// "Did you mean?" over dictionary (Levenshtein) — roadmap #426.
library;

import 'levenshtein_utils.dart';

/// Returns up to [limit] words from [dictionary] closest to [word] by edit distance.
List<String> didYouMean(String word, List<String> dictionary, {int limit = 5}) {
  if (word.isEmpty || dictionary.isEmpty) return [];
  final List<(String, int)> scored = dictionary
      .map((String w) => (w, LevenshteinUtils.distance(word, w)))
      .toList();
  scored.sort((a, b) => a.$2.compareTo(b.$2));
  return scored.take(limit).map((e) => e.$1).toList();
}
