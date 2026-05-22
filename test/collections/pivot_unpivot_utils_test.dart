import 'package:flutter_test/flutter_test.dart';
import 'package:saropa_dart_utils/collections/pivot_unpivot_utils.dart';

void main() {
  group('pivot', () {
    test('should produce one row per rowKey value with columns per colKey', () {
      final List<Map<String, Object?>> rows = [
        {'region': 'N', 'quarter': 'Q1', 'sales': 10},
        {'region': 'N', 'quarter': 'Q2', 'sales': 20},
        {'region': 'S', 'quarter': 'Q1', 'sales': 5},
      ];
      final List<Map<String, Object?>> result = pivot(rows, 'region', 'quarter', 'sales');
      expect(result, [
        {'region': 'N', 'Q1': 10, 'Q2': 20},
        {'region': 'S', 'Q1': 5},
      ]);
    });

    test('should return empty list for empty rows', () {
      expect(pivot(<Map<String, Object?>>[], 'r', 'c', 'v'), <Map<String, Object?>>[]);
    });

    test('should keep the rowKey column in each output row', () {
      final List<Map<String, Object?>> rows = [
        {'id': 1, 'k': 'x', 'v': 100},
      ];
      final List<Map<String, Object?>> result = pivot(rows, 'id', 'k', 'v');
      expect(result.single['id'], 1);
      expect(result.single['x'], 100);
    });

    test('should overwrite duplicate row/col combinations with the last value', () {
      final List<Map<String, Object?>> rows = [
        {'r': 'A', 'c': 'X', 'v': 1},
        {'r': 'A', 'c': 'X', 'v': 9},
      ];
      final List<Map<String, Object?>> result = pivot(rows, 'r', 'c', 'v');
      expect(result.single['X'], 9);
    });

    test('should stringify non-string column key values', () {
      final List<Map<String, Object?>> rows = [
        {'r': 'A', 'c': 2024, 'v': 7},
      ];
      final List<Map<String, Object?>> result = pivot(rows, 'r', 'c', 'v');
      expect(result.single['2024'], 7);
    });

    test('should handle a single row', () {
      final List<Map<String, Object?>> rows = [
        {'r': 'A', 'c': 'X', 'v': 42},
      ];
      expect(pivot(rows, 'r', 'c', 'v'), [
        {'r': 'A', 'X': 42},
      ]);
    });
  });
}
