/// Fuzzy search over list of strings with token + edit distance + ranking (roadmap #406).
library;

import 'levenshtein_utils.dart';

/// One candidate from fuzzy search with score and matched text.
class FuzzySearchUtils {
  /// Creates a match at [index] in the original candidate list, holding the
  /// matched [text] and its computed relevance [score].
  const FuzzySearchUtils(int index, String text, double score)
    : _index = index,
      _text = text,
      _score = score;
  final int _index;

  /// Position of this match within the original `candidates` list.
  int get index => _index;
  final String _text;

  /// The candidate string that matched the query.
  String get text => _text;
  final double _score;

  /// Relevance score in `[0, 1]`; higher means a closer match to the query.
  double get score => _score;

  @override
  String toString() => 'FuzzySearchUtils(index: $_index, text: $_text, score: $_score)';
}

/// Searches [candidates] for [query]; returns matches sorted by match score descending.
///
/// Score combines token overlap and edit-distance ratio. [maxDistance] caps
/// per-token edit distance; [minScore] excludes results below that threshold.
List<FuzzySearchUtils> fuzzySearch(
  String query,
  List<String> candidates, {
  int maxDistance = 2,
  double minScore = 0.0,
}) {
  final String q = query.trim().toLowerCase();
  if (q.isEmpty) {
    return candidates.asMap().entries.map((e) => FuzzySearchUtils(e.key, e.value, 1.0)).toList();
  }
  final List<String> qTokens = q.split(RegExp(r'\s+'));
  final List<FuzzySearchUtils> out = <FuzzySearchUtils>[];
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
    if (norm >= minScore) out.add(FuzzySearchUtils(i, c, norm));
  }
  out.sort((FuzzySearchUtils a, FuzzySearchUtils b) => b.score.compareTo(a.score));
  return out;
}

/// Splits [s] into lowercased whitespace-separated tokens, dropping empties.
List<String> _fuzzyTokens(String s) =>
    s.toLowerCase().split(RegExp(r'\s+')).where((String t) => t.isNotEmpty).toList();

/// fuzzywuzzy-style **partial ratio**: how well the shorter string matches the
/// best-aligning slice of the longer one, in `[0, 1]`.
///
/// Slides a window the length of the shorter string across the longer string
/// and returns the best [LevenshteinUtils.ratio] of any window. This scores a
/// substring match high even when the surrounding text differs — e.g.
/// `'New York'` against `'New York City'` — where the plain whole-string ratio
/// would be penalized for the extra words. Comparison is case-insensitive.
///
/// Two empty strings score `1.0`; one empty against a non-empty scores `0.0`.
double partialRatio(String a, String b) {
  final String shorter = (a.length <= b.length ? a : b).toLowerCase();
  final String longer = (a.length <= b.length ? b : a).toLowerCase();

  if (shorter.isEmpty) {
    return longer.isEmpty ? 1.0 : 0.0;
  }

  double best = 0.0;
  // Each window is the shorter string's length; the best-aligned slice wins.
  for (int start = 0; start + shorter.length <= longer.length; start++) {
    final double r = LevenshteinUtils.ratio(
      shorter,
      longer.substring(start, start + shorter.length),
    );
    if (r > best) {
      best = r;
    }
  }

  return best;
}

/// fuzzywuzzy-style **token-sort ratio**: ratio after each string's tokens are
/// lowercased, sorted, and rejoined, in `[0, 1]`.
///
/// Makes the comparison order-insensitive, so `'York New'` matches `'New York'`
/// fully — the right metric when word order varies but content does not (names
/// entered "First Last" vs "Last First").
double tokenSortRatio(String a, String b) {
  final List<String> ta = _fuzzyTokens(a)..sort();
  final List<String> tb = _fuzzyTokens(b)..sort();

  return LevenshteinUtils.ratio(ta.join(' '), tb.join(' '));
}

/// fuzzywuzzy-style **token-set ratio**: the best ratio over the shared tokens
/// and each side's remainder, in `[0, 1]`.
///
/// Splits both strings into token sets, then compares the sorted intersection
/// against the intersection-plus-each-remainder. A string that is a superset of
/// the other's tokens (`'apple pie'` vs `'apple pie with cinnamon'`) scores
/// high because the shared core aligns exactly. More forgiving of extra words
/// than [tokenSortRatio]. Comparison is case-insensitive.
double tokenSetRatio(String a, String b) {
  final Set<String> sa = _fuzzyTokens(a).toSet();
  final Set<String> sb = _fuzzyTokens(b).toSet();

  final List<String> intersection = sa.intersection(sb).toList()..sort();
  final List<String> diffAb = sa.difference(sb).toList()..sort();
  final List<String> diffBa = sb.difference(sa).toList()..sort();

  // The shared core, and the core extended by each side's leftovers.
  final String core = intersection.join(' ');
  final String combinedA = <String>[...intersection, ...diffAb].join(' ').trim();
  final String combinedB = <String>[...intersection, ...diffBa].join(' ').trim();

  // The best of the three pairings is the token-set score. fold (not reduce)
  // with a 0.0 seed — ratios are always >= 0, so the seed never wins spuriously
  // and there is no empty-collection crash risk.
  final double r1 = LevenshteinUtils.ratio(core, combinedA);
  final double r2 = LevenshteinUtils.ratio(core, combinedB);
  final double r3 = LevenshteinUtils.ratio(combinedA, combinedB);

  return <double>[r1, r2, r3].fold<double>(0.0, (double m, double v) => v > m ? v : m);
}
