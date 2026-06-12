/// TF-IDF keyphrase extraction over a small corpus — roadmap #432.
library;

import 'dart:math' as math;

/// Small built-in English stopword set, removed before scoring so common
/// function words never surface as keyphrases. Kept deliberately short — a
/// large list belongs in caller-supplied config, not a tree-shaken util.
const Set<String> _kStopwords = <String>{
  'a',
  'an',
  'and',
  'are',
  'as',
  'at',
  'be',
  'but',
  'by',
  'for',
  'from',
  'has',
  'have',
  'he',
  'her',
  'his',
  'i',
  'in',
  'is',
  'it',
  'its',
  'of',
  'on',
  'or',
  'she',
  'so',
  'than',
  'that',
  'the',
  'their',
  'them',
  'then',
  'they',
  'this',
  'to',
  'was',
  'were',
  'will',
  'with',
  'you',
  'your',
};

/// A scored keyphrase: the [phrase] text and its tf*idf [score].
typedef Keyphrase = ({String phrase, double score});

/// Options controlling keyphrase extraction; grouped to keep the public API
/// under the 3-parameter limit and allow future knobs without breaking callers.
class KeyphraseOptions {
  /// Creates extraction options.
  ///
  /// [topK] caps the result size; [includeBigrams] also scores adjacent word
  /// pairs (after stopword filtering) so multi-word phrases can rank.
  /// Audited: 2026-06-12 11:26 EDT
  const KeyphraseOptions({this.topK = 5, this.includeBigrams = false});

  /// Maximum number of keyphrases returned.
  final int topK;

  /// When true, adjacent term pairs are scored alongside single terms.
  final bool includeBigrams;
}

/// Splits [text] into lowercase alphanumeric tokens, dropping stopwords.
///
/// Punctuation and casing are normalized away so 'Cats, cats!' yields a single
/// repeated term. One-character tokens are dropped as noise.
///
/// Example:
/// ```dart
/// tokenizeKeyphrases('The quick Brown fox'); // ['quick', 'brown', 'fox']
/// ```
/// Audited: 2026-06-12 11:26 EDT
List<String> tokenizeKeyphrases(String text) => text
    .toLowerCase()
    .split(RegExp(r'[^a-z0-9]+'))
    .where((String t) => t.length > 1 && !_kStopwords.contains(t))
    .toList();

/// Counts how many times each token appears in [tokens] (term frequency).
///
/// Returns an empty map for empty input; counts are raw, not normalized, so
/// callers can divide by total length if they need relative frequency.
///
/// Example:
/// ```dart
/// termFrequencies(['cat', 'cat', 'dog']); // {'cat': 2, 'dog': 1}
/// ```
/// Audited: 2026-06-12 11:26 EDT
Map<String, int> termFrequencies(List<String> tokens) {
  final Map<String, int> tf = <String, int>{};
  for (final String t in tokens) {
    tf[t] = (tf[t] ?? 0) + 1;
  }
  return tf;
}

/// Computes inverse document frequency for every term across [corpus].
///
/// Uses smoothed idf `ln(1 + N / df)` so a single-document corpus never divides
/// by zero and every term keeps a positive weight; rarer terms score higher.
///
/// Example:
/// ```dart
/// computeIdf([['cat', 'dog'], ['cat']])['cat']; // ln(1 + 2/2) = ln 2
/// ```
/// Audited: 2026-06-12 11:26 EDT
Map<String, double> computeIdf(List<List<String>> corpus) {
  // Document frequency: number of docs containing each term at least once.
  final Map<String, int> df = <String, int>{};
  for (final List<String> doc in corpus) {
    for (final String term in doc.toSet()) {
      df[term] = (df[term] ?? 0) + 1;
    }
  }
  final int n = corpus.length;
  return df.map(
    (String term, int count) => MapEntry<String, double>(term, math.log(1 + n / count)),
  );
}

/// Extracts the top-K tf*idf keyphrases from [doc] against [corpus].
///
/// [corpus] supplies idf weights; pass `[doc]` alone for single-document mode
/// (idf stays positive via smoothing). Ties break by descending score then
/// ascending phrase, giving a stable, deterministic order. Returns empty for an
/// empty document.
///
/// Example:
/// ```dart
/// extractKeyphrases('cat cat dog', <List<String>>[]); // [(phrase: 'cat', ...)]
/// ```
/// Audited: 2026-06-12 11:26 EDT
List<Keyphrase> extractKeyphrases(
  String doc,
  List<List<String>> corpus, [
  KeyphraseOptions options = const KeyphraseOptions(),
]) {
  final List<String> tokens = tokenizeKeyphrases(doc);
  if (tokens.isEmpty) return <Keyphrase>[];
  // The target doc must influence its own idf; without it, a corpus that never
  // saw these terms would leave them all with the same df and flatten scores.
  final List<List<String>> effective = <List<String>>[...corpus, tokens];
  final Map<String, double> idf = computeIdf(effective);
  final Map<String, double> scores = _scoreTerms(tokens, idf, options);
  return _rankTopK(scores, options.topK);
}

/// Builds tf*idf scores for unigrams (and bigrams when enabled).
/// Audited: 2026-06-12 11:26 EDT
Map<String, double> _scoreTerms(
  List<String> tokens,
  Map<String, double> idf,
  KeyphraseOptions options,
) {
  final Map<String, double> scores = <String, double>{};
  termFrequencies(tokens).forEach((String term, int tf) {
    scores[term] = tf * (idf[term] ?? 0);
  });
  if (options.includeBigrams) {
    _addBigramScores(tokens, idf, scores);
  }
  return scores;
}

/// Scores adjacent token pairs using the product of their unigram idf weights,
/// so a phrase of two rare words outranks either word alone.
/// Audited: 2026-06-12 11:26 EDT
void _addBigramScores(
  List<String> tokens,
  Map<String, double> idf,
  Map<String, double> scores,
) {
  // Accumulate count and the product of the pair's idf weights together, so we
  // never re-split the phrase string (which the linter can't prove non-empty).
  final Map<String, ({int count, double weight})> bf = <String, ({int count, double weight})>{};
  for (int i = 0; i + 1 < tokens.length; i++) {
    final String bigram = '${tokens[i]} ${tokens[i + 1]}';
    final double weight = (idf[tokens[i]] ?? 0) * (idf[tokens[i + 1]] ?? 0);
    final int prior = bf[bigram]?.count ?? 0;
    bf[bigram] = (count: prior + 1, weight: weight);
  }
  bf.forEach((String bigram, ({int count, double weight}) v) {
    scores[bigram] = v.count * v.weight;
  });
}

/// Sorts scored phrases and returns the highest [topK].
/// Audited: 2026-06-12 11:26 EDT
List<Keyphrase> _rankTopK(Map<String, double> scores, int topK) {
  final List<Keyphrase> ranked = scores.entries
      .map((MapEntry<String, double> e) => (phrase: e.key, score: e.value))
      .toList();
  // Stable tie-break: higher score first, then alphabetical phrase, so equal
  // scores never depend on the underlying map's iteration order.
  ranked.sort((Keyphrase a, Keyphrase b) {
    final int byScore = b.score.compareTo(a.score);
    return byScore != 0 ? byScore : a.phrase.compareTo(b.phrase);
  });
  return ranked.take(math.max(0, topK)).toList();
}
