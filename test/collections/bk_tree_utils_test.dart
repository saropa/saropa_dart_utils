import 'package:flutter_test/flutter_test.dart';
import 'package:saropa_dart_utils/collections/bk_tree_utils.dart';
import 'package:saropa_dart_utils/collections/damerau_levenshtein_utils.dart';

void main() {
  group('BkTree', () {
    test('should find words within the given edit distance', () {
      final BkTree t = BkTree()
        ..add('book')
        ..add('books')
        ..add('cake')
        ..add('boo')
        ..add('cape');

      final List<String> hits = t.search('book', 1)..sort();

      expect(hits, equals(<String>['book', 'books', 'boo']..sort()));
    });

    test('should return an exact match at distance zero', () {
      final BkTree t = BkTree()
        ..add('alpha')
        ..add('beta');

      expect(t.search('alpha', 0), equals(<String>['alpha']));
    });

    test('should return nothing when no word is close enough', () {
      final BkTree t = BkTree()
        ..add('apple')
        ..add('orange');

      expect(t.search('zzzzz', 1), isEmpty);
    });

    test('should ignore duplicate inserts (set semantics)', () {
      final BkTree t = BkTree()
        ..add('dog')
        ..add('dog')
        ..add('dog');

      expect(t.length, equals(1));
      expect(t.search('dog', 0), equals(<String>['dog']));
    });

    test('should search an empty tree without error', () {
      expect(BkTree().search('anything', 3), isEmpty);
    });

    test('should reject a negative max distance', () {
      final BkTree t = BkTree()..add('x');

      expect(() => t.search('x', -1), throwsA(isA<ArgumentError>()));
    });

    test('should return the same set as a linear scan using the tree metric', () {
      // The tree's job is to PRUNE without dropping matches; verify it returns
      // exactly what a full scan with the same distance metric would.
      final List<String> words = <String>[
        'kitten',
        'sitting',
        'kitchen',
        'mitten',
        'bitten',
        'flatten',
        'recieve',
        'receive',
      ];
      final BkTree t = BkTree();
      for (final String w in words) {
        t.add(w);
      }

      // Oracle: linear scan with the exact distance the tree uses by default.
      List<String> brute(String q, int k) =>
          words.where((String w) => damerauLevenshteinDistance(w, q) <= k).toList()..sort();

      for (final String query in <String>['kitten', 'fitting', 'kitch', 'recieve']) {
        for (int k = 0; k <= 3; k++) {
          final List<String> got = t.search(query, k)..sort();
          expect(got, equals(brute(query, k)), reason: 'q=$query k=$k');
        }
      }
    });
  });
}
