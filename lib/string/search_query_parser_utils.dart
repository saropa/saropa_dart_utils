/// Simplified search query parser (AND/OR, quotes, minus) — roadmap #418.
library;

import 'string_extensions.dart';

/// Simple parser: "a b" = AND, "a OR b", quoted = phrase, -x = exclude.
abstract final class SearchQueryParserUtils {
  SearchQueryParserUtils._();

  /// Parses [query] into a list of [QueryTerm] (words/phrases, AND/OR, minus).
  /// Audited: 2026-06-12 11:26 EDT
  static List<QueryTerm> parseSearchQuery(String query) {
    final String q = query.trim();
    final RegExp quoted = RegExp(r'"([^"]*)"');
    final RegExp ws = RegExp(r'\s+');
    int pos = 0;
    // Upper bound on term count: every character could in theory start a new
    // single-char term, so length+1 slots can never overflow. Pre-filling avoids
    // per-add growth and the trailing slots are dropped by the final sublist.
    final int maxTerms = query.length + 1;
    final List<QueryTerm> out = List.filled(maxTerms, QueryTerm(''));
    int outIndex = 0;
    // Walk the quoted phrases in order; the gap before each match (pos..m.start)
    // is bare text that gets word-split, and the captured group is one phrase term.
    for (final Match m in quoted.allMatches(q)) {
      if (m.start > pos) {
        final int end = m.start.clamp(0, q.length);
        final int start = pos.clamp(0, end);
        final String span = start < end ? q.substringSafe(start, end) : '';
        for (final String word in span.split(ws).where((String x) => x.isNotEmpty)) {
          // "OR" is dropped, not emitted as a term: this parser treats every gap
          // between terms as AND, so the explicit OR keyword is a no-op separator.
          if (word.toUpperCase() != 'OR') {
            // Strip the leading '-' from the stored text (consistent with the
            // trailing-words branch below); the negation is captured separately.
            final bool negated = word.startsWith('-');
            final String term = negated ? word.replaceRange(0, 1, '') : word;
            // Skip a bare '-' (term empty after stripping): it is punctuation,
            // not a real negated term, and would otherwise emit QueryTerm('').
            if (term.isNotEmpty) out[outIndex++] = QueryTerm(term, isNegated: negated);
          }
        }
      }
      final String phrase = m.group(1) ?? '';
      if (phrase.isNotEmpty) {
        out[outIndex++] = QueryTerm(phrase);
      }
      pos = m.end;
    }
    final int restStart = pos.clamp(0, q.length);
    final String rest = restStart < q.length ? q.substringSafe(restStart) : '';
    for (final String word in rest.split(ws).where((String x) => x.isNotEmpty)) {
      if (word.toUpperCase() != 'OR') {
        final bool negated = word.startsWith('-');
        final String term = negated ? word.replaceRange(0, 1, '') : word;
        if (term.isNotEmpty) out[outIndex++] = QueryTerm(term, isNegated: negated);
      }
    }
    return out.sublist(0, outIndex);
  }
}

/// Parsed query term: phrase or word, optional negated.
class QueryTerm {
  /// Creates a query term for [text]; set [isNegated] for excluded ("-word") terms.
  /// Audited: 2026-06-12 11:26 EDT
  const QueryTerm(this.text, {this.isNegated = false});

  /// The word or quoted phrase to match (without the leading "-" if negated).
  final String text;

  /// True when this term must be excluded from results (entered as "-term").
  final bool isNegated;

  @override
  String toString() => 'QueryTerm(text: $text, isNegated: $isNegated)';
}
