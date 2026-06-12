import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:saropa_dart_utils/collections/skip_list_utils.dart';

void main() {
  group('SkipList', () {
    int byInt(int a, int b) => a.compareTo(b);

    SkipList<int> seeded() => SkipList<int>(byInt, random: Random(99));

    group('empty', () {
      test('should report empty and yield no values', () {
        final SkipList<int> s = seeded();

        expect(s.isEmpty, isTrue);
        expect(s.length, equals(0));
        expect(s.values, isEmpty);
        expect(s.contains(1), isFalse);
        expect(s.floor(5), isNull);
        expect(s.ceiling(5), isNull);
      });
    });

    group('add', () {
      test('should add a single value', () {
        final SkipList<int> s = seeded()..add(7);

        expect(s.length, equals(1));
        expect(s.contains(7), isTrue);
        expect(s.values, equals(<int>[7]));
      });

      test('should return false on a duplicate add and not grow', () {
        final SkipList<int> s = seeded();

        expect(s.add(3), isTrue);
        expect(s.add(3), isFalse);
        expect(s.length, equals(1));
      });
    });

    group('remove', () {
      test('should remove an existing value', () {
        final SkipList<int> s = seeded()
          ..add(1)
          ..add(2)
          ..add(3);

        expect(s.remove(2), isTrue);
        expect(s.contains(2), isFalse);
        expect(s.values, equals(<int>[1, 3]));
      });

      test('should return false removing an absent value', () {
        final SkipList<int> s = seeded()..add(1);

        expect(s.remove(99), isFalse);
        expect(s.length, equals(1));
      });
    });

    test('should keep values ascending after many seeded inserts', () {
      final SkipList<int> s = seeded();
      final Random src = Random(7);
      final Set<int> oracle = <int>{};
      for (int i = 0; i < 300; i++) {
        final int v = src.nextInt(1000);
        s.add(v);
        oracle.add(v);
      }

      final List<int> expected = oracle.toList()..sort();
      expect(s.values.toList(), equals(expected));
      expect(s.length, equals(oracle.length));
    });

    test('should match brute-force contains/floor/ceiling (seeded)', () {
      final SkipList<int> s = seeded();
      final Random src = Random(123);
      final List<int> present = <int>[
        for (int i = 0; i < 100; i++) src.nextInt(500) * 2, // even values only
      ];
      final Set<int> set = <int>{};
      for (final int v in present) {
        s.add(v);
        set.add(v);
      }
      final List<int> sorted = set.toList()..sort();

      // Brute-force floor: largest sorted value <= q.
      int? bruteFloor(int q) {
        int? best;
        for (final int v in sorted) {
          if (v <= q) best = v;
        }
        return best;
      }

      // Brute-force ceiling: smallest sorted value >= q.
      int? bruteCeiling(int q) {
        for (final int v in sorted) {
          if (v >= q) return v;
        }
        return null;
      }

      // Probe odd and even points across and beyond the value range.
      for (int q = -2; q <= 1002; q++) {
        expect(s.contains(q), equals(set.contains(q)), reason: 'contains $q');
        expect(s.floor(q), equals(bruteFloor(q)), reason: 'floor $q');
        expect(s.ceiling(q), equals(bruteCeiling(q)), reason: 'ceiling $q');
      }
    });
  });
}
