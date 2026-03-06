/// Fuzzy search over list of strings with token + edit distance + ranking (roadmap #406).
library;

import 'levenshtein_utils.dart';

/// One candidate from fuzzy search with score and matched text.
class FuzzyMatch {
  const FuzzyMatch(int index, String text, double score)
    : _index = index,
      _text = text,
      _score = score;
  final int _index;

  int get index => _index;
  final String _text;

  String get text => _text;
  final double _score;

  double get score => _score;

  @override
  String toString() => 'FuzzyMatch(index: $_index, text: $_text, score: $_score)';
}

/// Searches [candidates] for [query]; returns matches sorted by match score descending.
///
/// Score combines token overlap and edit-distance ratio. [maxDistance] caps
/// per-token edit distance; [minScore] excludes results below that threshold.
List<FuzzyMatch> fuzzySearch(
  String query,
  List<String> candidates, {
  int maxDistance = 2,
  double minScore = 0.0,
}) {
  final String q = query.trim().toLowerCase();
  if (q.isEmpty)
    return candidates.asMap().entries.map((e) => FuzzyMatch(e.key, e.value, 1.0)).toList();
  final List<String> qTokens = q.split(RegExp(r'\s+'));
  final List<FuzzyMatch> out = <FuzzyMatch>[];
  for (int i = 0; i < candidates.length; i++) {
    final String c = candidates[i];
    final String cLower = c.toLowerCase();
    final List<String> cTokens = cLower.split(RegExp(r'\s+'));
    double score = 0.0;
    for (final String qt in qTokens) {
      double best = 0.0;
      for (final String ct in cTokens) {
        final int d = LevenshteinUtils.distance(qt, ct);
        if (d <= maxDistance) {
          final double r = LevenshteinUtils.ratio(qt, ct);
          if (r > best) best = r;
        }
      }
      score += best;
    }
    final double norm = score / qTokens.length;
    if (norm >= minScore) out.add(FuzzyMatch(i, c, norm));
  }
  out.sort((FuzzyMatch a, FuzzyMatch b) => b.score.compareTo(a.score));
  return out;
}
