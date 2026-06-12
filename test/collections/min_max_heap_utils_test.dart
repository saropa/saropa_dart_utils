import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:saropa_dart_utils/collections/min_max_heap_utils.dart';

void main() {
  group('MinMaxHeap', () {
    // Ascending comparator reused across tests.
    int byInt(int a, int b) => a.compareTo(b);

    group('empty heap', () {
      test('should report empty and zero length', () {
        final MinMaxHeap<int> h = MinMaxHeap<int>(byInt);

        expect(h.isEmpty, isTrue);
        expect(h.length, equals(0));
        expect(h.minOrNull, isNull);
        expect(h.maxOrNull, isNull);
      });

      test('should throw StateError on min/max/removeMin/removeMax', () {
        final MinMaxHeap<int> h = MinMaxHeap<int>(byInt);

        expect(() => h.min, throwsStateError);
        expect(() => h.max, throwsStateError);
        expect(() => h.removeMin(), throwsStateError);
        expect(() => h.removeMax(), throwsStateError);
      });
    });

    group('single element', () {
      test('should expose the lone element as both min and max', () {
        final MinMaxHeap<int> h = MinMaxHeap<int>(byInt)..add(42);

        expect(h.min, equals(42));
        expect(h.max, equals(42));
        expect(h.length, equals(1));
      });

      test('should return the lone element from removeMin and become empty', () {
        final MinMaxHeap<int> h = MinMaxHeap<int>(byInt)..add(42);

        expect(h.removeMin(), equals(42));
        expect(h.isEmpty, isTrue);
      });
    });

    group('two elements', () {
      test('should order min and max correctly', () {
        final MinMaxHeap<int> h = MinMaxHeap<int>(byInt)
          ..add(9)
          ..add(3);

        expect(h.min, equals(3));
        expect(h.max, equals(9));
      });
    });

    test('should drain ascending via repeated removeMin', () {
      final MinMaxHeap<int> h = MinMaxHeap<int>(byInt);
      // Deterministic insertion order.
      for (final int v in <int>[5, 1, 9, 3, 7, 2, 8, 4, 6, 0]) {
        h.add(v);
      }

      final List<int> out = <int>[];
      while (!h.isEmpty) {
        out.add(h.removeMin());
      }
      expect(out, equals(<int>[0, 1, 2, 3, 4, 5, 6, 7, 8, 9]));
    });

    test('should drain descending via repeated removeMax', () {
      final MinMaxHeap<int> h = MinMaxHeap<int>(byInt);
      for (final int v in <int>[5, 1, 9, 3, 7, 2, 8, 4, 6, 0]) {
        h.add(v);
      }

      final List<int> out = <int>[];
      while (!h.isEmpty) {
        out.add(h.removeMax());
      }
      expect(out, equals(<int>[9, 8, 7, 6, 5, 4, 3, 2, 1, 0]));
    });

    test('should handle duplicate values', () {
      final MinMaxHeap<int> h = MinMaxHeap<int>(byInt);
      for (final int v in <int>[4, 4, 1, 4, 1, 9]) {
        h.add(v);
      }

      expect(h.min, equals(1));
      expect(h.max, equals(9));
      final List<int> out = <int>[];
      while (!h.isEmpty) {
        out.add(h.removeMin());
      }
      expect(out, equals(<int>[1, 1, 4, 4, 4, 9]));
    });

    test('should match a sorted oracle under mixed removals (seeded)', () {
      final Random rng = Random(2026);
      final List<int> source = <int>[for (int i = 0; i < 200; i++) rng.nextInt(1000)];
      final MinMaxHeap<int> h = MinMaxHeap<int>(byInt);
      for (final int v in source) {
        h.add(v);
      }
      // Oracle: a sorted copy we pop from either end to mirror the heap removals.
      final List<int> oracle = List<int>.of(source)..sort();
      int lo = 0;
      int hi = oracle.length - 1;

      // Alternate removeMin/removeMax; each must equal the matching oracle end.
      bool takeMin = true;
      while (lo <= hi) {
        if (takeMin) {
          expect(h.removeMin(), equals(oracle[lo]));
          lo++;
        } else {
          expect(h.removeMax(), equals(oracle[hi]));
          hi--;
        }
        takeMin = !takeMin;
      }
      expect(h.isEmpty, isTrue);
    });
  });
}
