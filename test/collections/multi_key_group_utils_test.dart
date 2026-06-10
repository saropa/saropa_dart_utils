import 'package:flutter_test/flutter_test.dart';
import 'package:saropa_dart_utils/collections/multi_key_group_utils.dart';

void main() {
  final List<Map<String, Object>> rows = <Map<String, Object>>[
    <String, Object>{'country': 'US', 'year': 2024, 'sales': 10},
    <String, Object>{'country': 'US', 'year': 2024, 'sales': 5},
    <String, Object>{'country': 'US', 'year': 2025, 'sales': 7},
    <String, Object>{'country': 'CA', 'year': 2024, 'sales': 3},
  ];

  group('MultiKey', () {
    test('is value-equal so equal tuples are the same map key', () {
      expect(const MultiKey(<Object?>['US', 2024]), const MultiKey(<Object?>['US', 2024]));
      expect(
        const MultiKey(<Object?>['US', 2024]).hashCode,
        const MultiKey(<Object?>['US', 2024]).hashCode,
      );
      expect(const MultiKey(<Object?>['US', 2024]) == const MultiKey(<Object?>['US', 2025]), isFalse);
    });
  });

  group('groupByKeys', () {
    test('buckets rows by the composite (country, year) key', () {
      final Map<MultiKey, List<Map<String, Object>>> groups = groupByKeys(
        rows,
        <Object? Function(Map<String, Object>)>[(Map<String, Object> r) => r['country'], (Map<String, Object> r) => r['year']],
      );
      expect(groups, hasLength(3));
      expect(groups[const MultiKey(<Object?>['US', 2024])], hasLength(2));
      expect(groups[const MultiKey(<Object?>['CA', 2024])], hasLength(1));
    });

    test('single key behaves like a normal group-by', () {
      final Map<MultiKey, List<Map<String, Object>>> groups = groupByKeys(
        rows,
        <Object? Function(Map<String, Object>)>[(Map<String, Object> r) => r['country']],
      );
      expect(groups, hasLength(2));
      expect(groups[const MultiKey(<Object?>['US'])], hasLength(3));
    });

    test('empty input yields an empty map', () {
      expect(
        groupByKeys<int>(
          <int>[],
          <Object? Function(int)>[(int x) => x],
        ),
        isEmpty,
      );
    });
  });

  group('aggregateByKeys', () {
    test('counts per composite key', () {
      final Map<MultiKey, int> counts = aggregateByKeys(
        rows,
        <Object? Function(Map<String, Object>)>[(Map<String, Object> r) => r['country'], (Map<String, Object> r) => r['year']],
        (List<Map<String, Object>> g) => g.length,
      );
      expect(counts[const MultiKey(<Object?>['US', 2024])], 2);
      expect(counts[const MultiKey(<Object?>['US', 2025])], 1);
    });

    test('sums a field per single key', () {
      final Map<MultiKey, int> sales = aggregateByKeys(
        rows,
        <Object? Function(Map<String, Object>)>[(Map<String, Object> r) => r['country']],
        (List<Map<String, Object>> g) => g.fold<int>(0, (int s, Map<String, Object> r) => s + (r['sales']! as int)),
      );
      expect(sales[const MultiKey(<Object?>['US'])], 22);
      expect(sales[const MultiKey(<Object?>['CA'])], 3);
    });
  });
}
