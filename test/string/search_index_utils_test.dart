import 'package:flutter_test/flutter_test.dart';
import 'package:saropa_dart_utils/string/search_index_utils.dart';

void main() {
  // cspell: disable
  group('SearchIndexUtils', () {
    test('length should start at zero', () {
      expect(SearchIndexUtils(), hasLength(0));
    });

    test('addDocument should increase length and store text', () {
      final SearchIndexUtils index = SearchIndexUtils()
        ..addDocument('first doc')
        ..addDocument('second doc');
      expect(index, hasLength(2));
      expect(index.getDocument(0), 'first doc');
      expect(index.getDocument(1), 'second doc');
    });

    test('search should return the most relevant document first', () {
      final SearchIndexUtils index = SearchIndexUtils()
        ..addDocument('the cat sat on the mat')
        ..addDocument('rockets fly to the moon');
      final List<(int, double)> hits = index.search('cat mat');
      expect(hits.first.$1, 0);
      expect(hits.first.$2, greaterThan(0));
    });

    test('search should exclude documents with zero similarity', () {
      final SearchIndexUtils index = SearchIndexUtils()
        ..addDocument('apples and oranges')
        ..addDocument('quantum mechanics');
      final List<(int, double)> hits = index.search('apples');
      expect(hits, hasLength(1));
      expect(hits.single.$1, 0);
    });

    test('search should sort results by descending score', () {
      final SearchIndexUtils index = SearchIndexUtils()
        ..addDocument('alpha beta gamma')
        ..addDocument('alpha only');
      final List<(int, double)> hits = index.search('alpha beta gamma');
      for (int i = 1; i < hits.length; i++) {
        expect(hits[i - 1].$2 >= hits[i].$2, isTrue);
      }
      expect(hits.first.$1, 0);
    });

    test('search should respect the limit parameter', () {
      final SearchIndexUtils index = SearchIndexUtils()
        ..addDocument('apple pie')
        ..addDocument('apple tart')
        ..addDocument('apple cake');
      expect(index.search('apple', limit: 2), hasLength(2));
    });

    test('search should return empty list when index is empty', () {
      expect(SearchIndexUtils().search('anything'), isEmpty);
    });

    test('toString should report the document count', () {
      final SearchIndexUtils index = SearchIndexUtils()..addDocument('x');
      expect(index.toString(), 'SearchIndexUtils(length: 1)');
    });
  });
}
