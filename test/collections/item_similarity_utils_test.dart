import 'package:flutter_test/flutter_test.dart';
import 'package:saropa_dart_utils/collections/item_similarity_utils.dart';

void main() {
  group('ItemSimilarityModel', () {
    // Three baskets: bread is everywhere, butter and jam each in two.
    final ItemSimilarityModel<String> model = ItemSimilarityModel<String>.fromBaskets(<Set<String>>[
      <String>{'bread', 'butter', 'jam'},
      <String>{'bread', 'butter'},
      <String>{'bread', 'jam'},
    ]);

    test('should expose all distinct items', () {
      expect(model.items, equals(<String>{'bread', 'butter', 'jam'}));
    });

    test('should compute Jaccard similarity over basket sets', () {
      // bread in {0,1,2}, butter in {0,1}: intersection 2, union 3.
      expect(model.similarity('bread', 'butter'), closeTo(2 / 3, 1e-9));
      // butter in {0,1}, jam in {0,2}: intersection 1, union 3.
      expect(model.similarity('butter', 'jam'), closeTo(1 / 3, 1e-9));
    });

    test('should be symmetric', () {
      expect(
        model.similarity('bread', 'jam'),
        equals(model.similarity('jam', 'bread')),
      );
    });

    test('should keep every similarity within [0, 1]', () {
      for (final String a in model.items) {
        for (final String b in model.items) {
          final double s = model.similarity(a, b);
          expect(s, greaterThanOrEqualTo(0));
          expect(s, lessThanOrEqualTo(1));
        }
      }
    });

    test('should give 1.0 for an item compared with itself', () {
      expect(model.similarity('bread', 'bread'), equals(1.0));
    });

    test('should give 1.0 for items with identical co-occurrence', () {
      // x and y always appear together, so their basket sets are identical.
      final ItemSimilarityModel<String> twins = ItemSimilarityModel<String>.fromBaskets(
        <Set<String>>[
          <String>{'x', 'y'},
          <String>{'x', 'y', 'z'},
        ],
      );

      expect(twins.similarity('x', 'y'), equals(1.0));
    });

    test('should return 0 for items that never co-occur', () {
      // a only in basket 0, b only in basket 1: no shared basket.
      final ItemSimilarityModel<String> disjoint = ItemSimilarityModel<String>.fromBaskets(
        <Set<String>>[
          <String>{'a'},
          <String>{'b'},
        ],
      );

      expect(disjoint.similarity('a', 'b'), equals(0));
    });

    test('should return 0 similarity for an unknown item', () {
      expect(model.similarity('bread', 'ghost'), equals(0));
      expect(model.similarity('ghost', 'phantom'), equals(0));
    });

    group('recommend', () {
      test('should rank neighbors by descending similarity', () {
        // From butter: bread (2/3) should outrank jam (1/3).
        final List<({String item, double score})> recs = model.recommend(
          'butter',
        );

        expect(
          recs.map((({String item, double score}) r) => r.item).toList(),
          equals(<String>['bread', 'jam']),
        );
        expect(recs.first.score, greaterThan(recs.last.score));
      });

      test('should exclude the query item itself', () {
        final List<({String item, double score})> recs = model.recommend(
          'bread',
        );

        expect(
          recs.every((({String item, double score}) r) => r.item != 'bread'),
          isTrue,
        );
      });

      test('should cap results at topN', () {
        final List<({String item, double score})> recs = model.recommend(
          'bread',
          topN: 1,
        );

        expect(recs, hasLength(1));
      });

      test('should exclude zero-score (non co-occurring) candidates', () {
        // c shares no basket with a, so a's recommendations omit it.
        final ItemSimilarityModel<String> sparse = ItemSimilarityModel<String>.fromBaskets(
          <Set<String>>[
            <String>{'a', 'b'},
            <String>{'c'},
          ],
        );

        final List<({String item, double score})> recs = sparse.recommend('a');

        expect(
          recs.map((({String item, double score}) r) => r.item).toList(),
          equals(<String>['b']),
        );
      });

      test('should return an empty list for an unknown item', () {
        expect(model.recommend('ghost'), isEmpty);
      });
    });

    test('should collapse duplicate items within a basket', () {
      // Passing a duplicate-bearing iterable must count the item once.
      final ItemSimilarityModel<String> dup = ItemSimilarityModel<String>.fromBaskets(
        <List<String>>[
          <String>['p', 'p', 'q'],
          <String>['p', 'q'],
        ],
      );

      // p and q co-occur in both baskets → identical sets → similarity 1.
      expect(dup.similarity('p', 'q'), equals(1.0));
    });
  });
}
