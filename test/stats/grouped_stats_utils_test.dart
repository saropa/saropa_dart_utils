import 'package:flutter_test/flutter_test.dart';
import 'package:saropa_dart_utils/stats/grouped_stats_utils.dart';

void main() {
  final List<({String country, int sales})> rows = <({String country, int sales})>[
    (country: 'US', sales: 10),
    (country: 'US', sales: 5),
    (country: 'CA', sales: 3),
  ];

  group('groupedStats', () {
    test('computes count/sum/min/max/mean per key in one pass', () {
      final Map<String, NumericStats> stats = groupedStats(
        rows,
        keyOf: (({String country, int sales}) r) => r.country,
        valueOf: (({String country, int sales}) r) => r.sales,
      );
      expect(
        stats['US'],
        const NumericStats(count: 2, sum: 15, min: 5, max: 10, mean: 7.5),
      );
      expect(
        stats['CA'],
        const NumericStats(count: 1, sum: 3, min: 3, max: 3, mean: 3),
      );
    });

    test('single-value group has equal min/max and mean', () {
      final Map<String, NumericStats> stats = groupedStats(
        <({String k, num v})>[(k: 'a', v: 9)],
        keyOf: (({String k, num v}) r) => r.k,
        valueOf: (({String k, num v}) r) => r.v,
      );
      final NumericStats? a = stats['a'];
      expect(a?.min, 9);
      expect(a?.max, 9);
      expect(a?.mean, 9);
    });

    test('handles negative values', () {
      final Map<String, NumericStats> stats = groupedStats(
        <int>[-5, -1, -10],
        keyOf: (int _) => 'g',
        valueOf: (int v) => v,
      );
      expect(stats['g']?.min, -10);
      expect(stats['g']?.max, -1);
      expect(stats['g']?.sum, -16);
    });

    test('empty input yields an empty map', () {
      expect(
        groupedStats<int, String>(<int>[], keyOf: (int _) => 'x', valueOf: (int v) => v),
        isEmpty,
      );
    });
  });
}
