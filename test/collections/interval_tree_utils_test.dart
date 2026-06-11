import 'package:flutter_test/flutter_test.dart';
import 'package:saropa_dart_utils/collections/interval_tree_utils.dart';

void main() {
  group('IntervalEntry', () {
    test('should report point containment inclusively', () {
      final IntervalEntry<String> e = IntervalEntry<String>(10, 20, 'x');

      expect(e.contains(10), isTrue);
      expect(e.contains(20), isTrue);
      expect(e.contains(21), isFalse);
      expect(e.overlaps(20, 30), isTrue);
      expect(e.overlaps(21, 30), isFalse);
    });
  });

  group('IntervalTree', () {
    // Helper to read the labels of a result set in order.
    List<String> labels(List<IntervalEntry<String>> entries) =>
        entries.map((IntervalEntry<String> e) => e.value).toList();

    final IntervalTree<String> tree = IntervalTree<String>(<IntervalEntry<String>>[
      IntervalEntry<String>(1, 5, 'a'),
      IntervalEntry<String>(3, 8, 'b'),
      IntervalEntry<String>(6, 10, 'c'),
      IntervalEntry<String>(15, 20, 'd'),
      IntervalEntry<String>(17, 25, 'e'),
    ]);

    test('should report its size and non-emptiness', () {
      expect(tree.size, equals(5));
      expect(tree.isEmpty, isFalse);
      expect(IntervalTree<String>(<IntervalEntry<String>>[]).isEmpty, isTrue);
    });

    group('queryPoint', () {
      test('should return all intervals containing a point, in low order', () {
        expect(labels(tree.queryPoint(4)), equals(<String>['a', 'b']));
      });

      test('should include intervals touching the point at a boundary', () {
        // Point 5 is the inclusive high of 'a' and inside 'b'.
        expect(labels(tree.queryPoint(5)), equals(<String>['a', 'b']));
      });

      test('should return a single interval when only one contains the point', () {
        expect(labels(tree.queryPoint(9)), equals(<String>['c']));
      });

      test('should return empty for a point in a gap', () {
        expect(tree.queryPoint(12), isEmpty);
      });

      test('should return empty for a point beyond all intervals', () {
        expect(tree.queryPoint(100), isEmpty);
      });
    });

    group('queryRange', () {
      test('should return every interval overlapping the range, in low order', () {
        // [4, 7] overlaps a(1-5), b(3-8), c(6-10).
        expect(labels(tree.queryRange(4, 7)), equals(<String>['a', 'b', 'c']));
      });

      test('should treat boundary touches as overlap', () {
        // [10, 15] touches c at 10 and d at 15.
        expect(labels(tree.queryRange(10, 15)), equals(<String>['c', 'd']));
      });

      test('should return empty when the range falls in a gap', () {
        expect(tree.queryRange(11, 14), isEmpty);
      });
    });

    group('hasOverlap', () {
      test('should be true when something overlaps', () {
        expect(tree.hasOverlap(7, 9), isTrue);
      });

      test('should be false for a gap', () {
        expect(tree.hasOverlap(11, 14), isFalse);
      });
    });

    test('should handle a larger random-ish set against a brute-force oracle', () {
      final List<IntervalEntry<String>> entries = <IntervalEntry<String>>[
        for (int i = 0; i < 50; i++) IntervalEntry<String>(i * 2, i * 2 + 5, 'i$i'),
      ];
      final IntervalTree<String> big = IntervalTree<String>(entries);

      for (int q = -3; q < 110; q++) {
        final Set<String> fromTree = big
            .queryPoint(q)
            .map((IntervalEntry<String> e) => e.value)
            .toSet();
        final Set<String> brute = entries
            .where((IntervalEntry<String> e) => e.contains(q))
            .map((IntervalEntry<String> e) => e.value)
            .toSet();
        expect(fromTree, equals(brute), reason: 'point $q');
      }
    });

    test('should reject an inverted interval entry', () {
      expect(() => IntervalEntry<String>(10, 5, 'bad'), throwsA(isA<AssertionError>()));
    });
  });
}
