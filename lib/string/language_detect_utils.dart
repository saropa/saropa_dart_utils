/// Heuristic n-gram language detector (lite, best-effort) — roadmap #428.
library;

/// Minimum trigram count below which detection is unreliable and returns null.
const int _kMinTrigrams = 3;

/// Penalty rank for a trigram absent from a profile (out-of-place distance).
const int _kMaxRank = 300;

/// Built-in ranked trigram profiles for a handful of common languages.
///
/// Each list holds the most frequent trigrams (most frequent first). Profiles
/// are deliberately compact: a dozen-plus top trigrams per language is enough
/// for a coarse "lite" detector while keeping this file small and data-free.
const Map<String, List<String>> _kProfiles = <String, List<String>>{
  'en': <String>[
    'the', 'and', ' th', 'he ', 'ing', ' an', 'nd ', 'ion', 'tio', 'ent',
    ' to', 'ed ', ' in', 'er ', 'is ', 'ng ', 'th ', 'at ', ' of', 'of ',
  ],
  'es': <String>[
    ' de', 'de ', ' la', 'os ', 'que', 'la ', 'el ', 'as ', 'es ', 'ado',
    'cio', 'ent', ' co', ' es', 'ion', 'aci', 'con', ' a l', 'nte', 'one',
  ],
  'fr': <String>[
    ' de', 'de ', 'ent', ' le', 'es ', 'le ', 'ion', ' la', 'la ', 'tio',
    'on ', ' co', 'que', 'men', 'ans', 'res', ' et', 'eme', 'ait', ' pr',
  ],
  'de': <String>[
    'en ', 'er ', 'ich', 'der', 'die', ' de', 'sch', 'ein', 'che', 'nd ',
    'und', 'gen', 'ung', 'ten', 'cht', ' di', 'den', ' un', ' ge', 'ber',
  ],
  'it': <String>[
    ' di', 'di ', 'che', 'ent', 'la ', 'to ', 'are', ' co', 'on ', 'ato',
    'ion', 'lla', 'ell', 'zio', ' la', 'er ', 'one', ' pe', 'per', 'del',
  ],
  'pt': <String>[
    ' de', 'de ', ' co', 'os ', 'que', 'ent', 'ado', 'as ', 'ção', 'do ',
    'es ', 'ção ', ' qu', 'com', 'par', 'ara', 'nte', 'a d', 'da ', 'men',
  ],
};

/// Result of a language detection: the [language] code and a [score].
///
/// The score is a normalized distance in `[0, 1]` where lower is a closer
/// match; `confidence` is its complement so a bigger number means more sure.
/// Kept as an immutable value object so results are safe to cache and compare.
///
/// Example:
/// ```dart
/// const r = LanguageGuess('en', 0.2);
/// print(r.confidence); // 0.8
/// ```
class LanguageGuess {
  /// Creates an immutable guess from a [language] code and distance [score].
  const LanguageGuess(this.language, this.score);

  /// ISO-639-1 style code of the best-matching profile (e.g. `'en'`).
  final String language;

  /// Normalized out-of-place distance in `[0, 1]`; lower means a closer match.
  final double score;

  /// Convenience inverse of [score]: higher means a more confident guess.
  double get confidence => 1 - score;

  @override
  String toString() => 'LanguageGuess($language, $score)';

  @override
  bool operator ==(Object other) =>
      other is LanguageGuess && other.language == language && other.score == score;

  @override
  int get hashCode => Object.hash(language, score);
}

/// Extracts ranked trigrams from [text], most frequent first.
///
/// Lowercases and collapses runs of whitespace so casing and spacing do not
/// fragment the profile; spaces are kept as trigram characters because word
/// boundaries carry strong language signal (e.g. `'the'` vs `' th'`).
///
/// Example:
/// ```dart
/// languageTrigrams('the the'); // ['the', 'he ', 'e t', ...]
/// ```
List<String> languageTrigrams(String text) {
  final String clean = text.toLowerCase().replaceAll(RegExp(r'\s+'), ' ').trim();
  if (clean.length < _kMinTrigrams) return <String>[];
  // Count every length-3 window, then rank by descending frequency so the most
  // characteristic trigrams dominate the out-of-place comparison.
  final Map<String, int> counts = <String, int>{};
  for (int i = 0; i + 3 <= clean.length; i++) {
    final String gram = clean.substring(i, i + 3);
    counts[gram] = (counts[gram] ?? 0) + 1;
  }
  // Read counts with ?? 0 so the sort never uses a bare ! on the map lookup;
  // every key came from the same map, so 0 is an unreachable but safe fallback.
  return counts.keys.toList()
    ..sort((a, b) => (counts[b] ?? 0).compareTo(counts[a] ?? 0));
}

/// Detects the dominant language of [text]; returns null when too short.
///
/// Heuristic, best-effort only: it compares the input's ranked trigrams against
/// tiny built-in profiles using an out-of-place rank distance, so short or mixed
/// text and unsupported languages can mis-detect. Returns null when fewer than
/// [_kMinTrigrams] trigrams exist, since there is too little signal to decide.
///
/// Example:
/// ```dart
/// detectLanguage('the quick brown fox and the lazy dog')?.language; // 'en'
/// ```
LanguageGuess? detectLanguage(String text) {
  final List<String> grams = languageTrigrams(text);
  if (grams.length < _kMinTrigrams) return null;
  // Score every profile and keep the smallest normalized distance. Using
  // firstOrNull-style folding avoids any bare .first on a possibly-empty list.
  LanguageGuess? best;
  for (final MapEntry<String, List<String>> entry in _kProfiles.entries) {
    final double score = _profileDistance(grams, entry.value);
    if (best == null || score < best.score) {
      best = LanguageGuess(entry.key, score);
    }
  }
  return best;
}

/// Normalized out-of-place distance between input [grams] and a [profile].
double _profileDistance(List<String> grams, List<String> profile) {
  // For each input trigram, add the absolute rank gap to its profile position;
  // missing trigrams cost _kMaxRank. Dividing by the worst case keeps it in
  // [0, 1] so scores are comparable across inputs of different lengths.
  int total = 0;
  for (int i = 0; i < grams.length; i++) {
    final int profileRank = profile.indexOf(grams[i]);
    total += profileRank < 0 ? _kMaxRank : (i - profileRank).abs();
  }
  return total / (grams.length * _kMaxRank);
}
