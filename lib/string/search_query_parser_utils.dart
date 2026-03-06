/// Simplified search query parser (AND/OR, quotes, minus) — roadmap #418.
library;

import 'string_extensions.dart';

/// Parsed query term: phrase or word, optional negated.
class QueryTerm {
  const QueryTerm(this.text, {this.isNegated = false});
  final String text;
  final bool isNegated;

  @override
  String toString() => 'QueryTerm(text: $text, isNegated: $isNegated)';
}

/// Simple parser: "a b" = AND, "a OR b", quoted = phrase, -x = exclude.
abstract final class SearchQueryParserUtils {
  SearchQueryParserUtils._();

  /// Parses [query] into a list of [QueryTerm] (words/phrases, AND/OR, minus).
  static List<QueryTerm> parseSearchQuery(String query) {
    final String q = query.trim();
    final RegExp quoted = RegExp(r'"([^"]*)"');
    final RegExp ws = RegExp(r'\s+');
    int pos = 0;
    final int maxTerms = query.length + 1;
    final List<QueryTerm> out = List.filled(maxTerms, QueryTerm(''));
    int outIndex = 0;
    for (final Match m in quoted.allMatches(q)) {
      if (m.start > pos) {
        final int end = m.start.clamp(0, q.length);
        final int start = pos.clamp(0, end);
        final String span = start < end ? q.substringSafe(start, end) : '';
        for (final String word in span.split(ws).where((String x) => x.isNotEmpty)) {
          if (word.toUpperCase() != 'OR') {
            out[outIndex++] = QueryTerm(word, isNegated: word.startsWith('-'));
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
        final String term = word.startsWith('-') ? word.replaceRange(0, 1, '') : word;
        out[outIndex++] = QueryTerm(term, isNegated: word.startsWith('-'));
      }
    }
    return out.sublist(0, outIndex);
  }
}
