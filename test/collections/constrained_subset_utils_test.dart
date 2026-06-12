import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:saropa_dart_utils/collections/constrained_subset_utils.dart';

void main() {
  group('weightedSubset', () {
    // Uniform weight of 1 for every item.
    double uniform(String _) => 1;

    test('should return exactly count items when enough are eligible', () {
      final List<String> out = weightedSubset<String>(
        <String>['a', 'b', 'c', 'd'],
        count: 2,
        weight: uniform,
        random: Random(1),
      );

      expect(out.length, equals(2));
      expect(out.toSet().length, equals(2)); // distinct (no replacement)
    });

    test('should return an empty list for a non-positive count', () {
      expect(
        weightedSubset<String>(<String>['a'], count: 0, weight: uniform),
        isEmpty,
      );
    });

    test('should return all eligible items when count exceeds the eligible pool', () {
      final List<String> out = weightedSubset<String>(
        <String>['a', 'b'],
        count: 10,
        weight: uniform,
        random: Random(1),
      );

      expect(out.toSet(), equals(<String>{'a', 'b'}));
    });

    test('should never return an excluded item', () {
      for (int seed = 0; seed < 50; seed++) {
        final List<String> out = weightedSubset<String>(
          <String>['a', 'b', 'c', 'd'],
          count: 3,
          weight: uniform,
          exclude: <String>{'b'},
          random: Random(seed),
        );

        expect(out, isNot(contains('b')), reason: 'seed $seed');
        expect(out.length, equals(3)); // 3 eligible remain after excluding 'b'
      }
    });

    test('should never choose a zero or negative weight item', () {
      for (int seed = 0; seed < 50; seed++) {
        final List<String> out = weightedSubset<String>(
          <String>['z', 'a', 'b'],
          count: 3,
          weight: (String s) => s == 'z' ? 0 : 1, // z has zero weight
          random: Random(seed),
        );

        expect(out, isNot(contains('z')), reason: 'seed $seed');
        expect(out.toSet(), equals(<String>{'a', 'b'}));
      }
    });

    test('should clamp the result to the number of eligible items', () {
      // Two of three carry weight; count of 5 must clamp to 2.
      final List<String> out = weightedSubset<String>(
        <String>['x', 'a', 'b'],
        count: 5,
        weight: (String s) => s == 'x' ? -3 : 2,
        random: Random(4),
      );

      expect(out.toSet(), equals(<String>{'a', 'b'}));
    });

    test('should favor a heavily-weighted item across many seeded trials', () {
      // 'heavy' has 100x the weight of each light item; over many single-pick
      // trials it should be selected far more often than any individual light.
      int heavyHits = 0;
      int lightHits = 0;
      for (int seed = 0; seed < 1000; seed++) {
        final List<String> out = weightedSubset<String>(
          <String>['heavy', 'l1', 'l2', 'l3'],
          count: 1,
          weight: (String s) => s == 'heavy' ? 100 : 1,
          random: Random(seed),
        );
        // Single pick per trial; tally which kind won.
        if (out.first == 'heavy') {
          heavyHits++;
        } else {
          lightHits++;
        }
      }

      // Heavy (weight 100) vs three lights (weight 1 each, total 3): heavy should
      // dominate overwhelmingly.
      expect(heavyHits, greaterThan(lightHits * 5), reason: 'heavy=$heavyHits light=$lightHits');
    });
  });
}
