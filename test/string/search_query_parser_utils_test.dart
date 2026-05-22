import 'package:flutter_test/flutter_test.dart';
import 'package:saropa_dart_utils/string/search_query_parser_utils.dart';

/// Reduce a term to a comparable tuple for exact assertions.
(String, bool) _t(QueryTerm q) => (q.text, q.isNegated);

void main() {
  // cspell: disable
  group('QueryTerm', () {
    test('should default isNegated to false', () {
      const QueryTerm term = QueryTerm('cat');
      expect(term.text, 'cat');
      expect(term.isNegated, isFalse);
    });

    test('should store an explicit isNegated flag', () {
      const QueryTerm term = QueryTerm('dog', isNegated: true);
      expect(term.isNegated, isTrue);
    });

    test('toString should render text and flag', () {
      expect(
        const QueryTerm('cat', isNegated: true).toString(),
        'QueryTerm(text: cat, isNegated: true)',
      );
    });
  });

  group('SearchQueryParserUtils.parseSearchQuery', () {
    test('should split bare words as AND terms', () {
      expect(
        SearchQueryParserUtils.parseSearchQuery('cat dog').map(_t).toList(),
        <(String, bool)>[('cat', false), ('dog', false)],
      );
    });

    test('should keep a quoted phrase as one term', () {
      expect(
        SearchQueryParserUtils.parseSearchQuery('"hello world" foo').map(_t).toList(),
        <(String, bool)>[('hello world', false), ('foo', false)],
      );
    });

    test('should drop the OR keyword as a no-op separator', () {
      expect(
        SearchQueryParserUtils.parseSearchQuery('a OR b').map(_t).toList(),
        <(String, bool)>[('a', false), ('b', false)],
      );
    });

    test('should mark a leading-minus word as negated and strip the minus', () {
      expect(
        SearchQueryParserUtils.parseSearchQuery('-spam').map(_t).toList(),
        <(String, bool)>[('spam', true)],
      );
    });

    test('should combine words, phrases, and negation', () {
      expect(
        SearchQueryParserUtils.parseSearchQuery('cat "big dog" -bird').map(_t).toList(),
        <(String, bool)>[('cat', false), ('big dog', false), ('bird', true)],
      );
    });

    test('should return empty list for empty query', () {
      expect(SearchQueryParserUtils.parseSearchQuery(''), isEmpty);
    });

    test('should return empty list for whitespace-only query', () {
      expect(SearchQueryParserUtils.parseSearchQuery('   '), isEmpty);
    });

    test('should collapse multiple spaces between words', () {
      expect(
        SearchQueryParserUtils.parseSearchQuery('cat    dog').map(_t).toList(),
        <(String, bool)>[('cat', false), ('dog', false)],
      );
    });

    test(
      'should strip the minus on a negated word appearing before a quoted phrase',
      () {
        // A negated word before a quoted phrase strips its leading "-" in text,
        // consistent with the trailing-words branch; negation is captured in the
        // isNegated flag.
        expect(
          SearchQueryParserUtils.parseSearchQuery('-bad "phrase"').map(_t).toList(),
          <(String, bool)>[('bad', true), ('phrase', false)],
        );
      },
    );
  });
}
