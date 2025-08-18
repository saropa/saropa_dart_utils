import 'package:flutter_test/flutter_test.dart';
import 'package:saropa_dart_utils/list/unique_list_extensions.dart';

void main() {
  group('toUniqueBy()', () {
    test('1. Basic case: should keep last unique item and preserve original relative order', () {
      final List<Map<String, Object>> list = <Map<String, Object>>[
        <String, Object>{'id': 1, 'name': 'Alice'},
        <String, Object>{'id': 2, 'name': 'Bob'},
        <String, Object>{'id': 1, 'name': 'Alicia'}, // Last unique for id:1
      ];
      final List<Map<String, Object>> result = list.toUniqueBy(
        (Map<String, Object> item) => item['id'],
      );
      expect(result, <Map<String, Object>>[
        <String, Object>{'id': 2, 'name': 'Bob'},
        <String, Object>{'id': 1, 'name': 'Alicia'},
      ]);
    });

    test('2. Empty list: should return an empty list', () {
      final List<Map<String, dynamic>> list = <Map<String, dynamic>>[];
      final List<Map<String, dynamic>> result = list.toUniqueBy(
        (Map<String, dynamic> item) => item['id'],
      );
      expect(result, isEmpty);
    });

    test('3. No duplicates: should return an identical list', () {
      final List<Map<String, Object>> list = <Map<String, Object>>[
        <String, Object>{'id': 1, 'name': 'Alice'},
        <String, Object>{'id': 2, 'name': 'Bob'},
        <String, Object>{'id': 3, 'name': 'Charlie'},
      ];
      final List<Map<String, Object>> result = list.toUniqueBy(
        (Map<String, Object> item) => item['id'],
      );
      expect(result, list);
    });

    test('4. All same key: should return a list with only the last item', () {
      final List<Map<String, Object>> list = <Map<String, Object>>[
        <String, Object>{'id': 1, 'name': 'A'},
        <String, Object>{'id': 1, 'name': 'B'},
        <String, Object>{'id': 1, 'name': 'C'},
      ];
      final List<Map<String, Object>> result = list.toUniqueBy(
        (Map<String, Object> item) => item['id'],
      );
      expect(result, <Map<String, Object>>[
        <String, Object>{'id': 1, 'name': 'C'},
      ]);
    });

    test('5. Null keys (default): should remove items with null keys', () {
      final List<Map<String, Object?>> list = <Map<String, Object?>>[
        <String, Object>{'id': 1, 'name': 'Alice'},
        <String, String?>{'id': null, 'name': 'No-ID Bob'},
        <String, Object>{'id': 2, 'name': 'Charlie'},
      ];
      final List<Map<String, Object?>> result = list.toUniqueBy(
        (Map<String, Object?> item) => item['id'],
      );
      expect(result, <Map<String, Object>>[
        <String, Object>{'id': 1, 'name': 'Alice'},
        <String, Object>{'id': 2, 'name': 'Charlie'},
      ]);
    });

    test('6. Null keys (ignoreNullKeys: false): should keep last item with null key', () {
      final List<Map<String, Object?>> list = <Map<String, Object?>>[
        <String, String?>{'id': null, 'name': 'No-ID Alice'},
        <String, Object>{'id': 1, 'name': 'Bob'},
        <String, String?>{'id': null, 'name': 'No-ID Charlie'},
      ];
      final List<Map<String, Object?>> result = list.toUniqueBy(
        (Map<String, Object?> item) => item['id'],
        ignoreNullKeys: false,
      );
      expect(result, <Map<String, Object?>>[
        <String, Object>{'id': 1, 'name': 'Bob'},
        <String, String?>{'id': null, 'name': 'No-ID Charlie'},
      ]);
    });

    test('7. String key: should keep last unique item by name', () {
      final List<Map<String, Object>> list = <Map<String, Object>>[
        <String, Object>{'id': 1, 'name': 'common'},
        <String, Object>{'id': 2, 'name': 'unique'},
        <String, Object>{'id': 3, 'name': 'common'},
      ];
      final List<Map<String, Object>> result = list.toUniqueBy(
        (Map<String, Object> item) => item['name'],
      );
      expect(result, <Map<String, Object>>[
        <String, Object>{'id': 2, 'name': 'unique'},
        <String, Object>{'id': 3, 'name': 'common'},
      ]);
    });

    test('8. Single element list: should return a new list with that one element', () {
      final List<Map<String, Object>> list = <Map<String, Object>>[
        <String, Object>{'id': 1, 'name': 'Alice'},
      ];
      final List<Map<String, Object>> result = list.toUniqueBy(
        (Map<String, Object> item) => item['id'],
      );
      expect(result, <Map<String, Object>>[
        <String, Object>{'id': 1, 'name': 'Alice'},
      ]);
      expect(identical(result, list), isFalse);
    });

    test('9. Only null-keyed items: should return empty by default', () {
      final List<Map<String, String?>> list = <Map<String, String?>>[
        <String, String?>{'id': null, 'name': 'A'},
        <String, String?>{'id': null, 'name': 'B'},
      ];
      final List<Map<String, String?>> result = list.toUniqueBy(
        (Map<String, String?> item) => item['id'],
      );
      expect(result, isEmpty);
    });

    test('10. Complex mix: should handle various duplicates and nulls correctly', () {
      final List<Map<String, Object?>> list = <Map<String, Object?>>[
        <String, Object>{'id': 1, 'name': 'A'},
        <String, String?>{'id': null, 'name': 'B'},
        <String, Object>{'id': 2, 'name': 'C'},
        <String, Object>{'id': 1, 'name': 'D'},
        <String, String?>{'id': null, 'name': 'E'},
      ];
      final List<Map<String, Object?>> result = list.toUniqueBy(
        (Map<String, Object?> item) => item['id'],
        ignoreNullKeys: false,
      );
      expect(result, <Map<String, Object?>>[
        <String, Object>{'id': 2, 'name': 'C'},
        <String, Object>{'id': 1, 'name': 'D'},
        <String, String?>{'id': null, 'name': 'E'},
      ]);
    });
  });

  group('toUniqueByInPlace()', () {
    test('1. Basic case: should keep last unique item and preserve original relative order', () {
      final List<Map<String, Object>> list = <Map<String, Object>>[
        <String, Object>{'id': 1, 'name': 'Alice'},
        <String, Object>{'id': 2, 'name': 'Bob'},
        <String, Object>{'id': 1, 'name': 'Alicia'},
      ];
      list.toUniqueByInPlace((Map<String, Object> item) => item['id']);
      expect(list, <Map<String, Object>>[
        <String, Object>{'id': 2, 'name': 'Bob'},
        <String, Object>{'id': 1, 'name': 'Alicia'},
      ]);
    });

    test('2. Empty list: should remain an empty list', () {
      final List<Map<String, dynamic>> list = <Map<String, dynamic>>[];
      list.toUniqueByInPlace((Map<String, dynamic> item) => item['id']);
      expect(list, isEmpty);
    });

    test('3. No duplicates: list should be unchanged', () {
      final List<Map<String, Object>> original = <Map<String, Object>>[
        <String, Object>{'id': 1, 'name': 'Alice'},
        <String, Object>{'id': 2, 'name': 'Bob'},
      ];
      final List<Map<String, dynamic>> list = List<Map<String, dynamic>>.from(original);
      list.toUniqueByInPlace((Map<String, dynamic> item) => item['id']);
      expect(list, original);
    });

    test('4. All same key: should result in a list with only the last item', () {
      final List<Map<String, Object>> list = <Map<String, Object>>[
        <String, Object>{'id': 1, 'name': 'A'},
        <String, Object>{'id': 1, 'name': 'B'},
        <String, Object>{'id': 1, 'name': 'C'},
      ];
      list.toUniqueByInPlace((Map<String, Object> item) => item['id']);
      expect(list, <Map<String, Object>>[
        <String, Object>{'id': 1, 'name': 'C'},
      ]);
    });

    test('5. Null keys (default): should remove items with null keys', () {
      final List<Map<String, Object?>> list = <Map<String, Object?>>[
        <String, Object>{'id': 1, 'name': 'Alice'},
        <String, String?>{'id': null, 'name': 'No-ID Bob'},
        <String, Object>{'id': 2, 'name': 'Charlie'},
      ];
      list.toUniqueByInPlace((Map<String, Object?> item) => item['id']);
      expect(list, <Map<String, Object>>[
        <String, Object>{'id': 1, 'name': 'Alice'},
        <String, Object>{'id': 2, 'name': 'Charlie'},
      ]);
    });

    test('6. Null keys (ignoreNullKeys: false): should keep last item with null key', () {
      final List<Map<String, Object?>> list = <Map<String, Object?>>[
        <String, String?>{'id': null, 'name': 'No-ID Alice'},
        <String, Object>{'id': 1, 'name': 'Bob'},
        <String, String?>{'id': null, 'name': 'No-ID Charlie'},
      ];
      list.toUniqueByInPlace((Map<String, Object?> item) => item['id'], ignoreNullKeys: false);
      expect(list, <Map<String, Object?>>[
        <String, Object>{'id': 1, 'name': 'Bob'},
        <String, String?>{'id': null, 'name': 'No-ID Charlie'},
      ]);
    });

    test('7. String key: should keep last unique item by name', () {
      final List<Map<String, Object>> list = <Map<String, Object>>[
        <String, Object>{'id': 1, 'name': 'common'},
        <String, Object>{'id': 2, 'name': 'unique'},
        <String, Object>{'id': 3, 'name': 'common'},
      ];
      list.toUniqueByInPlace((Map<String, Object> item) => item['name']);
      expect(list, <Map<String, Object>>[
        <String, Object>{'id': 2, 'name': 'unique'},
        <String, Object>{'id': 3, 'name': 'common'},
      ]);
    });

    test('8. Single element list: list should be unchanged', () {
      final List<Map<String, Object>> list = <Map<String, Object>>[
        <String, Object>{'id': 1, 'name': 'Alice'},
      ];
      list.toUniqueByInPlace((Map<String, Object> item) => item['id']);
      expect(list, <Map<String, Object>>[
        <String, Object>{'id': 1, 'name': 'Alice'},
      ]);
    });

    test('9. Only null-keyed items: should become empty by default', () {
      final List<Map<String, String?>> list = <Map<String, String?>>[
        <String, String?>{'id': null, 'name': 'A'},
        <String, String?>{'id': null, 'name': 'B'},
      ];
      list.toUniqueByInPlace((Map<String, String?> item) => item['id']);
      expect(list, isEmpty);
    });

    test('10. Complex mix: should handle various duplicates and nulls correctly', () {
      final List<Map<String, Object?>> list = <Map<String, Object?>>[
        <String, Object>{'id': 1, 'name': 'A'},
        <String, String?>{'id': null, 'name': 'B'},
        <String, Object>{'id': 2, 'name': 'C'},
        <String, Object>{'id': 1, 'name': 'D'},
        <String, String?>{'id': null, 'name': 'E'},
      ];
      list.toUniqueByInPlace((Map<String, Object?> item) => item['id'], ignoreNullKeys: false);
      expect(list, <Map<String, Object?>>[
        <String, Object>{'id': 2, 'name': 'C'},
        <String, Object>{'id': 1, 'name': 'D'},
        <String, String?>{'id': null, 'name': 'E'},
      ]);
    });
  });
}
