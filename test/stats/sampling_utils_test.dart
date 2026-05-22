import 'dart:math' show Random;

import 'package:flutter_test/flutter_test.dart';
import 'package:saropa_dart_utils/stats/sampling_utils.dart';

void main() {
  group('systematicSample', () {
    test('takes every step-th element from the start', () {
      expect(
        systematicSample<int>(<int>[0, 1, 2, 3, 4, 5, 6, 7, 8, 9], 2),
        <int>[0, 2, 4, 6, 8],
      );
    });

    test('honors a non-zero start offset', () {
      expect(
        systematicSample<int>(<int>[0, 1, 2, 3, 4, 5], 2, start: 1),
        <int>[1, 3, 5],
      );
    });

    test('step of 1 returns the whole list', () {
      expect(systematicSample<int>(<int>[1, 2, 3], 1), <int>[1, 2, 3]);
    });

    test('step below 1 returns empty', () {
      expect(systematicSample<int>(<int>[1, 2, 3], 0), isEmpty);
    });

    test('start beyond length returns empty', () {
      expect(systematicSample<int>(<int>[1, 2, 3], 1, start: 5), isEmpty);
    });

    test('works for non-int element types', () {
      expect(
        systematicSample<String>(<String>['a', 'b', 'c', 'd'], 2),
        <String>['a', 'c'],
      );
    });
  });

  group('stratifiedSampleIndices', () {
    test('takes perGroup indices drawn from each stratum', () {
      // Groups: 'a' -> {0,1}, 'b' -> {2,3}. One sampled per group.
      final List<int> sample = stratifiedSampleIndices(
        <Object?>['a', 'a', 'b', 'b'],
        1,
        Random(42),
      );
      expect(sample, hasLength(2));
      // Exactly one index from each group's index set.
      expect(<int>{0, 1}.intersection(sample.toSet()), hasLength(1));
      expect(<int>{2, 3}.intersection(sample.toSet()), hasLength(1));
    });

    test('perGroup larger than a group caps at the group size', () {
      // 'a' has 2 indices, 'b' has 1; requesting 5 returns all 3.
      final List<int> sample = stratifiedSampleIndices(
        <Object?>['a', 'a', 'b'],
        5,
        Random(1),
      );
      expect(sample.toSet(), <int>{0, 1, 2});
    });

    test('empty strata returns empty', () {
      expect(stratifiedSampleIndices(<Object?>[], 2, Random(1)), isEmpty);
    });
  });
}
