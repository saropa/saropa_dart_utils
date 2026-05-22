import 'package:flutter_test/flutter_test.dart';
import 'package:saropa_dart_utils/collections/columnar_view_utils.dart';

void main() {
  group('columnValues', () {
    test('should extract a single column in row order', () {
      final List<Map<String, Object?>> rows = [
        {'a': 1, 'b': 'x'},
        {'a': 2, 'b': 'y'},
      ];
      expect(columnValues(rows, 'a'), [1, 2]);
      expect(columnValues(rows, 'b'), ['x', 'y']);
    });

    test('should return nulls for missing keys', () {
      final List<Map<String, Object?>> rows = [
        {'a': 1},
        {'b': 2},
      ];
      expect(columnValues(rows, 'a'), [1, null]);
    });

    test('should return empty list for empty rows', () {
      expect(columnValues(<Map<String, Object?>>[], 'a'), <Object?>[]);
    });

    test('should preserve null cell values', () {
      final List<Map<String, Object?>> rows = [
        {'a': null},
        {'a': 5},
      ];
      expect(columnValues(rows, 'a'), [null, 5]);
    });
  });

  group('toColumnar', () {
    test('should convert rows to column map using first row keys', () {
      final List<Map<String, Object?>> rows = [
        {'a': 1, 'b': 'x'},
        {'a': 2, 'b': 'y'},
      ];
      expect(toColumnar(rows), {
        'a': [1, 2],
        'b': ['x', 'y'],
      });
    });

    test('should return empty map for empty rows', () {
      expect(toColumnar(<Map<String, Object?>>[]), <String, List<Object?>>{});
    });

    test('should only use keys present in the first row', () {
      final List<Map<String, Object?>> rows = [
        {'a': 1},
        {'a': 2, 'b': 99},
      ];
      final Map<String, List<Object?>> result = toColumnar(rows);
      expect(result.keys, ['a']);
      expect(result['a'], [1, 2]);
    });

    test('should handle single row', () {
      expect(
        toColumnar([
          {'x': 10},
        ]),
        {
          'x': [10],
        },
      );
    });
  });
}
