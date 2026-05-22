import 'package:flutter_test/flutter_test.dart';
import 'package:saropa_dart_utils/collections/row_column_table_utils.dart';

void main() {
  group('columnarToRows', () {
    test('should convert a column map to a list of rows', () {
      final Map<String, List<Object?>> columnar = {
        'a': [1, 2],
        'b': ['x', 'y'],
      };
      expect(columnarToRows(columnar), [
        {'a': 1, 'b': 'x'},
        {'a': 2, 'b': 'y'},
      ]);
    });

    test('should return empty list for empty columnar map', () {
      expect(columnarToRows(<String, List<Object?>>{}), <Map<String, Object?>>[]);
    });

    test('should use first column length and pad short columns with null', () {
      final Map<String, List<Object?>> columnar = {
        'a': [1, 2, 3],
        'b': ['x'],
      };
      expect(columnarToRows(columnar), [
        {'a': 1, 'b': 'x'},
        {'a': 2, 'b': null},
        {'a': 3, 'b': null},
      ]);
    });

    test('should handle a single column', () {
      expect(columnarToRows({
        'a': [10, 20],
      }), [
        {'a': 10},
        {'a': 20},
      ]);
    });

    test('should preserve null cell values', () {
      expect(columnarToRows({
        'a': [null, 5],
      }), [
        {'a': null},
        {'a': 5},
      ]);
    });

    test('should return empty list when first column is empty', () {
      expect(columnarToRows({'a': <Object?>[]}), <Map<String, Object?>>[]);
    });
  });
}
