import 'package:flutter_test/flutter_test.dart';
import 'package:saropa_dart_utils/collections/inverted_index_utils.dart';

void main() {
  group('buildInvertedIndex', () {
    test('should map terms to document indices', () {
      final Map<String, List<int>> index = buildInvertedIndex([
        'the quick brown fox',
        'the lazy dog',
      ]);
      expect(index['the'], [0, 1]);
      expect(index['quick'], [0]);
      expect(index['dog'], [1]);
    });

    test('should lowercase terms', () {
      final Map<String, List<int>> index = buildInvertedIndex(['Hello WORLD']);
      expect(index['hello'], [0]);
      expect(index['world'], [0]);
      expect(index.containsKey('Hello'), isFalse);
    });

    test('should deduplicate repeated terms within a document', () {
      // 'cat' appears twice in doc 0 but is indexed once per document.
      final Map<String, List<int>> index = buildInvertedIndex(['cat cat cat']);
      expect(index['cat'], [0]);
    });

    test('should split on non-alphanumeric characters', () {
      final Map<String, List<int>> index = buildInvertedIndex(['a-b_c,d']);
      expect(index.keys.toSet(), {'a', 'b', 'c', 'd'});
    });

    test('should keep digits as terms', () {
      final Map<String, List<int>> index = buildInvertedIndex(['item 42']);
      expect(index['42'], [0]);
    });

    test('should return empty map for empty input', () {
      expect(buildInvertedIndex(<String>[]), <String, List<int>>{});
    });

    test('should produce empty map for documents with no word characters', () {
      expect(buildInvertedIndex(['!!! ...']), <String, List<int>>{});
    });

    test('should list multiple documents for a shared term', () {
      final Map<String, List<int>> index = buildInvertedIndex(['apple', 'apple pie', 'apple jam']);
      expect(index['apple'], [0, 1, 2]);
    });
  });
}
