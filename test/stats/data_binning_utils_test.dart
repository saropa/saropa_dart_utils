import 'package:flutter_test/flutter_test.dart';
import 'package:saropa_dart_utils/stats/data_binning_utils.dart';

void main() {
  group('binByWidth', () {
    test('assigns values to equal-width bins', () {
      // Range 0..10 in 5 bins => width 2: pairs share a bin.
      expect(
        binByWidth(<num>[0, 1, 2, 3, 8, 9], min: 0, max: 10, bins: 5),
        <int>[0, 0, 1, 1, 4, 4],
      );
    });

    test('clamps out-of-range values into the edge bins', () {
      // Below min lands in bin 0; at/above max lands in the last bin.
      expect(
        binByWidth(<num>[-5, 15], min: 0, max: 10, bins: 5),
        <int>[0, 4],
      );
    });

    test('value at max clamps to the last bin', () {
      expect(binByWidth(<num>[10], min: 0, max: 10, bins: 5), <int>[4]);
    });

    test('rejects non-positive bin count', () {
      expect(
        () => binByWidth(<num>[1], min: 0, max: 10, bins: 0),
        throwsA(isA<AssertionError>()),
      );
    });
  });

  group('quantileBoundaries', () {
    test('splits sorted values into roughly equal-count groups', () {
      final List<num> bounds = quantileBoundaries(
        <num>[1, 2, 3, 4, 5, 6, 7, 8, 9, 10],
        2,
      );
      expect(bounds, hasLength(1));
      final List<int> counts = binCounts(
        binByBoundaries(<num>[1, 2, 3, 4, 5, 6, 7, 8, 9, 10], bounds),
        2,
      );
      // 10 values into 2 bins: each side close to 5.
      expect((counts[0] - counts[1]).abs(), lessThanOrEqualTo(2));
    });

    test('returns bins-1 internal cut points', () {
      expect(
        quantileBoundaries(<num>[1, 2, 3, 4, 5, 6, 7, 8], 4),
        <num>[3.0, 5.0, 7.0],
      );
    });

    test('returns empty for fewer than two bins', () {
      expect(quantileBoundaries(<num>[1, 2, 3], 1), isEmpty);
    });

    test('returns empty for empty input', () {
      expect(quantileBoundaries(<num>[], 4), isEmpty);
    });
  });

  group('binByBoundaries', () {
    test('assigns by upper-bound search over boundaries', () {
      // <=5 -> bin 0, (5,10] -> bin 1, >10 -> bin 2.
      expect(binByBoundaries(<num>[1, 5, 10, 15], <num>[5, 10]), <int>[0, 0, 1, 2]);
    });

    test('values on a boundary land in the lower bin', () {
      expect(binByBoundaries(<num>[5, 10], <num>[5, 10]), <int>[0, 1]);
    });

    test('every value exceeding all boundaries goes to the top bin', () {
      expect(binByBoundaries(<num>[100, 200], <num>[5, 10]), <int>[2, 2]);
    });
  });

  group('binCounts', () {
    test('counts frequency per bin', () {
      expect(binCounts(<int>[0, 0, 1, 2, 2, 2], 3), <int>[2, 1, 3]);
    });

    test('total equals the number of in-range indices', () {
      final List<int> indices = <int>[0, 1, 1, 2, 2, 2];
      final List<int> counts = binCounts(indices, 3);
      final int total = counts.fold(0, (int a, int b) => a + b);
      expect(total, equals(indices.length));
    });

    test('ignores out-of-range indices', () {
      // -1 and 5 fall outside 0..2 and must not corrupt the histogram.
      expect(binCounts(<int>[-1, 0, 1, 5], 3), <int>[1, 1, 0]);
    });

    test('empty indices give all-zero counts', () {
      expect(binCounts(<int>[], 3), <int>[0, 0, 0]);
    });
  });
}
